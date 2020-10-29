#
# Constraint Template Definitions
#
# Constraint templates help simplify data wrangling across multiple petroleum
# Flow formulations by providing an abstraction layer between the network data
# and network constraint definitions.  The constraint template's job is to
# extract the required parameters from a given network data structure and
# pass the data as named arguments to the petroleum Flow formulations.
#
# Constraint templates should always be defined over "AbstractPetroleumModel"
# and should never refer to model variables

#################################################################################################
# Templates for constraints associated with volume flow through junctions
#################################################################################################
" standard flow balance equation where demand is fixed "
function constraint_junction_volume_flow_balance_d(pm::AbstractPetroleumModel, i; n::Int=pm.cnw)

    producer                = ref(pm,n,:producer)
    consumer                = ref(pm,n,:consumer)
    junction                = ref(pm,n,:junction,i)
    f_tanks                 = ref(pm,n,:tanks_fr,i)
    t_tanks                 = ref(pm,n,:tanks_to,i)
    f_pipes                = ref(pm,n,:pipes_fr,i)
    t_pipes                = ref(pm,n,:pipes_to,i)
    f_pumps                = ref(pm,n,:pumps_fr,i)
    t_pumps                = ref(pm,n,:pumps_to,i)
    dispatch_consumers     = ref(pm,n,:dispatchable_consumers_in_junction,i)
    nondispatch_consumers  = ref(pm,n,:nondispatchable_consumers_in_junction,i)
    dispatch_producers     = ref(pm,n,:dispatchable_producers_in_junction,i)
    nondispatch_producers  = ref(pm,n,:nondispatchable_producers_in_junction,i)
    dispatch_transfers     = ref(pm,n,:dispatchable_transfers_in_junction,i)
    qg                      = length(dispatch_producers) > 0 ? sum(producer[j]["qg"] for j in dispatch_producers) : 0
    ql                      = length(dispatch_consumers) > 0 ? sum(consumer[j]["ql"] for j in dispatch_consumers) : 0

    constraint_junction_volume_flow_balance_d(pm, n, i, f_pipes, t_pipes, f_tanks, t_tanks, f_pumps, t_pumps, ql, dispatch_producers, dispatch_consumers)
end

" standard flow balance equation where production is fixed "
function constraint_junction_volume_flow_balance_p(pm::AbstractPetroleumModel, i; n::Int=pm.cnw)

    producer                = ref(pm,n,:producer)
    consumer                = ref(pm,n,:consumer)
    junction                = ref(pm,n,:junction,i)
    f_tanks                 = ref(pm,n,:tanks_fr,i)
    t_tanks                 = ref(pm,n,:tanks_to,i)
    f_pipes                 = ref(pm,n,:pipes_fr,i)
    t_pipes                 = ref(pm,n,:pipes_to,i)
    f_pumps           = ref(pm,n,:pumps_fr,i)
    t_pumps           = ref(pm,n,:pumps_to,i)
    dispatch_consumers       = ref(pm,n,:dispatchable_consumers_in_junction,i)
    nondispatch_consumers    = ref(pm,n,:nondispatchable_consumers_in_junction,i)
    dispatch_producers     = ref(pm,n,:dispatchable_producers_in_junction,i)
    nondispatch_producers  = ref(pm,n,:nondispatchable_producers_in_junction,i)
    dispatch_transfers      = ref(pm,n,:dispatchable_transfers_in_junction,i)
    qg                      = length(dispatch_producers) > 0 ? sum(producer[j]["qg"] for j in dispatch_producers) : 0
    ql                      = length(dispatch_consumers) > 0 ? sum(consumer[j]["ql"] for j in dispatch_consumers) : 0
    constraint_junction_volume_flow_balance_p(pm, n, i, f_pipes, t_pipes, f_tanks, t_tanks, f_pumps, t_pumps, qg, dispatch_producers, dispatch_consumers)
end


" standard flow balance equation where demand and production are not fixed "
function constraint_junction_volume_flow_balance(pm::AbstractPetroleumModel, i; n::Int=pm.cnw)

    producer                = ref(pm,n,:producer)
    consumer                = ref(pm,n,:consumer)
    junction                = ref(pm,n,:junction,i)
    f_tanks                 = ref(pm,n,:tanks_fr,i)
    t_tanks                 = ref(pm,n,:tanks_to,i)
    f_pipes                 = ref(pm,n,:pipes_fr,i)
    t_pipes                 = ref(pm,n,:pipes_to,i)
    f_pumps                 = ref(pm,n,:pumps_fr,i)
    t_pumps                 = ref(pm,n,:pumps_to,i)
    dispatch_consumers      = ref(pm,n,:dispatchable_consumers_in_junction,i)
    nondispatch_consumers   = ref(pm,n,:nondispatchable_consumers_in_junction,i)
    dispatch_producers     = ref(pm,n,:dispatchable_producers_in_junction,i)
    nondispatch_producers  = ref(pm,n,:nondispatchable_producers_in_junction,i)
    qg                      = length(dispatch_producers) > 0 ? sum(producer[j]["qg"] for j in dispatch_producers) : 0
    ql                      = length(dispatch_consumers) > 0 ? sum(consumer[j]["ql"] for j in dispatch_consumers) : 0

    constraint_junction_volume_flow_balance(pm, n, i, f_pipes, t_pipes, f_tanks, t_tanks, f_pumps, t_pumps, dispatch_producers, dispatch_consumers)

