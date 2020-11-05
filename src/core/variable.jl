##########################################################################################################
# The purpose of this file is to define commonly used and created variables used in petroleum flow models
##########################################################################################################

" Variables associated with volume flow through a pipe: ``q`` "
function variable_volume_flow_pipe(pm::AbstractPetroleumModel, nw::Int=pm.cnw; bounded::Bool=true, report::Bool=true)

    q_pipe = pm.var[:nw][nw][:q_pipe] = JuMP.@variable(pm.model,
        [i in ids(pm,nw,:pipe)],
        base_name="$(nw)_q_pipe",
        start=comp_start_value(pm.ref[:nw][nw][:pipe], i, "q_pipe_start",  pm.ref[:nw][nw][:pipe][i]["flow_min"])
    )

    if bounded
        for (i, pipe) in ref(pm, nw, :pipe)
            JuMP.set_lower_bound(q_pipe[i], pm.ref[:nw][nw][:pipe][i]["flow_min"])
            JuMP.set_upper_bound(q_pipe[i], pm.ref[:nw][nw][:pipe][i]["flow_max"])
        end
    end

    report && _IM.sol_component_value(pm, nw, :pipe, :q_pipe, ids(pm, nw, :pipe), q_pipe)
end

" Variables associated with volume flow through a pump: ``q`` "
function variable_volume_flow_pump(pm::AbstractPetroleumModel, nw::Int=pm.cnw; bounded::Bool=true, report::Bool=true)

    q_pump = pm.var[:nw][nw][:q_pump] = JuMP.@variable(pm.model,
        [i in ids(pm,nw,:pump)],
        base_name="$(nw)_q_pump",
        start=comp_start_value(pm.ref[:nw][nw][:pump], i, "q_pump_start", 0)
    )

    if bounded
        for (i, pump) in ref(pm, nw, :pump)
            JuMP.set_lower_bound(q_pump[i], 0)
            JuMP.set_upper_bound(q_pump[i], pm.ref[:nw][nw][:pump][i]["flow_max"])
        end
    end

    report && _IM.sol_component_value(pm, nw, :pump, :q_pump, ids(pm, nw, :pump), q_pump)
end


" Variables associated with volume production: ``qg`` "
function variable_production_volume_flow(pm::AbstractPetroleumModel, nw::Int=pm.cnw; bounded::Bool=true, report::Bool=true)

    qg = pm.var[:nw][nw][:qg] = JuMP.@variable(pm.model,
        [i in ids(pm,nw,:producer)],
        base_name="$(nw)_qg",
        start=comp_start_value(pm.ref[:nw][nw][:producer], i, "qg_start", 0.01)
    )

    if bounded
        for (i, producer) in ref(pm, nw, :producer)
            JuMP.set_lower_bound(qg[i], pm.ref[:nw][nw][:producer][i]["injection_min"])
            JuMP.set_upper_bound(qg[i], pm.ref[:nw][nw][:producer][i]["injection_max"])
        end
    end

    report && _IM.sol_component_value(pm, nw, :producer, :qg, ids(pm, nw, :producer), qg)
end

" Variables associated with volume demand: ``ql``"
function variable_demand_volume_flow(pm::AbstractPetroleumModel, nw::Int=pm.cnw; bounded::Bool=true, report::Bool=true)

    ql = pm.var[:nw][nw][:ql] = JuMP.@variable(pm.model,
        [i in ids(pm,nw,:consumer)],
        base_name="$(nw)_ql",
        start=comp_start_value(pm.ref[:nw][nw][:consumer], i, "ql_start", 0.01)
    )

    if bounded
        for (i, consumer) in ref(pm, nw, :consumer)
            JuMP.set_lower_bound(ql[i],  pm.ref[:nw][nw][:consumer][i]["withdrawal_min"])
            JuMP.set_upper_bound(ql[i],  pm.ref[:nw][nw][:consumer][i]["withdrawal_max"])
        end
    end

    report && _IM.sol_component_value(pm, nw, :consumer, :ql, ids(pm, nw, :consumer), ql)
end


