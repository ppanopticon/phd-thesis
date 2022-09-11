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
entities = Dict([("features_averagecolor", 3), ("features_visualtextcoembedding", 25), ("features_hogmf25k512", 512), ("features_inceptionresnetv2", 1536), ("features_conceptmasksade20k", 2048)])
indexes = Dict([("SCAN", 1), ("VAF", 2), ("PQ", 3)])
queries = Dict([("Fetch", 1), ("Mean", 2), ("Range", 3), ("NNS", 4), ("Select", 5)])

# Load Non-SIMD data
df1 = DataFrame(Entity = String[],  Dimension = Int32[], Query = String[], QueryOrder = Int32[], Index = String[], IndexOrder = Int32[], Parallel = Int32[], Runtime = Float64[], Recall = Float64[], NDCG = Float64[])
dict = read_json(joinpath("./evaluation/data/analytics/","analytics-normal~measurements.json"))
for (entity, query, index, parallel, runtime, recall, dcg) in zip(dict["entity"], dict["query"], dict["index"], dict["parallel"], dict["runtime"], dict["recall"], dict["ndcg"])
    push!(df1, (replace(entity,"features_" => ""), entities[entity], query, queries[query], index, indexes[index], parallel, runtime, recall, dcg))
end

df2 = DataFrame(Entity = String[], Query = String[], Index = String[], Plan = String[])
dict = read_json(joinpath("./evaluation/data/analytics/","analytics-normal~plans.json"))
for (entity, query, index, plan) in zip(dict["entity"], dict["query"], dict["index"], dict["plan"])
    push!(df2, (entity, query, index, last(plan)))
end

df2 = df2 |> @filter(_.Query in ["Mean", "Range", "NNS"]) |> DataFrame

# Generate PDFs
nnsr = df1 |>
    @filter(_.Parallel in [2, 8, 16]) |>
    @orderby_descending(_.Dimension) |> 
    @thenby_descending(_.IndexOrder) |>
    @thenby_descending(_.Parallel) |>
    @thenby_descending(_.QueryOrder) |>
    @groupby({_.Dimension, _.Query, _.Index, _.Parallel}) |> 
    @map({
        Dimension=key(_).Dimension, 
        Query=key(_).Query,
        Index=key(_).Index,
        Parallel=key(_).Parallel,
        Type="$(key(_).Index) (p=$(key(_).Parallel))",
        RuntimeMean=Statistics.mean(_.Runtime),
        RuntimeStd=Statistics.std(_.Runtime)
    }) |> DataFrame

nns_sum = nnsr |>
    @groupby({_.Dimension, _.Index, _.Parallel}) |> 
    @map({
        Dimension=key(_).Dimension, 
        Index=key(_).Index,
        Parallel=key(_).Parallel,
        Type="$(key(_).Index) (p=$(key(_).Parallel))",
        Label="$(round(sum(_.RuntimeMean), digits=2))±$(round(sum(_.RuntimeStd), digits=2))",
        LabelPosition=minimum([sum(_.RuntimeMean) + 2, 28])
    }) |> DataFrame

runtime_normal = plot(nnsr,
    color=:Query, x=:RuntimeMean, y=:Type, ygroup=:Dimension,
    Geom.subplot_grid(
        layer(nns_sum, x=:LabelPosition, y=:Type, ygroup=:Dimension, label=:Label, Geom.label(position=:centered), Stat.dodge(position=:stack)),
        layer(Geom.bar(orientation = :horizontal)),
        Guide.xticks(ticks = [0, 5, 10, 15, 20, 25, 30])
    ),
    Guide.xlabel("Latency [s]"),
    Guide.ylabel(nothing),
    Guide.colorkey(title="Query", labels=["Fetch (Q1a)","Mean (Q1b)","Range (Q1c)","NNS (Q1d)","Select (Q1e)"], pos=[0.8,-0.4]),
    Scale.x_continuous(minvalue = 0.0, maxvalue=30.0),
    Scale.y_discrete,
    Scale.color_discrete_manual("#A5D7D2","#D20537","#2D373C","#D2EBE9","#DD879B","#46505A"),
    Theme(
        major_label_font="Helvetica Neue Bold",
        major_label_font_size=20pt, 
        minor_label_font="Helvetica Neue",
        minor_label_font_size=18pt, 
        key_title_font="Helvetica Neue Bold",
        key_title_font_size=20pt,
        key_label_font="Helvetica Neue",
        key_label_font_size=18pt, 
        point_label_font="Helvetica Neue Light",
        point_label_font_size=16pt, 
        bar_spacing=1mm, 
        default_color="#D2EBE9",
        key_position=:inside
    )
)

