# tools for working with PetroleumModels internal data format


"data getters"
@inline base_head(data::Dict{String,Any})                       = data["base_head"]
@inline base_viscosity(data::Dict{String,Any})                  = data["base_viscosity"]
@inline base_gravitational_acceleration(data::Dict{String,Any}) = data["gravitational_acceleration"]
@inline base_diameter(data::Dict{String,Any})                   = data["base_diameter"]
@inline base_length(data::Dict{String,Any})                     = data["base_length"]
@inline base_flow(data::Dict{String,Any})                       = data["base_flow"]
@inline leibenzon_exponent(data::Dict{String,Any})              = 0.25
@inline leibenzon_constant(data::Dict{String,Any})              = 1.02


"apply a function on a dict entry"
function _apply_func!(data::Dict{String,Any}, key::String, func)
    if haskey(data, key)
        data[key] = func(data[key])
    end
end

function calc_tank_head_initial(data::Dict{String,Any}, tank::Dict{String,Any})
    radius     = tank["radius"]
    volume     = tank["initial_volume"]
    g          = data["gravitational_acceleration"]
    head_initial = (volume / (3.14 * radius ^ 2))

    if !haskey(data, "is_per_unit") || data["is_per_unit"] == true
        head_initial  = head_initial / base_head(data)
    end
    return head_initial
end


"if original data is in per-unit ensure it has base values"
function is_per_!(data::Dict{String,Any})
    if get(data, "is_per_unit", false) == true
        if get(data, "base_head", false) == false ||
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
    (get(data, "base_viscosity", false) == false) && (data["base_viscosity"] = 4.9e-6)
    (get(data, "base_length", false) == false) && (data["base_length"] = 500.0)
    data["base_diameter"] = 0.75
    (get(data, "base_flow", false) == false) && (data["base_flow"] = calc_base_flow(data))
end

"make transient data to si units"
function make_si_units!(transient_data::Array{Dict{String,Any},1}, static_data::Dict{String,Any})
    if static_data["units"] == "si"
        return
    end
    mmscfd_to_kgps = x -> x * get_mmscfd_to_kgps_conversion_factor(static_data)
    inv_mmscfd_to_kgps = x -> x / get_mmscfd_to_kgps_conversion_factor(static_data)
    head_params = [
        "head_min",
        "head_max",
        "H"
    ]

    flow_params = [
        "density",
        "viscosity",
        "gravitational_acceleration",
        "q_pipe",
        "q_pump",
        "flow_nom",
        "flow_min",
        "flow_max",
        "qg",
        "ql",
        "injection_min",
        "injection_max",
        "injection_nominal",
        "withdrawal_min",
        "withdrawal_max",
        "withdrawl_nominal",
        "qin",
        "qoff"
    ]

    inv_flow_params = ["bid_price", "offer_price"]
    for line in transient_data
        param = line["parameter"]
        if param in head_params
            line["value"] = ft_to_m(line["value"])
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

    "junction" => [
        "head_max",
        "head_min",
        "elevation"
    ],

    "pipe" => [
        "flow_min",
        "flow_max",
        "diameter",
        "length",
        "q_pipe"
    ],

    "pump" => [
        "flow_nom",
        "flow_max",
        "delta_head_max",
        "delta_head_min",
        "rotation_coefficient",
        "flow_coefficient"
    ],

    "consumer" => [
        "withdrawal_min",
        "withdrawal_max",
        "withdrawal_nominal",
        "ql"
    ],

    "producer" => [
        "injection_min",
        "injection_max",
        "injection_nominal",
        "qg"
    ],

    "tank" => [
        "capacity_min",
        "capacity_max",
        "initial_volume",
        "intake_min",
        "intake_max",
        "offtake_min",
        "offtake_max"
    ],
)

function _rescale_functions(
    rescale_q_pipe::Function,
    rescale_q_pump::Function,
    rescale_q_pump_nom::Function,
    rescale_qin::Function,
    rescale_qoff::Function,
    rescale_viscosity::Function,
    rescale_diameter::Function,
    rescale_length::Function,
    rescale_head::Function,
    rescale_elevation::Function,
    rescale_rotation_coefficient::Function,
    rescale_flow_coefficient::Function,
    rescale_volume::Function
)::Dict{String,Function}
    Dict{String,Function}(
        "q_pipe"                     => rescale_q_pipe,
        "q_pump"                     => rescale_q_pipe,
        "ql"                         => rescale_q_pipe,
        "qg"                         => rescale_q_pipe,
        "head_max"                   => rescale_head,
        "head_min"                   => rescale_head,
        "elevation"                  => rescale_elevation,
        "withdrawal_min"             => rescale_q_pipe,
        "withdrawal_max"             => rescale_q_pipe,
        "withdrawal_nominal"         => rescale_q_pipe,
        "injection_min"              => rescale_q_pipe,
        "injection_max"              => rescale_q_pipe,
        "injection_nominal"          => rescale_q_pipe,
        "flow_min"                   => rescale_q_pipe,
        "flow_max"                   => rescale_q_pipe,
        "flow_nom"                   => rescale_q_pump_nom,
        "delta_head_max"             => rescale_head,
        "delta_head_min"             => rescale_head,
        "rotation_coefficient"       => rescale_rotation_coefficient,
        "flow_coefficient"           => rescale_flow_coefficient,
        "viscosity"                  => rescale_viscosity,
        "diameter"                   => rescale_diameter,
        "length"                     => rescale_length,
        "capacity_min"               => rescale_volume,
        "capacity_max"               => rescale_volume,
        "initial_volume"             => rescale_volume,
        "intake_min"                 => rescale_q_pipe,
        "intake_max"                 => rescale_q_pipe,
        "offtake_min"                => rescale_q_pipe,
        "offtake_max"                => rescale_q_pipe
    )
