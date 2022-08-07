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
    point_label_font_size=18pt
)


# Load data files
entities = Dict([("features_averagecolor", 3), ("features_visualtextcoembedding", 25), ("features_hogmf25k512", 512), ("features_inceptionresnetv2", 1536), ("features_conceptmasksade20k", 2048)])
indexes = Dict([("SCAN", 1), ("VAF", 2), ("PQ", 3)])

df1 = DataFrame(Entity = String[], Dimension = Int32[], Type = String[], Runtime = Float64[])
dict = read_json(joinpath("./evaluation/data/index/","index-vaf-cache~measurements.json"))
for (entity, runtime) in zip(dict["entity"], dict["runtime"])
    push!(df1, (replace(entity,"features_" => ""), entities[entity], "Cache", runtime))
end

dict = read_json(joinpath("./evaluation/data/index/","index-vaf-nocache~measurements.json"))
for (entity, runtime) in zip(dict["entity"], dict["runtime"])
    push!(df1, (replace(entity,"features_" => ""), entities[entity], "No Cache", runtime))
end

# Prepare data for plotting
nns1 = df1 |> @orderby_descending(_.Dimension) |> DataFrame

# Prepare plot 
runtime_vaf = plot(nns1,
    x=:Type, y=:Runtime, color=:Dimension,
    Geom.boxplot(suppress_outliers=true),
    Guide.xlabel("Cache"),
    Guide.ylabel("Latency [s]"),
    Guide.colorkey(title="Optimisation"),
    Scale.x_discrete,
    Scale.y_continuous(minvalue = 0.0, maxvalue=5.0),
    Scale.color_discrete_manual("#A5D7D2","#D20537","#2D373C","#D2EBE9","#DD879B","#46505A"),
    theme
)

draw(PDF("./mainmatter/08-evaluation/figures/index/index-vaf-runtime.pdf",15cm,15cm),runtime_vaf);