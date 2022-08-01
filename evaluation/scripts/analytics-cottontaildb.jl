
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


# Load data files
df = DataFrame(Query = String[], Entity = String[], Index = String[], Parallel = Int32[], Runtime = Float64[], Recall = Float64[], NDCG = Float64[])
dict = read_json(joinpath("./evaluation/data/analytics/","analytics~measurements.json"))
for (entity, query, index, parallel, runtime, recall, dcg) in zip(dict["entity"], dict["query"], dict["index"], dict["parallel"], dict["runtime"], dict["recall"], dict["ndcg"])
    push!(df, (query, entity, index, parallel, runtime, recall, dcg))
end

#print(df)

# Generate PDFs
nns = df |>
@orderby(_.Entity) |> 
@thenby(_.Index) |>
@groupby({_.Entity, _.Query, _.Index, _.Parallel}) |> 
@map({
    Entity=key(_).Entity, 
    Query=key(_).Query,
    Index=key(_).Index,
    Parallel=key(_).Parallel,
    Type="$(key(_).Index) (p=$(key(_).Parallel))",
    RuntimeMean=Statistics.mean(_.Runtime), 
    RecallMean=Statistics.mean(_.Recall), 
    NDCGMean=Statistics.mean(_.NDCG),
    LabelPosition=minimum([Statistics.mean(_.Runtime), 100]), 
}) |> DataFrame

print(nns)

p1 = plot(nns,
    color=:Query, ygroup=:Entity, x=:RuntimeMean, y=:Type,
    Geom.subplot_grid(layer(x=:LabelPosition, Geom.bar(orientation = :horizontal)), Guide.xticks(orientation=:vertical)),
    Guide.xlabel("Latency [s]"),
    Guide.ylabel(nothing),
    Guide.colorkey(title="Query"),
    Scale.x_continuous(minvalue = 0.0, maxvalue=20.0),
    Scale.y_discrete,
    Theme(
        major_label_font="Helvetica Neue Bold",
        major_label_font_size=20pt, 
        minor_label_font="Helvetica Neue",
        minor_label_font_size=18pt, 
        point_label_font="Helvetica Neue Light",
        point_label_font_size=16pt, 
        bar_spacing=1mm, 
        default_color="#D2EBE9"
    )
)

draw(PDF("./mainmatter/08-evaluation/figures/analytics/analytics-cottontail-runtime.pdf",24cm,48cm),p1);