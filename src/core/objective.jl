##########################################################################################################
# The purpose of this file is to define commonly used and created objective functions used in models
##########################################################################################################

 function objective_min_expenses_max_benefit(pm::AbstractPetroleumModel, nws=[pm.cnw])
         # normalization = get(pm.data, "objective_normalization", 1.0)
         # nws = collect(1:length(pm.ref[:nw]))
         nws = [0]
         qg = Dict(n => pm.var[:nw][n][:qg] for n in nws)
         ql = Dict(n => pm.var[:nw][n][:ql] for n in nws)
         q_pump  = Dict(n => pm.var[:nw][n][:q_pump] for n in nws)
         # q_pipe  = Dict(n => pm.var[:nw][n][:q_pipe] for n in nws)
         # q_tank  = Dict(n => pm.var[:nw][n][:q_tank] for n in nws)
         # volume_tank  = Dict(n => pm.var[:nw][n][:volume_tank] for n in nws)
         obj = JuMP.@NLobjective(pm.model, Min,
         sum(
              -(-sum(pm.ref[:nw][n][:producer][i]["offer_price"] * qg[n][i] for (i, producer) in pm.ref[:nw][n][:producer]) +
              sum(pm.ref[:nw][n][:consumer][i]["bid_price"] * ql[n][i] for (i, consumer) in pm.ref[:nw][n][:consumer]))
              +
              pm.data["rho"] * pm.data["gravitational_acceleration"] * sum(pm.ref[:nw][n][:pump][i]["electricity_price"] *
              q_pump[n][i] * (pm.var[:nw][n][:H][pump["to_junction"]] -
              pm.var[:nw][n][:H][pump["fr_junction"]]) /3600/ (0.966 * 0.95 * pm.var[:nw][n][:eta][i])  / 1000
                   for (i, pump) in pm.ref[:nw][n][:pump] )
                                           for n in nws))

 end
