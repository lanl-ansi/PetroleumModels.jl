
function run_ls(file, model_type, optimizer; kwargs...)
    return run_model(file, model_type, optimizer, build_ls; kwargs...)
end

function build_ls(pm::AbstractPetroleumModel)
    variable_head(pm)
    variable_volume_flow_pipe(pm)
    variable_volume_flow_pump(pm)
    variable_pump_rotation(pm)
    variable_pump_efficiency(pm)
    variable_production_volume_flow(pm)
    variable_demand_volume_flow(pm)
    variable_tank_in(pm)
    variable_tank_out(pm)

    objective_min_expenses_max_benefit(pm)

    # for i in ids(pm, :junction)
    #     constraint_node_head(pm, i)
    # end

    for i in ids(pm, :pipe)
        constraint_nodal_volume_balance(pm, i)
    end

    for i in ids(pm, :pump)
        constraint_pump_efficiency_and_rotation(pm, i)
    end

    for i in ids(pm, :junction)
        constraint_junction_volume_flow_balance(pm, i)
    end

    # for i in ids(pm, :tank)
    #     constraint_tank_volume_balance(pm, i)
    # end


end

" construct the feasbility problem "
function post_ls_(pm::AbstractPetroleumModel)
network_ids = sort(collect(nw_ids(pm)))

for (n, data) in nws(pm)

    variable_head(pm, n=n)
    variable_volume_flow(pm, n=n)
    variable_pump_rotation(pm, n=n)
    variable_pump_efficiency(pm, n=n)
    variable_production_volume_flow(pm, n=n)
    variable_demand_volume_flow(pm, n=n)
    variable_tank_in(pm, n=n)
    variable_tank_out(pm, n=n)
    # @show var(pm, n, :q)
# network_ids = sort(collect(nw_ids(pm)))

    for i in ids(pm, n, :junction)
        constraint_junction_volume_flow_balance(pm, n, i)
    end
    #
    # for i in ids(pm, n, :junction)
    #     constraint_node_head(pm, n, i)
    #
    # end

    for i in ids(pm, n, :pipe)
        constraint_nodal_volume_balance(pm, n, i)
    end

    for i in ids(pm, n, :pump)
        constraint_pump_efficiency_and_rotation(pm, n, i)
    end

    # for i in ids(pm, n, :tank)
    #     constraint_tank_volume_balance(pm, n, i)
    # end
end

objective_min_expenses_max_benefit(pm)

end

# Get all the load shedding solution values
function get_ls_solution(pm::AbstractPetroleumModel,sol::Dict{String,Any})

    add_connection_flow_setpoint(sol, pm)
    add_junction_head_setpoint(pm, i, nw=n)
    add_load_volume_flow_setpoint(sol, pm)
    add_production_volume_flow_setpoint(sol, pm)

end
