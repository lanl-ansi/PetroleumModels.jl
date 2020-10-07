# tools for working with PetroleumModels internal data format


"data getters"
@inline h_base(data::Dict{String,Any}) = data["baseH"]
@inline base_rho(data::Dict{String,Any}) = data["base_rho"]
@inline base_nu(data::Dict{String,Any}) = data["base_nu"]
@inline base_gravitational_acceleration(data::Dict{String,Any}) = data["gravitational_acceleration"]
@inline base_diameter(data::Dict{String,Any}) = data["base_diameter"]
@inline base_length(data::Dict{String,Any}) = data["base_length"]
@inline q_base(data::Dict{String,Any}) = data["baseQ"]
@inline z_base(data::Dict{String,Any}) = data["base_z"]
@inline a_base(data::Dict{String,Any}) = data["base_a"]
@inline b_base(data::Dict{String,Any}) = data["base_b"]
@inline volume_base(data::Dict{String,Any}) = data["base_volume"]
@inline E_base(data::Dict{String,Any}) = data["E_base"]

# @inline get_base_time(data::Dict{String,Any}) = data["base_time"]

"calculates constant flow production"
function calc_qg(data::Dict{String,Any}, producer::Dict{String,Any})
    producer["qg"]
end

"calculates constant flow consumer"
function calc_ql(data::Dict{String,Any}, consumer::Dict{String,Any})
    consumer["ql"]
end

"apply a function on a dict entry"
function _apply_func!(data::Dict{String,Any}, key::String, func)
    if haskey(data, key)
        data[key] = func(data[key])
    end
end

function calc_tank_head_initial(data::Dict{String,Any}, tank::Dict{String,Any})
    radius     = tank["radius"]
    volume     = tank["Initial_Volume"]
    g          = data["gravitational_acceleration"]
    head_initial = (volume / (3.14 * radius ^ 2))

    if !haskey(data, "is_per_unit") || data["is_per_unit"] == true
        head_initial  = head_initial / h_base(data)
    end
    return head_initial
end



"if original data is in per-unit ensure it has base values"
function is_per_!(data::Dict{String,Any})
    if get(data, "is_per_unit", false) == true
        if get(data, "baseH", false) == false ||
           get(data, "base_length", false) == false
            Memento.error(
                _LOGGER,
                "data in .m file is in per unit but no base_head (in m) value is provided")

        end

    end
end


"adds additional non-dimensional constants to data dictionary"
function add_base_values!(data::Dict{String,Any})
    (get(data, "base_head", false) == false) &&
    (data["base_head"] = calc_base_head(data))
    (get(data, "base_nu", false) == false) && (data["base_nu"] = 4.9e-6)
    # (get(data, "base_rho", false) == false) && (data["base_rho"] = 850)
    (get(data, "base_length", false) == false) && (data["base_length"] = 500.0)
    data["base_diameter"] = 0.75
    (get(data, "baseQ", false) == false) && (data["baseQ"] = calc_base_flow(data))

end

"make transient data to si units"
function make_si_units!(transient_data::Array{Dict{String,Any},1}, static_data::Dict{String,Any},
)
    if static_data["units"] == "si"
        return
    end
    mmscfd_to_kgps = x -> x * get_mmscfd_to_kgps_conversion_factor(static_data)
    inv_mmscfd_to_kgps = x -> x / get_mmscfd_to_kgps_conversion_factor(static_data)
    head_params = [
        "Hmin",
        "Hmax",
        "H"
    ]
    flow_params = [
        "rho",
        "nu",
        "gravitational_acceleration",
        "Q_pipe_dim",
        "Q_pump_dim",
        "q_pipe",
        "q_pump",
        "q_nom",
        "Qmin",
        "Qmax",
        "qg",
        "ql",
        "qgmin",
        "qgmax",
        "qlmin",
        "qlmax",
        "q_tank_in",
        "q_tank_out",
        "electricity_price"

    ]
    inv_flow_params = ["bid_price", "offer_price"]
    for line in transient_data
        param = line["parameter"]
        if param in head_params
            line["value"] = psi_to_pascal(line["value"])
        end
        if param in flow_params
            line["value"] = mmscfd_to_kgps(line["value"])
        end
        if param in inv_flow_params
            line["value"] = inv_mmscfd_to_kgps(line["value"])
        end
    end
