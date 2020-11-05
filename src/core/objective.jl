##########################################################################################################
# The purpose of this file is to define commonly used and created objective functions used in models
##########################################################################################################

"Economic objective function for petroluem models that takes the form of ``min \\sum_{i \\in producer} c_i - \\sum_{i \\in consumer} c_i + \\rho * g * \\sum_{ij \\in pump} c_{ij} * ``"
function objective_min_expenses_max_benefit(pm::AbstractPetroleumModel, nws=[pm.cnw])
    qg      = Dict(n => var(pm,n,:qg) for n in nws)
    ql      = Dict(n => var(pm,n,:ql) for n in nws)
    q_pump  = Dict(n => var(pm,n,:q_pump) for n in nws)
    eta     = Dict(n => var(pm,n,:eta) for n in nws)
    h       = Dict(n => var(pm,n,:h) for n in nws)

    kw_s_to_J                  = 1000.0 # J = (kg ⋅m^2)/⋅ s
    density                    = pm.data["density"]
    gravitational_acceleration = pm.data["gravitational_acceleration"]

    JuMP.@NLobjective(pm.model, _IM._MOI.MIN_SENSE,
         sum(
              sum(producer["offer_price"] * qg[n][i] for (i, producer) in ref(pm,n,:producer)) -
              sum(consumer["bid_price"]   * ql[n][i] for (i, consumer) in ref(pm,n,:consumer)) +
              (density * gravitational_acceleration) / kw_s_to_J *
                sum( (pump["electricity_price"] * q_pump[n][i] * (h[n][pump["to_junction"]] - h[n][pump["fr_junction"]])) /
                     (pump["electric_motor_efficiency"] * pump["mechanical_transmission_efficiency"] * eta[n][i])
              for (i, pump) in ref(pm,n,:pump) )
         for n in nws)
         )
 end
