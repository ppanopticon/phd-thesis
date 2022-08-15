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

df_vaf = DataFrame(Timestamp = Int32[], Count = Int32[], Insert = Int32[], Delete = Int32[], OOB = Int32[], Rebuild = Bool[], Runtime = Float64[], NDCG = Float64[], Recall = Float64[], Score=Float64[])
dict = read_json(joinpath("./evaluation/data/index/","index-vaf-adaptiveness-with-rebuild~measurements.json"))
for (timestamp, count, insert, delete, oob, rebuild, runtime, ndcg, recall, plan) in zip(dict["timestamp"],dict["count"],dict["insert"], dict["delete"], dict["oob"], dict["rebuilt"], dict["runtime"], dict["dcg"], dict["recall"], dict["plan"])
    push!(df_vaf, (timestamp, count, insert, delete, oob, rebuild, runtime, ndcg, recall, plan["second"]))
end
rebuild_df_vaf = (df_vaf |> @filter(_.Rebuild == true) |> DataFrame)[1,:Timestamp]

df_vaf_jitter_5 = DataFrame(Timestamp = Int32[], Count = Int32[], Insert = Int32[], Delete = Int32[], OOB = Int32[], Rebuild = Bool[], Runtime = Float64[], NDCG = Float64[], Recall = Float64[], Score=Float64[])
dict = read_json(joinpath("./evaluation/data/index/","index-vaf-adaptiveness-with-rebuild-and-jitter-5~measurements.json"))
for (timestamp, count, insert, delete, oob, rebuild, runtime, ndcg, recall, plan) in zip(dict["timestamp"],dict["count"],dict["insert"], dict["delete"], dict["oob"], dict["rebuilt"], dict["runtime"], dict["dcg"], dict["recall"], dict["plan"])
    push!(df_vaf_jitter_5, (timestamp, count, insert, delete, oob, rebuild, runtime, ndcg, recall, plan["second"]))
end
rebuild_df_vaf_jitter_5 = (df_vaf_jitter_5 |> @filter(_.Rebuild == true) |> DataFrame)[1,:Timestamp]

df_vaf_jitter_10 = DataFrame(Timestamp = Int32[], Count = Int32[], Insert = Int32[], Delete = Int32[], OOB = Int32[], Rebuild = Bool[], Runtime = Float64[], NDCG = Float64[], Recall = Float64[], Score=Float64[])
dict = read_json(joinpath("./evaluation/data/index/","index-vaf-adaptiveness-with-rebuild-and-jitter-10~measurements.json"))
for (timestamp, count, insert, delete, oob, rebuild, runtime, ndcg, recall, plan) in zip(dict["timestamp"],dict["count"],dict["insert"], dict["delete"], dict["oob"], dict["rebuilt"], dict["runtime"], dict["dcg"], dict["recall"], dict["plan"])
    push!(df_vaf_jitter_10, (timestamp, count, insert, delete, oob, rebuild, runtime, ndcg, recall, plan["second"]))
end
rebuild_df_vaf_jitter_10 = (df_vaf_jitter_10 |> @filter(_.Rebuild == true) |> DataFrame)[1,:Timestamp]

df_pq = DataFrame(Timestamp = Int32[], Count = Int32[], Insert = Int32[], Delete = Int32[], Rebuild = Bool[], Runtime = Float64[], NDCG = Float64[], Recall = Float64[])
dict = read_json(joinpath("./evaluation/data/index/","index-pq-adaptiveness-with-rebuild~measurements.json"))
for (timestamp, count, insert, delete, rebuild, runtime, ndcg, recall) in zip(dict["timestamp"],dict["count"],dict["insert"], dict["delete"], dict["rebuilt"], dict["runtime"], dict["dcg"], dict["recall"])
    push!(df_pq, (timestamp, count, insert, delete, rebuild, runtime, ndcg, recall))
end
rebuild_df_pq = (df_pq |> @filter(_.Rebuild == true) |> DataFrame)[1,:Timestamp]

df_pq_jitter_10 = DataFrame(Timestamp = Int32[], Count = Int32[], Insert = Int32[], Delete = Int32[], OOB = Int32[], Rebuild = Bool[], Runtime = Float64[], NDCG = Float64[], Recall = Float64[])
dict = read_json(joinpath("./evaluation/data/index/","index-pq-adaptiveness-with-rebuild-and-jitter-10~measurements.json"))
for (timestamp, count, insert, delete, oob, rebuild, runtime, ndcg, recall) in zip(dict["timestamp"],dict["count"],dict["insert"], dict["delete"], dict["oob"], dict["rebuilt"], dict["runtime"], dict["dcg"], dict["recall"])
    push!(df_pq_jitter_10, (timestamp, count, insert, delete, oob, rebuild, runtime, ndcg, recall))