end

#################################################################################################
# Constraints associated with pipes
#################################################################################################

function constraint_nodal_volume_balance(pm::AbstractPetroleumModel, n::Int, k)
        pipe = ref(pm,n,:pipe,k)
        i    = pipe["fr_junction"]
        j    = pipe["to_junction"]
        beta = pm.data["beta"]
        nu = pm.data["nu"]
        D = pipe["diameter"]
        L = pipe["length"]
        zi = ref(pm,n,:junction, i)["z"]
        zj = ref(pm,n,:junction, j)["z"]
        Q_pipe_dim = pm.data["Q_pipe_dim"]
        constraint_nodal_volume_balance(pm, n, k, i, j, beta, nu, D, L, zi, zj, Q_pipe_dim)


end
constraint_nodal_volume_balance(pm::AbstractPetroleumModel, k::Int) = constraint_nodal_volume_balance(pm, pm.cnw, k)

#################################################################################################
# Constraints associated with pumps
#################################################################################################

function constraint_pump_efficiency_and_rotation(pm::AbstractPetroleumModel, n::Int, k)
    pump    = ref(pm, n, :pump, k)
    i       = pump["fr_junction"]
    j       = pump["to_junction"]
    eta_min = pm.ref[:nw][n][:pump][k]["pump_efficiency_min"]
    eta_max = pm.ref[:nw][n][:pump][k]["pump_efficiency_max"]
    w_min = pm.ref[:nw][n][:pump][k]["rotation_min"]
    w_max = pm.ref[:nw][n][:pump][k]["rotation_max"]
    flow_nom = pm.ref[:nw][n][:pump][k]["flow_nom"]
    w_nom = pm.ref[:nw][n][:pump][k]["w_nom"]
    a = pm.ref[:nw][n][:pump][k]["a"]
    b = pm.ref[:nw][n][:pump][k]["b"]
    delta_head_max = pm.ref[:nw][n][:pump][k]["delta_head_max"]
    delta_head_min = pm.ref[:nw][n][:pump][k]["delta_head_min"]
    Q_pump_dim = pm.data["Q_pump_dim"]
    constraint_pump_efficiency_and_rotation(pm, n, k, i, j, eta_min, eta_max, w_min, w_max, flow_nom, w_nom, a, b, delta_head_min, delta_head_max, Q_pump_dim)
end
constraint_pump_efficiency_and_rotation(pm::AbstractPetroleumModel, k::Int) = constraint_pump_efficiency_and_rotation(pm, pm.cnw, k)

#################################################################################################
# Constraints associated with tanks
#################################################################################################
#
# "tanks"
# function constraint_tank_volume_balance(pm::AbstractPetroleumModel, n::Int, k; tank_head_initial = calc_tank_head_initial)
#         tank = ref(pm,n,:connection,k)
#         i = tank["fr_junction"]
#         j = tank["to_junction"]
#         f_tanks = ref(pm,n,:f_tanks,i)
#         t_tanks = ref(pm,n,:t_tanks,i)
#         # q_tank = length(tanks) > 0 ? sum(calc_qg(pm.data,tank[j]) for j in tanks) : 0
#         Initial_Volume = ref(pm,n,:tank, k)["Initial_Volume"]
#         # Min_Capacity_Limitation = ref(pm,n,:tank, k)["Min_Capacity_Limitation"]
#         # Max_Capacity_Limitation = ref(pm,n,:tank, k)["Max_Capacity_Limitation"]
#         # offtake_min = ref(pm,n,:tank, k)["offtake_min"]
#         # offtake_max = ref(pm,n,:tank, k)["offtake_max"]
#         # Time = ref(pm,n,:tank, k)["time"]
#         Cd   = ref(pm,n,:tank, k)["Cd"]
#         Hi   = ref(pm,n,:tank, k)["vessel_pressure_head"]
#         Hj   = tank_head_initial(pm.data, tank)
#         constraint_tank_volume_balance(pm, n, k, i, j, f_tanks, Cd, Hi, Hj, Initial_Volume)
#
# end
# constraint_tank_volume_balance(pm::AbstractPetroleumModel, k::Int) = constraint_tank_volume_balance(pm, pm.cnw, k, i, j, f_tanks, Cd, Hi, Hj, Initial_Volume)
