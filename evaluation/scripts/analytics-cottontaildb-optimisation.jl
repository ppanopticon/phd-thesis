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
    key_position=:inside
)


# Load data files
entities = Dict([("features_averagecolor", 3), ("features_visualtextcoembedding", 25), ("features_hogmf25k512", 512), ("features_inceptionresnetv2", 1536), ("features_conceptmasksade20k", 2048)])
indexes = Dict([("SCAN", 1), ("VAF", 2), ("PQ", 3)])
queries = Dict([("Fetch", 1), ("Mean", 2), ("Range", 3), ("NNS", 4), ("Select", 5)])

df1 = DataFrame(Entity = String[], Dimension = Int32[], Query = String[], QueryOrder = Int32[], Type = String[], Runtime = Float64[])
dict = read_json(joinpath("./evaluation/data/analytics/","analytics-opt~measurements.json"))
for (entity, query, runtime) in zip(dict["entity"], dict["query"], dict["runtime"])
    push!(df1, (replace(entity,"features_" => ""), entities[entity], query, queries[query], "With Optimisation", runtime))
end

dict = read_json(joinpath("./evaluation/data/analytics/","analytics-no-opt~measurements.json"))
for (entity, query, runtime) in zip(dict["entity"], dict["query"], dict["runtime"])
    push!(df1, (replace(entity,"features_" => ""), entities[entity], query, queries[query], "Without Optimisation", runtime))
end

df2 = DataFrame(Entity = String[], Dimension = Int32[], Query = String[], QueryOrder = Int32[], Type = String[], Runtime = Float64[])
dict = read_json(joinpath("./evaluation/data/analytics/","analytics-opt-lowmem~measurements.json"))
for (entity, query, runtime) in zip(dict["entity"], dict["query"], dict["runtime"])
    push!(df2, (replace(entity,"features_" => ""), entities[entity], query, queries[query], "With Optimisation", runtime))
end

dict = read_json(joinpath("./evaluation/data/analytics/","analytics-no-opt-lowmem~measurements.json"))
for (entity, query, runtime) in zip(dict["entity"], dict["query"], dict["runtime"])
    push!(df2, (replace(entity,"features_" => ""), entities[entity], query, queries[query], "Without Optimisation", runtime))
end

# Prepare data for plotting
nns1 = df1 |>
    @orderby_descending(_.Dimension) |> 
    @thenby(_.QueryOrder) |> DataFrame

# Prepare plot 
runtime_normal = plot(nns1,
    color=:Type, x=:Query, y=:Runtime, ygroup=:Dimension,
    Geom.subplot_grid(Geom.boxplot(suppress_outliers=true), free_y_axis = true),
    Guide.xlabel("Type of Query"),
    Guide.ylabel("Latency [s]"),
    Guide.colorkey(title="Optimisation", pos=[0.8,-0.4]),
    Scale.x_discrete,
    Scale.y_continuous(minvalue = 0.0, maxvalue=20.0),
    Scale.color_discrete_manual("#A5D7D2","#D20537","#2D373C","#D2EBE9","#DD879B","#46505A"),
    theme
)

nns2 = df2 |>
    @orderby_descending(_.Dimension) |> 
    @thenby(_.QueryOrder) |> DataFrame

runtime_lowmem = plot(nns2,
    color=:Type, x=:Query, y=:Runtime, ygroup=:Dimension,
    Geom.subplot_grid(Geom.boxplot(suppress_outliers=true), free_y_axis = true),
    Guide.xlabel("Type of Query"),
    Guide.ylabel("Latency [s]"),
    Guide.colorkey(title="Optimisation", pos=[0.8,-0.4]),
    Scale.x_discrete,
    Scale.y_continuous(minvalue = 0.0, maxvalue=20.0),
    Scale.color_discrete_manual("#A5D7D2","#D20537","#2D373C","#D2EBE9","#DD879B","#46505A"),
    theme
)

draw(PDF("./mainmatter/08-evaluation/figures/analytics/analytics-cottontail-optimisation-runtime.pdf",25cm,40cm),runtime_normal);
draw(PDF("./mainmatter/08-evaluation/figures/analytics/analytics-cottontail-optimisation-lowmem-runtime.pdf",25cm,40cm),runtime_lowmem);