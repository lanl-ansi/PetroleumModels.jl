"""
    parse_file(io)
Parses the IOStream of a file into a Models data structure.
"""
function parse_file(io::IO; filetype::AbstractString="m", validate::Bool = true)
    if filetype == "m"
        pmd_data = PetroleumModels.parse_matpetro(io)
    elseif filetype == "json"
        pmd_data = PetroleumModels.parse_json(io)
    else
        @warn string("only .m and .json files are supported")
    end

    if validate
        correct_network_data!(pmd_data)
    end

    return pmd_data
end


""
function parse_file(file::String; validate::Bool = true)
    pmd_data = open(file) do io
        parse_file(io; filetype = split(lowercase(file), '.')[end], validate = validate)
    end

    return pmd_data
end

"""
    correct_network_data!(data::Dict{String,Any})

Data integrity checks
"""
function correct_network_data!(data::Dict{String,Any})
    make_si_units!(data)
    make_per_unit!(data)
end