" Variables associated with pump efficiency: ``\\eta`` "
function variable_pump_efficiency(pm::AbstractPetroleumModel, nw::Int=pm.cnw; bounded::Bool=true, report::Bool=true)

    eta = pm.var[:nw][nw][:eta] = JuMP.@variable(pm.model,
        [i in ids(pm,nw,:pump)],
        base_name="$(nw)_eta",
        start=comp_start_value(pm.ref[:nw][nw][:pump], i, "eta_start", 0)
    )

    if bounded
        for (i, pump) in ref(pm, nw, :pump)
            JuMP.set_lower_bound(eta[i], pm.ref[:nw][nw][:pump][i]["pump_efficiency_min"])
            JuMP.set_upper_bound(eta[i], pm.ref[:nw][nw][:pump][i]["pump_efficiency_max"])
        end
    end

    report && _IM.sol_component_value(pm, nw, :pump, :eta, ids(pm, nw, :pump), eta)
end

" Variables associated with pump rotation: ``w`` "
function variable_pump_rotation(pm::AbstractPetroleumModel, nw::Int=pm.cnw; bounded::Bool=true, report::Bool=true)

    w = pm.var[:nw][nw][:w] = JuMP.@variable(pm.model,
        [i in ids(pm,nw,:pump)],
        base_name="$(nw)_w",
        start=comp_start_value(pm.ref[:nw][nw][:pump], i, "w_start", 0)
    )

    if bounded
        for (i, pump) in ref(pm, nw, :pump)
            JuMP.set_lower_bound(w[i], pm.ref[:nw][nw][:pump][i]["rotation_min"])
            JuMP.set_upper_bound(w[i], pm.ref[:nw][nw][:pump][i]["rotation_max"])
        end
    end

    report && _IM.sol_component_value(pm, nw, :pump, :w, ids(pm, nw, :pump), w)
end

" variables associated with head: ``h`` "
function variable_head(pm::AbstractPetroleumModel, nw::Int=pm.cnw; bounded::Bool=true, report::Bool=true)

    h = pm.var[:nw][nw][:h] = JuMP.@variable(pm.model,
        [i in ids(pm,nw,:junction)],
        base_name="$(nw)_h",
        start=comp_start_value(pm.ref[:nw][nw][:junction], i, "h_start", 0.1)
    )

    if bounded
        for (i, junction) in ref(pm, nw, :junction)
            JuMP.set_lower_bound(h[i], pm.ref[:nw][nw][:junction][i]["head_min"])
            JuMP.set_upper_bound(h[i], pm.ref[:nw][nw][:junction][i]["head_max"])
        end
    end

    report && _IM.sol_component_value(pm, nw, :junction, :h, ids(pm, nw, :junction), h)
end

" variables associated with tank intake: ``qin`` "
function variable_tank_intake(pm::AbstractPetroleumModel, nw::Int=pm.cnw; bounded::Bool=true, report::Bool=true)

    qin = pm.var[:nw][nw][:qin] = JuMP.@variable(pm.model,
        [i in ids(pm,nw,:tank)],
        base_name="$(nw)_qin",
        start=comp_start_value(pm.ref[:nw][nw][:tank], i, "qin_start", 0)
    )

    if bounded
        for (i, tank) in ref(pm, nw, :tank)
            JuMP.set_lower_bound(qin[i], pm.ref[:nw][nw][:tank][i]["intake_min"])
            JuMP.set_upper_bound(qin[i], pm.ref[:nw][nw][:tank][i]["intake_max"])
        end
    end

    report && _IM.sol_component_value(pm, nw, :tank, :qin, ids(pm, nw, :tank), qin)
end

" variables associated with tank offtake: ``qoff`` "
function variable_tank_offtake(pm::AbstractPetroleumModel, nw::Int=pm.cnw; bounded::Bool=true, report::Bool=true)

    qoff = pm.var[:nw][nw][:qoff] = JuMP.@variable(pm.model,
        [i in ids(pm,nw,:tank)],
        base_name="$(nw)_qoff",
        start=comp_start_value(pm.ref[:nw][nw][:tank], i, "qoff_start", 0)
    )

    if bounded
        for (i, tank) in ref(pm, nw, :tank)
            JuMP.set_lower_bound(qoff[i], pm.ref[:nw][nw][:tank][i]["offtake_min"])
            JuMP.set_upper_bound(qoff[i], pm.ref[:nw][nw][:tank][i]["offtake_max"])
        end
    end

    report && _IM.sol_component_value(pm, nw, :tank, :qoff, ids(pm, nw, :tank), qoff)
end
