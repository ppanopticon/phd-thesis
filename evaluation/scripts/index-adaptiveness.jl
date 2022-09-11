using DataFrames
using Statistics
using Gadfly
using Cairo
using Fontconfig
using Query
using Formatting
using CSV
using Printf

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
for i in ["pq","vaf"]
    for r in ["90-10", "50-50"]
        df = DataFrame(Timestamp = Int32[], Count = Int32[], Insert = Int32[], Delete = Int32[], OOB = Int32[], Rebuild = Bool[], Speedup = Float64[], NDCG = Float64[], Recall = Float64[], Score=Float64[])
        dict = read_json(joinpath("./evaluation/data/index/","index-$(i)-adaptiveness-$(r)-no-rebuild~measurements.json"))
        for (timestamp, count, insert, delete, oob, rebuild, speedup, ndcg, recall, plan) in zip(dict["timestamp"],dict["count"],dict["insert"], dict["delete"], dict["oob"], dict["rebuilt"], dict["speedup_bf"], dict["dcg"], dict["recall"], dict["plan"])
            push!(df, (timestamp, count, insert, delete, oob, rebuild, speedup, ndcg, recall, plan["second"]))
        end

        count = plot(df, x=:Timestamp,
            layer(y=:Count, Geom.line),
            Guide.xlabel("Elapsed Time [s]"),
            Guide.ylabel("Collection Size"),
            Coord.cartesian(xmin=0, xmax=1800, ymin=0, ymax=5000000),
            Scale.y_continuous(labels=x -> @sprintf("%0.0fM", x / 1000000)),
            theme
        )
        operations = plot(df, x=:Timestamp,
            layer(y=:Insert, Geom.line, color=["Inserts"]),
            layer(y=:Delete, Geom.line,  color=["Deletes"]),
            layer(y=:OOB, Geom.line,  color=["OOB"]),
            Guide.xlabel("Elapsed Time [s]"),
            Guide.ylabel("Operations"),
            Guide.colorkey(title="Type"),
            Scale.color_discrete_manual("#A5D7D2","#D20537"),
            Coord.cartesian(xmin=0, xmax=1800, ymin=0.0, ymax=4000000),
            Scale.y_continuous(labels=x -> @sprintf("%0.0fM", x / 1000000)),
            theme
        )
        speedup = plot(df, x=:Timestamp, y=:Speedup,
            layer(Geom.line, Stat.smooth(), Theme(default_color="#D20537")),
            layer(Geom.line),
            layer(yintercept=[maximum(df[!,:Speedup])], Geom.hline(color=["#A5D7D2"], style=[:dot])),
            layer(yintercept=[minimum(df[!,:Speedup])], Geom.hline(color=["#A5D7D2"], style=[:dot])),
            Guide.xlabel("Elapsed Time [s]"),
            Guide.ylabel("Speed-Up [s]"),
            Coord.cartesian(xmin=0, xmax=1800, ymin=-4.0, ymax=4.0),
            theme
        )
        quality = plot(df, x=:Timestamp, 
            layer(y=:NDCG, color=["nDCG"], Geom.line),
            layer(y=:Recall, color=["Recall"], Geom.line),
            layer(yintercept=[maximum(df[!,:Recall])], Geom.hline(color=["#D20537"], style=[:dot])),
            layer(yintercept=[minimum(df[!,:Recall])], Geom.hline(color=["#D20537"], style=[:dot])),
            layer(yintercept=[maximum(df[!,:NDCG])], Geom.hline(color=["#A5D7D2"], style=[:dot])),
            layer(yintercept=[minimum(df[!,:NDCG])], Geom.hline(color=["#A5D7D2"], style=[:dot])),
            Guide.xlabel("Elapsed Time [s]"),
            Guide.ylabel("Quality (NNS)"),
            Guide.colorkey(title="Metric"),
            Guide.yticks(ticks=[0.0, 0.2, 0.4, 0.6, 0.8, 1.0]),
            Coord.cartesian(xmin=0, xmax=1800, ymin=0.0, ymax=1.0),
            Scale.color_discrete_manual("#A5D7D2","#D20537"),
            theme
        )

        draw(PDF("./mainmatter/08-evaluation/figures/index/index-$(i)-adaptiveness-$(r)-no-rebuild.pdf",30cm,20cm),vstack(hstack(count, operations), hstack(speedup, quality)));
    end
end

