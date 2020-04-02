
function run_ls(file, model_type, optimizer; kwargs...)
    return run_model(file, model_type, optimizer, post_ls_; solution_builder = get_ls_solution, kwargs...)
end

" construct the feasbility problem "
function post_ls_(pm::AbstractPetroleumFormulation)
network_ids = sort(collect(nw_ids(pm)))
num_time_points = length(keys(pm.ref[:nw]))
printl("num_time_points=",num_time_points)
@show(num_time_points)
for (n, file) in nws(pm)

    variable_volume_flow(pm, n=n)
    variable_head(pm, n=n)
    variable_pump_rotation(pm, n=n)
    variable_pump_efficiency(pm, n=n)
    variable_production_volume_flow(pm, n=n)
    variable_demand_volume_flow(pm, n=n)
end

    objective_min_expenses_max_benefit(pm)


    for i in ids(pm, :junction, n=n)
        constraint_junction_volume_flow_balance(pm, i)
    end

    for i in ids(pm, :junction, n=n)
        constraint_node_head(pm, i)
    end

    for i in ids(pm, :pipe, n=n)
        constraint_nodal_volume_balance(pm, i)
    end

    for i in ids(pm, :pump, n=n)
        constraint_pump_efficiency_and_rotation(pm, i)

    end


end

# Get all the load shedding solution values
function get_ls_solution(pm::AbstractPetroleumFormulation,sol::Dict{String,Any})
    add_junction_head_setpoint(sol, pm)
    add_connection_flow_setpoint(sol, pm)
    # add_direction_setpoint(sol, pm)
    add_load_volume_flow_setpoint(sol, pm)
    # add_load_mass_flow_setpoint(sol, pm)
    add_production_volume_flow_setpoint(sol, pm)

    # add_dual_head!(sol, pm)
    # add_production_mass_flow_setpoint(sol, pm)
    # add_compressor_ratio_setpoint(sol, pm)
    println("RESULTS2_____________________")
end
