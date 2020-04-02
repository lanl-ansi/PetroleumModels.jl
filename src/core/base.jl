abstract type AbstractPetroleumFormulation end


    "a macro for adding the base fields to a type definition"
    InfrastructureModels.@def pm_fields begin
        model::JuMP.AbstractModel

        data::Dict{String,<:Any}
        setting::Dict{String,<:Any}
        solution::Dict{String,<:Any}

        ref::Dict{Symbol,<:Any}
        var::Dict{Symbol,<:Any}
        con::Dict{Symbol,<:Any}
        cnw::Int


        ext::Dict{Symbol,<:Any}
    end


    "default generic constructor"
    function GenericPetroleumModel(PetroleumModel::Type, data::Dict{String,<:Any}; ext=Dict{Symbol,Any}(), setting=Dict{String,Any}(), jump_model::JuMP.AbstractModel=JuMP.Model(), kwargs...)
        @assert PetroleumModel <: AbstractPetroleumFormulation

        ref = InfrastructureModels.ref_initialize(data, _pm_global_keys)  # reference data

        var = Dict{Symbol,Any}(:nw => Dict{Int,Any}())
        con = Dict{Symbol,Any}(:nw => Dict{Int,Any}())
        for nw_id in keys(ref[:nw])
            var[:nw][nw_id] = Dict{Symbol,Any}()
            con[:nw][nw_id] = Dict{Symbol,Any}()
        end

        cnw = minimum([k for k in keys(ref[:nw])])


        println(length(keys(ref[:nw])))

        pm = PetroleumModel(
            jump_model, # model
            data, # data
            setting, # setting
            Dict{String,Any}(), # solution
            ref,
            var, # vars
            con,
            cnw,
            ext # ext
        )
        return pm
    end
# Helper functions for ignoring multinetwork support
ismultinetwork(pm::AbstractPetroleumFormulation) = (length(pm.ref[:nw]) > 1)
nw_ids(pm::AbstractPetroleumFormulation) = keys(pm.ref[:nw])
nws(pm::AbstractPetroleumFormulation) = pm.ref[:nw]
# num_time_points(pm::AbstractPetroleumFormulation) = length(keys(pm.ref[:nw]))

ids(pm::AbstractPetroleumFormulation, key::Symbol) = ids(pm, pm.cnw, key)
ids(pm::AbstractPetroleumFormulation, n::Int, key::Symbol) = keys(pm.ref[:nw][n][key])

ref(pm::AbstractPetroleumFormulation, key::Symbol) = ref(pm, pm.cnw, key)
ref(pm::AbstractPetroleumFormulation, key::Symbol, idx) = ref(pm, pm.cnw, key, idx)
ref(pm::AbstractPetroleumFormulation, n::Int, key::Symbol) = pm.ref[:nw][n][key]
ref(pm::AbstractPetroleumFormulation, n::Int, key::Symbol, idx) = pm.ref[:nw][n][key][idx]


var(pm::AbstractPetroleumFormulation, key::Symbol) = var(pm, pm.cnw, key)
var(pm::AbstractPetroleumFormulation, key::Symbol, idx) = var(pm, pm.cnw, key, idx)
var(pm::AbstractPetroleumFormulation, n::Int, key::Symbol) = pm.var[:nw][n][key]
var(pm::AbstractPetroleumFormulation, n::Int, key::Symbol, idx) = pm.var[:nw][n][key][idx]

con(pm::AbstractPetroleumFormulation, nw::Int) = pm.con[:nw][nw]
con(pm::AbstractPetroleumFormulation, nw::Int, key::Symbol) = pm.con[:nw][nw][key]
con(pm::AbstractPetroleumFormulation, nw::Int, key::Symbol, idx) = pm.con[:nw][nw][key][idx]

con(pm::AbstractPetroleumFormulation; nw::Int=pm.cnw) = pm.con[:nw][nw]
con(pm::AbstractPetroleumFormulation, key::Symbol; nw::Int=pm.cnw) = pm.con[:nw][nw][key]
con(pm::AbstractPetroleumFormulation, key::Symbol, idx; nw::Int=pm.cnw) = pm.con[:nw][nw][key][idx]


