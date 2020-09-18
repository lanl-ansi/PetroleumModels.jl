# stuff that is universal to all models
"root of the petroleum formulation hierarchy"
abstract type AbstractPetroleumModel <: _IM.AbstractInfrastructureModel end

"a macro for adding the base PetroleumModels fields to a type definition"
_IM.@def pm_fields begin @im_fields end


""
function run_model(file::String, model_type, optimizer, build_method; ref_extensions=[], solution_processors=[], kwargs...)
    data = parse_file(file)
    return run_model(data, model_type, optimizer, build_method; ref_extensions=ref_extensions, solution_processors= solution_processors, kwargs...)
end

""
function run_model(data::Dict{String,<:Any}, model_type, optimizer, build_method; ref_extensions=[], solution_processors=[], kwargs...)
    pm = instantiate_model(data, model_type, build_method; ref_extensions=ref_extensions, ext=get(kwargs, :ext, Dict{Symbol,Any}()), setting=get(kwargs, :setting, Dict{String,Any}()), jump_model=get(kwargs, :jump_model, JuMP.Model()))
    result = optimize_model!(pm, optimizer=optimizer, solution_processors=solution_processors)

    # if haskey(data, "objective_normalization")
    #     result["objective"] *= data["objective_normalization"]
    # end

    return result
end

""
function instantiate_model(file::String,  model_type, build_method; kwargs...)
    data = parse_file(file)
    return instantiate_model(data, model_type, build_method; kwargs...)
end


function instantiate_model(data::Dict{String,<:Any}, model_type::Type, build_method; kwargs...)
    pm = _IM.instantiate_model(data, model_type, build_method, ref_add_core!, _pm_global_keys; kwargs...)
    return pm
end


"""
Builds the ref dictionary from the data dictionary. Additionally the ref
dictionary would contain fields populated by the optional vector of
ref_extensions provided as a keyword argument.
"""
function build_ref(data::Dict{String,<:Any}; ref_extensions=[])
    return _IM.build_ref(data, ref_add_core!, _pm_global_keys, ref_extensions=ref_extensions)
end

"""
Returns a dict that stores commonly used pre-computed data from of the data dictionary,
primarily for converting data-types, filtering out deactivated components, and storing
system-wide values that need to be computed globally.
Some of the common keys include:
* `:junction` -- the set of junctions in the system,
* `:pipe` -- the set of pipes in the system,
* `:pump` -- the set of pumps in the system,
* `:consumer` -- the set of consumer points in the system,
* `:producer` -- the set of producer points in the system,
* `:tank` -- the set of tanks in the system,
* `:degree` -- the degree of junction i using existing connections (see `ref_degree!`)),
"""
function ref_add_core!(refs::Dict{Symbol,<:Any})
    _ref_add_core!(refs[:nw], base_rho=refs[:base_rho], base_nu=refs[:base_nu], base_diameter=refs[:base_diameter], base_length=refs[:base_length], baseQ=refs[:baseQ], baseH=refs[:baseH], base_z=refs[:base_z], base_a = refs[:base_a] , base_b=refs[:base_b])
end