end
rebuild_df_pq_jitter_10 = (df_pq_jitter_10 |> @filter(_.Rebuild == true) |> DataFrame)[1,:Timestamp]

# Prepare plot (VAF Score)
score_vaf = plot(
    layer(df_vaf, x=:Timestamp, y=:Score, color=["No Jitter"], Geom.line),
    layer(df_vaf_jitter_5, x=:Timestamp, y=:Score, color=["Jitter 5"], Geom.line),
    layer(df_vaf_jitter_10, x=:Timestamp, y=:Score, color=["Jitter 10"], Geom.line),
    Guide.xlabel("Ellapsed Time [s]"),
    Guide.ylabel("Score"),
    layer(xintercept=[rebuild_df_vaf], Geom.vline(color=["#46505A"], style=[:dot])),
    Coord.cartesian(xmin=0, xmax=7200),
    theme
)

# Prepare plot  (Count)
count_vaf = plot(df_vaf, x=:Timestamp,
    layer(y=:Count, Geom.line),
    Guide.xlabel("Ellapsed Time [s]"),
    Guide.ylabel("Collection Size"),
    layer(xintercept=[rebuild_df_vaf], Geom.vline(color=["#46505A"], style=[:dot])),
    Coord.cartesian(xmin=0, xmax=7200),
    theme
)
count_vaf_jitter_5 = plot(df_vaf_jitter_5, x=:Timestamp,
    layer(y=:Count, Geom.line),
    Guide.xlabel("Ellapsed Time [s]"),
    Guide.ylabel("Collection Size"),
    layer(xintercept=[rebuild_df_vaf_jitter_5], Geom.vline(color=["#46505A"], style=[:dot])),
    Coord.cartesian(xmin=0, xmax=7200),
    theme
)
count_vaf_jitter_10 = plot(df_vaf_jitter_10, x=:Timestamp,
    layer(y=:Count, Geom.line),
    Guide.xlabel("Ellapsed Time [s]"),
    Guide.ylabel("Collection Size"),
    layer(xintercept=[rebuild_df_vaf_jitter_10], Geom.vline(color=["#46505A"], style=[:dot])),
    Coord.cartesian(xmin=0, xmax=7200),
    theme
)
count_pq = plot(df_pq, x=:Timestamp,
    layer(y=:Count, Geom.line),
    Guide.xlabel("Ellapsed Time [s]"),
    Guide.ylabel("Collection Size"),
    layer(xintercept=[rebuild_df_pq_jitter_10], Geom.vline(color=["#46505A"], style=[:dot])),
    Coord.cartesian(xmin=0, xmax=7200),
    theme
)
count_pq_jitter_10 = plot(df_pq_jitter_10, x=:Timestamp,
    layer(y=:Count, Geom.line),
    Guide.xlabel("Ellapsed Time [s]"),
    Guide.ylabel("Collection Size"),
    layer(xintercept=[rebuild_df_pq], Geom.vline(color=["#46505A"], style=[:dot])),
    Coord.cartesian(xmin=0, xmax=7200),
    theme
)

# Prepare plot (Ops)
operations_vaf = plot(df_vaf, x=:Timestamp,
    layer(y=:Insert, Geom.line, color=["Inserts"]),
    layer(y=:Delete, Geom.line,  color=["Deletes"]),
    layer(y=:OOB, Geom.line,  color=["Tombstones"]),
    layer(xintercept=[rebuild_df_vaf], Geom.vline(color=["#46505A"], style=[:dot])),
    Guide.xlabel("Ellapsed Time [s]"),
    Guide.ylabel("Operations"),
    Scale.color_discrete_manual("#A5D7D2","#D20537"),
    Coord.cartesian(xmin=0, xmax=7200),
    theme
)
operations_vaf_jitter_5 = plot(df_vaf_jitter_5, x=:Timestamp,
    layer(y=:Insert, Geom.line, color=["Inserts"]),
    layer(y=:Delete, Geom.line,  color=["Deletes"]),
    layer(y=:OOB, Geom.line,  color=["Tombstones"]),
    layer(xintercept=[rebuild_df_vaf_jitter_5], Geom.vline(color=["#46505A"], style=[:dot])),
    Guide.xlabel("Ellapsed Time [s]"),
    Guide.ylabel("Operations"),
    Scale.color_discrete_manual("#A5D7D2","#D20537"),
    Coord.cartesian(xmin=0, xmax=7200),
    theme
)
operations_vaf_jitter_10 = plot(df_vaf_jitter_10, x=:Timestamp,
    layer(y=:Insert, Geom.line, color=["Inserts"]),
    layer(y=:Delete, Geom.line,  color=["Deletes"]),
    layer(y=:OOB, Geom.line,  color=["Tombstones"]),
    layer(xintercept=[rebuild_df_vaf_jitter_10], Geom.vline(color=["#46505A"], style=[:dot])),
    Guide.xlabel("Ellapsed Time [s]"),
    Guide.ylabel("Operations"),
    Scale.color_discrete_manual("#A5D7D2","#D20537"),
    Coord.cartesian(xmin=0, xmax=7200),
    theme
)
operations_pq = plot(df_pq, x=:Timestamp,
    layer(y=:Insert, Geom.line, color=["Inserts"]),
    layer(y=:Delete, Geom.line,  color=["Deletes"]),
    layer(xintercept=[rebuild_df_pq], Geom.vline(color=["#46505A"], style=[:dot])),
    Guide.xlabel("Ellapsed Time [s]"),
    Guide.ylabel("Operations"),
    Scale.color_discrete_manual("#A5D7D2","#D20537"),
    Coord.cartesian(xmin=0, xmax=7200),
    theme
)
operations_pq_jitter_10 = plot(df_pq_jitter_10, x=:Timestamp,
    layer(y=:Insert, Geom.line, color=["Inserts"]),
    layer(y=:Delete, Geom.line,  color=["Deletes"]),
    layer(xintercept=[rebuild_df_pq_jitter_10], Geom.vline(color=["#46505A"], style=[:dot])),
    Guide.xlabel("Ellapsed Time [s]"),
    Guide.ylabel("Operations"),
    Scale.color_discrete_manual("#A5D7D2","#D20537"),
    Coord.cartesian(xmin=0, xmax=7200),
    theme
)