# With Jitter 10
for i in ["pq","vaf"]
    for r in ["90-10"]

    df = DataFrame(Timestamp = Int32[], Count = Int32[], Insert = Int32[], Delete = Int32[], OOB = Int32[], Rebuild = Bool[], Speedup = Float64[], NDCG = Float64[], Recall = Float64[], Score=Float64[])
    dict = read_json(joinpath("./evaluation/data/index/","index-$(i)-adaptiveness-$(r)-with-rebuild-jitter~measurements.json"))
    for (timestamp, count, insert, delete, oob, rebuild, speedup, ndcg, recall, plan) in zip(dict["timestamp"],dict["count"],dict["insert"], dict["delete"], dict["oob"], dict["rebuilt"], dict["speedup_bf"], dict["dcg"], dict["recall"], dict["plan"])
        push!(df, (timestamp, count, insert, delete, oob, rebuild, speedup, ndcg, recall, plan["second"]))
    end

    rebuild_df = (df |> @filter(_.Rebuild == true) |> DataFrame)[1,:Timestamp]
    count = plot(df, x=:Timestamp,
        layer(xintercept=[rebuild_df], Geom.vline(color=["#46505A"], style=[:dot])),
        layer(y=:Count, Geom.line),
        Guide.xlabel("Elapsed Time [s]"),
        Guide.ylabel("Collection Size"),
        Guide.xticks(ticks=[0, 900, 1800, 2700, 3600, 4800]),
        Coord.cartesian(xmin=0, xmax=5400, ymin=0000000, ymax=5000000),
        Scale.y_continuous(labels=x -> @sprintf("%0.0fM", x / 1000000)),
        theme
    )
    operations = plot(df, x=:Timestamp,
        layer(xintercept=[rebuild_df], Geom.vline(color=["#46505A"], style=[:dot])),
        layer(y=:Insert, Geom.line, color=["Inserts"]),
        layer(y=:Delete, Geom.line,  color=["Deletes"]),
        layer(y=:OOB, Geom.line,  color=["OOB"]),
        Guide.xlabel("Elapsed Time [s]"),
        Guide.ylabel("Operations"),
        Guide.colorkey(title="Type"),
        Guide.xticks(ticks=[0, 900, 1800, 2700, 3600, 4800]),
        Scale.color_discrete_manual("#A5D7D2","#D20537"),
        Scale.y_continuous(labels=x -> @sprintf("%0.0fM", x / 1000000)),
        Coord.cartesian(xmin=0, xmax=4800, ymin=0.0, ymax=4000000),
        theme
    )
    speedup = plot(df, x=:Timestamp, y=:Speedup,
        layer(xintercept=[rebuild_df], Geom.vline(color=["#46505A"], style=[:dot])),
        layer(Geom.line, Stat.smooth(), Theme(default_color="#D20537")),
        layer(Geom.line),
        layer(yintercept=[maximum(df[!,:Speedup])], Geom.hline(color=["#A5D7D2"], style=[:dot])),
        layer(yintercept=[minimum(df[!,:Speedup])], Geom.hline(color=["#A5D7D2"], style=[:dot])),
        Guide.xticks(ticks=[0, 900, 1800, 2700, 3600, 4800]),
        Guide.xlabel("Elapsed Time [s]"),
        Guide.ylabel("Speed-Up [s]"),
        Coord.cartesian(xmin=0, xmax=4800, ymin=-4.0, ymax=4.0),
        theme
    )
    quality = plot(df, x=:Timestamp, 
        layer(xintercept=[rebuild_df], Geom.vline(color=["#46505A"], style=[:dot])),
        layer(y=:NDCG, color=["nDCG"], Geom.line),
        layer(y=:Recall, color=["Recall"], Geom.line),
        layer(yintercept=[maximum(df[!,:Recall])], Geom.hline(color=["#D20537"], style=[:dot])),
        layer(yintercept=[minimum(df[!,:Recall])], Geom.hline(color=["#D20537"], style=[:dot])),
        layer(yintercept=[maximum(df[!,:NDCG])], Geom.hline(color=["#A5D7D2"], style=[:dot])),
        layer(yintercept=[minimum(df[!,:NDCG])], Geom.hline(color=["#A5D7D2"], style=[:dot])),
        Guide.xlabel("Elapsed Time [s]"),
        Guide.ylabel("Quality (NNS)"),
        Guide.colorkey(title="Metric"),
        Guide.xticks(ticks=[0, 900, 1800, 2700, 3600, 4800]),
        Coord.cartesian(xmin=0, xmax=4800, ymin=0.0, ymax=1.0),
        Scale.color_discrete_manual("#A5D7D2","#D20537"),
        theme
    ) 
    draw(PDF("./mainmatter/08-evaluation/figures/index/index-$(i)-adaptiveness-$(r)-with-rebuild-and-jitter.pdf",30cm,20cm),vstack(hstack(count, operations), hstack(speedup, quality)));
end
end