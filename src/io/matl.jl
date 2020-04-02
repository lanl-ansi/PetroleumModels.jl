using Printf
"Parses the matpetroleum data from either a filename or an IO object"
function parse_matlab(file::Union{IO, String})
    mlab_data = parse_m_file(file)
    pm_data = matlab_to_petroleummodels(mlab_data)
    return pm_data
end


const mlab_data_names = [
"mgc.rho", "mgc.nu", "mgc.gravitational_acceleration",
 "mgc.standard_density", "mgc.baseQ", "mgc.baseH", "mgc.base_z", "mgc.base_h_loss", "mgc.base_a",
 "mgc.base_b", "mgc.per_unit","mgc.junction", "mgc.pipe", "mgc.pump", "mgc.producer", "mgc.consumer", "mgc.num_steps", "mgc.pump_id", "mgc.time_series"
 # "mgc.time_series"
]

const mlab_junction_columns = [
("junction_i", Int),
("junction_type", Int),
("Hmin", Float64), ("Hmax", Float64),
("H", Float64),
("z", Float64),
("status", Int)
]

const mlab_pipe_columns = [
("pipline_i", Int),
("f_junction", Int),
("t_junction", Int),
("diameter", Float64),
("length", Float64),
("Qmin", Float64),
("Qmax", Float64),
("status", Int)
]

const mlab_ne_pipe_columns = [
("pipline_i", Int),
("f_junction", Int),
("t_junction", Int),
("diameter", Float64),
("length", Float64),
("Qmin", Float64),
("Qmax", Float64),
("status", Int)
]

const mlab_pump_columns = [
("pump_i", Int),
("f_junction", Int),
("t_junction", Int),
("station_i", Int),
("a", Float64),
("b", Float64),
("q_nom", Float64),
("delta_Hmax", Float64), ("delta_Hmin", Float64),
("min_pump_efficiency", Float64),
("max_pump_efficiency", Float64),
("w_nom", Float64),
("min_w", Float64),
("max_w", Float64),
("electricity_price", Float64),
("status", Int)
]

const mlab_ne_pump_columns = [
("pump_i", Int),
("f_junction", Int),
("t_junction", Int),
("station_i", Int),
("a", Float64),
("b", Float64),
("q_nom", Float64),
("delta_Hmax", Float64), ("delta_Hmin", Float64),
("min_pump_efficiency", Float64),
("max_pump_efficiency", Float64),
("w_nom", Float64),
("min_w", Float64),
("max_w", Float64),
("electricity_price", Float64),
("status", Int)
]


const mlab_producer_columns = [
("producer_i", Int),
("junction", Int),
("qgmin", Float64),
("qgmax", Float64),
("qg", Float64),
("status", Int),
("dispatchable", Int),
("price", Float64)
]

const mlab_consumer_columns = [
("consumer_i", Int),
("junction", Int),
("qlmin", Float64),
("qlmax", Float64),
("ql", Float64),
("status", Float64),
("dispatchable", Int),
("price", Float64)
]

const mlab_time_series_columns = [
("electricity_price", Float64)
]


"parses matlab-formatted .m file"
function parse_m_file(file_string::String)
    mlab_data = open(file_string) do io
        parse_m_file(io)
    end

    return mlab_data
end


"parses matlab-formatted .m file"
function parse_m_file(io::IO)
    data_string = read(io, String)

    return parse_m_string(data_string)
end


