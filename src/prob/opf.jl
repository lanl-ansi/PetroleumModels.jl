
"entry point for running the optimal petroleum flow problem"
function run_opf(file, model_type, optimizer; kwargs...)
    return run_model(file, model_type, optimizer, build_opf; kwargs...)
end

"construct the optimal petroleum flow problem"
function build_opf(pm::AbstractPetroleumModel)
    variable_head(pm)
    variable_volume_flow_pipe(pm)
    variable_volume_flow_pump(pm)
    variable_pump_rotation(pm)
    variable_pump_efficiency(pm)
    variable_production_volume_flow(pm)
    variable_demand_volume_flow(pm)
    variable_tank_intake(pm)
    variable_tank_offtake(pm)

    objective_min_expenses_max_benefit(pm)

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