ext(pm::AbstractPetroleumFormulation, key::Symbol) = ext(pm, pm.cnw, key)
ext(pm::AbstractPetroleumFormulation, key::Symbol, idx) = ext(pm, pm.cnw, key, idx)
ext(pm::AbstractPetroleumFormulation, n::Int, key::Symbol) = pm.ext[:nw][n][key]
ext(pm::AbstractPetroleumFormulation, n::Int, key::Symbol, idx) = pm.ext[:nw][n][key][idx]

function parse_status(termination_status::MOI.TerminationStatusCode)
    if termination_status == MOI.OPTIMAL
        return :Optimal
    elseif termination_status == MOI.LOCALLY_SOLVED
        return :LocalOptimal
    elseif termination_status == MOI.INFEASIBLE
        return :Infeasible
    elseif termination_status == MOI.LOCALLY_INFEASIBLE
        return :LocalInfeasible
    elseif termination_status == MOI.INFEASIBLE_OR_UNBOUNDED
        return :Infeasible
    else
        return :Error
    end
end


# run_generic_model
function run_model(file::String, model_type, optimizer, build_method; kwargs...)
    data = parse_file(file)
    return run_model(data, model_type, optimizer, build_method; kwargs...)
end

""
function run_model(data::Dict{String,<:Any}, model_type, optimizer, build_method; ref_extensions=[], solution_builder=get_solution, kwargs...)
# build_generic_model
    pm = instantiate_model(data, model_type, build_method; ref_extensions=ref_extensions, kwargs...)
# solve_generic_model
    result = optimize_model!(pm, optimizer=optimizer; solution_builder = get_solution)
    return result
end

""
# build_generic_model
function instantiate_model(file::String,  model_type, build_method; kwargs...)
    data = parse_file(file)
    return instantiate_model(data, model_type, build_method; kwargs...)
end

""
# build_generic_model
function instantiate_model(data::Dict{String,<:Any}, model_type, build_method; ref_extensions=[], multinetwork=false, kwargs...)
    pm = GenericPetroleumModel(model_type, data; kwargs...)

    if !multinetwork && data["multinetwork"]
        @warn "building a single network model with multinetwork data, only network ($(pm.cnw)) will be used."
    end

    ref_add_core!(pm)
    for ref_ext in ref_extensions
        ref_ext(pm)
    end

    build_method(pm; kwargs...)

    return pm
end

""
function optimize_model!(pm::AbstractPetroleumFormulation; optimizer, solution_builder=get_solution)
    termination_status, solve_time = optimize!(pm, optimizer=optimizer; solution_builder = get_solution)
    status = parse_status(termination_status)

    return build_solution(pm, status, solve_time; solution_builder = solution_builder)
end

" Do a solve of the problem "
function optimize!(pm::AbstractPetroleumFormulation; optimizer, solution_builder=get_solution)
    if pm.model.moi_backend.state == MOIU.NO_OPTIMIZER
        _, solve_time, solve_bytes_alloc, sec_in_gc = @timed JuMP.optimize!(pm.model, optimizer)
    else
        @warn "Model already contains optimizer factory, cannot use optimizer specified in `solve_generic_model`"
        _, solve_time, solve_bytes_alloc, sec_in_gc = @timed JuMP.optimize!(pm.model)
    end

    try
        solve_time = MOI.get(pm.model, MOI.SolveTime())
    catch
        @warn "the given optimizer does not provide the SolveTime() attribute, falling back on @timed.  This is not a rigorous timing value."
    end

    return JuMP.termination_status(pm.model), solve_time
end



