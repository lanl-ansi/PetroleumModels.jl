# tools for working with PetroleumModels internal data format

"calculates constant flow production"
function calc_qg(data::Dict{String,Any}, producer::Dict{String,Any})
    producer["qg"]
end

"calculates constant flow consumer"
function calc_ql(data::Dict{String,Any}, consumer::Dict{String,Any})

    consumer["ql"]
end


"Ensures that consumer priority exists as a field in loads"
function add_default_consumer_priority(data::Dict{String,Any})
    nws_data = data["multinetwork"] ? data["nw"] : nws_data = Dict{String,Any}("0" => data)

    for (n,data) in nws_data
        for (idx,component) in data["consumer"]
            if !haskey(component,"priority")
                component["priority"] = 1
            end
        end
    end
end



"Add the degree information"
function add_degree(ref::Dict{Symbol,Any})
    for (i,junction) in ref[:junction]
        junction["degree"] = 0
        junction["degree_all"] = 0
    end
end


function calc_head_loss(data::Dict{String,Any}, pipe::Dict{String,Any})
    beta       = 0.0246 # s/m2, assume turbulent flow
    @show keys(data)
    nu         = data["nu"]
    D          = pipe["diameter"]
    L          = pipe["length"]
    head_loss = (beta * nu^0.25 / D^4.75 * L * 1.02)

    if !haskey(data, "per_unit") || data["per_unit"] == true
        head_loss  = head_loss / data["base_h_loss"]
    end
    return head_loss
end


"Transforms network data into per-unit (non-dimensionalized)"
function make_per_unit!(data::Dict{String,Any})

    if !haskey(data, "per_unit") || data["per_unit"] == true
        h_base = data["baseH"]
        q_base = data["baseQ"]
        z_base = data["base_z"]
        a_base = data["base_a"]
        b_base = data["base_b"]


        if InfrastructureModels.ismultinetwork(data)
            for (i,nw_data) in data["nw"]
                _make_per_unit!(nw_data, h_base, q_base, z_base, a_base, b_base)
            end
        else
            _make_per_unit!(data, h_base, q_base, z_base, a_base, b_base)
        end
    end
end

""
function _make_per_unit!(data::Dict{String,Any}, h_base::Real, q_base::Real, z_base::Real, a_base::Real, b_base::Real)
    rescale_q      = x -> x/q_base
    rescale_H      = x -> x/h_base
    rescale_z      = x -> x/z_base
    rescale_a      = x -> x/a_base
    rescale_b      = x -> x/b_base

    if haskey(data, "junction")
        for (i, junction) in data["junction"]
            _apply_func!(junction, "Hmax", rescale_H)
            _apply_func!(junction, "Hmin", rescale_H)
            _apply_func!(junction, "z", rescale_z)
        end
    end

    if haskey(data, "consumer")
        for (i, consumer) in data["consumer"]
            _apply_func!(consumer, "qlmin", rescale_q)
            _apply_func!(consumer, "qlmax", rescale_q)
        end
    end

    if haskey(data, "producer")
        for (i, producer) in data["producer"]
            _apply_func!(producer, "qgmin", rescale_q)
            _apply_func!(producer, "qgmin", rescale_q)
            _apply_func!(producer, "qgmax", rescale_q)
        end
    end

    if haskey(data, "pipe")
        for (i, pipe) in data["pipe"]
              _apply_func!(pipe, "Qmin", rescale_q)
              _apply_func!(pipe, "Qmax", rescale_q)
        end
    end

    if haskey(data, "pump")
        for (i, pump) in data["pump"]
            # _apply_func!(pump, "q", rescale_q)
            _apply_func!(pump, "delta_Hmax", rescale_H)
            _apply_func!(pump, "delta_Hmin", rescale_H)
            _apply_func!(pump, "a", rescale_a)
            _apply_func!(pump, "b", rescale_b)
        end
    end



end


