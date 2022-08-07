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
plans = Dict([
    (301251082736639032, "P1: ScanIndex[PQ,feature,L2]"), 
    (183418504497291366, "P2: ScanEntity[feature]"),
    (74604402737375334, "P3: ScanEntity[id,feature]"), 
    
    # Range
    (4817430002262786335, "P1: ScanIndex[PQ,feature,L2]"), 
    (-2208122050355648033, "P2: ScanIndex[PQ,feature,L2]"),
    (4817477855857574525, "P3: ScanIndex[PQ,feature,L2]"), 
    (8744637559034823793, "P4: ScanEntity[feature]"), 
    (-8427985728988109811, "P5: ScanEntity[feature]"), 
    (1486491801562255110, "P6: ScanEntity[id,feature]"),


    # NNS
    (-4320830370914670928, "P1: ScanIndex[PQ,feature,L2]"), 
    (4824833675157418254, "P2: ScanIndex[PQ,feature,L2]"),
    (5729011964148328198, "P3: ScanIndex[VAF,feature,L2]"), 
    (-4879747946231347746, "P4: ScanEntity[feature]"), 
    (8752041231929455712, "P5: ScanEntity[feature]")
])

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
    point_size=6pt,
    key_position=:none
)


df = DataFrame(Digest = Int64[],  Score = Float64[], Rank = Int32[], Plan = String[], Query = String[], Entity = String[], CPUW = Float64[], IOW = Float64[], QW = Float64[], PERF = Float64[])
dict = read_json(joinpath("./evaluation/data/analytics/","cost-model.json"))
for (digest, score, rank, plan, query, entity, cpu, io, quality) in zip(dict["digest"], dict["score"], dict["rank"], dict["plan"], dict["query"], dict["entity"], dict["cpu"], dict["io"], dict["quality"])
    push!(df, (digest, score, rank, get(plans, digest, plan), query, entity, cpu, io, quality, cpu + io))
end

data1 = df |> @filter(_.Query == "Mean"  && _.CPUW == 0.3 && _.IOW  == 0.6 && _.Rank <= 3) |> DataFrame

p1 = plot(data1, x=:QW, color = :Plan, y=:Score, Geom.smooth,
    Scale.color_discrete_manual("#A5D7D2","#D20537","#2D373C","#D2EBE9","#DD879B","#46505A"),
    Guide.xlabel("wQ"),
    theme
)

p2 = plot(data1, x=:QW, color = :Plan, y=:Rank, Geom.point,
    Scale.color_discrete_manual("#A5D7D2","#D20537","#2D373C","#D2EBE9","#DD879B","#46505A"),
    Guide.xlabel("wQ"),
    Scale.y_discrete,
    theme
)


data2= df |> @filter(_.Query == "Range" && _.CPUW == 0.3 && _.IOW  == 0.6 && _.Rank <= 3) |> DataFrame

p3 = plot(data2, x=:QW, color = :Plan, y=:Score, Geom.line,
    Scale.color_discrete_manual("#A5D7D2","#D20537","#2D373C","#D2EBE9","#DD879B","#46505A"),
    Guide.xlabel("wQ"),
    theme
)

p4 = plot(data2, x=:QW, color = :Plan, y=:Rank, Geom.point,
    Scale.color_discrete_manual("#A5D7D2","#D20537","#2D373C","#D2EBE9","#DD879B","#46505A"),
    Guide.xlabel("wQ"),
    Scale.y_discrete,
    theme
)

data3 = df |> @filter(_.Query == "NNS" && _.CPUW == 0.3 && _.IOW  == 0.6 && _.Rank <= 3) |> DataFrame

p5 = plot(data3, x=:QW, color = :Plan, y=:Score, Geom.line,
    Scale.color_discrete_manual("#A5D7D2","#D20537","#2D373C","#D2EBE9","#DD879B","#46505A"),
    Guide.xlabel("wQ"),
    theme
)

p6 = plot(data3, x=:QW, color = :Plan, y=:Rank, Geom.point,
    Scale.color_discrete_manual("#A5D7D2","#D20537","#2D373C","#D2EBE9","#DD879B","#46505A"),
    Guide.xlabel("wQ"),
    Scale.y_discrete,
    theme
)

draw(PDF("./mainmatter/08-evaluation/figures/analytics/analytics-cottontail-cost-mean.pdf",28cm,10cm),hstack(p1,p2));
draw(PDF("./mainmatter/08-evaluation/figures/analytics/analytics-cottontail-cost-range.pdf",28cm,12cm),hstack(p3,p4));
draw(PDF("./mainmatter/08-evaluation/figures/analytics/analytics-cottontail-cost-nns.pdf",28cm,11cm),hstack(p5,p6));