# Prepare plot (Runtime)
runtime_vaf = plot(df_vaf, x=:Timestamp, y=:Runtime,
    layer(Geom.line, Stat.smooth(method=:loess), color=["Smooth"]),
    layer(xintercept=[rebuild_df_vaf], Geom.vline(color=["#46505A"], style=[:dot])),
    layer(Geom.line),
    Guide.xlabel("Ellapsed Time [s]"),
    Guide.ylabel("Latency [s]"),
    Coord.cartesian(xmin=0, xmax=7200),
    Scale.color_discrete_manual("#D20537"),
    theme
)
runtime_vaf_jitter_5 = plot(df_vaf_jitter_5, x=:Timestamp, y=:Runtime,
    layer(Geom.line, Stat.smooth(method=:loess), color=["Smooth"]),
    layer(xintercept=[rebuild_df_vaf_jitter_5], Geom.vline(color=["#46505A"], style=[:dot])),
    layer(Geom.line),
    Guide.xlabel("Ellapsed Time [s]"),
    Guide.ylabel("Latency [s]"),
    Coord.cartesian(xmin=0, xmax=7200),
    Scale.color_discrete_manual("#D20537"),
    theme
)
runtime_vaf_jitter_10 = plot(df_vaf_jitter_10, x=:Timestamp, y=:Runtime,
    layer(Geom.line, Stat.smooth(method=:loess), color=["Smooth"]),
    layer(xintercept=[rebuild_df_vaf_jitter_10], Geom.vline(color=["#46505A"], style=[:dot])),
    layer(Geom.line),
    Guide.xlabel("Ellapsed Time [s]"),
    Guide.ylabel("Latency [s]"),
    Coord.cartesian(xmin=0, xmax=7200),
    Scale.color_discrete_manual("#D20537"),
    theme
)
runtime_pq = plot(df_pq, x=:Timestamp, y=:Runtime,
    layer(Geom.line, Stat.smooth(method=:loess), color=["Smooth"]),
    layer(xintercept=[rebuild_df_pq], Geom.vline(color=["#46505A"], style=[:dot])),
    layer(Geom.line),
    Guide.xlabel("Ellapsed Time [s]"),
    Guide.ylabel("Latency [s]"),
    Coord.cartesian(xmin=0, xmax=7200),
    Scale.color_discrete_manual("#D20537"),
    theme
)
runtime_pq_jitter_10 = plot(df_pq_jitter_10, x=:Timestamp, y=:Runtime,
    layer(Geom.line, Stat.smooth(method=:loess), color=["Smooth"]),
    layer(xintercept=[rebuild_df_pq_jitter_10], Geom.vline(color=["#46505A"], style=[:dot])),
    layer(Geom.line),
    Guide.xlabel("Ellapsed Time [s]"),
    Guide.ylabel("Latency [s]"),
    Coord.cartesian(xmin=0, xmax=7200),
    Scale.color_discrete_manual("#D20537"),
    theme
)

