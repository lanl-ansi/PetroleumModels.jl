##########################################################################################################
# The purpose of this file is to define commonly used and created constraints used in petroleum flow models
##########################################################################################################

" Utility function for adding constraints to a pm.model "
function add_constraint(pm::AbstractPetroleumFormulation, n::Int, key, k, constraint)
    if !haskey(pm.con[:nw][n], key)
        pm.con[:nw][n][key] = Dict{Any,ConstraintRef}()
    end
    pm.con[:nw][n][key][k] = constraint
end

" All constraints associated with flows through at a junction"
constraint_junction_volume_flow_balance_d(pm::AbstractPetroleumFormulation, i::Int) = constraint_junction_volume_flow_balance_d(pm, pm.cnw, i)

constraint_junction_volume_flow_balance_p(pm::AbstractPetroleumFormulation, i::Int) = constraint_junction_volume_flow_balance_p(pm, pm.cnw, i)

constraint_junction_volume_flow_balance(pm::AbstractPetroleumFormulation, i::Int) = constraint_junction_volume_flow_balance(pm, pm.cnw, i)

constraint_node_head(pm::AbstractPetroleumFormulation, i::Int) = constraint_node_head(pm, pm.cnw, i)


" standard flow balance equation where demand is fixed "
constraint_junction_volume_flow_balance_ls(pm::AbstractPetroleumFormulation, i::Int) = constraint_junction_volume_flow_balance_ls(pm, pm.cnw, i)

"Pipe volume flow balance equation "
constraint_nodal_volume_balance(pm::AbstractPetroleumFormulation, i::Int) = constraint_nodal_volume_balance(pm, pm.cnw, i)


" constraints on pump efficiency and rotation"
constraint_pump_efficiency_and_rotation(pm::AbstractPetroleumFormulation, i::Int) = constraint_pump_efficiency_and_rotation(pm, pm.cnw, i)


" standard volume flow balance equation where demand is fixed "
function constraint_junction_volume_flow_balance_d(pm::AbstractPetroleumFormulation, n::Int, i, f_branches, t_branches, ql, consumers, producers)
    q = var(pm,n,:q)
    qg = var(pm,n,:qg)

    add_constraint(pm, n, :junction_volume_flow_balance, i, @constraint(pm.model, sum(qg[a] for a in producers) - ql == sum(q[a]
    for a in f_branches) - sum(q[a] for a in t_branches)))
end

" standard volume flow balance equation where production is fixed "
function constraint_junction_volume_flow_balance_p(pm::AbstractPetroleumFormulation, n::Int, i, f_branches, t_branches, qg, consumers, producers)
    q = var(pm,n,:q)
    ql = var(pm,n,:ql)
    add_constraint(pm, n, :junction_volume_flow_balance, i, @constraint(pm.model, qg - sum(ql[a] for a in consumers) == sum(q[a]
    for a in f_branches) - sum(q[a] for a in t_branches)))
end

" standard volume flow balance equation where demand and production are not fixed "
function constraint_junction_volume_flow_balance(pm::AbstractPetroleumFormulation, n::Int, i, f_branches, t_branches, consumers, producers)
    @show keys(pm.var[:nw][n])
    q = var(pm,n,:q)
    qg = var(pm,n,:qg)
    ql = var(pm,n,:ql)
    add_constraint(pm, n, :junction_volume_flow_balance, i, @constraint(pm.model,sum(qg[a] for a in producers) - sum(ql[a] for a in consumers) == sum(q[a]
    for a in f_branches) - sum(q[a] for a in t_branches)))
end

" standard flow balance equation where demand is fixed "
function constraint_junction_volume_flow_balance_ls(pm::AbstractPetroleumFormulation, n::Int, i, f_branches, t_branches, ql_constant, qg_constant, consumers, producers)
    q  = var(pm,n,:q)
    qg = var(pm,n,:qg)
    add_constraint(pm, n, :junction_volume_flow_balance_ls, i, @constraint(pm.model, qg_constant - ql_constant +
    sum(qg[a] for a in producers) == sum(q[a] for a in f_branches) - sum(q[a] for a in t_branches)))
end



function constraint_node_head(pm::AbstractPetroleumFormulation, n::Int, i::Int, junction)
    H = var(pm,n,:H,i)
    a = pm.ref[:nw][n][:junction][i]["H"]
    if a > 0
    junction_i = pm.ref[:nw][n][:junction][i]["junction_i"]
    H = var(pm,n,:H,junction_i)
    # Add the constraint.
    con(pm, n, :node_head)[i] = JuMP.@constraint(pm.model, H == pm.ref[:nw][n][:junction][junction_i]["H"])

    end
end


#################################################################################################
# Constraints associated with pipes
#################################################################################################

"Pipe volume flow balance equation "
function constraint_nodal_volume_balance(pm::AbstractPetroleumFormulation, n::Int, k, i, j, e, zi, zj)
    inclination_i = zi
    inclination_j = zj
    h_loss = e
    Hi = var(pm,n,:H,i)
    Hj = var(pm,n,:H,j)
    q  = var(pm,n,:q,k)

    add_constraint(pm, n, :nodal_volume_balance, k, @NLconstraint(pm.model, (Hi - Hj) == (inclination_j - inclination_i) + h_loss * q^1.75))
    # @show((inclination_j - inclination_i))
    # con_1 = JuMP.@NLconstraint(pm.model, (Hi - Hj) == (inclination_j - inclination_i) + h_loss * ((q)^1.75))

end

#################################################################################################
# Constraints associated with pumps
#################################################################################################
" constraints on pump efficiency and rotation"
function constraint_pump_efficiency_and_rotation(pm::AbstractPetroleumFormulation, n::Int, k, i, j)
    eta_min = pm.ref[:nw][n][:pump][k]["min_pump_efficiency"]
    eta_max = pm.ref[:nw][n][:pump][k]["max_pump_efficiency"]
    w_min = pm.ref[:nw][n][:pump][k]["min_w"]
    w_max = pm.ref[:nw][n][:pump][k]["max_w"]
    q_nom = pm.ref[:nw][n][:pump][k]["q_nom"]
    w_nom = pm.ref[:nw][n][:pump][k]["w_nom"]
    a = pm.ref[:nw][n][:pump][k]["a"]
    b = pm.ref[:nw][n][:pump][k]["b"]
    delta_Hmax = pm.ref[:nw][n][:pump][k]["delta_Hmax"]
    delta_Hmin = pm.ref[:nw][n][:pump][k]["delta_Hmin"]

    q   = var(pm,n,:q,k)
    w   = var(pm,n,:w,k)
    eta = var(pm,n,:eta,k)
    Hi = var(pm,n,:H,i)
    Hj = var(pm,n,:H,j)



    add_constraint(pm, n, :eta_con, i, @NLconstraint(pm.model, eta == eta_max - (q / q_nom -  w / w_nom)^2 * (w_nom / w)^2 * eta_max))
    add_constraint(pm, n, :pump_head_con, i, @NLconstraint(pm.model, (Hj - Hi) == (w / w_nom)^2 * a -  (q*3600)^2 * b ))
    add_constraint(pm, n, :delta_Hmax_con, i, @constraint(pm.model, delta_Hmax <= (Hj - Hi)))
    add_constraint(pm, n, :delta_Hmin_con, i, @constraint(pm.model, (Hj - Hi) <= delta_Hmin))

end
