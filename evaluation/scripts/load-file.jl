import JSON
function read_json(file)
    open(file, "r") do f
        global inDict
        return JSON.parse(f)
    end
end