# Prepare plot (Quality)
quality_vaf = plot(df_vaf, x=:Timestamp, 
    layer(y=:NDCG, color=["nDCG"], Geom.line),
    layer(y=:Recall, color=["Recall"], Geom.line),
    layer(xintercept=[rebuild_df_vaf], Geom.vline(color=["#46505A"], style=[:dot])),
    Guide.xlabel("Ellapsed Time [s]"),
    Guide.ylabel("Quality"),
    Scale.y_continuous(minvalue=0.0, maxvalue=1.0),
    Coord.cartesian(xmin=0, xmax=7200),
    Scale.color_discrete_manual("#A5D7D2","#D20537"),
    theme
)
quality_vaf_jitter_5 = plot(df_vaf_jitter_5, x=:Timestamp, 
    layer(xintercept=[rebuild_df_vaf_jitter_5], Geom.vline(color=["#46505A"], style=[:dot])),
    layer(y=:NDCG, color=["nDCG"], Geom.line),
    layer(y=:Recall, color=["Recall"], Geom.line),
    Guide.xlabel("Ellapsed Time [s]"),
    Guide.ylabel("Quality"),
    Scale.y_continuous(minvalue=0.0, maxvalue=1.0),
    Coord.cartesian(xmin=0, xmax=7200),
    Scale.color_discrete_manual("#A5D7D2","#D20537"),
    theme
)
quality_vaf_jitter_10 = plot(df_vaf_jitter_10, x=:Timestamp, 
    layer(xintercept=[rebuild_df_vaf_jitter_10], Geom.vline(color=["#46505A"], style=[:dot])),
    layer(y=:NDCG, color=["nDCG"], Geom.line),
    layer(y=:Recall, color=["Recall"], Geom.line),
    Guide.xlabel("Ellapsed Time [s]"),
    Guide.ylabel("Quality"),
    Scale.y_continuous(minvalue=0.0, maxvalue=1.0),
    Coord.cartesian(xmin=0, xmax=7200),
    Scale.color_discrete_manual("#A5D7D2","#D20537"),
    theme
)
quality_pq = plot(df_pq, x=:Timestamp, 
    layer(xintercept=[rebuild_df_pq], Geom.vline(color=["#46505A"], style=[:dot])),
    layer(y=:NDCG, color=["nDCG"], Geom.line),
    layer(y=:Recall, color=["Recall"], Geom.line),
    Guide.xlabel("Ellapsed Time [s]"),
    Guide.ylabel("Quality"),
    Scale.y_continuous(minvalue=0.0, maxvalue=1.0),
    Coord.cartesian(xmin=0, xmax=7200),
    Scale.color_discrete_manual("#A5D7D2","#D20537"),
    theme
)
quality_pq_jitter_10 = plot(df_pq_jitter_10, x=:Timestamp, 
    layer(xintercept=[rebuild_df_pq_jitter_10], Geom.vline(color=["#46505A"], style=[:dot])),
    layer(y=:NDCG, color=["nDCG"], Geom.line),
    layer(y=:Recall, color=["Recall"], Geom.line),
    Guide.xlabel("Ellapsed Time [s]"),
    Guide.ylabel("Quality"),
    Scale.y_continuous(minvalue=0.0, maxvalue=1.0),
    Coord.cartesian(xmin=0, xmax=7200),
    Scale.color_discrete_manual("#A5D7D2","#D20537"),
    theme
)
draw(PDF("./mainmatter/08-evaluation/figures/index/index-vaf-adaptiveness.pdf",30cm,20cm),vstack(hstack(count_vaf, operations_vaf), hstack(runtime_vaf, quality_vaf)));
draw(PDF("./mainmatter/08-evaluation/figures/index/index-vaf-adaptiveness-with-jitter-5.pdf",30cm,20cm),vstack(hstack(count_vaf_jitter_5, operations_vaf_jitter_5), hstack(runtime_vaf_jitter_5, quality_vaf_jitter_5)));
draw(PDF("./mainmatter/08-evaluation/figures/index/index-vaf-adaptiveness-with-jitter-10.pdf",30cm,20cm),vstack(hstack(count_vaf_jitter_10, operations_vaf_jitter_10), hstack(runtime_vaf_jitter_10, quality_vaf_jitter_10)));
draw(PDF("./mainmatter/08-evaluation/figures/index/index-pq-adaptiveness.pdf",30cm,20cm),vstack(hstack(count_pq, operations_pq), hstack(runtime_pq, quality_pq)));
draw(PDF("./mainmatter/08-evaluation/figures/index/index-pq-adaptiveness-with-jitter-10.pdf",30cm,20cm),vstack(hstack(count_pq_jitter_10, operations_pq_jitter_10), hstack(runtime_pq_jitter_10, quality_pq_jitter_10)));
draw(PDF("./mainmatter/08-evaluation/figures/index/score_vaf.pdf",30cm,20cm),score_vaf);