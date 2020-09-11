# Definitions for running a feasible Petroleum flow

"entry point into running the liquid flow feasability problem"
function run_lf(file, model_type, optimizer; kwargs...)
    return run_model(file, model_type, optimizer, build_lf; kwargs...)
end


""
function run_soc_lf(file, optimizer; kwargs...)
    return run_lf(file, MISOCPPetroleumModel, optimizer; kwargs...)
end


""
function run_minlp_lf(file, optimizer; kwargs...)
    return run_lf(file, MINLPPetroleumModel, optimizer; kwargs...)
end


"construct the petroleum flow feasbility problem"
function build_lf(pm::AbstractPetroleumModel)
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

    for i in ids(pm, :junction)
        constraint_node_head(pm, i)
        constraint_junction_volume_flow_balance(pm, i)
    end

    for i in ids(pm, :pipe)
        constraint_nodal_volume_balance(pm, i)
    end

    for i in ids(pm, :pump)
        constraint_pump_efficiency_and_rotation(pm, i)

    end

    # for i in ids(pm, :tank)
    #     constraint_tank_volume_balance(pm, i)
    # end
end