end

const _params_for_unit_conversions = Dict(

    "junction" =>
        ["Hmax", "Hmin",  "z"],
    #
    # "original_junction" => ["p_min", "p_max", "p_nominal", "p"],

    "pipe" => ["Qmin", "Qmax",
    "diameter",
    "length", "q_pipe"],

    "ne_pipe" => ["Qmin", "Qmax",
    "diameter",
    "length"],

    "pump" => [
    "q_nom",
    "delta_Hmax",
    "delta_Hmin",
    "a",
    "b",
    "electricity_price",
    "Q_pump_dim"],

    "ne_pump" => [
    "q_nom",
    "delta_Hmax",
    "delta_Hmin",
    "a",
    "b",
    "electricity_price",
    "Q_pump_dim"],

    "consumer" => [
        "qlmin",
        "qlmax", "ql"
    ],
    "producer" => [
        "qgmin",
        "qgmax",
        "qg"
    ],

    "tank" => [
    "Min_Capacity_Limitation",
    "Max_Capacity_Limitation",
    "Min_Load_Flow_Rate",
    "Max_Load_Flow_Rate",
    "Min_Unload_Flow_Rate",
    "Max_Unload_Flow_Rate"
    ],
)

function _rescale_functions(
    rescale_electricity_price::Function,
    rescale_q_pipe::Function,
    rescale_q_pump::Function,
    rescale_q_pump_nom::Function,
    rescale_q_tank_in::Function,
    rescale_q_tank_out::Function,
    rescale_rho::Function,
    rescale_nu::Function,
    rescale_gravitational_acceleration::Function,
    rescale_diameter::Function,
    rescale_length::Function,
    rescale_H::Function,
    rescale_z::Function,
    rescale_a::Function,
    rescale_b::Function,
    rescale_volume::Function,
    rescale_Q_pipe_dim::Function,
    rescale_Q_pump_dim::Function
)::Dict{String,Function}
    Dict{String,Function}(
        "electricity_price" => rescale_electricity_price,
        "q_pipe" => rescale_q_pipe,
        "q_pump" => rescale_q_pipe,
        "ql" => rescale_q_pipe,
        "qg" => rescale_q_pipe,
        "Hmax" => rescale_H,
        "Hmin" => rescale_H,
        "z" => rescale_z,
        "qlmin" => rescale_q_pipe,
        "qlmax" => rescale_q_pipe,
        "qgmin" => rescale_q_pipe,
        "qgmax" => rescale_q_pipe,
        "Qmin" => rescale_q_pipe,
        "Qmax" => rescale_q_pipe,
        "q_nom" => rescale_q_pump_nom,
        "delta_Hmax" => rescale_H,
        "delta_Hmin" => rescale_H,
        "a" => rescale_a,
        "b" => rescale_b,
        "rho" => rescale_rho,
        "nu" => rescale_nu,
        "gravitational_acceleration" => rescale_gravitational_acceleration,
        "diameter" => rescale_diameter,
        "length" => rescale_length,
        "Q_pipe_dim" => rescale_Q_pipe_dim,
        "Q_pump_dim" => rescale_Q_pump_dim,

        "Min_Capacity_Limitation" => rescale_volume,
        "Max_Capacity_Limitation" => rescale_volume,
        "Min_Load_Flow_Rate" => rescale_q_pipe,
        "Max_Load_Flow_Rate" => rescale_q_pipe,
        "Min_Unload_Flow_Rate" => rescale_q_pipe,
        "Max_Unload_Flow_Rate" => rescale_q_pipe
    )