end

"Transforms data to si units"
function si_to_pu!(data::Dict{String,<:Any}; id = "0")
    rescale_q_pipe                     = x -> x/base_flow(data)
    rescale_q_pump                     = x -> x/base_flow(data)
    rescale_q_pump_nom                 = x -> x/base_flow(data)
    rescale_qin                        = x -> x/base_flow(data)
    rescale_qoff                       = x -> x/base_flow(data)
    rescale_viscosity                  = x -> x/base_viscosity(data)
    rescale_diameter                   = x -> x/base_diameter(data)
    rescale_length                     = x -> x/base_length(data)
    rescale_head                       = x -> x/base_head(data)
    rescale_elevation                  = x -> x/base_head(data)
    rescale_rotation_coefficient       = x -> x/base_head(data)
    rescale_flow_coefficient           = x -> x/base_head(data)*base_flow(data)^2 # head/flow^2 - s^2/m^5
    rescale_volume                     = x -> x/base_head(data)^3

    functions = _rescale_functions(
        rescale_q_pipe,
        rescale_q_pump,
        rescale_q_pump_nom,
        rescale_qin,
        rescale_qoff,
        rescale_viscosity,
        rescale_diameter,
        rescale_length,
        rescale_head,
        rescale_elevation,
        rescale_rotation_coefficient,
        rescale_flow_coefficient,
        rescale_volume
    )

    nw_data = (id == "0") ? data : data["nw"][id]
    _apply_func!(nw_data, "viscosity", rescale_viscosity)

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
    rescale_q_pipe                     = x -> x*base_flow(data)
    rescale_q_pump                     = x -> x*base_flow(data)
    rescale_q_pump_nom                 = x -> x*base_flow(data)
    rescale_qin                        = x -> x*base_flow(data)
    rescale_qoff                       = x -> x*base_flow(data)
    rescale_viscosity                  = x -> x*base_viscosity(data)
    rescale_diameter                   = x -> x*base_diameter(data)
    rescale_length                     = x -> x*base_length(data)
    rescale_head                       = x -> x*base_head(data)
    rescale_elevation                  = x -> x*base_head(data)
    rescale_rotation_coefficient       = x -> x*base_head(data)
    rescale_flow_coefficient           = x -> x*base_head(data) / base_flow(data)^2 # head/flow^2 - s^2/m^5
    rescale_volume                     = x -> x*base_head(data)^3

    functions = _rescale_functions(
        rescale_q_pipe,
        rescale_q_pump,
        rescale_q_pump_nom,
        rescale_qin,
        rescale_qoff,
        rescale_viscosity,
        rescale_diameter,
        rescale_length,
        rescale_head,
        rescale_elevation,
        rescale_rotation_coefficient,
        rescale_flow_coefficient,
        rescale_volume
    )

    nw_data = (id == "0") ? data : data["nw"][id]
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


"prints the text summary for a data file to IO"
function summary(io::IO, file::String; kwargs...)
    data = parse_file(file)
    summary(io, data; kwargs...)
    return data
end


const _pm_component_types_order = Dict(
    "junction" => 1.0,
    "pipe"     => 2.0,
    "pump"     => 3.0,
    "consumer" => 4.0,
    "producer" => 5.0,
    "tank"     => 6.0,
)


const _pm_component_parameter_order = Dict(
    "id"             => 1.0,
    "junction_type"  => 2.0,
    "head_min"       => 3.0,
    "head_max"       => 4.0,
    "fr_junction"    => 11.0,
    "to_junction"    => 12.0,
    "length"         => 13.0,
    "diameter"       => 14.0,
    "flow_min"       => 16.0,
    "flow_max"       => 17.0,
    "delta_head_min" => 18.0,
    "delta_head_max" => 19.0,
    "junction_id"    => 51.0,
    "status"         => 500.0,
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


"Calculates pipeline \"resistance\" using the leibenzon formulation"
function _calc_pipe_resistance_leibenzon(pipe::Dict{String,Any}, nu, m, lc)
    beta = pipe["friction_factor"]
    D    = pipe["diameter"]
    L    = pipe["length"]
    return (beta * L * lc * nu^m) / (D^(5.0-m))
end
