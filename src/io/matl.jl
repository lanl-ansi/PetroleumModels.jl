"Parses the matpetroleum data from either a filename or an IO object"
function parse_matlab(file::Union{IO, String})
    mp_data = parse_m_file(file)
    pm_data = _matpetroleum_to_petroleummodels(mp_data)
    return pm_data
end

const _mlab_data_names = Vector{String}([
    "mpc.density",
    "mpc.viscosity",
    "mpc.gravitational_acceleration",
    "mpc.base_density",
    "mpc.base_viscosity",
    "mpc.base_diameter",
    "mpc.base_length",
    "mpc.base_flow",
    "mpc.base_head",
    "mpc.units",
    "mpc.is_per_unit",
    "mpc.junction",
    "mpc.pipe",
    "mpc.pump",
    "mpc.producer",
    "mpc.consumer",
    "mpc.tank",
    "mpc.time_step",
    "mpc.base_energy"
])

const _mlab_junction_columns = Vector{Tuple{String,Type}}([
    ("id", Int),
    ("junction_type", Int),
    ("head_min", Float64),
    ("head_max", Float64),
    ("elevation", Float64),
    ("status", Int)
])

const _mlab_pipe_columns =  Vector{Tuple{String,Type}}([
    ("pipline_i", Int),
    ("fr_junction", Int),
    ("to_junction", Int),
    ("diameter", Float64),
    ("length", Float64),
    ("flow_min", Float64),
    ("flow_max", Float64),
    ("friction_factor", Float64),
    ("status", Int)
])


const _mlab_pump_columns =  Vector{Tuple{String,Type}}([
    ("pump_i", Int),
    ("fr_junction", Int),
    ("to_junction", Int),
    ("station_i", Int),
    ("rotation_coefficient", Float64),
    ("flow_coefficient", Float64),
    ("flow_nom", Float64),
    ("flow_max", Float64),
    ("delta_head_min", Float64),
    ("delta_head_max", Float64),
    ("pump_efficiency_min", Float64),
    ("pump_efficiency_max", Float64),
    ("rotation_nom", Float64),
    ("rotation_min", Float64),
    ("rotation_max", Float64),
    ("electricity_price", Float64),
    ("status", Int),
    ("electric_motor_efficiency", Float64),
    ("mechanical_transmission_efficiency", Float64)
])


const _mlab_producer_columns =  Vector{Tuple{String,Type}}([
    ("producer_i", Int),
    ("junction_id", Int),
    ("injection_min", Float64),
    ("injection_max", Float64),
    ("injection_nominal", Float64),
    ("status", Int),
    ("is_dispatchable", Int),
    ("offer_price", Float64)
])

const _mlab_consumer_columns =  Vector{Tuple{String,Type}}([
    ("consumer_i", Int),
    ("junction_id", Int),
    ("withdrawal_min", Float64),
    ("withdrawal_max", Float64),
    ("withdrawal_nominal", Float64),
    ("status", Float64),
    ("is_dispatchable", Int),
    ("bid_price", Float64)
])

const _mlab_time_series_columns =  Vector{Tuple{String,Type}}([
    ("consumer_price", Float64),
    ("producer_price", Float64)
])

const _mlab_tank_columns =  Vector{Tuple{String,Type}}([
    ("tank_i", Int),
    ("fr_junction", Int),
    ("to_junction", Int),
    ("vessel_pressure_head", Float64),
    ("radius", Float64),
    ("capacity_min", Float64),
    ("capacity_max", Float64),
    ("initial_volume", Float64),
    ("intake_min", Float64),
    ("intake_max", Float64),
    ("offtake_min", Float64),
    ("offtake_max", Float64),
    ("Cd", Float64),
    ("status", Int),
    ("price", Float64),
    ("p_price", Float64)
])


const _mlab_dtype_lookup = Dict{String,Dict{String,Type}}(
    "mpc.junction" => Dict{String,Type}(_mlab_junction_columns),
    "mpc.pipe" => Dict{String,Type}(_mlab_pipe_columns),
    "mpc.pump" => Dict{String,Type}(_mlab_pump_columns),
    "mpc.producer" => Dict{String,Type}(_mlab_producer_columns),
    "mpc.consumer" => Dict{String,Type}(_mlab_consumer_columns),
    "mpc.tank" => Dict{String,Type}(_mlab_tank_columns),
)


"parses matlab-formatted .m file"
function parse_m_file(file_string::String)
    mp_data = open(file_string) do io
        parse_m_file(io)
    end

    return mp_data
end


"parses matlab-formatted .m file"
function parse_m_file(io::IO)
    data_string = read(io, String)

    return parse_m_string(data_string)
