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

df1 = DataFrame(Timestamp = Int32[], Count = Int32[], Insert = Int32[], Delete = Int32[], Runtime = Float64[], NDCG = Float64[], Recall = Float64[])
dict = read_json(joinpath("./evaluation/data/index/","index-vaf-adaptiveness~measurements.json"))
for (timestamp, count, insert, delete, runtime, ndcg, recall) in zip(dict["timestamp"],dict["count"],dict["insert"], dict["delete"], dict["runtime"], dict["dcg"], dict["recall"])
    push!(df1, (timestamp, count, insert, delete, runtime, ndcg, recall))
end

# Prepare plot 
count = plot(df1, x=:Timestamp,
    layer(y=:Count, Geom.line),
    Guide.xlabel("Ellapsed Time [s]"),
    Guide.ylabel("Collection Size"),
    theme
)

operations = plot(df1, x=:Timestamp,
    layer(y=:Insert, Geom.line),
    layer(y=:Delete, Geom.line),
    Guide.xlabel("Ellapsed Time [s]"),
    Guide.ylabel("Operations"),
    theme
)

runtime = plot(df1, x=:Timestamp, y=:Runtime, Geom.line,
    Guide.xlabel("Ellapsed Time [s]"),
    Guide.ylabel("Runtime"),
    theme
)

quality = plot(df1, x=:Timestamp, 
    layer(y=:NDCG, color=["nDCG"], Geom.line),
    layer(y=:Recall,  color=["Recall"], Geom.line),
    Guide.xlabel("Ellapsed Time [s]"),
    Guide.ylabel("Quality"),
    Scale.color_discrete_manual("#A5D7D2","#D20537","#2D373C","#D2EBE9","#DD879B","#46505A"),
    theme
)

draw(PDF("./mainmatter/08-evaluation/figures/index/index-vaf-adaptiveness.pdf",15cm,40cm),vstack(count, operations, runtime, quality));