nnsq = df1 |>
    @orderby(_.Dimension) |> 
    @thenby_descending(_.IndexOrder) |>
    @thenby_descending(_.Parallel) |>
    @thenby_descending(_.QueryOrder) |>
    @groupby({_.Dimension, _.Query, _.Index}) |> 
    @map({
        Dimension=key(_).Dimension, 
        Query=key(_).Query,
        Index=key(_).Index,
        RecallMax=maximum(_.Recall),
        RecallMean=Statistics.mean(_.Recall),
        RecallMin=minimum(_.Recall), 
        NDCGMax=maximum(_.NDCG), 
        NDCGMean=Statistics.mean(_.NDCG),
        NDCGMin=minimum(_.NDCG)
    }) |> DataFrame

quality_range = plot(nnsq |> @filter(_.Query == "Range") |> DataFrame,
    x=:Index, xgroup=:Dimension, 
    Geom.subplot_grid(
        layer(y=:RecallMean, ymin=:RecallMin, ymax=:RecallMax, Geom.point, Geom.errorbar, color=["Recall"], shape = [Shape.diamond]),
        layer(y=:NDCGMean, ymin=:NDCGMin, ymax=:NDCGMax, Geom.point, Geom.errorbar, color=["nDCG"], shape = [Shape.circle]),
        Guide.xticks(orientation=:vertical),
        Guide.yticks(ticks=[0.0, 0.25, 0.5, 0.75, 1.0]),
        Coord.cartesian(ymin=0.0, xmin=1.0)
    ), 
    Guide.xlabel(nothing),
    Guide.ylabel("Quality"),
    Guide.colorkey(title="Metric"),
    Scale.x_discrete,
    Scale.color_discrete_manual("#D2EBE9","#DD879B"),
    Theme(
        major_label_font="Helvetica Neue Bold",
        major_label_font_size=20pt, 
        minor_label_font="Helvetica Neue",
        minor_label_font_size=18pt, 
        point_label_font="Helvetica Neue Light",
        point_label_font_size=16pt, 
        point_size=6pt, 
        default_color="#D2EBE9"
    )
)

quality_nns = plot(nnsq |> @filter(_.Query == "NNS") |> DataFrame,
    x=:Index, xgroup=:Dimension, y=:NDCGMean, ymin=:NDCGMin, ymax=:NDCGMax,
    Geom.subplot_grid(
        layer(y=:RecallMean, ymin=:RecallMin, ymax=:RecallMax, Geom.point, Geom.errorbar, color=["Recall"], shape = [Shape.diamond]),
        layer(y=:NDCGMean, ymin=:NDCGMin, ymax=:NDCGMax, Geom.point, Geom.errorbar, color=["nDCG"], shape = [Shape.circle]),
        Guide.xticks(orientation=:vertical),
        Guide.yticks(ticks=[0.0, 0.25, 0.5, 0.75, 1.0]),
        Coord.cartesian(ymin=0.0, xmin=1.0)
    ),
    Guide.xlabel(nothing),
    Guide.ylabel("Quality"),
    Guide.colorkey(title="Metric"),
    Scale.x_discrete,
    Scale.color_discrete_manual("#D2EBE9","#DD879B"),
    Theme(
        major_label_font="Helvetica Neue Bold",
        major_label_font_size=20pt, 
        minor_label_font="Helvetica Neue",
        minor_label_font_size=18pt, 
        point_label_font="Helvetica Neue Light",
        point_label_font_size=16pt, 
        point_size=6pt, 
        default_color="#D2EBE9"
    )
)

draw(PDF("./mainmatter/08-evaluation/figures/analytics/analytics-cottontail-runtime.pdf",36cm,49cm),runtime_normal);
draw(PDF("./mainmatter/08-evaluation/figures/analytics/analytics-cottontail-quality-range.pdf",22cm,11cm),quality_range);
draw(PDF("./mainmatter/08-evaluation/figures/analytics/analytics-cottontail-quality-nns.pdf",22cm,11cm),quality_nns);