# function optimize_model!(pm::AbstractPetroleumFormulation; optimizer, solution_builder=get_solution)
#     if optimizer != nothing
#         if pm.model.moi_backend.state == MOIU.NO_OPTIMIZER
#             JuMP.set_optimizer(pm.model, optimizer)
#         else
#             Memento.warn(_LOGGER, "Model already contains optimizer, cannot use optimizer specified in `optimize_model!`")
#         end
#     end
#
#     if pm.model.moi_backend.state == MOIU.NO_OPTIMIZER
#         Memento.error(_LOGGER, "no optimizer specified in `optimize_model!` or the given JuMP model.")
#     end
#
#     _, solve_time, solve_bytes_alloc, sec_in_gc = @timed JuMP.optimize!(pm.model)
#
#     try
#         solve_time = MOI.get(pm.model, MOI.SolveTime())
#     catch
#         Memento.warn(_LOGGER, "the given optimizer does not provide the SolveTime() attribute, falling back on @timed.  This is not a rigorous timing value.")
#     end
#
#     result = build_solution(pm, status, solve_time; solution_builder=get_solution)
#     pm.solution = result["solution"]
#     return result
# end


function build_ref(data::Dict{String,<:Any}; ref_extensions=[])
    ref = InfrastructureModels.ref_initialize(data, _pm_global_keys)
    _ref_add_core!(ref[:nw])
    # for ref_ext in ref_extensions
    #     ref_ext(pm)
    # end

    return ref
end


function ref_add_core!(pm::AbstractPetroleumFormulation)
    _ref_add_core!(pm.ref[:nw])
end

function _ref_add_core!(nw_refs::Dict)
    for (nw, ref) in nw_refs

        # filter turned off stuff
        # ref[:junction] = haskey(ref, :junction) ? Dict(x for x in ref[:junction] if x.second["status"] == 1) : Dict()
        # ref[:pipe] = haskey(ref, :pipe) ? Dict(x for x in ref[:pipe] if x.second["status"] == 1 && x.second["f_junction"] in keys(ref[:junction]) && x.second["t_junction"] in keys(ref[:junction])) : Dict()
        # ref[:pump] = haskey(ref, :pump) ? Dict(x for x in ref[:pump] if x.second["status"] == 1 && x.second["f_junction"] in keys(ref[:junction]) && x.second["t_junction"] in keys(ref[:junction])) : Dict()
        # ref[:consumer] = haskey(ref, :consumer) ? Dict(x for x in ref[:consumer] if x.second["status"] == 1 && x.second["ql_junc"] in keys(ref[:junction])) : Dict()
        # ref[:producer] = haskey(ref, :producer) ? Dict(x for x in ref[:producer] if x.second["status"] == 1 && x.second["qg_junc"] in keys(ref[:junction])) : Dict()

        ref[:junction] = Dict(x for x in ref[:junction] if x.second["status"] == 1)
        ref[:consumer] = Dict(x for x in ref[:consumer] if x.second["status"] == 1 && x.second["ql_junc"] in keys(ref[:junction]))
        ref[:producer] = Dict(x for x in ref[:producer] if x.second["status"] == 1 && x.second["qg_junc"] in keys(ref[:junction]))
        ref[:pipe] = haskey(ref, :pipe) ? Dict(x for x in ref[:pipe] if x.second["status"] == 1 && x.second["f_junction"] in keys(ref[:junction]) && x.second["t_junction"] in keys(ref[:junction])) : Dict()
        ref[:pump] = haskey(ref, :pump) ? Dict(x for x in ref[:pump] if x.second["status"] == 1 && x.second["f_junction"] in keys(ref[:junction]) && x.second["t_junction"] in keys(ref[:junction])) : Dict()


        # ref[:junction] = haskey(ref, :junction) ? Dict(x for x in ref[:junction] if x.second["status"] == 1) : Dict()
        # ref[:pipe] = haskey(ref, :pipe) ? Dict(x for x in ref[:pipe] if x.second["status"] == 1 && x.second["f_junction"] in keys(ref[:junction]) && x.second["t_junction"] in keys(ref[:junction])) : Dict()
        # ref[:pump] = haskey(ref, :pump) ? Dict(x for x in ref[:pump] if x.second["status"] == 1 && x.second["f_junction"] in keys(ref[:junction]) && x.second["t_junction"] in keys(ref[:junction])) : Dict()

        ref[:parallel_pipes] = Dict()
        ref[:parallel_pumps] = Dict()
        _add_parallel_edges!(ref[:parallel_pipes], ref[:pipe])
        _add_parallel_edges!(ref[:parallel_pumps], ref[:pump])



        # create references to all connections in the system
        ref[:connection] =  merge(ref[:pipe],ref[:pump])

        check_connection_ids(ref::Dict)

        ref[:junction_connections]    = Dict(i => [] for (i,junction) in ref[:junction])
        ref[:t_connections]           = Dict(i => [] for (i,junction) in ref[:junction])
        ref[:f_connections]           = Dict(i => [] for (i,junction) in ref[:junction])

        for (idx, connection) in ref[:connection]
            i = connection["f_junction"]
            j = connection["t_junction"]
            push!(ref[:junction_connections][i], idx)
            push!(ref[:junction_connections][j], idx)

            push!(ref[:f_connections][i], idx)
            push!(ref[:t_connections][j], idx)
        end


        junction_consumers = Dict([(i, []) for (i,junction) in ref[:junction]])
        junction_dispatchable_consumers = Dict([(i, []) for (i,junction) in ref[:junction]])
        junction_nondispatchable_consumers = Dict([(i, []) for (i,junction) in ref[:junction]])
        for (i,consumer) in ref[:consumer]
            push!(junction_consumers[consumer["ql_junc"]], i)
            if (consumer["dispatchable"] == 1)
                push!(junction_dispatchable_consumers[consumer["ql_junc"]], i)
            else
                push!(junction_nondispatchable_consumers[consumer["ql_junc"]], i)
            end
        end
        ref[:junction_consumers] = junction_consumers
        ref[:junction_dispatchable_consumers] = junction_dispatchable_consumers
        ref[:junction_nondispatchable_consumers] = junction_nondispatchable_consumers

        junction_producers = Dict([(i, []) for (i,junction) in ref[:junction]])
        junction_dispatchable_producers = Dict([(i, []) for (i,junction) in ref[:junction]])
        junction_nondispatchable_producers = Dict([(i, []) for (i,junction) in ref[:junction]])
        for (i,producer) in ref[:producer]
            push!(junction_producers[producer["qg_junc"]], i)
            if (producer["dispatchable"] == 1)
                push!(junction_dispatchable_producers[producer["qg_junc"]], i)
            else
                push!(junction_nondispatchable_producers[producer["qg_junc"]], i)
            end
        end
        ref[:junction_producers] = junction_producers
        ref[:junction_dispatchable_producers] = junction_dispatchable_producers
        ref[:junction_nondispatchable_producers] = junction_nondispatchable_producers

        add_degree(ref)

    end