end
"Transforms data to si units"
function si_to_pu!(data::Dict{String,<:Any}; id = "0")
    rescale_electricity_price   = x -> x*E_base(data)
    rescale_q_pipe   = x -> x/q_base(data)
    rescale_Q_pipe_dim = x -> x/3600
    rescale_Q_pump_dim = x ->  x*3600
    rescale_q_pump   = x -> x/q_base(data)
    rescale_q_pump_nom   = x -> x/q_base(data)
    rescale_q_tank_in = x -> x/q_base(data)
    rescale_q_tank_out = x -> x/q_base(data)
    rescale_rho = x -> x/base_rho(data)
    rescale_nu = x -> x/base_nu(data)
    rescale_gravitational_acceleration = x -> x/9.8
    rescale_diameter = x -> x/base_diameter(data)
    rescale_length = x -> x/base_length(data)
    rescale_H      = x -> x/h_base(data)
    rescale_z      = x -> x/z_base(data)
    rescale_a      = x -> x/a_base(data)
    rescale_b      = x -> x/b_base(data)
    rescale_volume  = x -> x/volume_base(data)

    functions = _rescale_functions(
    rescale_electricity_price,
    rescale_q_pipe,
    rescale_q_pump,
    rescale_q_pump_nom,
    rescale_q_tank_in,
    rescale_q_tank_out,
    rescale_rho,
    rescale_nu,
    rescale_gravitational_acceleration,
    rescale_diameter,
    rescale_length,
    rescale_H,
    rescale_z,
    rescale_a,
    rescale_b,
    rescale_volume,
    rescale_Q_pipe_dim,
    rescale_Q_pump_dim
    )

    nw_data = (id == "0") ? data : data["nw"][id]
    _apply_func!(nw_data, "nu", rescale_nu)
    _apply_func!(nw_data, "rho", rescale_rho)
    _apply_func!(nw_data, "gravitational_acceleration", rescale_gravitational_acceleration)
    _apply_func!(nw_data, "Q_pipe_dim", rescale_Q_pipe_dim)
    _apply_func!(nw_data, "Q_pump_dim", rescale_Q_pump_dim)
    for (component, parameters) in _params_for_unit_conversions
        for (i, comp) in get(nw_data, component, [])
            if ~haskey(comp, "is_per_unit") && ~haskey(data, "is_per_unit")
                Memento.error(
                    _LOGGER,
                    "the current units of the data/result dictionary unknown")
            end
            if ~haskey(comp, "is_per_unit") && haskey(data, "is_per_unit")
                comp["is_per_unit"] = data["is_per_unit"]
                comp["is_si_units"] = 0
            end
            if comp["is_si_units"] == true && comp["is_per_unit"] == false
                for param in parameters
                    _apply_func!(comp, param, functions[param])
                    comp["is_si_units"] = 0
                    comp["is_per_unit"] = 1
                end
            end
        end
    end
end

function pu_to_si!(data::Dict{String,<:Any}; id = "0")
    rescale_electricity_price   = x -> x/E_base(data)
    rescale_q_pipe          = x -> x*q_base(data)
    rescale_Q_pipe_dim      = x -> x*3600
    rescale_Q_pump_dim      = x -> x/3600
    rescale_q_pump          = x -> x*q_base(data)
    rescale_q_pump_nom      = x -> x*q_base(data)
    rescale_q_tank_in       = x -> x*q_base(data)
    rescale_q_tank_out      = x -> x*q_base(data)
    rescale_rho             = x -> x*base_rho(data)
    rescale_nu              = x -> x*base_nu(data)
    rescale_gravitational_acceleration = x -> x*9.8
    rescale_diameter        = x -> x*base_diameter(data)
    rescale_length = x -> x*base_length(data)
    rescale_H      = x -> x
    rescale_z      = x -> x*z_base(data)
    rescale_a      = x -> x*a_base(data)
    rescale_b      = x -> x*b_base(data)
    rescale_volume = x -> x*volume_base(data)

    functions = _rescale_functions(
    rescale_electricity_price,
    rescale_q_pipe,
    rescale_q_pump,
    rescale_q_pump_nom,
    rescale_q_tank_in,
    rescale_q_tank_out,
    rescale_rho,
    rescale_nu,
    rescale_gravitational_acceleration,
    rescale_diameter,
    rescale_length,
    rescale_H,
    rescale_z,
    rescale_a,
    rescale_b,
    rescale_volume,
    rescale_Q_pipe_dim,
    rescale_Q_pump_dim
    )

    nw_data = (id == "0") ? data : data["nw"][id]
    # _apply_func!(nw_data, "time_point", rescale_time)
    for (component, parameters) in _params_for_unit_conversions
        for (i, comp) in get(nw_data, component, [])
            if ~haskey(comp, "is_per_unit") && ~haskey(data, "is_per_unit")
                Memento.error(
                    _LOGGER,
                    "the current units of the data/result dictionary unknown",
                )
            end
            if ~haskey(comp, "is_per_unit") && haskey(data, "is_per_unit")
                @assert data["is_per_unit"] == 1
                comp["is_per_unit"] = data["is_per_unit"]
                comp["is_si_units"] = 0
            end
            if comp["is_si_units"] == false && comp["is_per_unit"] == true
                for param in parameters
                    _apply_func!(comp, param, functions[param])
                    comp["is_si_units"] = 1
                    comp["is_per_unit"] = 0
                end
            end
        end
    end
