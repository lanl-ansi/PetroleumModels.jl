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
# Constraints associated with junctions
##########################################################################################################

" Constraint for balancing volumetric flow a function (nodes) "
function constraint_junction_volume_flow_balance(pm::AbstractPetroleumModel, n::Int, i, f_pipes, t_pipes, f_tanks, t_tanks, f_pumps, t_pumps, producers, consumers, qg_f, ql_f)

    qin  = var(pm,n,:qin)
    qoff = var(pm,n,:qoff)
    qg = var(pm,n,:qg)
    ql = var(pm,n,:ql)
    q_pump = var(pm,n,:q_pump)
    q_pipe = var(pm,n,:q_pipe)
    _add_constraint!(pm, n, :junction_volume_flow_balance, i, JuMP.@constraint(pm.model, qg_f - ql_f + sum(qg[a] for a in producers) - sum(ql[b] for b in consumers) ==
                                                                          sum(q_pipe[a] for a in f_pipes) - sum(q_pipe[a] for a in t_pipes) +
                                                                          sum(q_pump[a] for a in f_pumps) - sum(q_pump[a] for a in t_pumps)  +
                                                                          sum(qoff[a] for a in f_tanks) - sum(qin[a] for a in t_tanks))
                    )
end


#################################################################################################
# Constraints associated with pipes
#################################################################################################

" Leibenzon model for pipeline physics "
function constraint_leibenzon(pm::AbstractPetroleumModel, n::Int, k, i, j, lambda, zi, zj, m)
    hi = var(pm,n,:h,i)
    hj = var(pm,n,:h,j)
    q  = var(pm,n,:q_pipe,k)
    _add_constraint!(pm, n, :leibenzon, k, JuMP.@NLconstraint(pm.model, (hi - hj) == (zj - zi) + (lambda * q^(2.0-m))))
end

#################################################################################################
# Constraints associated with pumps
#################################################################################################

" constraints on pump efficiency and rotation"
function constraint_pump_efficiency_and_rotation(pm::AbstractPetroleumModel, n::Int, k, i, j, eta_min, eta_max, w_min, w_max, flow_nom, w_nom, a, b, delta_head_min, delta_head_max, Q_pump_dim)
    q_pump   = var(pm,n,:q_pump,k)
    w_pump   = var(pm,n,:w,k)
    eta      = var(pm,n,:eta,k)
    hi       = var(pm,n,:h,i)
    hj       = var(pm,n,:h,j)

    _add_constraint!(pm, n, :eta_con,            i, JuMP.@NLconstraint(pm.model, eta == eta_max - (q_pump / flow_nom -  w_pump / w_nom)^2 * (w_nom / w_pump)^2 * eta_max))
    _add_constraint!(pm, n, :pump_head_con,      i, JuMP.@constraint(pm.model,   (hj - hi) == (w_pump / w_nom)^2 * a -  (q_pump * Q_pump_dim )^2 * b ))
    _add_constraint!(pm, n, :delta_head_max_con, i, JuMP.@constraint(pm.model,   delta_head_min <= (hj - hi)))
    _add_constraint!(pm, n, :delta_head_min_con, i, JuMP.@constraint(pm.model,   (hj - hi) <= delta_head_max))
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
