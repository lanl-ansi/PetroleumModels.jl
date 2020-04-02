#
# function run_ls(data, model_type, optimizer; kwargs...)
#     return run_model(data, model_type, optimizer, post_ls_;  kwargs...)
# end
function run_ls(data, model_type, optimizer; kwargs...)
    return run_model(data, model_type, optimizer, post_ls_;  kwargs...)
end


function post_ls_1(pm::AbstractPetroleumFormulation)
    variable_head(pm)
    variable_volume_flow(pm)
    variable_pump_rotation(pm)
    variable_pump_efficiency(pm)
    variable_production_volume_flow(pm)
    variable_demand_volume_flow(pm)

    objective_min_expenses_max_benefit(pm)

    for i in ids(pm, :junction)
        constraint_node_head(pm, i)
    end

    for i in ids(pm, :pipe)
        constraint_nodal_volume_balance(pm, i)
    end

    for i in ids(pm, :pump)
        constraint_pump_efficiency_and_rotation(pm, i)

    end

    for i in ids(pm, :junction)
        constraint_junction_volume_flow_balance(pm, i)
    end


end

" construct the feasbility problem "
function post_ls_(pm::AbstractPetroleumFormulation)
network_ids = sort(collect(nw_ids(pm)))
# num_time_points = length(keys(pm.ref[:nw]))

# println("num_time_points=",num_time_points)
# @show(num_time_points)

# println("here=",nws(pm))
# @show(nws(pm))
    # for (n, data) in nws(pm)
    #     @show n
    # end
for (n, data) in nws(pm)

    variable_head(pm, n=n)
    variable_volume_flow(pm, n=n)
    variable_pump_rotation(pm, n=n)
    variable_pump_efficiency(pm, n=n)
    variable_production_volume_flow(pm, n=n)
    variable_demand_volume_flow(pm, n=n)
    # @show var(pm, n, :q)
# network_ids = sort(collect(nw_ids(pm)))

    for i in ids(pm, n, :junction)
        constraint_junction_volume_flow_balance(pm, n, i)
    end

    for i in ids(pm, n, :junction)
        constraint_node_head(pm, n, i)

    end

    for i in ids(pm, n, :pipe)
        constraint_nodal_volume_balance(pm, n, i)
    end

    for i in ids(pm, n, :pump)
        constraint_pump_efficiency_and_rotation(pm, n, i)

    end
end

objective_min_expenses_max_benefit(pm)
end

# Get all the load shedding solution values
function get_ls_solution(pm::AbstractPetroleumFormulation,sol::Dict{String,Any})

    add_connection_flow_setpoint(sol, pm)
    add_junction_head_setpoint(pm, i, nw=n)
    # add_direction_setpoint(sol, pm)
    add_load_volume_flow_setpoint(sol, pm)
    # add_load_mass_flow_setpoint(sol, pm)
    add_production_volume_flow_setpoint(sol, pm)

    # add_dual_head!(sol, pm)
    # add_production_mass_flow_setpoint(sol, pm)
    # add_compressor_ratio_setpoint(sol, pm)
    println("RESULTS2_____________________")
end