end


"transforms data to si units"
function make_si_units!(data::Dict{String,<:Any})
    if get(data, "is_si_units", false) == true
        return
    end
    if get(data, "is_per_unit", false) == true
        if _IM.ismultinetwork(data)
            for (i, _) in data["nw"]
                pu_to_si!(data, id = i)
            end
        else
            pu_to_si!(data)
        end
        # if haskey(data, "time_step")
        #     rescale_time = x -> x * get_base_time(data)
        #     data["time_step"] = rescale_time(data["time_step"])
        # end
        data["is_si_units"] = 1
        data["is_per_unit"] = 0
    end

end


"Transforms network data into per unit"
function make_per_unit!(data::Dict{String,<:Any})
    if get(data, "is_per_unit", false) == true
        return
    end

    if get(data, "is_si_units", false) == true
        if _IM.ismultinetwork(data)
            for (i, _) in data["nw"]
                si_to_pu!(data, id = i)
            end
        else
            si_to_pu!(data)
        end
        # if haskey(data, "time_step")
        #     rescale_time = x -> x / get_base_time(data)
        #     data["time_step"] = rescale_time(data["time_step"])
        # end
        data["is_si_units"] = 0
        data["is_per_unit"] = 1
    end
end

"checks for non-negativity of certain fields in the data"
function check_non_negativity(data::Dict{String,<:Any})
    for field in non_negative_metadata
        if get(data, field, 0.0) < 0.0
            Memento.error(
            _LOGGER,"metadata $field is < 0")
        end
    end

    for field in keys(non_negative_data)
        for (i, table) in get(data, field, [])
            for column_name in get(non_negative_data, field, [])
                if get(table, column_name, 0.0) < 0.0
                    Memento.error(
            _LOGGER,"$field[$i][$column_name] is < 0")
                end
            end
        end
    end
end


"extracts the start value"
function comp_start_value(set, item_key, value_key, default = 0.0)
    return get(get(set, item_key, Dict()), value_key, default)
end


"Helper function for determining if direction cuts can be applied"
function _apply_mass_flow_cuts(yp, branches)
    is_disjunction = true
    for k in branches
        is_disjunction &= haskey(yp, k)
    end
    return is_disjunction
end


"calculates connections in parallel with one another and their orientation"
function _calc_parallel_connections(
    pm::AbstractPetroleumModel,
    n::Int,
    connection::Dict{String,Any},
)
    i = min(connection["fr_junction"], connection["to_junction"])
    j = max(connection["fr_junction"], connection["to_junction"])

    parallel_pipes =
        haskey(ref(pm, n, :parallel_pipes), (i, j)) ? ref(pm, n, :parallel_pipes, (i, j)) :
        []
    parallel_pumps = haskey(ref(pm, n, :parallel_pumps), (i, j)) ?
        ref(pm, n, :parallel_pumps, (i, j)) : []
    parallel_tanks = haskey(ref(pm, n, :parallel_tanks), (i, j)) ?
        ref(pm, n, :parallel_tanks, (i, j)) : []

    num_connections =
        length(parallel_pipes) +
        length(parallel_pumps) +
        length(parallel_tanks)

    pipes = ref(pm, n, :pipe)
    pumps = ref(pm, n, :pump)
    tanks = ref(pm, n, :tank)


    aligned_pipes =
        filter(i -> pipes[i]["fr_junction"] == connection["fr_junction"], parallel_pipes)
    opposite_pipes =
        filter(i -> pipes[i]["fr_junction"] != connection["fr_junction"], parallel_pipes)
    aligned_pumps = filter(
        i -> pumps[i]["fr_junction"] == connection["fr_junction"],
        parallel_pumps,
    )
    opposite_pumps = filter(
        i -> pumps[i]["fr_junction"] != connection["fr_junction"],
        parallel_pumps,
    )
    aligned_tanks = filter(
        i -> tanks[i]["fr_junction"] == connection["fr_junction"],
        parallel_tanks,
    )
    opposite_pumps = filter(
        i -> tanks[i]["fr_junction"] != connection["fr_junction"],
        parallel_tanks,
    )


    return num_connections,
    aligned_pipes,
    opposite_pipes,
    aligned_pumps,
    opposite_pumps,
    aligned_tanks,
    opposite_tanks
