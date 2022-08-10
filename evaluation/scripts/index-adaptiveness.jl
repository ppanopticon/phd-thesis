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
    default_color="#A5D7D2"
)


# Load data files
entities = Dict([("features_averagecolor", 3), ("features_visualtextcoembedding", 25), ("features_hogmf25k512", 512), ("features_inceptionresnetv2", 1536), ("features_conceptmasksade20k", 2048)])
indexes = Dict([("SCAN", 1), ("VAF", 2), ("PQ", 3)])

df1 = DataFrame(Timestamp = Int32[], Count = Int32[], Insert = Int32[], Delete = Int32[], OOB = Int32[], Rebuild = Bool[], Runtime = Float64[], NDCG = Float64[], Recall = Float64[])
dict = read_json(joinpath("./evaluation/data/index/","index-vaf-adaptiveness-with-rebuild~measurements.json"))
for (timestamp, count, insert, delete, oob, rebuild, runtime, ndcg, recall) in zip(dict["timestamp"],dict["count"],dict["insert"], dict["delete"], dict["oob"], dict["rebuilt"], dict["runtime"], dict["dcg"], dict["recall"])
    push!(df1, (timestamp, count, insert, delete, oob, rebuild, runtime, ndcg, recall))
end
rebuild_df1 = (df1 |> @filter(_.Rebuild == true) |> DataFrame)[1,:Timestamp]

df2 = DataFrame(Timestamp = Int32[], Count = Int32[], Insert = Int32[], Delete = Int32[], Rebuild = Bool[], Runtime = Float64[], NDCG = Float64[], Recall = Float64[])
dict = read_json(joinpath("./evaluation/data/index/","index-pq-adaptiveness-with-rebuild~measurements.json"))
for (timestamp, count, insert, delete, rebuild, runtime, ndcg, recall) in zip(dict["timestamp"],dict["count"],dict["insert"], dict["delete"], dict["rebuilt"], dict["runtime"], dict["dcg"], dict["recall"])
    push!(df2, (timestamp, count, insert, delete, rebuild, runtime, ndcg, recall))
end
rebuild_df2 = (df2 |> @filter(_.Rebuild == true) |> DataFrame)[1,:Timestamp]

# Prepare plot 
count_vaf = plot(df1, x=:Timestamp,
    layer(y=:Count, Geom.line),
    Guide.xlabel("Ellapsed Time [s]"),
    Guide.ylabel("Collection Size"),
    layer(xintercept=[rebuild_df1], Geom.vline(color=["#46505A"], style=[:dot])),
    Coord.cartesian(xmin=0, xmax=7200),
    theme
)
count_pq = plot(df2, x=:Timestamp,
    layer(y=:Count, Geom.line),
    Guide.xlabel("Ellapsed Time [s]"),
    Guide.ylabel("Collection Size"),
    layer(xintercept=[rebuild_df2], Geom.vline(color=["#46505A"], style=[:dot])),
    Coord.cartesian(xmin=0, xmax=7200),
    theme
)

operations_vaf = plot(df1, x=:Timestamp,
    layer(y=:Insert, Geom.line, color=["Inserts"]),
    layer(y=:Delete, Geom.line,  color=["Deletes"]),
    layer(y=:OOB, Geom.line,  color=["Tombstones"]),
    layer(xintercept=[rebuild_df1], Geom.vline(color=["#46505A"], style=[:dot])),
    Guide.xlabel("Ellapsed Time [s]"),
    Guide.ylabel("Operations"),
    Scale.color_discrete_manual("#A5D7D2","#D20537"),
    Coord.cartesian(xmin=0, xmax=7200),
    theme
)
operations_pq = plot(df2, x=:Timestamp,
    layer(y=:Insert, Geom.line, color=["Inserts"]),
    layer(y=:Delete, Geom.line,  color=["Deletes"]),
    layer(xintercept=[rebuild_df2], Geom.vline(color=["#46505A"], style=[:dot])),
    Guide.xlabel("Ellapsed Time [s]"),
    Guide.ylabel("Operations"),
    Scale.color_discrete_manual("#A5D7D2","#D20537"),
    Coord.cartesian(xmin=0, xmax=7200),
    theme
)

runtime_vaf = plot(df1, x=:Timestamp, y=:Runtime,
    layer(Geom.line, Stat.smooth(method=:lm, levels=[0.70,0.80,0.90,0.99]), Geom.line, Geom.ribbon(fill=true)),
    layer(xintercept=[rebuild_df1], Geom.vline(color=["#46505A"], style=[:dot])),
    Guide.xlabel("Ellapsed Time [s]"),
    Guide.ylabel("Latency [s]"),
    Coord.cartesian(xmin=0, xmax=7200),
    theme
)
runtime_pq = plot(df2, x=:Timestamp, y=:Runtime,
    layer(Geom.line,  Stat.smooth(method=:lm, levels=[0.70,0.80,0.90,0.99]), Geom.line, Geom.ribbon(fill=true)),
    layer(xintercept=[rebuild_df2], Geom.vline(color=["#46505A"], style=[:dot])),
    Guide.xlabel("Ellapsed Time [s]"),
    Guide.ylabel("Latency [s]"),
    Coord.cartesian(xmin=0, xmax=7200),
    theme
)

quality_vaf = plot(df1, x=:Timestamp, 
    layer(y=:NDCG, color=["nDCG"], Geom.line),
    layer(y=:Recall, color=["Recall"], Geom.line),
    layer(xintercept=[rebuild_df1], Geom.vline(color=["#46505A"], style=[:dot])),
    Guide.xlabel("Ellapsed Time [s]"),
    Guide.ylabel("Quality"),
    Scale.y_continuous(minvalue=0.0, maxvalue=1.0),
    Coord.cartesian(xmin=0, xmax=7200),
    Scale.color_discrete_manual("#A5D7D2","#D20537"),
    theme
)
quality_pq = plot(df2, x=:Timestamp, 
    layer(y=:NDCG, color=["nDCG"], Stat.smooth(method=:lm, levels=[0.9,0.99]), Geom.line, Geom.ribbon(fill=true)),
    layer(y=:Recall, color=["Recall"], Stat.smooth(method=:lm, levels=[0.9,0.999]), Geom.line, Geom.ribbon(fill=true)),
    layer(xintercept=[rebuild_df2], Geom.vline(color=["#46505A"], style=[:dot])),
    Guide.xlabel("Ellapsed Time [s]"),
    Guide.ylabel("Quality"),
    Scale.y_continuous(minvalue=0.0, maxvalue=1.0),
    Coord.cartesian(xmin=0, xmax=7200),
    Scale.color_discrete_manual("#A5D7D2","#D20537"),
    theme
)

draw(PDF("./mainmatter/08-evaluation/figures/index/index-vaf-adaptiveness.pdf",30cm,20cm),vstack(hstack(count_vaf, operations_vaf), hstack(runtime_vaf, quality_vaf)));
draw(PDF("./mainmatter/08-evaluation/figures/index/index-pq-adaptiveness.pdf",30cm,20cm),vstack(hstack(count_pq, operations_pq), hstack(runtime_pq, quality_pq)));