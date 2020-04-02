##########################################################################################################
# The purpose of this file is to define commonly used and created variables used in petroleum flow models
##########################################################################################################

"extracts the start value"
function getstart(set, item_key, value_key, default = 0.0)
    return get(get(set, item_key, Dict()), value_key, default)
end



" variables associated with volume flow "
function variable_volume_flow(pm::AbstractPetroleumFormulation; n::Int=pm.cnw, bounded::Bool = true)
    # max_flow = pm.ref[:nw][n][:max_volume_flow]
    # min_flow = pm.ref[:nw][n][:min_volume_flow]
    # num_time_points = length(keys(pm.ref[:nw]))
    # println("heere:")
    # @show(num_time_points)
    @show n
    if bounded
        pm.var[:nw][n][:q] = @variable(pm.model, [i in keys(pm.ref[:nw][n][:connection])], base_name="$(n)_q")
        for i in keys(pm.ref[:nw][n][:pipe])
            JuMP.set_lower_bound(pm.var[:nw][n][:q][i], pm.ref[:nw][n][:pipe][i]["Qmin"])
            JuMP.set_upper_bound(pm.var[:nw][n][:q][i], pm.ref[:nw][n][:pipe][i]["Qmax"])
        end
            # lower_bound = pm.ref[:nw][n][:pipe][i]["Qmin"],
            # upper_bound = pm.ref[:nw][n][:pipe][i]["Qmax"],
            # start = getstart(pm.ref[:nw][n][:pipe], i, "q_start", 0))
    else
        pm.var[:nw][n][:q] = @variable(pm.model, [i in keys(pm.ref[:nw][n][:pipe])], base_name="$(n)_q",
                                                                                           start = getstart(pm.ref[:nw][n][:pipe], i, "q_start", 0))
    end
end

" variables associated with production "
function variable_production_volume_flow(pm::AbstractPetroleumFormulation; n::Int=pm.cnw, bounded::Bool = true)
    prod_set = collect(keys(Dict(x for x in pm.ref[:nw][n][:producer] if x.second["qgmax"] != 0 || x.second["qgmin"] != 0)))
    if bounded
        pm.var[:nw][n][:qg] = @variable(pm.model, [i in prod_set], base_name="$(n)_qg", lower_bound = pm.ref[:nw][n][:producer][i]["qgmin"],
                                                                                        upper_bound = pm.ref[:nw][n][:producer][i]["qgmax"],
                                                                                        start = getstart(pm.ref[:nw][n][:producer], i, "qg_start",
                                                                                        pm.ref[:nw][n][:producer][i]["qgmin"]))
    else
        pm.var[:nw][n][:qg] = @variable(pm.model, [i in prod_set], base_name="$(n)_qg", start = getstart(pm.ref[:nw][n][:producer], i, "qg_start",
                                                                                        pm.ref[:nw][n][:producer][i]["qgmin"] ))
    end
end

" variables associated with demand "
function variable_demand_volume_flow(pm::AbstractPetroleumFormulation; n::Int=pm.cnw, bounded::Bool = true)
    cons_set = collect(keys(Dict(x for x in pm.ref[:nw][n][:consumer] if x.second["qlmax"] != 0 || x.second["qlmin"] != 0)))
    if bounded
        pm.var[:nw][n][:ql] = @variable(pm.model, [i in cons_set], base_name="$(n)_ql", lower_bound = pm.ref[:nw][n][:consumer][i]["qlmin"],
                                                                                        upper_bound = pm.ref[:nw][n][:consumer][i]["qlmax"],
                                                                                        start = getstart(pm.ref[:nw][n][:consumer], i, "ql_start",
                                                                                        pm.ref[:nw][n][:consumer][i]["qlmin"]))
    else
        pm.var[:nw][n][:ql] = @variable(pm.model, [i in cons_set], base_name="$(n)_ql", start = getstart(pm.ref[:nw][n][:consumer], i, "ql_start",
                                                                                        pm.ref[:nw][n][:consumer][i]["qlmin"]))
    end
end

" variables associated with pump efficiency."
function variable_pump_efficiency(pm::AbstractPetroleumFormulation; n::Int=pm.cnw, bounded::Bool = true)

    if bounded
        pm.var[:nw][n][:eta] = @variable(pm.model, [i in keys(pm.ref[:nw][n][:pump])], base_name="$(n)_eta",
                                                                                           lower_bound = pm.ref[:nw][n][:pump][i]["min_pump_efficiency"],
                                                                                           upper_bound = pm.ref[:nw][n][:pump][i]["max_pump_efficiency"] ,
                                                                                           start = getstart(pm.ref[:nw][n][:pump], i, "eta_start", pm.ref[:nw][n][:pump][i]["min_pump_efficiency"]))
    else
        pm.var[:nw][n][:eta] = @variable(pm.model, [i in keys(pm.ref[:nw][n][:pump])], base_name="$(n)_eta",
                                                                                           start = getstart(pm.ref[:nw][n][:pump], i, "eta_start", pm.ref[:nw][n][:pump][i]["min_pump_efficiency"]))
    end
end

" variables associated with pump rotation."
function variable_pump_rotation(pm::AbstractPetroleumFormulation; n::Int=pm.cnw, bounded::Bool = true)

    if bounded
        pm.var[:nw][n][:w] = @variable(pm.model, [i in keys(pm.ref[:nw][n][:pump])], base_name="$(n)_w",
                                                                                           lower_bound = pm.ref[:nw][n][:pump][i]["min_w"],
                                                                                           upper_bound = pm.ref[:nw][n][:pump][i]["max_w"],
                                                                                           start = getstart(pm.ref[:nw][n][:pump], i, "w_start", pm.ref[:nw][n][:pump][i]["min_w"]))
    else
        pm.var[:nw][n][:w] = @variable(pm.model, [i in keys(pm.ref[:nw][n][:pump])], base_name="$(n)_w",
                                                                                           start = getstart(pm.ref[:nw][n][:pump], i, "w_start", pm.ref[:nw][n][:pump][i]["min_w"]))
    end
end

" variables associated with head "
function variable_head(pm::AbstractPetroleumFormulation; n::Int=pm.cnw, bounded::Bool = true)
    if bounded
        pm.var[:nw][n][:H] = @variable(pm.model, [i in keys(pm.ref[:nw][n][:junction])], base_name="$(n)_H",
                                                                                           lower_bound = pm.ref[:nw][n][:junction][i]["Hmin"],
                                                                                           upper_bound = pm.ref[:nw][n][:junction][i]["Hmax"],
                                                                                           start = getstart(pm.ref[:nw][n][:junction], i, "H_start", pm.ref[:nw][n][:junction][i]["Hmin"]))
    else
        pm.var[:nw][n][:H] = @variable(pm.model, [i in keys(pm.ref[:nw][n][:junction])], base_name="$(n)_H",
                                                                                           start = getstart(pm.ref[:nw][n][:junction], i, "H_start", pm.ref[:nw][n][:junction][i]["Hmin"]))
    end
end
