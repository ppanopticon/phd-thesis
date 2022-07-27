
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


# Functions used to load Milvus data
function loadCottontailData(name, df)
    dict = read_json(joinpath("./evaluation/data/biganns/cottontaildb","cottontail-$(name).json"))
    for (entity, query, index, parallel, runtime, recall, dcg, plan) in zip(dict["entity"], dict["query"], dict["index"], dict["parallel"], dict["runtime"], dict["recall"], dict["dcg"], dict["plan"])
        push!(df, (query, uppercase(replace(entity, "yandex_deep" => "")), index, parallel, runtime, recall, dcg, plan))
    end
end

# Load data files
df = DataFrame(Query = String[], Entity = String[], Index = String[], Parallel = Int32[], Runtime = Float64[], Recall = Float64[], DCG = Float64[], Plan = Array{String}[])
loadCottontailData("5mto100m", df)

# Export query plans
plan = df |> 
    @filter(_.Entit == "100M") |> 
    @orderby(_.Query) |> 
    @groupby({_.Query, _.Index}) |> 
    @map({
        Query=key(_).Query,
        Index=key(_).Index,
        Plans=length(_.Plan),
        Plan=first(_.Plan)
    }) |>  DataFrame

CSV.write("./mainmatter/08-evaluation/figures/bignns/cottontail/plans.csv", plan)


# Generate PDFs
for query in ["NNS","NNS + Fetch","Hybrid"]
    nns = df |> @filter(_.Query == query && _.Parallel == 32) |> 
    @orderby_descending(_.Entity) |> 
    @thenby_descending(_.Parallel) |> @thenby(_.Index) |>
    @groupby({_.Entity, _.Index, _.Parallel}) |> 
    @map({
        Entity=key(_).Entity, 
        Index=key(_).Index,
        Parallel=key(_).Parallel,
        Type="$(key(_).Index) (p=$(key(_).Parallel))",
        RuntimeMean=Statistics.mean(_.Runtime), 
        RecallMean=Statistics.mean(_.Recall), 
        DCGMean=Statistics.mean(_.DCG), 
        RuntimeMeanMax=Statistics.mean(_.Runtime)+Statistics.std(_.Runtime), 
        RuntimeMeanMin=Statistics.mean(_.Runtime)+Statistics.std(_.Runtime), 
        Label="$(round(Statistics.mean(_.Runtime), digits=2))±$(round(Statistics.std(_.Runtime), digits=2))",
        LabelPosition=minimum([Statistics.mean(_.Runtime), 15]), 
    }) |> DataFrame

    p1 = plot(nns,
        ygroup=:Entity, x=:RuntimeMean, y=:Index, label=:Label,
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

    p2 = plot(nns,
        ygroup=:Entity, x=:Index,
        Geom.subplot_grid(
            layer(y=:RecallMean, Geom.point, color=["#D2EBE9"], shape = [Shape.diamond]),
            layer(y=:DCGMean, Geom.point, color=["#DD879B"], shape = [Shape.circle]), 
            Guide.xticks(orientation=:vertical)
        ),
        Guide.xlabel("Quality"),
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
            key_position=:none,
            default_color="#D2EBE9"
        )
    )

    draw(PDF("./mainmatter/08-evaluation/figures/bignns/cottontail/bignns-cottontail-$(query)-runtime.pdf",21cm,22cm),p1);
    draw(PDF("./appendices/01-appendix/figures/bignns-cottontail-$(query)-quality.pdf",21cm,29cm),p2);
end