"parses matlab-format string"
function parse_m_string(data_string::String)
    matlab_data, func_name, colnames = InfrastructureModels.parse_matlab_string(data_string, extended=true)

    case = Dict{String,Any}()

    if func_name != nothing
        case["name"] = func_name
    else
        @warn string("no case name found in .m file.  The file seems to be missing \"function mgc = ...\"")
        case["name"] = "no_name_found"
    end

    case["source_type"] = ".m"
    if haskey(matlab_data, "mgc.version")
        case["source_version"] = VersionNumber(matlab_data["mgc.version"])
    else
        @warn string( "no case version found in .m file.  The file seems to be missing \"mgc.version = ...\"")
        case["source_version"] = "0.0.0+"
    end

    required_metadata_names = [
    "mgc.rho",
    "mgc.nu",
    "mgc.gravitational_acceleration",
    "mgc.standard_density"]

    optional_metadata_names = [
    "mgc.baseH", "mgc.base_z",
    "mgc.base_h_loss", "mgc.base_a",
    "mgc.base_b", "mgc.baseQ", "mgc.per_unit"]

    for data_name in required_metadata_names
        (data_name == "mgc.units") && (continue)
        if haskey(matlab_data, data_name)
            case[data_name[5:end]] = matlab_data[data_name]
        else
            error( string("no $constant found in .m file"))
        end
    end



    # handling optional meta data names
    if haskey(matlab_data, "mgc.baseH")
        case["baseH"] = matlab_data["mgc.baseH"]
    else
        @warn string( string("no baseH found in .m file.
            This value will be auto-assigned based on the head limits provided in the data"))
    end

    if haskey(matlab_data, "mgc.baseQ")
        case["baseQ"] = matlab_data["mgc.baseQ"]
    else
        @warn string( string("no baseQ found in .m file.
            This value will be auto-assigned based on the pipe data"))
    end

    if haskey(matlab_data, "mgc.per_unit")
        case["per_unit"] = matlab_data["mgc.per_unit"]
    else
        @warn string( string("no per_unit found in .m file.
            Auto assigning a value of 0 (false) for the per_unit field"))
        case["per_unit"] = 0
    end

    if haskey(matlab_data, "mgc.base_z")
        case["base_z"] = matlab_data["mgc.base_z"]
    else
        @warn string("no base_z found in .m file.
            The file seems to be missing \"mgc.base_z = ...\" \n")
    end


    if haskey(matlab_data, "mgc.base_h_loss")
        case["base_h_loss"] = matlab_data["mgc.base_h_loss"]
    else
        @warn string("no base_h_loss found in .m file.
            The file seems to be missing \"mgc.base_h_loss = ...\" \n")
    end


    if haskey(matlab_data, "mgc.base_a")
        case["base_a"] = matlab_data["mgc.base_a"]
    else
        @warn string("no base_a found in .m file.
            The file seems to be missing \"mgc.base_a = ...\" \n")
    end

    if haskey(matlab_data, "mgc.base_b")
        case["base_b"] = matlab_data["mgc.base_b"]
    else
        @warn string("no base_b found in .m file.
            The file seems to be missing \"mgc.base_b = ...\" \n")
    end

    if haskey(matlab_data, "mgc.junction")
        junctions = []
        for junction_row in matlab_data["mgc.junction"]
            junction_data = InfrastructureModels.row_to_typed_dict(junction_row, mlab_junction_columns)
            junction_data["index"] = InfrastructureModels.check_type(Int, junction_row[1])
            push!(junctions, junction_data)
        end
        case["junction"] = junctions
    else
        error( string("no junction table found in .m file.
            The file seems to be missing \"mgc.junction = [...];\""))
    end

    if haskey(matlab_data, "mgc.pipe")
        pipes = []
        for pipe_row in matlab_data["mgc.pipe"]
            pipe_data = InfrastructureModels.row_to_typed_dict(pipe_row, mlab_pipe_columns)
            pipe_data["index"] = InfrastructureModels.check_type(Int, pipe_row[1])
            push!(pipes, pipe_data)
        end
        case["pipe"] = pipes
    else
        error( string("no pipe table found in .m file.
            The file seems to be missing \"mgc.pipe = [...];\""))
    end

    if haskey(matlab_data, "mgc.ne_pipe")
        ne_pipes = []
        for pipe_row in matlab_data["mgc.ne_pipe"]
            pipe_data = InfrastructureModels.row_to_typed_dict(pipe_row, mlab_ne_pipe_columns)
            pipe_data["index"] = InfrastructureModels.check_type(Int, pipe_row[1])
            push!(ne_pipes, pipe_data)
        end
        case["ne_pipe"] = ne_pipes
    end

    if haskey(matlab_data, "mgc.pump")
        pumps = []
        for pump_row in matlab_data["mgc.pump"]
            pump_data = InfrastructureModels.row_to_typed_dict(pump_row, mlab_pump_columns)
            pump_data["index"] = InfrastructureModels.check_type(Int, pump_row[1])
            push!(pumps, pump_data)
        end
        case["pump"] = pumps
    else
        error( string("no pump table found in .m file.
            The file seems to be missing \"mgc.pump = [...];\""))
    end

    if haskey(matlab_data, "mgc.ne_pump")
        ne_pumps = []
        for pump_row in matlab_data["mgc.ne_pump"]
            pump_data = InfrastructureModels.row_to_typed_dict(pump_row, mlab_ne_pump_columns)
            pump_data["index"] = InfrastructureModels.check_type(Int, pump_row[1])
            push!(ne_pumps, pump_data)
        end
        case["ne_pump"] = ne_pumps
    end



    if haskey(matlab_data, "mgc.producer")
        producers = []
        for producer_row in matlab_data["mgc.producer"]
            producer_data = InfrastructureModels.row_to_typed_dict(producer_row, mlab_producer_columns)
            producer_data["index"] = InfrastructureModels.check_type(Int, producer_row[1])
            push!(producers, producer_data)
        end
        case["producer"] = producers
    end

    if haskey(matlab_data, "mgc.consumer")
        consumers = []
        for consumer_row in matlab_data["mgc.consumer"]
            consumer_data = InfrastructureModels.row_to_typed_dict(consumer_row, mlab_consumer_columns)
            consumer_data["index"] = InfrastructureModels.check_type(Int, consumer_row[1])
            push!(consumers, consumer_data)
        end
        case["consumer"] = consumers
    end

    if haskey(matlab_data, "mgc.num_steps")
        case["num_steps"] = matlab_data["mgc.num_steps"]
    else
        @warn string("no num_steps found in .m file.
            The file seems to be missing \"mgc.num_steps = ...\" ")
    end

    if haskey(matlab_data, "mgc.pump_id")
        case["pump_id"] = matlab_data["mgc.pump_id"]
    else
        @warn string("no pump_id found in .m file.
            The file seems to be missing \"mgc.pump_id = ...\" ")
    end

    if haskey(matlab_data, "mgc.time_series")
        pumps = []
        electricity_prices = []
        for time_series_row in matlab_data["mgc.time_series"]
            time_series_data = InfrastructureModels.row_to_typed_dict(time_series_row, mlab_time_series_columns)
            time_series_data["index"] = InfrastructureModels.check_type(Float64, time_series_row[1])
            push!(pumps, time_series_data)
            push!(electricity_prices, time_series_data["electricity_price"])
            #=
            consumer_prices = Dict{String,Any}()
            consumer_prices[id] = [9, 9 , 9, 9]
            =#
        end
        id = string(case["pump_id"])
        case["time_series"]  = Dict("num_steps" => case["num_steps"],
        "pump"=> Dict( id => Dict("electricity_price" => electricity_prices)))
        # "consumer"=> Dict( id => Dict("price" => prices) for (id, prices) in consumer_prices))
    end


    for k in keys(matlab_data)
        if !in(k, mlab_data_names) && startswith(k, "mgc.")
            case_name = k[5:length(k)]
            value = matlab_data[k]
            if isa(value, Array)
                column_names = []
                if haskey(colnames, k)
                    column_names = colnames[k]
                end
                tbl = []
                for (i, row) in enumerate(matlab_data[k])
                    row_data = InfrastructureModels.row_to_dict(row, column_names)
                    row_data["index"] = i
                    push!(tbl, row_data)
                end
                case[case_name] = tbl
                @info "extending matlab format with data: $(case_name) $(length(tbl))x$(length(tbl[1])-1)"
            else
                case[case_name] = value
                @info "extending matlab format with constant data: $(case_name)"
            end
        end
    end

    return case
end


"Converts a matpetroleum dict into a PowerModels dict"
function matlab_to_petroleummodels(mlab_data::Dict{String,Any})
    pm_data = deepcopy(mlab_data)

    if !haskey(pm_data, "multinetwork")
        pm_data["multinetwork"] = false
    end
    mlab2gm_producer(pm_data)
    mlab2gm_consumer(pm_data)
    mlab2gm_connection(pm_data)
    # translate component models
    _merge_generic_data!(pm_data)

    # use once available
    InfrastructureModels.arrays_to_dicts!(pm_data)

    return pm_data
end
"adds the volumetric firm and flexible flows for the producers"
function mlab2gm_producer(data::Dict{String,Any})
    producers = [producer for producer in data["producer"]]
    for producer in producers
        producer["qg_junc"] = producer["junction"]

    end
end
function mlab2gm_consumer(data::Dict{String,Any})
    consumers = [consumer for consumer in data["consumer"]]
    for consumer in consumers
        consumer["ql_junc"] = consumer["junction"]
    end
end

    "merges pipes and pumps to connections"

    function mlab2gm_connection(data::Dict{String,Any})
        pumps = [pump for pump in data["pump"]]
        for pump in pumps
            pump["qmin"] = pump["q_nom"] * 0.8
            pump["qmax"] = pump["q_nom"] * 1.2
            # delete!(pump, "Q_nom")
        end
    end

"merges Matlab tables based on the table extension syntax"
function _merge_generic_data!(data::Dict{String,Any})
    mg_matrix_names = [name[5:length(name)] for name in mlab_data_names]

    key_to_delete = []
    for (k,v) in data
        if isa(v, Array)
            for mg_name in mg_matrix_names
                if startswith(k, "$(mg_name)_")
                    mg_matrix = data[mg_name]
                    push!(key_to_delete, k)

                    if length(mg_matrix) != length(v)
                        error("failed to extend the matlab matrix \"$(mg_name)\" with the matrix \"$(k)\" because they do not have the same number of rows, $(length(mg_matrix)) and $(length(v)) respectively.")
                    end

                    @info "extending matlab format by appending matrix \"$(k)\" in to \"$(mg_name)\""

                    for (i, row) in enumerate(mg_matrix)
                        merge_row = v[i]
                        delete!(merge_row, "index")
                        for key in keys(merge_row)
                            if haskey(row, key)
                                error( "failed to extend the matlab matrix \"$(mg_name)\" with the matrix \"$(k)\" because they both share \"$(key)\" as a column name.")
                            end
                            row[key] = merge_row[key]
                        end
                    end

                    break # out of mg_matrix_names loop
                end
            end

        end
    end

    for key in key_to_delete
        delete!(data, key)
    end
end


"Get a default value for dict entry"
function _get_default(dict, key, default=0.0)
    if haskey(dict, key) && dict[key] != NaN
        return dict[key]
    end
    return default
end


"order data types should appear in matlab format"
const _matlab_data_order = ["junction", "pipe", "pump", "ne_pipe", "ne_pump"]


"order data fields should appear in matlab format"
const _matlab_field_order = Dict{String,Array}(
    "junction"                   => [key for (key, dtype) in mlab_junction_columns],
    "pipe"                       => [key for (key, dtype) in mlab_pipe_columns],
    "pump"                       => [key for (key, dtype) in mlab_pump_columns],
    "producer"                   => [key for (key, dtype) in mlab_producer_columns],
    "consumer"                   => [key for (key, dtype) in mlab_consumer_columns],
    "time_series"                => [key for (key, dtype) in mlab_time_series_columns],
    "ne_pipe"                    => [key for (key, dtype) in mlab_ne_pipe_columns],
    "ne_pump"                    => [key for (key, dtype) in mlab_ne_pump_columns]
)


"order of required global parameters"
const _matlab_global_params_order_required = [
"rho",
"nu",
"gravitational_acceleration",
"standard_density"]

const _matlab_global_params_order_optional = ["baseH", "base_z",
"base_h_loss", "base_a",
"base_b", "baseQ", "per_unit"]



# const non_negative_metadata = [
#     "petroleum_specific_gravity", "specific_heat_capacity_ratio",
#     "temperature", "sound_speed", "compressibility_factor"
# ]

# const non_negative_data = Dict{String,Vector{String}}(
#     "junction" => ["p_min", "p_max", "p_nominal"],
#     "pipe" => ["diameter", "length", "friction_factor", "p_min", "p_max"],
#     "pump" => ["c_ratio_min", "c_ratio_max", "power_max", "flow_max",
#         "inlet_p_min", "inlet_p_max", "outlet_p_min", "outlet_p_max", "operating_cost"],
#
#     "producer" => ["injection_min", "injection_max", "injection_nominal"],
#     "consumer" => ["withdrawal_min", "withdrawal_max", "withdrawal_nominal"],
#     "storage" => ["pressure_nominal", "flow_injection_rate_min", "flow_injection_rate_max",
#         "flow_withdrawal_rate_min", "flow_withdrawal_rate_max", "capacity"]
# )


"write to matpetroleum"
function _petroleummodels_to_matpetroleum_string(data::Dict{String,Any}; units::String="si", include_extended::Bool=false)::String
    # (data["is_english_units"] == true) && (units = "usc")
    lines = ["function mgc = $(replace(data["name"], " " => "_"))", ""]

    push!(lines, "%% required global data")
    for param in _matlab_global_params_order_required
        if isa(data[param], Float64)
            line = Printf.@sprintf "mgc.%s = %.4f;" param data[param]
        else
            line = "mgc.$(param) = $(data[param]);"
        end
        if haskey(_units[units], param)
            line = "$line  % $(_units[units][param])"
        end

        push!(lines, line)
    end
    push!(lines, "mgc.units = \'$units\';")
    push!(lines, "")

    push!(lines, "%% optional global data (that was either provided or computed based on required global data)")
    for param in _matlab_global_params_order_optional
        if isa(data[param], Float64)
            line = Printf.@sprintf "mgc.%s = %.4f;" param data[param]
        else
            line = "mgc.$(param) = $(data[param]);"
        end
        if haskey(_units[units], param)
            line = "$line  % $(_units[units][param])"
        end

        push!(lines, line)
    end
    push!(lines, "")

    for data_type in _matlab_data_order
        if haskey(data, data_type)
            push!(lines, "%% $data_type data")
            fields_header = []
            for field in _matlab_field_order[data_type]
                idxs = [parse(Int, i) for i in keys(data[data_type])]
                if !isempty(idxs)
                    check_id = idxs[1]
                    if haskey(data[data_type]["$check_id"], field)
                        push!(fields_header, field)
                    end
                end
            end
            push!(lines, "% $(join(fields_header, "\t"))")

            push!(lines, "mgc.$data_type = [")
            idxs = [parse(Int, i) for i in keys(data[data_type])]
            if !isempty(idxs)
                for i in sort(idxs)
                    entries = []
                    for field in fields_header
                        if haskey(data[data_type]["$i"], field)
                            if isa(data[data_type]["$i"][field], Union{String, SubString{String}})
                                push!(entries, "\'$(data[data_type]["$i"][field])\'")
                            elseif isa(data[data_type]["$i"][field], Float64)
                                push!(entries, Printf.@sprintf "%.4f" data[data_type]["$i"][field])
                            else
                                push!(entries, "$(data[data_type]["$i"][field])")
                            end
                        end
                    end
                    push!(lines, "$(join(entries, "\t"))")
                end
            end
            push!(lines, "];\n")
        end
    end

    if include_extended
        for data_type in _matlab_data_order
            if haskey(data, data_type)
                all_ext_cols = Set([col for item in values(data[data_type]) for col in keys(item) if !(col in _matlab_field_order[data_type])])
                common_ext_cols = [col for col in all_ext_cols if all(col in keys(item) for item in values(data[data_type]))]

                if !isempty(common_ext_cols)
                    push!(lines, "%% $data_type data (extended)")
                    push!(lines, "%column_names% $(join(common_ext_cols, "\t"))")
                    push!(lines, "mgc.$(data_type)_data = [")
                    for i in sort([parse(Int, i) for i in keys(data[data_type])])
                        push!(lines, "\t$(join([data[data_type]["$i"][col] for col in sort(common_ext_cols)], "\t"))")
                    end
                    push!(lines, "];\n")
                end
            end
        end
    end

    push!(lines, "end\n")

    return join(lines, "\n")
end


"writes data structure to matlab format"
function write_matpetroleum!(data::Dict{String,Any}, fileout::String; units::String="si", include_extended::Bool=false)
    if haskey(data, "original_pipe")
        data["new_pipe"] = deepcopy(data["pipe"])
        data["pipe"] = deepcopy(data["original_pipe"])
        delete!(data, "original_pipe")
    end
    if haskey(data, "original_junction")
        data["new_junction"] = deepcopy(data["junction"])
        data["junction"] = deepcopy(data["original_junction"])
        delete!(data, "original_junction")
    end

    open(fileout, "w") do f
        write(f, _petroleummodels_to_matpetroleum_string(data; units=units, include_extended=include_extended))
    end

    if haskey(data, "new_pipe")
        data["original_pipe"] = deepcopy(data["pipe"])
        data["pipe"] = deepcopy(data["new_pipe"])
        delete!(data, "new_pipe")
    end
    if haskey(data, "new_junction")
        data["original_junction"] = deepcopy(data["junction"])
        data["junction"] = deepcopy(data["new_junction"])
        delete!(data, "new_junction")
    end
end
