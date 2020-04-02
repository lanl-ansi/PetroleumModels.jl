#
# Constraint Template Definitions
#
# Constraint templates help simplify data wrangling across multiple petroleum
# Flow formulations by providing an abstraction layer between the network data
# and network constraint definitions.  The constraint template's job is to
# extract the required parameters from a given network data structure and
# pass the data as named arguments to the petroleum Flow formulations.
#
# Constraint templates should always be defined over "AbstractPetroleumFormulation"
# and should never refer to model variables

#################################################################################################
# Templates for constraints associated with junctions
#################################################################################################
" standard flow balance equation where demand is fixed "
function constraint_junction_volume_flow_balance_d(pm::AbstractPetroleumFormulation, n::Int, i)
    junction   = ref(pm,n,:junction,i)
    consumer   = ref(pm,n,:consumer)
    producer   = ref(pm,n,:producer)
    consumers  = ref(pm,n,:junction_consumers,i)
    producers  = ref(pm,n,:junction_producers,i)
    f_branches = ref(pm,n,:f_connections,i)
    t_branches = ref(pm,n,:t_connections,i)

    qg         = length(producers) > 0 ? sum(calc_qg(pm.data,producer[j]) for j in producers) : 0
    ql         = length(consumers) > 0 ? sum(calc_ql(pm.data,consumer[j]) for j in consumers) : 0
    constraint_junction_volume_flow_balance_d(pm, n, i, f_branches, t_branches, ql, consumers, producers)
end
constraint_junction_volume_flow_balance_d(pm::AbstractPetroleumFormulation, i::Int) = constraint_junction_volume_flow_balance_d(pm, pm.cnw, i)

" standard flow balance equation where production is fixed "
function constraint_junction_volume_flow_balance_p(pm::AbstractPetroleumFormulation, n::Int, i)
    junction   = ref(pm,n,:junction,i)
    consumer   = ref(pm,n,:consumer)
    producer   = ref(pm,n,:producer)
    consumers  = ref(pm,n,:junction_consumers,i)
    producers  = ref(pm,n,:junction_producers,i)
    f_branches = ref(pm,n,:f_connections,i)
    t_branches = ref(pm,n,:t_connections,i)

    qg         = length(producers) > 0 ? sum(calc_qg(pm.data,producer[j]) for j in producers) : 0
    ql         = length(consumers) > 0 ? sum(calc_ql(pm.data,consumer[j]) for j in consumers) : 0
    constraint_junction_volume_flow_balance_p(pm, n, i, f_branches, t_branches, qg, consumers, producers)
end
constraint_junction_volume_flow_balance_p(pm::AbstractPetroleumFormulation, i::Int) = constraint_junction_volume_flow_balance_p(pm, pm.cnw, i)

" standard flow balance equation where demand and production are fixed "
function constraint_junction_volume_flow_balance(pm::AbstractPetroleumFormulation, n::Int, i)
    junction   = ref(pm,n,:junction,i)
    consumer   = ref(pm,n,:consumer)
    producer   = ref(pm,n,:producer)
    consumers  = ref(pm,n,:junction_consumers,i)
    producers  = ref(pm,n,:junction_producers,i)
    f_branches = ref(pm,n,:f_connections,i)
    t_branches = ref(pm,n,:t_connections,i)
    # qg         = length(producers) > 0 ? sum(calc_qg(pm.data,producer[j]) for j in producers) : 0
    # ql         = length(consumers) > 0 ? sum(calc_ql(pm.data,consumer[j]) for j in consumers) : 0
    constraint_junction_volume_flow_balance(pm, n, i, f_branches, t_branches, consumers, producers)
end
constraint_junction_volume_flow_balance(pm::AbstractPetroleumFormulation, i::Int) = constraint_junction_volume_flow_balance(pm, pm.cnw, i)



