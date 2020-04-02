function run_ne(file, model_type, optimizer; kwargs...)
    return run_model(file, model_type, optimizer, post_ne; solution_builder = solution_ne, kwargs...)
end

# function run_owf(network, model_constructor, optimizer; kwargs...)
#     return run_model(network, model_constructor, optimizer, post_owf; kwargs...)
# end

function post_ne(pm::AbstractPetroleumFormulation; kwargs...)
    # Create head loss functions, if necessary.

    objective_min_expenses_max_benefit(pm)

    for (n, file) in nws(pm)
        variable_volume_flow(pm, nw=n)
        variable_head(pm, nw=n)
        variable_pump_rotation(pm, nw=n)
        variable_pump_efficiency(pm, nw=n)
        variable_production_volume_flow(pm, nw=n)
        variable_demand_volume_flow(pm, nw=n)

        for (a, pipe) in ref(pm, :pipe, nw=n)
            constraint_nodal_volume_balance(pm, a, nw=n)
        end

        for a in ids(pm, :pump, nw=n)
            constraint_pump_efficiency_and_rotation(pm, a, nw=n)
        end

        for (i, junction) in ref(pm, :junction, nw=n)
            constraint_node_head(pm, i, nw=n)
        end

        for (i, junction) in ref(pm, :junction, nw=n)
            constraint_junction_volume_flow_balance(pm, i, nw=n)
        end

    end
end
    # Get all the load shedding solution values
    function solution_ne(pm::AbstractPetroleumFormulation,sol::Dict{String,Any})
        add_junction_head_setpoint(sol, pm)
        add_connection_flow_setpoint(sol, pm)

        add_load_volume_flow_setpoint(sol, pm)
        # add_load_mass_flow_setpoint(sol, pm)
        add_production_volume_flow_setpoint(sol, pm)


    end
network_ids = sort(collect(nw_ids(pm)))
