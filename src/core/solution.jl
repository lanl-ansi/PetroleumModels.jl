function _IM.solution_preprocessor(pm::AbstractPetroleumModel, solution::Dict)

    solution["is_per_unit"] = pm.data["is_per_unit"]
    solution["multinetwork"] = ismultinetwork(pm.data)
    solution["baseH"] = pm.ref[:baseH]
    solution["baseQ"] = pm.ref[:baseQ]
    solution["base_z"] = pm.ref[:base_z]
    solution["base_a"] = pm.ref[:base_a]
    solution["base_b"] = pm.ref[:base_b]
    solution["base_length"] = pm.ref[:base_length]
    solution["base_diameter"] = pm.ref[:base_diameter]
    solution["base_rho"] = pm.ref[:base_rho]
    solution["base_nu"] = pm.ref[:base_nu]

end

#
#
# function sol_psqr_to_p!(pm::AbstractPetroleumModel, solution::Dict)
#     if haskey(solution, "nw")
#         nws_data = solution["nw"]
#     else
#         nws_data = Dict("0" => solution)
#     end
#
#     for (n, nw_data) in nws_data
#         if haskey(nw_data, "junction")
#             for (i,junction) in nw_data["junction"]
#                 # if haskey(junction, "psqr")
#                 #     junction["p"] = sqrt(max(0.0, junction["psqr"]))
#                 # end
#             end
#         end
#     end
# end
#
#
# function sol_first!(pm::AbstractPetroleumModel, solution::Dict)
#     if haskey(solution, "nw")
#         nws_data = solution["nw"]
#     else
#         nws_data = Dict("0" => solution)
#     end
#
#     for (n, nw_data) in nws_data
#         if haskey(nw_data, "pump")
#             for (i,pump) in nw_data["pump"]
#                 # if haskey(pump, "rsqr")
#                 #     pump["r"] = sqrt(max(0.0, pump["rsqr"]))
#                 # end
#             end
#         end
#     end
# end
#
#
# function sol_pump!(pm::AbstractPetroleumModel, solution::Dict)
#     if haskey(solution, "nw")
#         nws_data = solution["nw"]
#     else
#         nws_data = Dict("0" => solution)
#     end
#
#     for (n, nw_data) in nws_data
#         if haskey(nw_data, "pump")
#             for (k,pump) in nw_data["pump"]
#                 i = ref(pm,:pump,parse(Int64,k); nw=parse(Int64, n))["fr_junction"]
#                 j = ref(pm,:pump,parse(Int64,k); nw=parse(Int64, n))["to_junction"]
#
#             end
#         end
#     end
# end
#
#
# function sol_ne_pump!(pm::AbstractPetroleumModel, solution::Dict)
#     if haskey(solution, "nw")
#         nws_data = solution["nw"]
#     else
#         nws_data = Dict("0" => solution)
#     end
#
#     for (n, nw_data) in nws_data
#         if haskey(nw_data, "ne_pump")
#             for (k,pump) in nw_data["ne_pump"]
#                 i = ref(pm,:ne_pump,parse(Int64,k); nw=parse(Int64, n))["fr_junction"]
#                 j = ref(pm,:ne_pump,parse(Int64,k); nw=parse(Int64, n))["to_junction"]
#                 # f = pump["f"]
#             end
#         end
#     end
# end
#
#
# function build_solution(pm::AbstractPetroleumModel, status, solve_time; solution_builder=get_solution)
#     if status != :Error
#         objective = status != :Infeasible ? JuMP.objective_value(pm.model) : NaN
#         status = optimizer_status_dict(Symbol(typeof(pm.model.moi_backend).name.module), status)
#     end
#     sol = _init_solution(pm)
#     data = Dict{String,Any}("name" => haskey(pm.data, "name") ? pm.data["name"] : "none")
#     # nws = collect(1:length(pm.ref[:nw]))
#     nws = [0]
#     # sum_A = 0
#     # sum_B = 0
#     qg = Dict(n => pm.var[:nw][n][:qg] for n in nws)
#     ql = Dict(n => pm.var[:nw][n][:ql] for n in nws)
#     q_pump  = Dict(n => pm.var[:nw][n][:q_pump] for n in nws)
#     A = sum((-sum(pm.ref[:nw][n][:producer][i]["offer_price"] * qg[n][i] for (i, producer) in pm.ref[:nw][n][:producer]) +
#     sum(pm.ref[:nw][n][:consumer][i]["bid_price"] * ql[n][i] for (i, consumer) in pm.ref[:nw][n][:consumer])) for n in nws)
#
#     if pm.data["multinetwork"]
#         sol_nws = sol["nw"] = Dict{String,Any}()
#         data_nws = data["nw"] = Dict{String,Any}()
#
#         for (n,nw_data) in pm.data["nw"]
#             sol_nw = sol_nws[n] = Dict{String,Any}()
#             pm.cnw = parse(Int, n)
#             solution_builder(pm, sol_nw)
#             data_nws[n] = Dict(
#                 "name" => nw_data["name"],
#                 "junction_count" => length(nw_data["junction"]),
#                 "pipe_count" => haskey(nw_data, "pipe") ? length(nw_data["pipe"]) : 0,
#                 "pump_count" => haskey(nw_data, "pump") ? length(nw_data["pump"]) : 0,
#             )
#         end
#     else
#         solution_builder(pm, sol)
#         data["junction_count"] = length(pm.data["junction"])
#         data["pipe_count"] = haskey(pm.data, "pipe") ? length(pm.data["pipe"]) : 0
#         data["pump_count"] = haskey(pm.data, "pump") ? length(pm.data["pump"]) : 0
#     end
#
#     solution = Dict{String,Any}(
#             "cpu" => Sys.cpu_info()[1].model,
#             "memory" => string(Sys.total_memory()/2^30, " Gb"),
#             "optimizer" => string(typeof(pm.model.moi_backend.optimizer)),
#             "status" => status,
#             "dual_status" => JuMP.dual_status(pm.model),
#             "objective" => objective,
#             "objective_lb" => _guard_objective_bound(pm.model),
#             "solve_time" => solve_time,
#             "solution" => sol,
#             "machine" => Dict(
#                 "cpu" => Sys.cpu_info()[1].model,
#                 "memory" => string(Sys.total_memory()/2^30, " Gb")
#                 ),
#             "data" => data
#
#         )
#
#     return solution
# end
#
#
# ""
# function _init_solution(pm::AbstractPetroleumModel)
#     data_keys = ["is_per_unit", "baseH", "baseQ", "multinetwork"]
#     return Dict{String,Any}(key => pm.data[key] for key in data_keys)
# end
#
#
# optimizer_status_lookup = Dict{Any, Dict{Symbol, Symbol}}(
#     :Ipopt => Dict(:Optimal => :LocalOptimal, :Infeasible => :LocalInfeasible),
#     :ConicNonlinearBridge => Dict(:Optimal => :LocalOptimal, :Infeasible => :LocalInfeasible),
#     # note that AmplNLWriter.AmplNLSolver is the optimizer type of bonmin
#     :AmplNLWriter => Dict(:Optimal => :LocalOptimal, :Infeasible => :LocalInfeasible)
# )
#
# # translates optimizer status codes to our status codes"
# function optimizer_status_dict(optimizer_type, status)
#     for (st, optimizer_stat_dict) in optimizer_status_lookup
#         if optimizer_type == st
#             if status in keys(optimizer_stat_dict)
#                 return optimizer_stat_dict[status]
#             else
#                 return status
#             end
#         end
#     end
#     return status
# end
#
# ""
# function _guard_objective_value(model)
#     obj_val = NaN
#
#     try
#         obj_val = JuMP.objective_value(model)
#     catch
#     end
#
#     return obj_val
# end
#
#
# ""
# function _guard_objective_bound(model)
#     obj_lb = -Inf
#
#     try
#         obj_lb = JuMP.objective_bound(model)
#     catch
#     end
#
#     return obj_lb
# end
#
#
#
#
