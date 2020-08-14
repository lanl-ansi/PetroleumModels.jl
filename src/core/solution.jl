function _IM.solution_preprocessor(pm::AbstractPetroleumModel, solution::Dict)
    solution["per_unit"] = pm.data["per_unit"]
    solution["multinetwork"] = ismultinetwork(pm.data)
    solution["baseH"] = pm.ref[:baseH]
    solution["base_h_loss"] = pm.ref[:base_h_loss]
    solution["baseQ"] = pm.ref[:baseQ]
    solution["base_z"] = pm.ref[:base_z]
    solution["base_a"] = pm.ref[:base_a]
    solution["base_b"] = pm.ref[:base_b]
end



function sol_psqr_to_p!(pm::AbstractPetroleumModel, solution::Dict)
    if haskey(solution, "nw")
        nws_data = solution["nw"]
    else
        nws_data = Dict("0" => solution)
    end

    for (n, nw_data) in nws_data
        if haskey(nw_data, "junction")
            for (i,junction) in nw_data["junction"]
                # if haskey(junction, "psqr")
                #     junction["p"] = sqrt(max(0.0, junction["psqr"]))
                # end
            end
        end
    end
end


function sol_first!(pm::AbstractPetroleumModel, solution::Dict)
    if haskey(solution, "nw")
        nws_data = solution["nw"]
    else
        nws_data = Dict("0" => solution)
    end

    for (n, nw_data) in nws_data
        if haskey(nw_data, "pump")
            for (i,pump) in nw_data["pump"]
                # if haskey(pump, "rsqr")
                #     pump["r"] = sqrt(max(0.0, pump["rsqr"]))
                # end
            end
        end
    end
end


function sol_pump!(pm::AbstractPetroleumModel, solution::Dict)
    if haskey(solution, "nw")
        nws_data = solution["nw"]
    else
        nws_data = Dict("0" => solution)
    end

    for (n, nw_data) in nws_data
        if haskey(nw_data, "pump")
            for (k,pump) in nw_data["pump"]
                i = ref(pm,:pump,parse(Int64,k); nw=parse(Int64, n))["fr_junction"]
                j = ref(pm,:pump,parse(Int64,k); nw=parse(Int64, n))["to_junction"]
                # f = pump["f"]
                # pi = max(0.0, nw_data["junction"][string(i)]["psqr"])
                # pj = max(0.0, nw_data["junction"][string(j)]["psqr"])

                # pump["r"] = (f >= 0) ? sqrt(pj) / sqrt(pi) : sqrt(pi) / sqrt(pj)
            end
        end
    end
end


function sol_ne_pump!(pm::AbstractPetroleumModel, solution::Dict)
    if haskey(solution, "nw")
        nws_data = solution["nw"]
    else
        nws_data = Dict("0" => solution)
    end

    for (n, nw_data) in nws_data
        if haskey(nw_data, "ne_pump")
            for (k,pump) in nw_data["ne_pump"]
                i = ref(pm,:ne_pump,parse(Int64,k); nw=parse(Int64, n))["fr_junction"]
                j = ref(pm,:ne_pump,parse(Int64,k); nw=parse(Int64, n))["to_junction"]
                # f = pump["f"]
                # pi = max(0.0, nw_data["junction"][string(i)]["psqr"])
                # pj = max(0.0, nw_data["junction"][string(j)]["psqr"])

                # pump["r"] = (f >= 0) ? sqrt(pj) / sqrt(pi) : sqrt(pi) / sqrt(pj)
            end
        end
    end
end




function build_solution(pm::AbstractPetroleumModel, status, solve_time; solution_builder=get_solution)
    if status != :Error
        objective = status != :Infeasible ? JuMP.objective_value(pm.model) : NaN
        status = optimizer_status_dict(Symbol(typeof(pm.model.moi_backend).name.module), status)
    end
    sol = _init_solution(pm)
    data = Dict{String,Any}("name" => haskey(pm.data, "name") ? pm.data["name"] : "none")

    if pm.data["multinetwork"]
        sol_nws = sol["nw"] = Dict{String,Any}()
        data_nws = data["nw"] = Dict{String,Any}()

        for (n,nw_data) in pm.data["nw"]
            sol_nw = sol_nws[n] = Dict{String,Any}()
            pm.cnw = parse(Int, n)
            solution_builder(pm, sol_nw)
            data_nws[n] = Dict(
                "name" => nw_data["name"],
                "junction_count" => length(nw_data["junction"]),
                "pipe_count" => haskey(nw_data, "pipe") ? length(nw_data["pipe"]) : 0,
                "pump_count" => haskey(nw_data, "pump") ? length(nw_data["pump"]) : 0,
            )
        end
    else
        solution_builder(pm, sol)
        data["junction_count"] = length(pm.data["junction"])
        data["pipe_count"] = haskey(pm.data, "pipe") ? length(pm.data["pipe"]) : 0
        data["pump_count"] = haskey(pm.data, "pump") ? length(pm.data["pump"]) : 0
    end

    solution = Dict{String,Any}(
            "cpu" => Sys.cpu_info()[1].model,
            "memory" => string(Sys.total_memory()/2^30, " Gb"),
            "optimizer" => string(typeof(pm.model.moi_backend.optimizer)),
            "status" => status,
            "dual_status" => JuMP.dual_status(pm.model),
            "objective" => objective,
            "objective_lb" => _guard_objective_bound(pm.model),
            "solve_time" => solve_time,
            "solution" => sol,
            "machine" => Dict(
                "cpu" => Sys.cpu_info()[1].model,
                "memory" => string(Sys.total_memory()/2^30, " Gb")
                ),
            "data" => data

        )

    return solution
