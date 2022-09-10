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

# Define theme
theme = Theme(
    major_label_font="Helvetica Neue Bold",
    major_label_font_size=16pt, 
    minor_label_font="Helvetica Neue",
    minor_label_font_size=12pt, 
    key_title_font="Helvetica Neue Bold",
    key_title_font_size=14pt,
    key_label_font="Helvetica Neue",
    key_label_font_size=12pt, 
    point_label_font="Helvetica Neue Light",
    point_label_font_size=18pt,
    line_style=[:dot],
    key_position=:none
)


# Load data files
entities = Dict([("features_averagecolor", 3), ("features_visualtextcoembedding", 25), ("features_hogmf25k512", 512), ("features_inceptionresnetv2", 1536), ("features_conceptmasksade20k", 2048)])
indexes = Dict([("SCAN", 1), ("VAF", 2), ("PQ", 3)])
queries = Dict([("Fetch", 1), ("Mean", 2), ("Range", 3), ("NNS", 4), ("Select", 5)])

df = DataFrame(Entity = String[], Dimension = Int32[], Query = String[], QueryOrder = Int32[], Type = String[], Runtime = Float64[])
dict = read_json(joinpath("./evaluation/data/analytics/","analytics-simd~measurements.json"))
for (entity, query, runtime) in zip(dict["entity"], dict["query"], dict["runtime"])
    push!(df, (replace(entity,"features_" => ""), entities[entity], query, queries[query], "SIMD", runtime))
end

dict = read_json(joinpath("./evaluation/data/analytics/","analytics-no-simd~measurements.json"))
for (entity, query, runtime) in zip(dict["entity"], dict["query"], dict["runtime"])
    push!(df, (replace(entity,"features_" => ""), entities[entity], query, queries[query], "No SIMD", runtime))
end

# Prepare data for plotting
nns = df |>
    @orderby_descending(_.Dimension) |> 
    @thenby_descending(_.QueryOrder) |>
    @groupby({_.Dimension, _.Query, _.Type}) |> 
    @map({
        Dimension=key(_).Dimension, 
        Query=key(_).Query,
        Type=key(_).Type,
        RuntimeMean=Statistics.mean(_.Runtime),
        LabelPosition=minimum([Statistics.mean(_.Runtime), 200]), 
        RuntimeMax=Statistics.mean(_.Runtime)+Statistics.std(_.Runtime), 
        RuntimeMin=Statistics.mean(_.Runtime)-Statistics.std(_.Runtime),
        Label="$(round(Statistics.mean(_.Runtime), digits=2))±$(round(Statistics.std(_.Runtime), digits=2))"
    }) |> DataFrame

# Prepare plot 
runtime_normal = plot(nns,
    color=:Type, x=:RuntimeMean, y=:Query, xgroup=:Dimension, xmin=:RuntimeMin, xmax=:RuntimeMax, label=:Label,
    Geom.subplot_grid(
        layer(x=:LabelPosition, Geom.label(position = :right), Geom.xerrorbar),
        Geom.bar(position=:dodge, orientation=:horizontal), Guide.xticks(ticks = [0, 5, 10, 15, 20])
    ),
    Guide.xlabel("Latency [s]"),
    Guide.ylabel(nothing),
    Guide.colorkey(title="Query", pos=[0.8,-0.4]),
    Scale.x_continuous(minvalue = 0.0, maxvalue=20.0),
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

draw(PDF("./mainmatter/08-evaluation/figures/analytics/analytics-cottontail-simd-runtime.pdf",36cm,49cm),runtime_normal);
