"""
    parse_file(io)
Parses the IOStream of a file into a Models data structure.
"""
function parse_file(io::IO; filetype::AbstractString="m")
    if filetype == "m"
        pmd_data = PetroleumModels.parse_matlab(io)
    elseif filetype == "json"
        pmd_data = PetroleumModels.parse_json(io)
    else
        @warn string("only .m and .json files are supported")
    end

    correct_network_data!(pmd_data)

    return pmd_data
end


# Generic function for parsing a file based on an extension
function parse_file(file)
  if endswith(file, ".m")
    pm_data = parse_matlab(file)
  else
    pm_data = parse_json(file)
  end
  check_network_data(pm_data)

  return pm_data
end

""
function check_network_data(data::Dict{String,Any})
    make_per_unit!(data)
end
