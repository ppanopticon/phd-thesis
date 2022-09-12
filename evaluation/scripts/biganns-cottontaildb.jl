
using DataFrames
using Statistics
using Gadfly
using Cairo
using Fontconfig
using Query
using Statistics
using Formatting
using CSV

include("./load-file.jl");
include("./recall.jl");

query_order = Dict([("NNS", 1), ("NNS + Fetch", 2), ("Hybrid", 3)])
query_names = Dict([("NNS", "NNS (Q2a)"), ("NNS + Fetch", "NNS + Fetch (Q2b)"), ("Hybrid", "Hybrid (Q2c)")])

# Functions used to load Milvus data
function loadCottontailData(name, df)
    dict = read_json(joinpath("./evaluation/data/biganns/cottontaildb","cottontail-$(name)~measurements.json"))
    for (entity, query, index, parallel, runtime, recall, dcg) in zip(dict["entity"], dict["query"], dict["index"], dict["parallel"], dict["runtime"], dict["recall"], dict["dcg"])
        if (entity == "yandex_deep5m")
            push!(df, (query_names[query], "5M", 1, index, parallel, runtime, recall, dcg))
        elseif (entity == "yandex_deep10m")
            push!(df, (query_names[query], "10M", 2, index, parallel, runtime, recall, dcg))
        elseif (entity == "yandex_deep100m")
            push!(df, (query_names[query], "100M", 3, index, parallel, runtime, recall, dcg))
        else
            push!(df, (query_names[query], "1B", 4, index, parallel, runtime, recall, dcg))
        end
    end
end

# Load data files
df = DataFrame(Query = String[], Entity = String[], EntityOrder = Int32[], Index = String[], Parallel = Int32[], Runtime = Float64[], Recall = Float64[], NDCG = Float64[])
loadCottontailData("5mto1b", df)

# Generate PDFs

nns = df |> @filter(_.Parallel == 32) |> 
@orderby(_.EntityOrder) |> 
@thenby(_.Index) |>
@groupby({_.Entity, _.Index, _.Parallel, _.Query}) |> 
@map({
    Entity=key(_).Entity, 
    Index=key(_).Index,
    Parallel=key(_).Parallel,
    Query=key(_).Query,
    Type="$(key(_).Index) (p=$(key(_).Parallel))",
    RuntimeMean=Statistics.mean(_.Runtime), 
    RecallMax=maximum(_.Recall),
    RecallMean=Statistics.mean(_.Recall), 
    RecallMin=minimum(_.Recall), 
    NDCGMax=maximum(_.NDCG), 
    NDCGMean=Statistics.mean(_.NDCG), 
    NDCGMin=minimum(_.NDCG),
    RuntimeMeanMax=Statistics.mean(_.Runtime)+Statistics.std(_.Runtime), 
    RuntimeMeanMin=Statistics.mean(_.Runtime)+Statistics.std(_.Runtime), 
    Label="$(round(Statistics.mean(_.Runtime), digits=2))±$(round(Statistics.std(_.Runtime), digits=2))",
    LabelPosition=minimum([Statistics.mean(_.Runtime), 100]), 
}) |> DataFrame

p1 = plot(nns,
    xgroup=:Query, ygroup=:Entity, x=:RuntimeMean, y=:Index, label=:Label,
    Geom.subplot_grid(layer(x=:LabelPosition, Geom.label(position = :right)), Geom.bar(position = :dodge, orientation = :horizontal), Guide.xticks(orientation=:vertical)),
    Guide.xlabel("Latency [s]"),
    Guide.ylabel(nothing),
    Scale.x_continuous(minvalue = 0.0, maxvalue=20.0),
    Scale.y_discrete,
    Scale.color_discrete_manual("#D2EBE9","#DD879B"),
    Theme(
        major_label_font="Helvetica Neue Bold",
        major_label_font_size=20pt, 
        minor_label_font="Helvetica Neue",
        minor_label_font_size=18pt, 
        point_label_font="Helvetica Neue Light",
        point_label_font_size=16pt, 
        bar_spacing=1mm, 
        key_position=:none,
        default_color="#D2EBE9"
    )
)

draw(PDF("./mainmatter/08-evaluation/figures/bignns/cottontail/bignns-cottontail-runtime.pdf",44cm,24cm),p1);

for (query, name) in query_names
    p2 = plot(nns |> @filter(_.Query == name) |> DataFrame,
        ygroup=:Entity, x=:Index,
        Geom.subplot_grid(
            layer(y=:RecallMean, ymin=:RecallMin, ymax=:RecallMax, Geom.point, Geom.errorbar, color=["Recall"], shape = [Shape.diamond]),
            layer(y=:NDCGMean, ymin=:NDCGMin, ymax=:NDCGMax, Geom.point, Geom.errorbar, color=["nDCG"], shape = [Shape.circle]), 
            Guide.xticks(orientation=:vertical),
            Guide.yticks(ticks=[0.0, 0.25, 0.5, 0.75, 1.0])
        ),
        Guide.xlabel("Quality"),
        Guide.colorkey(title="Metric"),
        Guide.ylabel(nothing),
        Scale.x_discrete,
        Scale.y_continuous(minvalue = 0.0, maxvalue=1.0),
        Scale.color_discrete_manual("#D2EBE9","#DD879B"),
        Theme(
            major_label_font="Helvetica Neue Bold",
            major_label_font_size=20pt, 
            minor_label_font="Helvetica Neue",
            minor_label_font_size=18pt, 
            point_label_font="Helvetica Neue Light",
            point_label_font_size=16pt, 
            point_size=6pt, 
            key_position=:inside
        )
    )
    draw(PDF("./appendices/02-additional-results/figures/bignns-cottontail-quality-$(query).pdf",21cm,29cm),p2);
end