end

function _add_parallel_edges!(parallel_ref::Dict, collection::Dict)
    for (idx, connection) in collection
        i = connection["f_junction"]
        j = connection["t_junction"]
        f = min(i, j)
        t = max(i, j)
        if get(parallel_ref, (f, t), false) == 1
            push!(parallel_ref[(f, t)], idx)
        else
            parallel_ref[(f, t)] = []
            push!(parallel_ref[(f, t)], idx)
        end
    end
end


"Add reference information for the degree of junction"
function add_degree(ref::Dict{Symbol,Any})
    ref[:degree] = Dict()
    for (i,junction) in ref[:junction]
        ref[:degree][i] = 0
    end

    connections = Set()
    for (i,j) in keys(ref[:parallel_pipes]) push!(connections, (i,j)) end
    for (i,j) in keys(ref[:parallel_pumps]) push!(connections, (i,j)) end

    for (i,j) in connections
        ref[:degree][i] = ref[:degree][i] + 1
        ref[:degree][j] = ref[:degree][j] + 1
    end
end


# "Just make sure there is an empty set for new connections if it does not exist"
function add_default_data(data :: Dict{String,Any})
    nws_data = data["multinetwork"] ? data["nw"] : nws_data = Dict{String,Any}("0" => data)

    for (n,data) in nws_data

        if !haskey(data, "pump")
            data["pump"] = []
        end
        if !haskey(data, "pipe")
            data["pipe"] = []
        end

    end
end

"Utility function for checking if ids of connections are the same"
function check_connection_ids(ref::Dict)
    num_connections = length(ref[:pipe]) + length(ref[:pump])

    if num_connections != length(ref[:connection])
        @error "There are connection elements with non-unique ids"
    end
end