end


"parses matlab-format string"
function parse_m_string(data_string::String)
    matlab_data, func_name, colnames = _IM.parse_matlab_string(data_string, extended=true)


    _colnames = Dict{String,Vector{Tuple{String,Type}}}()
    for (component_type, cols) in colnames
        _colnames[component_type] = Vector{Tuple{String,Type}}([])
        for col in cols
            dtype = get(get(_mlab_dtype_lookup, component_type, Dict{String,Type}()), col, SubString{String})
            push!(_colnames[component_type], (col, dtype))
        end
    end

    case = Dict{String,Any}()

    if func_name != nothing
        case["name"] = func_name
    else
        Memento.warn(_LOGGER,"no case name found in .m file.  The file seems to be missing \"function mpc = ...\"")
        case["name"] = "no_name_found"
    end

    case["source_type"] = ".m"
    if haskey(matlab_data, "mpc.version")
        case["source_version"] = VersionNumber(matlab_data["mpc.version"])
    else
        Memento.warn(_LOGGER, "no case version found in .m file.  The file seems to be missing \"mpc.version = ...\"")
        case["source_version"] = "0.0.0+"
    end

    required_metadata_names = [
        "mpc.density",
        "mpc.viscosity",
        "mpc.gravitational_acceleration",
        "mpc.units",
        "mpc.time_step",
        "mpc.base_energy"
    ]

    optional_metadata_names = [
        "mpc.base_density",
        "mpc.base_viscosity",
        "mpc.base_diameter",
        "mpc.base_length",
        "mpc.base_head",
        "mpc.base_flow",
        "mpc.is_per_unit"
    ]

    for data_name in required_metadata_names
        (data_name == "mpc.units") && (continue)
        if haskey(matlab_data, data_name)
            case[data_name[5:end]] = matlab_data[data_name]
        else
            @show data_name
            Memento.error(_LOGGER, string("no $constant found in .m file"))
        end
    end

    if haskey(matlab_data, "mpc.units")
        case["units"] = matlab_data["mpc.units"]
        if matlab_data["mpc.units"] == "si"
            case["is_si_units"] = 1
            case["is_english_units"] = 0
        elseif matlab_data["mpc.units"] == "usc"
            case["is_english_units"] = 1
            case["is_si_units"] = 0
        else
            Memento.error(_LOGGER, string("the possible values for units field in .m file are \"si\" or \"usc\""))
        end
    else
        Memento.error(_LOGGER, string("no units field found in .m file.
        The file seems to be missing \"mpc.units = ...;\" \n
        Possible values are 1 (SI) or 2 (English units)"))
    end

    # handling optional meta data names
    if haskey(matlab_data, "mpc.base_head")
        case["base_head"] = matlab_data["mpc.base_head"]
    else
        Memento.warn(_LOGGER, string("no base_head found in .m file.
            This value will be auto-assigned based on the head limits provided in the data"))
    end

    if haskey(matlab_data, "mpc.base_length")
        case["base_length"] = matlab_data["mpc.base_length"]
    else
        Memento.warn(_LOGGER, string("no base_length found in .m file.
            This value will be auto-assigned based on the head limits provided in the data"))
    end

    if haskey(matlab_data, "mpc.base_density")
        case["base_density"] = matlab_data["mpc.base_density"]
    else
        Memento.warn(_LOGGER,"no base_density found in .m file.
            The file seems to be missing \"mpc.base_density = ...\" \n")
    end

    if haskey(matlab_data, "mpc.base_viscosity")
        case["base_viscosity"] = matlab_data["mpc.base_viscosity"]
    else
        Memento.warn(_LOGGER,"no base_viscosity found in .m file.
            The file seems to be missing \"mpc.base_viscosity = ...\" \n")
    end

    if haskey(matlab_data, "mpc.base_diameter")
        case["base_diameter"] = matlab_data["mpc.base_diameter"]
    else
        Memento.warn(_LOGGER,"no base_diameter found in .m file.
            The file seems to be missing \"mpc.base_diameter = ...\" \n")
    end

    if haskey(matlab_data, "mpc.base_flow")
        case["base_flow"] = matlab_data["mpc.base_flow"]
    else
        Memento.warn(_LOGGER,"no base_flow found in .m file.
            The file seems to be missing \"mpc.base_flow = ...\" \n")
    end

    if haskey(matlab_data, "mpc.is_per_unit")
        case["is_per_unit"] = matlab_data["mpc.is_per_unit"]
    else
        Memento.warn(_LOGGER, string("no is_per_unit found in .m file.
            Auto assigning a value of 0 (false) for the is_per_unit field"))
        case["is_per_unit"] = 0
    end

    if haskey(matlab_data, "mpc.junction")
        junctions = []
        for junction_row in matlab_data["mpc.junction"]
            junction_data = _IM.row_to_typed_dict(junction_row, get(_colnames, "mpc.junction", _mlab_junction_columns))
            junction_data["index"] = _IM.check_type(Int, junction_row[1])
            junction_data["is_si_units"] = case["is_si_units"]
            junction_data["is_english_units"] = case["is_english_units"]
            junction_data["is_per_unit"] = case["is_per_unit"]
            push!(junctions, junction_data)
        end
        case["junction"] = junctions
    else
        Memento.error(_LOGGER, string("no junction table found in .m file.
            The file seems to be missing \"mpc.junction = [...];\""))
    end

    if haskey(matlab_data, "mpc.pipe")
        pipes = []
        for pipe_row in matlab_data["mpc.pipe"]
            pipe_data = _IM.row_to_typed_dict(pipe_row, get(_colnames, "mpc.pipe", _mlab_pipe_columns))
            pipe_data["index"] = _IM.check_type(Int, pipe_row[1])
            pipe_data["is_si_units"] = case["is_si_units"]
            pipe_data["is_english_units"] = case["is_english_units"]
            pipe_data["is_per_unit"] = case["is_per_unit"]
            push!(pipes, pipe_data)
        end
        case["pipe"] = pipes
    else
        Memento.error(_LOGGER, string("no pipe table found in .m file.
            The file seems to be missing \"mpc.pipe = [...];\""))
    end

    if haskey(matlab_data, "mpc.pump")
        pumps = []
        for pump_row in matlab_data["mpc.pump"]
            pump_data = _IM.row_to_typed_dict(pump_row, get(_colnames, "mpc.pump", _mlab_pump_columns))
            pump_data["index"] = _IM.check_type(Int, pump_row[1])
            pump_data["is_si_units"] = case["is_si_units"]
            pump_data["is_english_units"] = case["is_english_units"]
            pump_data["is_per_unit"] = case["is_per_unit"]
            push!(pumps, pump_data)
        end
        case["pump"] = pumps
    end

    if haskey(matlab_data, "mpc.producer")
        producers = []
        for producer_row in matlab_data["mpc.producer"]
            producer_data = _IM.row_to_typed_dict(producer_row, get(_colnames, "mpc.producer", _mlab_producer_columns))
            producer_data["index"] = _IM.check_type(Int, producer_row[1])
            producer_data["is_si_units"] = case["is_si_units"]
            producer_data["is_english_units"] = case["is_english_units"]
            producer_data["is_per_unit"] = case["is_per_unit"]
            push!(producers, producer_data)
        end
        case["producer"] = producers
    end

    if haskey(matlab_data, "mpc.consumer")
        consumers = []
        for consumer_row in matlab_data["mpc.consumer"]
            consumer_data = _IM.row_to_typed_dict(consumer_row, get(_colnames, "mpc.consumer", _mlab_consumer_columns))
            consumer_data["index"] = _IM.check_type(Int, consumer_row[1])
            consumer_data["is_si_units"] = case["is_si_units"]
            consumer_data["is_english_units"] = case["is_english_units"]
            consumer_data["is_per_unit"] = case["is_per_unit"]
            push!(consumers, consumer_data)
        end
        case["consumer"] = consumers
    end

    if haskey(matlab_data, "mpc.tank")
        tanks = []
        for tank_row in matlab_data["mpc.tank"]
            tank_data = _IM.row_to_typed_dict(tank_row, get(_colnames, "mpc.tank", _mlab_tank_columns))
            tank_data["index"] = _IM.check_type(Int, tank_row[1])
            tank_data["is_si_units"] = case["is_si_units"]
            tank_data["is_english_units"] = case["is_english_units"]
            tank_data["is_per_unit"] = case["is_per_unit"]
            push!(tanks, tank_data)
        end
        case["tank"] = tanks
    end


    for k in keys(matlab_data)
        if !in(k, _mlab_data_names) && startswith(k, "mpc.")
            case_name = k[5:length(k)]
            value = matlab_data[k]
            if isa(value, Array)
                column_names = []
                if haskey(colnames, k)
                    column_names = colnames[k]
                end
                tbl = []
                for (i, row) in enumerate(matlab_data[k])
                    row_data = _IM.row_to_dict(row, column_names)
                    row_data["index"] = i
                    push!(tbl, row_data)
                end
                case[case_name] = tbl
                Memento.info(_LOGGER,"extending matlab format with data: $(case_name) $(length(tbl))x$(length(tbl[1])-1)")
            else
                case[case_name] = value
                Memento.info(_LOGGER,"extending matlab format with constant data: $(case_name)")
            end
        end
    end

    return case
end


"Converts a matpetroleum dict into a PowerModels dict"
function _matpetroleum_to_petroleummodels(mp_data::Dict{String,Any})
    pm_data = deepcopy(mp_data)

    if !haskey(pm_data, "multinetwork")
        pm_data["multinetwork"] = false
    end

    # translate component models
    _merge_generic_data!(pm_data)

    # use once available
    _IM.arrays_to_dicts!(pm_data)

    return pm_data
end


"merges Matlab tables based on the table extension syntax"
function _merge_generic_data!(data::Dict{String,Any})
    mp_matrix_names = [name[5:length(name)] for name in _mlab_data_names]

    key_to_delete = []
    for (k,v) in data
        if isa(v, Array)
            for mp_name in mp_matrix_names
                if startswith(k, "$(mp_name)_")
                    mp_matrix = data[mp_name]
                    push!(key_to_delete, k)

                    if length(mp_matrix) != length(v)
                        Memento.error(_LOGGER,"failed to extend the matlab matrix \"$(mp_name)\" with the matrix \"$(k)\" because they do not have the same number of rows, $(length(mp_matrix)) and $(length(v)) respectively.")
                    end

                    Memento.info(_LOGGER,"extending matlab format by appending matrix \"$(k)\" in to \"$(mp_name)\"")

                    for (i, row) in enumerate(mp_matrix)
                        merge_row = v[i]
                        delete!(merge_row, "index")
                        for key in keys(merge_row)
                            if haskey(row, key)
                                Memento.error(_LOGGER, "failed to extend the matlab matrix \"$(mp_name)\" with the matrix \"$(k)\" because they both share \"$(key)\" as a column name.")
                            end
                            row[key] = merge_row[key]
                        end
                    end

                    break # out of mp_matrix_names loop
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
const _matlab_data_order = ["junction", "pipe", "pump", "short_pipe", "producer", "consumer", "tank"]

"order data fields should appear in matlab format"
const _matlab_field_order = Dict{String,Array}(
    "junction"      => [key for (key, dtype) in _mlab_junction_columns],
    "pipe"          => [key for (key, dtype) in _mlab_pipe_columns],
    "pump"          => [key for (key, dtype) in _mlab_pump_columns],
    "producer"      => [key for (key, dtype) in _mlab_producer_columns],
    "consumer"      => [key for (key, dtype) in _mlab_consumer_columns],
    "tank"          => [key for (key, dtype) in _mlab_tank_columns],
)


"order of required global parameters"
const _matlab_global_params_order_required = [
    "density",
    "viscosity",
    "gravitational_acceleration"
]


"order of optional global parameters"
const _matlab_global_params_order_optional = [
    "base_density",
    "base_viscosity",
    "base_diameter",
    "base_length",
    "base_head",
    "base_flow",
    "is_per_unit",
    "mpc.time_step",
    "mpc.base_energy"
]


"list of units of meta data fields"
const _units = Dict{String,Dict{String,String}}(
    "si" => Dict{String,String}(
        "base_density" => "kg/m3",
        "base_viscosity"  => "m2/s",
        "base_diameter" => "m",
        "base_length" => "m",
        "base_head" => "m",
        "base_flow" => "m3/s",
    ),
    "english" => Dict{String,String}(

    )
)

"write to matpetroleum"
function _petroleummodels_to_matpetroleum_string(data::Dict{String,Any}; units::String="si", include_extended::Bool=false)::String
    (data["is_english_units"] == true) && (units = "usc")
    lines = ["function mpc = $(replace(data["name"], " " => "_"))", ""]

    push!(lines, "%% required global data")
    for param in _matlab_global_params_order_required
        if isa(data[param], Float64)
            line = Printf.@sprintf "mpc.%s = %.4f;" param data[param]
        else
            line = "mpc.$(param) = $(data[param]);"
        end
        if haskey(_units[units], param)
            line = "$line  % $(_units[units][param])"
        end

        push!(lines, line)
    end
    push!(lines, "mpc.units = \'$units\';")
    push!(lines, "")

    push!(lines, "%% optional global data (that was either provided or computed based on required global data)")
    for param in _matlab_global_params_order_optional
        if isa(data[param], Float64)
            line = Printf.@sprintf "mpc.%s = %.4f;" param data[param]
        else
            line = "mpc.$(param) = $(data[param]);"
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

            push!(lines, "mpc.$data_type = [")
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
                    push!(lines, "mpc.$(data_type)_data = [")
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
