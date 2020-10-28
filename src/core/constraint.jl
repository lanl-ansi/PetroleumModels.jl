##########################################################################################################
# The purpose of this file is to define commonly used and created constraints used in petroleum flow models
##########################################################################################################

" Utility function for adding constraints to a pm.model "
function _add_constraint!(pm::AbstractPetroleumModel, n::Int, key, i, constraint)
    if !haskey(pm.con[:nw][n], key)
        pm.con[:nw][n][key] = Dict{Any,JuMP.ConstraintRef}()
    end
    pm.con[:nw][n][key][i] = constraint
end

##########################################################################################################
# Constraints associated with volume flow
##########################################################################################################

" standard volume flow balance equation where demand is fixed "
function constraint_junction_volume_flow_balance_d(pm::AbstractPetroleumModel, n::Int, i, f_pipes, t_pipes,  f_tanks, t_tanks, f_pumps, t_pumps, ql, producers, consumers)
    qg = var(pm,n,:qg)
    q_tank_in  = var(pm,n,:q_tank_in)
    q_tank_out = var(pm,n,:q_tank_out)
    q_pump = var(pm,n,:q_pump)
    q_pipe = var(pm,n,:q_pipe)
    @show( sum(q_tank_out[a] for a in f_tanks))
    _add_constraint!(pm, n, :junction_volume_flow_balance, i, JuMP.@constraint(pm.model, sum(qg[a] for a in producers) - ql ==
                                                                          sum(q_pipe[a] for a in f_pipes) - sum(q_pipe[a] for a in t_pipes) +
                                                                          sum(q_pump[a] for a in f_pumps) - sum(q_pump[a] for a in t_pumps) +
                                                                          sum(q_tank_out[a] for a in f_tanks) - sum(q_tank_in[a] for a in t_tanks)
                                                                      ))
end

" standard volume flow balance equation where production is fixed "
function constraint_junction_volume_flow_balance_p(pm::AbstractPetroleumModel, n::Int, i, f_pipes, t_pipes, f_tanks, t_tanks, f_pumps, t_pumps, qg, producers, consumers)

    q_tank_in  = var(pm,n,:q_tank_in)
    q_tank_out = var(pm,n,:q_tank_out)
    ql = var(pm,n,:ql)
    q_pump = var(pm,n,:q_pump)
    q_pipe = var(pm,n,:q_pipe)
    _add_constraint!(pm, n, :junction_volume_flow_balance, i, JuMP.@constraint(pm.model, qg - sum(ql[a] for a in consumers) ==
                                                                          sum(q_pipe[a] for a in f_pipes) - sum(q_pipe[a] for a in t_pipes) +
                                                                          sum(q_pump[a] for a in f_pumps) - sum(q_pump[a] for a in t_pumps) +
                                                                          sum(q_tank_out[a] for a in f_tanks) - sum(q_tank_in[a] for a in t_tanks)
                                                                      ) )
end

" standard volume flow balance equation where demand and production are not fixed "
# function constraint_junction_volume_flow_balance(pm::AbstractPetroleumModel, n::Int, i, f_branches, t_branches, f_tanks, t_tanks, producers, consumers)
function constraint_junction_volume_flow_balance(pm::AbstractPetroleumModel, n::Int, i, f_pipes, t_pipes, f_tanks, t_tanks, f_pumps, t_pumps, producers, consumers)

    q_tank_in  = var(pm,n,:q_tank_in)
    q_tank_out = var(pm,n,:q_tank_out)
    qg = var(pm,n,:qg)
    ql = var(pm,n,:ql)
    q_pump = var(pm,n,:q_pump)
    q_pipe = var(pm,n,:q_pipe)
    _add_constraint!(pm, n, :junction_volume_flow_balance, i, JuMP.@constraint(pm.model, sum(qg[a] for a in producers) - sum(ql[b] for b in consumers) ==
                                                                          sum(q_pipe[a] for a in f_pipes) - sum(q_pipe[a] for a in t_pipes) +
                                                                          sum(q_pump[a] for a in f_pumps) - sum(q_pump[a] for a in t_pumps)  +
                                                                          sum(q_tank_out[a] for a in f_tanks) - sum(q_tank_in[a] for a in t_tanks)
                                                                      ) )