function _ref_add_core!(nw_refs::Dict{Int,<:Any}; base_rho=850, base_nu= 4.9e-6, base_diameter=0.75, base_length=100, baseQ = 1, baseH = 100, base_z = 100, base_a = 100, base_b = 100)
    for (nw, ref) in nw_refs
        ref[:junction] = haskey(ref, :junction) ? Dict(x for x in ref[:junction] if x.second["status"] == 1) : Dict()
        ref[:pipe] = haskey(ref, :pipe) ? Dict(x for x in ref[:pipe] if x.second["status"] == 1 && x.second["fr_junction"] in keys(ref[:junction]) && x.second["to_junction"] in keys(ref[:junction])) : Dict()
        ref[:pump] = haskey(ref, :pump) ? Dict(x for x in ref[:pump] if x.second["status"] == 1 && x.second["fr_junction"] in keys(ref[:junction]) && x.second["to_junction"] in keys(ref[:junction])) : Dict()
        ref[:consumer] = haskey(ref, :consumer) ? Dict(x for x in ref[:consumer] if x.second["status"] == 1 && x.second["junction_id"] in keys(ref[:junction])) : Dict()
        ref[:producer] = haskey(ref, :producer) ? Dict(x for x in ref[:producer] if x.second["status"] == 1 && x.second["junction_id"] in keys(ref[:junction])) : Dict()
        ref[:tank] = haskey(ref, :tank) ? Dict(x for x in ref[:tank] if x.second["status"] == 1 && x.second["fr_junction"] in keys(ref[:junction]) && x.second["to_junction"] in keys(ref[:junction])) : Dict()
        ref[:properties] = haskey(ref, :properties) ? Dict(x for x in ref[:junction] if x.second["status"] == 1) : Dict()

        # dispatchable consumers, and producers
        ref[:dispatchable_consumer] = Dict(x for x in ref[:consumer] if x.second["is_dispatchable"] == 1)
        ref[:dispatchable_producer] = Dict(x for x in ref[:producer] if x.second["is_dispatchable"] == 1)
        ref[:nondispatchable_consumer] = Dict(x for x in ref[:consumer] if x.second["is_dispatchable"] == 0)
        ref[:nondispatchable_producer] = Dict(x for x in ref[:producer] if x.second["is_dispatchable"] == 0)

        #  consumers, producers and tanks in junction
        ref[:dispatchable_consumers_in_junction] = Dict([(i, []) for (i,junction) in ref[:junction]])
        ref[:dispatchable_producers_in_junction] = Dict([(i, []) for (i,junction) in ref[:junction]])
        ref[:nondispatchable_consumers_in_junction] = Dict([(i, []) for (i,junction) in ref[:junction]])
        ref[:nondispatchable_producers_in_junction] = Dict([(i, []) for (i,junction) in ref[:junction]])
        ref[:tanks_in_junction] = Dict([(i, []) for (i,junction) in ref[:junction]])

        _add_junction_map!(ref[:dispatchable_consumers_in_junction], ref[:dispatchable_consumer])
        _add_junction_map!(ref[:nondispatchable_consumers_in_junction], ref[:nondispatchable_consumer])
        _add_junction_map!(ref[:dispatchable_producers_in_junction], ref[:dispatchable_producer])
        _add_junction_map!(ref[:nondispatchable_producers_in_junction], ref[:nondispatchable_producer])
        # _add_junction_map!(ref[:tanks_in_junction], ref[:tank])

        ref[:parallel_pipes] = Dict()
        ref[:parallel_pumps] = Dict()
        ref[:parallel_tanks] = Dict()
        _add_parallel_edges!(ref[:parallel_pipes], ref[:pipe])
        _add_parallel_edges!(ref[:parallel_pumps], ref[:pump])
        _add_parallel_edges!(ref[:parallel_tanks], ref[:tank])

        ref[:pipes_fr] = Dict(i => [] for (i,junction) in ref[:junction])
        ref[:pipes_to] = Dict(i => [] for (i,junction) in ref[:junction])
        ref[:pumps_fr] = Dict(i => [] for (i,junction) in ref[:junction])
        ref[:pumps_to] = Dict(i => [] for (i,junction) in ref[:junction])
        ref[:tanks_fr] = Dict(i => [] for (i,junction) in ref[:junction])
        ref[:tanks_to] = Dict(i => [] for (i,junction) in ref[:junction])
        _add_edges_to_junction_map!(ref[:pipes_fr], ref[:pipes_to], ref[:pipe])
        _add_edges_to_junction_map!(ref[:pumps_fr], ref[:pumps_to], ref[:pump])
        _add_edges_to_junction_map!(ref[:tanks_fr], ref[:tanks_to], ref[:tank])

        ref_degree!(ref)

        for (idx, pipe) in ref[:pipe]
            i = pipe["fr_junction"]
            j = pipe["to_junction"]

        end

        for (idx, pump) in ref[:pump]
            i = pump["fr_junction"]
            j = pump["to_junction"]

        end
        for (idx, tank) in ref[:tank]
            i = tank["fr_junction"]
            j = tank["to_junction"]
        end
    end

end

function _add_junction_map!(junction_map::Dict, collection::Dict)
    for (i, component) in collection
        junction_id = component["junction_id"]
        push!(junction_map[junction_id], i)
    end
end


function _add_parallel_edges!(parallel_ref::Dict, collection::Dict)
    for (idx, connection) in collection
        i = connection["fr_junction"]
        j = connection["to_junction"]
        fr = min(i, j)
        to = max(i, j)
        if get(parallel_ref, (fr, to), false) == 1
            push!(parallel_ref[(fr, to)], idx)
        else
            parallel_ref[(fr, to)] = []
            push!(parallel_ref[(fr, to)], idx)
        end
    end
end

function _add_edges_to_junction_map!(fr_ref::Dict, to_ref::Dict, collection::Dict)
    for (idx, connection) in collection
        i = connection["fr_junction"]
        j = connection["to_junction"]
        push!(fr_ref[i], idx)
        push!(to_ref[j], idx)
    end
end

"Add reference information for the degree of junction"
function ref_degree!(ref::Dict{Symbol,Any})
    ref[:degree] = Dict()
    for (i,junction) in ref[:junction]
        ref[:degree][i] = 0
    end

    connections = Set()
    for (i,j) in keys(ref[:parallel_pipes]) push!(connections, (i,j)) end
    for (i,j) in keys(ref[:parallel_pumps]) push!(connections, (i,j)) end
    for (i,j) in keys(ref[:parallel_tanks]) push!(connections, (i,j)) end

    for (i,j) in connections
        ref[:degree][i] = ref[:degree][i] + 1
        ref[:degree][j] = ref[:degree][j] + 1
    end
end
