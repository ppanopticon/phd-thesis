
using DataFrames
using Statistics
using Gadfly
using Cairo
using Fontconfig
using Query
using Statistics
using Formatting
using Printf

include("./load-file.jl");
include("./recall.jl");


# Functions used to load Milvus data
function loadData(df, name)
    dict = read_json("./evaluation/data/quality/$(name)-quality.json")
    i = 0
    for (level, recall, ndcg) in zip(dict["level"], dict["recall"], dict["ndcg"])
        i += 1
        push!(df, (i, level, recall, ndcg))
    end
end

# Load data files
df1 = DataFrame(I = Int32[], Level = Int32[], Recall = Float64[], NDCG = Float64[])
loadData(df1, "pq")

df2 = DataFrame(I = Int32[], Level = Int32[], Recall = Float64[], NDCG = Float64[])
loadData(df2, "ivfpq")

# Generate PDFs
df1 = df1 |> @groupby({_.Level}) |> 
    @map({
        Level=key(_).Level, 
        MeanRecall=Statistics.mean(_.Recall), 
        MaxRecall=maximum(_.Recall), 
        MinRecall=minimum(_.Recall),
        StdRecall=Statistics.std(_.Recall),
        MeanNDCG=Statistics.mean(_.NDCG), 
        MaxNDCG=maximum(_.NDCG), 
        MinNDCG=minimum(_.NDCG),
        StdNDCG=Statistics.std(_.NDCG)
    }) |> DataFrame

df2 = df2 |> @groupby({_.Level}) |> 
    @map({
        Level=key(_).Level, 
        MeanRecall=Statistics.mean(_.Recall), 
        MaxRecall=maximum(_.Recall), 
        MinRecall=minimum(_.Recall),
        StdRecall=Statistics.std(_.Recall),
        MeanNDCG=Statistics.mean(_.NDCG), 
        MaxNDCG=maximum(_.NDCG), 
        MinNDCG=minimum(_.NDCG),
        StdNDCG=Statistics.std(_.NDCG)
    }) |> DataFrame

p1 = plot(df1,
        x=:Level,
        layer(y=:MeanRecall,  color=[1], Geom.line),
        layer(ymin=:MinRecall, ymax=:MaxRecall, color=[2],  Geom.ribbon),
    
        Guide.xlabel("Level"),
        Guide.ylabel("Recall"),
        Guide.xticks(orientation = :vertical),
        Scale.x_log2(labels=d->@sprintf("%d", 2^d)),
        Scale.color_discrete_manual("#DD879B", "#D2EBE9"),
        Theme(
            major_label_font="Helvetica Neue Bold",
            major_label_font_size=20pt, 
            minor_label_font="Helvetica Neue",
            minor_label_font_size=18pt, 
            point_label_font="Helvetica Neue Light",
            point_label_font_size=16pt, 
            bar_spacing=1mm, 
            key_position=:none
        )
    )

p2 = plot(df1,
    x=:Level,
    layer(y=:MeanNDCG, color=[1], Geom.line),
    layer(ymin=:MinNDCG, ymax=:MaxNDCG, color=[2], Geom.ribbon),

    Guide.xlabel("Level"),
    Guide.ylabel("nDCG"),
    Guide.xticks(orientation = :vertical),
    Scale.x_log2(labels=d->@sprintf("%d", 2^d)),
    Scale.color_discrete_manual("#DD879B", "#D2EBE9"),
    Theme(
        major_label_font="Helvetica Neue Bold",
        major_label_font_size=20pt, 
        minor_label_font="Helvetica Neue",
        minor_label_font_size=18pt, 
        point_label_font="Helvetica Neue Light",
        point_label_font_size=16pt, 
        bar_spacing=1mm, 
        key_position=:none
    )
)

p3 = plot(df2,
        x=:Level,
        layer(y=:MeanRecall,  color=[1], Geom.line),
        layer(ymin=:MinRecall, ymax=:MaxRecall, color=[2],  Geom.ribbon),
    
        Guide.xlabel("Level"),
        Guide.ylabel("Recall"),
        Guide.xticks(orientation = :vertical),
        Scale.x_log2(labels=d->@sprintf("%d", 2^d)),
        Scale.color_discrete_manual("#DD879B", "#D2EBE9"),
        Theme(
            major_label_font="Helvetica Neue Bold",
            major_label_font_size=20pt, 
            minor_label_font="Helvetica Neue",
            minor_label_font_size=18pt, 
            point_label_font="Helvetica Neue Light",
            point_label_font_size=16pt, 
            bar_spacing=1mm, 
            key_position=:none
        )
    )

p4 = plot(df2,
    x=:Level,
    layer(y=:MeanNDCG, color=[1], Geom.line),
    layer(ymin=:MinNDCG, ymax=:MaxNDCG, color=[2], Geom.ribbon),

    Guide.xlabel("Level"),
    Guide.ylabel("nDCG"),
    Guide.xticks(orientation = :vertical),
    Scale.x_log2(labels=d->@sprintf("%d", 2^d)),
    Scale.color_discrete_manual("#DD879B", "#D2EBE9"),
    Theme(
        major_label_font="Helvetica Neue Bold",
        major_label_font_size=20pt, 
        minor_label_font="Helvetica Neue",
        minor_label_font_size=18pt, 
        point_label_font="Helvetica Neue Light",
        point_label_font_size=16pt, 
        bar_spacing=1mm, 
        key_position=:none
    )
)

draw(PDF("./mainmatter/06-systemmodel/figures/index-quality-pq.pdf",21cm,10cm),hstack(p1, p2));
draw(PDF("./mainmatter/06-systemmodel/figures/index-quality-ivfpq.pdf",21cm,10cm),hstack(p3, p4));
