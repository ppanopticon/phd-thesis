
using DataFrames
using Statistics
using Gadfly
using Cairo
using Fontconfig
using Query
using Statistics
using Formatting

include("./load-file.jl");
include("./recall.jl");


# Functions used to load Milvus data
function loadMilvus(name, df)
    dict = read_json(joinpath("./evaluation/data/biganns/milvus","milvus-$name.json"))
    for (collection, value) in dict
        for (type, runtime) in zip(value["type"], value["runtime"])
            push!(df, (uppercase(replace(collection, "yandex_deep" => "")), type, uppercase(replace(name, "milvus-" => "")), "Runtime [s] (w/o loading)", runtime))
        end
        for (type, runtime) in zip(value["type"], value["runtime_with_load"])
            push!(df, (uppercase(replace(collection, "yandex_deep" => "")), type, uppercase(replace(name, "milvus-" => "")), "Runtime [s] (with loading)", runtime))
        end
    end
end

# Load data files
df = DataFrame(Collection = String[], Query = String[], Index = String[], Mode = String[], Runtime = Float64[])
loadMilvus("flat", df)
loadMilvus("ivfsq8-1024", df)
loadMilvus("ivfsq8-2048", df)

# Generate PDFs
for query in ["NNS","Hybrid","NNS + Fetch"]
    nns = df |> 
        @filter(_.Query == query) |>
        @orderby_descending(_.Collection) |>
        @thenby(_.Index) |>
        @groupby({_.Collection,_.Index,_.Mode}) |> 
        @map({
            Collection=key(_).Collection, 
            Index=key(_).Index, 
            Mode=key(_).Mode, 
            LabelPosition=minimum([Statistics.mean(_.Runtime), 200]), 
            RuntimeMean=Statistics.mean(_.Runtime), 
            RuntimeMeanMax=Statistics.mean(_.Runtime)+Statistics.std(_.Runtime), 
            RuntimeMeanMin=Statistics.mean(_.Runtime)+Statistics.std(_.Runtime), 
            Label="$(round(Statistics.mean(_.Runtime), digits=2))±$(round(Statistics.std(_.Runtime), digits=2))"}
        ) |> DataFrame

    p = plot(nns,
        xgroup = :Mode, ygroup=:Collection, x=:RuntimeMean, y=:Index, color = :Mode, label=:Label,
        Geom.subplot_grid(layer(x=:LabelPosition, Geom.label(position = :right)), Geom.bar(position = :dodge, orientation = :horizontal), Guide.xticks(orientation=:vertical)),
        Guide.xlabel(nothing),
        Guide.ylabel(nothing),
        Scale.x_continuous(minvalue = 0.0, maxvalue=300.0),
        Scale.y_discrete,
        Scale.color_discrete_manual("#D2EBE9","#DD879B"),
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

    draw(PDF("./mainmatter/08-evaluation/bignns/figures/milvus/binnns-milvus-$(query).pdf",40cm,18cm),p);
end