end


""
function _init_solution(pm::AbstractPetroleumModel)
    data_keys = ["per_unit", "baseH", "baseQ", "multinetwork"]
    return Dict{String,Any}(key => pm.data[key] for key in data_keys)
end

" Get all the solution values "
function get_solution(pm::AbstractPetroleumModel,sol::Dict{String,Any})
    add_junction_head_setpoint(sol, pm)
    add_connection_flow_setpoint(sol, pm)
    add_load_volume_flow_setpoint(sol, pm)
    add_production_volume_flow_setpoint(sol, pm)
    # add_dual_head!(sol, pm)
    # add_pump_ratio_setpoint(sol, pm)
end



" Get head solutions "
function add_junction_head_setpoint(sol, pm::AbstractPetroleumModel)
     add_setpoint(sol, pm, "junction", "H", :H)
end



" Get the load flow solutions "
function add_load_volume_flow_setpoint(sol, pm::AbstractPetroleumModel)
    add_setpoint(sol, pm, "consumer", "ql", :ql; default_value = (item) -> 0)
end

" Get the production flow set point "
function add_production_volume_flow_setpoint(sol, pm::AbstractPetroleumModel)
    add_setpoint(sol, pm, "producer", "qg", :qg; default_value = (item) -> 0)
end

" Add the flow solutions "
function add_connection_flow_setpoint(sol, pm::AbstractPetroleumModel)
    add_setpoint(sol, pm, "pipe", "q", :q)
    add_setpoint(sol, pm, "pump", "q", :q)

end

function add_dual_head!(sol, pm::AbstractPetroleumModel)
        add_dual!(sol, pm, "pipe", "q", :junction_volume_flow_balance)
        add_dual!(sol, pm, "pump", "q", :junction_volume_flow_balance)
end

""
function add_setpoint(sol, pm::AbstractPetroleumModel, dict_name, param_name, variable_symbol; index_name = nothing, default_value = (item) -> NaN, scale = (x,item) -> JuMP.value(x), extract_var = (var,idx,item) -> var[idx])
    sol_dict = get(sol, dict_name, Dict{String,Any}())

    if pm.data["multinetwork"]
        data_dict = haskey(pm.data["nw"]["$(pm.cnw)"], dict_name) ? pm.data["nw"]["$(pm.cnw)"][dict_name] : Dict()
    else
        data_dict = haskey(pm.data, dict_name) ? pm.data[dict_name] : Dict()
    end

    if length(data_dict) > 0
        sol[dict_name] = sol_dict
    end

    for (i,item) in data_dict
        idx = parse(Int64,i)
        if index_name != nothing
            idx = Int(item[index_name])
        end
        sol_item = sol_dict[i] = get(sol_dict, i, Dict{String,Any}())
        sol_item[param_name] = default_value(item)
        try
            variable = extract_var(var(pm, variable_symbol), idx, item)
            sol_item[param_name] = scale(variable, item)
        catch e
        end
    end
end

optimizer_status_lookup = Dict{Any, Dict{Symbol, Symbol}}(
    :Ipopt => Dict(:Optimal => :LocalOptimal, :Infeasible => :LocalInfeasible),
    :ConicNonlinearBridge => Dict(:Optimal => :LocalOptimal, :Infeasible => :LocalInfeasible),
    # note that AmplNLWriter.AmplNLSolver is the optimizer type of bonmin
    :AmplNLWriter => Dict(:Optimal => :LocalOptimal, :Infeasible => :LocalInfeasible)
)

# translates optimizer status codes to our status codes"
function optimizer_status_dict(optimizer_type, status)
    for (st, optimizer_stat_dict) in optimizer_status_lookup
        if optimizer_type == st
            if status in keys(optimizer_stat_dict)
                return optimizer_stat_dict[status]
            else
                return status
            end
        end
    end
    return status
end

""
function _guard_objective_value(model)
    obj_val = NaN

    try
        obj_val = JuMP.objective_value(model)
    catch
    end

    return obj_val
end


""
function _guard_objective_bound(model)
    obj_lb = -Inf

    try
        obj_lb = JuMP.objective_bound(model)
    catch
    end

    return obj_lb
end