end

##########################################################################################################
# Constraints associated with junctions
##########################################################################################################



#################################################################################################
# Constraints associated with pipes
#################################################################################################

"Pipe volume flow balance equation "
function constraint_nodal_volume_balance(pm::AbstractPetroleumModel, n::Int, k, i, j, beta, nu, D, L, zi, zj, Q_pipe_dim)
        elevation_i = zi
        elevation_j = zj
        Hi = var(pm,n,:H,i)
        Hj = var(pm,n,:H,j)
        q  = var(pm,n,:q_pipe,k)
        _add_constraint!(pm, n, :nodal_volume_balance, k, JuMP.@NLconstraint(pm.model, (Hi - Hj) == (elevation_j - elevation_i) + (beta * nu^0.25 / D^4.75 * L * 1.02) * (q / Q_pipe_dim)^1.75))
    end

#################################################################################################
# Constraints associated with pumps
#################################################################################################

" constraints on pump efficiency and rotation"
function constraint_pump_efficiency_and_rotation(pm::AbstractPetroleumModel, n::Int, k, i, j, eta_min, eta_max, w_min, w_max, q_nom, w_nom, a, b, delta_Hmin, delta_Hmax, Q_pump_dim)
    q_pump   = var(pm,n,:q_pump,k)
    w_pump   = var(pm,n,:w,k)
    eta      = var(pm,n,:eta,k)
    Hi       = var(pm,n,:H,i)
    Hj       = var(pm,n,:H,j)

    _add_constraint!(pm, n, :eta_con, i, JuMP.@NLconstraint(pm.model, eta == eta_max - (q_pump / q_nom -  w_pump / w_nom)^2 * (w_nom / w_pump)^2 * eta_max))
    _add_constraint!(pm, n, :pump_head_con, i, JuMP.@constraint(pm.model, (Hj - Hi) == (w_pump / w_nom)^2 * a -  (q_pump * Q_pump_dim )^2 * b ))
    _add_constraint!(pm, n, :delta_Hmax_con, i, JuMP.@constraint(pm.model, delta_Hmax <= (Hj - Hi)))
    _add_constraint!(pm, n, :delta_Hmin_con, i, JuMP.@constraint(pm.model, (Hj - Hi) <= delta_Hmin))
end

#################################################################################################
# Constraints associated with tanks
#################################################################################################

# "Tank volume flow balance equation "
# function constraint_tank_volume_balance(pm::AbstractPetroleumModel, n::Int, k, i, j, f_tanks, Cd, Hi, Hj, Initial_Volume)
#     g   = pm.data["gravitational_acceleration"]
#     d_pipe = 0.375
#     @show(Hi)
#     q_tank = var(pm,n,:q_tank)
#     # _add_constraint!(pm, n, :tank_time_con, j, @constraint(pm.model,    Time == Initial_Volume / (f_q_tank[a] for a in f_tanks) ) )
#     # _add_constraint!(pm, n, :tank_outflow_con, j, @NLconstraint(pm.model, (f_q_tank[a] for a in f_tanks) == (((Hj - 0.5) - Hi) * (2 * g *(Cd * pi * (d_pipe)^2)^2 ))^0.5 ))
#     for a in f_tanks
#     #volume flow -> volume for every hour
#     add_constraint(pm, n, :tank_time_con, j, @constraint(pm.model,    Time == Initial_Volume / (f_q_tank[a] ) ) )
#     add_constraint(pm, n, :tank_outflow_con, j, @NLconstraint(pm.model, f_q_tank[a] == (((Hj - 0.5) - Hi) * (2 * g *(discharge_coefficient * pi * (d_pipe)^2)^2 ))^0.5 ))
#     end
# end