function constraint_node_head(pm::AbstractPetroleumFormulation, n::Int, i)
    # Create the constraint dictionary if necessary.
    if !haskey(con(pm, n), :node_head)
        con(pm, n)[:node_head] = Dict{Int, JuMP.ConstraintRef}()
    end
    junction   = ref(pm,n,:junction,i)

    constraint_node_head(pm, n, i, junction)
end



" Template: Constraints for flow balance equation where demand and production are a mix of constants and variables"
function constraint_junction_volume_flow_balance_ls(pm::AbstractPetroleumFormulation, n::Int, i)
    junction      = ref(pm,n,:junction,i)
    f_branches    = ref(pm,n,:f_connections,i)
    t_branches    = ref(pm,n,:t_connections,i)
    consumer      = ref(pm,n,:consumer)
    producer      = ref(pm,n,:producer)
    consumers     = ref(pm,n,:junction_consumers,i)
    producers     = ref(pm,n,:junction_producers,i)
    dispatch_producers      = ref(pm,n,:junction_dispatchable_producers,i)
    nondispatch_producers   = ref(pm,n,:junction_nondispatchable_producers,i)
    dispatch_consumers      = ref(pm,n,:junction_dispatchable_consumers,i)
    nondispatch_consumers   = ref(pm,n,:junction_nondispatchable_consumers,i)

    qg = length(nondispatch_producers) > 0 ? sum(calc_qg(pm.data, producer[j]) for j in nondispatch_producers) : 0
    ql = length(nondispatch_consumers) > 0 ? sum(calc_ql(pm.data, consumer[j]) for j in nondispatch_consumers) : 0

    constraint_junction_volume_flow_balance_ls(pm, n, i, f_branches, t_branches, ql, qg, dispatch_consumers, dispatch_producers)
end
constraint_junction_volume_flow_balance_ls(pm::AbstractPetroleumFormulation, i::Int) = constraint_junction_volume_flow_balance_ls(pm, pm.cnw, i)

function constraint_nodal_volume_balance(pm::AbstractPetroleumFormulation, n::Int, k; pipe_head_loss = calc_head_loss)

    # @show ids(pm, n, :connection), k
    pipe = ref(pm,n,:connection,k)
        i    = pipe["f_junction"]
        j    = pipe["t_junction"]

        e  = pipe_head_loss(pm.data, pipe)
        zi = ref(pm,n,:junction, i)["z"]
        zj = ref(pm,n,:junction, j)["z"]

        constraint_nodal_volume_balance(pm, n, k, i, j, e, zi, zj)

end
constraint_nodal_volume_balance(pm::AbstractPetroleumFormulation, k::Int) = constraint_nodal_volume_balance(pm, pm.cnw, k)


"head_loss equation "
function constraint_head_loss(pm::AbstractPetroleumFormulation, n::Int, k; pipe_head_loss = calc_head_loss)
    pipe = ref(pm,n,:connection,k)
    i = pipe["f_junction"]
    j = pipe["t_junction"]
    mf = pm.ref[:nw][n][:max_volume_flow]
    e  = haskey(pm.ref[:nw][n][:pipe], k) : pipe_head_loss(pm.data, pipe)
    z  = junction["elevation"]

    constraint_head_loss(pm, n, k, i, j, mf, e, z)
end
constraint_head_loss(pm::AbstractPetroleumFormulation, k::Int) = constraint_head_loss(pm, pm.cnw, k)



#################################################################################################
# Templates for constraints associated with pumps
#################################################################################################
function constraint_pump_efficiency_and_rotation(pm::AbstractPetroleumFormulation, n::Int, k)
    pump = ref(pm, n, :connection, k)

    i        = pump["f_junction"]
    j        = pump["t_junction"]

    constraint_pump_efficiency_and_rotation(pm, n, k, i, j)
end
constraint_pump_efficiency_and_rotation(pm::AbstractPetroleumFormulation, k::Int) = constraint_pump_efficiency_and_rotation(pm, pm.cnw, k)