"Transforms network data into si-units (inverse of per-unit)--non-dimensionalized"
function make_si_unit!(data::Dict{String,Any}, result::Dict{String,Any})
    if haskey(data, "per_unit") && data["per_unit"] == true
        q_base = data["baseQ"]
        h_base = data["baseH"]
        z_base = data["base_z"]
        a_base = data["base_a"]
        b_base = data["base_b"]

        if InfrastructureModels.ismultinetwork(data)
            for (i,nw_data) in data["nw"]
                _make_si_unit!(nw_data, h_base, q_base, z_base, a_base, b_base, nw_result)
            end
        else
             _make_si_unit!(data, h_base, q_base, z_base, a_base, b_base, result)
        end
    end
end


""
function _make_si_unit!(data::Dict{String,Any}, h_base::Real, q_base::Real, z_base::Real, a_base::Real, b_base::Real, result::Dict{String,Any})
    rescale_q      = x -> x*q_base
    rescale_H      = x -> x*h_base
    rescale_z      = x -> x*z_base
    rescale_a      = x -> x*a_base
    rescale_b      = x -> x*b_base

    if haskey(result, "junction")
        for (i, junction) in result["junction"]
            _apply_func!(junction, "Hmax", rescale_H)
            _apply_func!(junction, "Hmin", rescale_H)
            _apply_func!(junction, "H", rescale_H)
            _apply_func!(junction, "z", rescale_z)
        end
    end

    if haskey(result, "consumer")
        for (i, consumer) in result["consumer"]
            _apply_func!(consumer, "qlmin", rescale_q)
            _apply_func!(consumer, "qlmax", rescale_q)
            _apply_func!(consumer, "ql", rescale_q)
        end
    end

    if haskey(result, "producer")
        for (i, producer) in result["producer"]
            _apply_func!(producer, "qgmin", rescale_q)
            _apply_func!(producer, "qgmax", rescale_q)
            _apply_func!(producer, "qg", rescale_q)
        end
    end

    if haskey(result, "pipe")
        for (i, pipe) in result["pipe"]
            _apply_func!(pipe, "q", rescale_q)
            _apply_func!(pipe, "Qmin", rescale_q)
            _apply_func!(pipe, "Qmax", rescale_q)
        end
    end

    if haskey(result, "pump")
        for (i, pump) in result["pump"]
            _apply_func!(pump, "q", rescale_q)
            _apply_func!(pump, "delta_Hmax", rescale_H)
            _apply_func!(pump, "delta_Hmin", rescale_H)
            _apply_func!(pump, "q_nom", rescale_q)
            _apply_func!(pump, "a", rescale_a)
            _apply_func!(pump, "b", rescale_b)
        end
    end


end


function replicate(sn_data::Dict{String,<:Any}, count::Int; global_keys::Set{String}=Set{String}())
    return InfrastructureModels.replicate(sn_data, count, union(global_keys, _pm_global_keys))
end

"turns a single network and a time_series data block into a multi-network"
function make_multinetwork(data::Dict{String, <:Any}; global_keys::Set{String}=Set{String}())
    return InfrastructureModels.make_multinetwork(data, union(global_keys, _pm_global_keys))
end


""
function _apply_func!(data::Dict{String,Any}, key::String, func)
    if haskey(data, key)
        data[key] = func(data[key])
    end
end


"calculates minimum mass flow consumption"
function _calc_flmin(data::Dict{String,Any}, consumer::Dict{String,Any})
    return consumer["qlmin"] * data["standard_density"]
end


"calculates maximum mass flow consumption"
function _calc_flmax(data::Dict{String,Any}, consumer::Dict{String,Any})
    return consumer["qlmax"] * data["standard_density"]
end


"prints the text summary for a data file or dictionary to stdout"
function print_summary(obj::Union{String, Dict{String,Any}}; kwargs...)
    summary(stdout, obj; kwargs...)
end

"calculates minimum mass flow production"
function _calc_fgmin(data::Dict{String,Any}, producer::Dict{String,Any})
    return producer["qgmin"] * data["standard_density"]
end


"calculates maximum mass flow production"
function _calc_fgmax(data::Dict{String,Any}, producer::Dict{String,Any})
    return producer["qgmax"] * data["standard_density"]
end


"calculates constant mass flow production"
function _calc_fg(data::Dict{String,Any}, producer::Dict{String,Any})
    return producer["qg"] * data["standard_density"]
end




