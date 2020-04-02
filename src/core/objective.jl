##########################################################################################################
# The purpose of this file is to define commonly used and created objective functions used in models
##########################################################################################################



 function objective_min_expenses_max_benefit(pm::AbstractPetroleumFormulation, nws=[pm.cnw])
         qg = Dict(n => pm.var[:nw][n][:qg] for n in nws)
         ql = Dict(n => pm.var[:nw][n][:ql] for n in nws)
         q  = Dict(n => pm.var[:nw][n][:q] for n in nws)

         obj = JuMP.@NLobjective(pm.model, Min,
         sum(
                -(-sum(pm.ref[:nw][n][:producer][i]["price"] * qg[n][i] for (i, producer) in pm.ref[:nw][n][:producer]) +
                sum(pm.ref[:nw][n][:consumer][i]["price"] * ql[n][i] for (i, consumer) in pm.ref[:nw][n][:consumer])) * 3600 +
                pm.data["rho"] * pm.data["gravitational_acceleration"]  * sum(pm.ref[:nw][n][:pump][i]["electricity_price"] *
                q[n][i] * (pm.var[:nw][n][:H][pump["t_junction"]] -
                pm.var[:nw][n][:H][pump["f_junction"]]) / (0.966 * 0.95 * pm.var[:nw][n][:eta][i])  / 1000
                     for (i, pump) in pm.ref[:nw][n][:pump] )
                                             for n in nws))


 end