end


"calculates connections in parallel with one another and their orientation"
function _calc_parallel_ne_connections(
    pm::AbstractPetroleumModel,
    n::Int,
    connection::Dict{String,Any},
)
    i = min(connection["fr_junction"], connection["to_junction"])
    j = max(connection["fr_junction"], connection["to_junction"])

    parallel_pipes = haskey(ref(pm, n, :parallel_pipes), (i, j)) ?
        ref(pm, n, :parallel_pipes, (i, j)) : []
    parallel_pumps = haskey(ref(pm, n, :parallel_pumps), (i, j)) ?
        ref(pm, n, :parallel_pumps, (i, j)) : []
    parallel_tanks = haskey(ref(pm, n, :parallel_tanks), (i, j)) ?
        ref(pm, n, :parallel_tanks, (i, j)) : []

    parallel_ne_pipes = haskey(ref(pm, n, :parallel_ne_pipes), (i, j)) ?
        ref(pm, n, :parallel_ne_pipes, (i, j)) : []
    parallel_ne_pumps = haskey(ref(pm, n, :parallel_ne_pumps), (i, j)) ?
        ref(pm, n, :parallel_ne_pumps, (i, j)) : []
    parallel_ne_tanks = haskey(ref(pm, n, :parallel_ne_tanks), (i, j)) ?
        ref(pm, n, :parallel_ne_tanks, (i, j)) : []

    num_connections =
        length(parallel_pipes) +
        length(parallel_pumps) +
        length(parallel_tanks) +
        length(parallel_ne_pipes) +
        length(parallel_ne_pumps) +
        length(parallel_ne_tanks)

    pipes = ref(pm, n, :pipe)
    pumps = ref(pm, n, :pump)
    tank = ref(pm, n, :tank)
    ne_pipes = ref(pm, n, :ne_pipe)
    ne_pumps = ref(pm, n, :ne_pump)
    ne_tanks = ref(pm, n, :ne_tank)

    aligned_pipes = filter(
        i -> pipes[i]["fr_junction"] == connection["fr_junction"], parallel_pipes
    )
    opposite_pipes = filter(
        i -> pipes[i]["fr_junction"] != connection["fr_junction"], parallel_pipes
    )
    aligned_pumps = filter(
        i -> pumps[i]["fr_junction"] == connection["fr_junction"],
        parallel_pumps,
    )
    opposite_pumps = filter(
        i -> pumps[i]["fr_junction"] != connection["fr_junction"],
        parallel_pumps,
    )
    aligned_tanks = filter(
        i -> tanks[i]["fr_junction"] == connection["fr_junction"],
        parallel_tanks,
    )
    opposite_tanks = filter(
        i -> tanks[i]["fr_junction"] != connection["fr_junction"],
        parallel_tanks,
    )
    aligned_ne_pipes = filter(
        i -> ne_pipes[i]["fr_junction"] == connection["fr_junction"],
        parallel_ne_pipes,
    )
    opposite_ne_pipes = filter(
        i -> ne_pipes[i]["fr_junction"] != connection["fr_junction"],
        parallel_ne_pipes,
    )
    aligned_ne_pumps = filter(
        i -> ne_pumps[i]["fr_junction"] == connection["fr_junction"],
        parallel_ne_pumps,
    )
    opposite_ne_pumps = filter(
        i -> ne_pumps[i]["fr_junction"] != connection["fr_junction"],
        parallel_ne_pumps,
    )
    aligned_ne_tanks = filter(
        i -> ne_tanks[i]["fr_junction"] == connection["fr_junction"],
        parallel_ne_tanks,
    )
    opposite_ne_tanks = filter(
        i -> ne_tanks[i]["fr_junction"] != connection["fr_junction"],
        parallel_ne_tanks,
    )

    return num_connections,
    aligned_pipes,
    opposite_pipes,
    aligned_pumps,
    opposite_pumps,
    aligned_tanks,
    opposite_tanks,
    aligned_ne_pipes,
    opposite_ne_pipes,
    aligned_ne_pumps,
    opposite_ne_pumps,
    aligned_ne_tanks,
    opposite_ne_tanks