"prints the text summary for a data file to IO"
function summary(io::IO, file::String; kwargs...)
    data = parse_file(file)
    summary(io, data; kwargs...)
    return data
end


const _pm_component_types_order = Dict(
    "junction" => 1.0, "connection" => 2.0, "producer" => 3.0, "consumer" => 4.0
)


const _pm_component_parameter_order = Dict(
    "junction_i" => 1.0, "junction_type" => 2.0,
    "Hmin" => 3.0, "Hmax" => 4.0,

    "type" => 10.0,
    "f_junction" => 11.0, "t_junction" => 12.0,
    "length" => 13.0, "diameter" => 14.0,


    "producer_i" => 50.0, "junction" => 51.0,
    "qg" => 52.0, "qgmin" => 53.0, "qgmax" => 54.0,

    "consumer_i" => 70.0, "junction" => 71.0,
    "ql" => 72.0, "qlmin" => 73.0, "qlmax" => 74.0,

    "status" => 500.0,
)

const _pm_component_types = ["pipe", "pump", "junction", "consumer",
                             "producer"]

const _pm_junction_keys = ["f_junction", "t_junction", "junction"]

const _pm_edge_types = ["pipe", "pump"]


"prints the text summary for a data dictionary to IO"
function summary(io::IO, data::Dict{String,Any}; kwargs...)
    InfrastructureModels.summary(io, data;
        component_types_order = _pm_component_types_order,
        component_parameter_order = _pm_component_parameter_order,
        kwargs...)
end

"extracts the start value"
function comp_start_value(set, item_key, value_key, default = 0.0)
    return get(get(set, item_key, Dict()), value_key, default)
end


function check_connectivity(data::Dict{String,<:Any})
    if InfrastructureModels.ismultinetwork(data)
        for (n, nw_data) in data["nw"]
            _check_connectivity(nw_data)
        end
    else
        _check_connectivity(data)
    end
end

function _check_connectivity(data::Dict{String,<:Any})
    junc_ids = Set(junc["junction_i"] for (i,junc) in data["junction"])
    @assert(length(junc_ids) == length(data["junction"]))

    for comp_type in _pm_component_types
        for (i, comp) in get(data, comp_type, Dict())
            for junc_key in _pm_junction_keys
                if haskey(comp, junc_key)
                    if !(comp[junc_key] in junc_ids)
                        @warn "$junc_key $(comp[junc_key]) in $comp_type $i is not defined"
                    end
                end
            end
        end
    end
end


"checks that active components are not connected to inactive buses, otherwise prints warnings"
function check_status(data::Dict{String,<:Any})
    if InfrastructureModels.ismultinetwork(data)
        @warn "check_status does not yet support multinetwork data"
    end

    active_junction_ids = Set(junction["junction_i"] for (i,junction) in data["junction"] if get(junction, "status", 1) != 0)

    for comp_type in _pm_component_types
        for (i, comp) in get(data, comp_type, Dict())
            for junc_key in _pm_junction_keys
                if haskey(comp, junc_key)
                    if get(comp, "status", 1) != 0 && !(comp[junc_key] in active_junction_ids)
                        @warn "active $comp_type $i is connected to inactive junction $(comp[junc_key])"
                    end
                end
            end
        end
    end
end




"""
computes the connected components of the network graph
returns a set of sets of juntion ids, each set is a connected component
"""
function calc_connected_components(data::Dict{String,<:Any}; edges=_pm_edge_types)
    if InfrastructureModels.ismultinetwork(data)
        @warn "calc_connected_components does not yet support multinetwork data"
    end

    active_junction = Dict(x for x in data["junction"] if x.second["status"] != 0)
    active_junction_ids = Set{Int64}([junction["junction_i"] for (i,junction) in active_junction])

    neighbors = Dict(i => [] for i in active_junction_ids)
    for edge_type in edges
        for edge in values(get(data, edge_type, Dict()))
            if get(edge, "status", 1) != 0 && edge["f_junction"] in active_junction_ids && edge["t_junction"] in active_junction_ids
                push!(neighbors[edge["f_junction"]], edge["t_junction"])
                push!(neighbors[edge["t_junction"]], edge["f_junction"])
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