end


"prints the text summary for a data file to IO"
function summary(io::IO, file::String; kwargs...)
    data = parse_file(file)
    summary(io, data; kwargs...)
    return data
end


const _pm_component_types_order = Dict(
    "junction" => 1.0,
    "pipe" => 2.0,
    "pump" => 3.0,
    "consumer" => 4.0,
    "producer" => 5.0,
    "tank" => 6.0,
)


const _pm_component_parameter_order = Dict(
    "id" => 1.0,
    "junction_type" => 2.0,
    "Hmin" => 3.0,
    "Hmax" => 4.0,
    "fr_junction" => 11.0,
    "to_junction" => 12.0,
    "length" => 13.0,
    "diameter" => 14.0,
    "Qmin" => 16.0,
    "Qmax" => 17.0,
    "delta_Hmin" => 18.0,
    "delta_Hmax" => 19.0,
    "junction_id" => 51.0,
    "status" => 500.0,
)


"prints the text summary for a data dictionary to IO"
function summary(io::IO, data::Dict{String,Any}; kwargs...)
    _IM.summary(
        io,
        data;
        component_types_order = _pm_component_types_order,
        component_parameter_order = _pm_component_parameter_order,
        kwargs...,
    )
end

function add_pump_fields!(data::Dict{String,<:Any})
    is_si_units = get(data, "is_si_units", 0)
    is_per_unit = get(data, "is_per_unit", false)
    for (i, pump) in data["pump"]
        if is_si_units == true
            # pump["Q_pump_dim"] = 3600
        end

        if is_per_unit == true

        end
    end

end

function add_pipe_fields!(data::Dict{String,:Any})
    is_si_units = get(data, "is_si_units", 0)
    is_per_unit = get(data, "is_per_unit", false)
    for (i, pipe) in data["pipe"]
        if is_si_units == true

        end

        if is_per_unit == true
            pump["Q_pipe_dim"] = 1
        end
    end

end

"""
computes the connected components of the network graph
returns a set of sets of juntion ids, each set is a connected component
"""
function calc_connected_components(data::Dict{String,<:Any}; edges = _pm_edge_types)
    if _IM.ismultinetwork(data)
        Memento.error(
            _LOGGER,
            "calc_connected_components does not yet support multinetwork data",
        )
    end

    active_junction = Dict(x for x in data["junction"] if x.second["status"] != 0)
    active_junction_ids =
        Set{Int64}([junction["junction_i"] for (i, junction) in active_junction])

    neighbors = Dict(i => [] for i in active_junction_ids)
    for edge_type in edges
        for edge in values(get(data, edge_type, Dict()))
            if get(edge, "status", 1) != 0 &&
               edge["fr_junction"] in active_junction_ids &&
               edge["to_junction"] in active_junction_ids
                push!(neighbors[edge["fr_junction"]], edge["to_junction"])
                push!(neighbors[edge["to_junction"]], edge["fr_junction"])
            end
        end
    end

    component_lookup = Dict(i => Set{Int64}([i]) for i in active_junction_ids)
    touched = Set{Int64}()

    for i in active_junction_ids
        if !(i in touched)
            _dfs(i, neighbors, component_lookup, touched)
        end
    end

    ccs = (Set(values(component_lookup)))

    return ccs
end

"perModels DFS on a graph"
function _dfs(i, neighbors, component_lookup, touched)
    push!(touched, i)
    for j in neighbors[i]
        if !(j in touched)
            new_comp = union(component_lookup[i], component_lookup[j])
            for k in new_comp
                component_lookup[k] = new_comp
            end
            _dfs(j, neighbors, component_lookup, touched)
        end
    end
end
