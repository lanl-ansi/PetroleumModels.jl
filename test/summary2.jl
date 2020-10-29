

H_values         = []
delta_H_values   = []
q_values         = []
nodal_volume_balance       = []
Eta_con          = []
Pump_head_con    = []
qg_value         = []
ql_value         = []
w_values         = []
eta_values       = []
pump_deltahead_max_dual       = []
pump_deltahead_min_dual       = []
H_dual_up = []
H_dual_low = []
q_dual_node = []
q_dual_up = []
q_dual_low = []
w_dual_up = []
w_dual_low = []
eta_dual_up = []
eta_dual_low = []
pump_efficiency_min = []
pump_efficiency_max = []
rotation_min = []
rotation_max = []
head_max = []
head_min = []
q_max = []
q_min = []
q_pump_values =[]
#Check the second order cone model on load shedding






@testset "test ----------" begin
    @testset "-------" begin
        println("Testing ----------------")
        data = parse_file("../test/data/pipeline_2012_seaway_m3_per_h.m")
        # data = parse_file("../test/data/small_case.m")

    for i=1:1
        data_new = deepcopy(data)

         pm = instantiate_model(data_new, MISOCPPetroleumModel, build_pf)
         # ipopt = JuMP.with_optimizer(Ipopt.Optimizer, print_level = 5)
         ipopt = JuMP.optimizer_with_attributes(Ipopt.Optimizer)
          # solution = pm.optimize_model!(pm, ipopt)
         JuMP.set_optimizer(pm.model, ipopt)
         # println(pm.model)
         a = JuMP.optimize!(pm.model)

         e = 0

         # nws = collect(1:length(pm.ref[:nw]))
         nws=0
         println(nws)
         # sum_A = 0
         # sum_B = 0
         n=0

         A = sum((-sum(pm.ref[:nw][n][:producer][i]["offer_price"] * JuMP.value(pm.var[:nw][n][:qg][i]) for (i, producer) in pm.ref[:nw][n][:producer]) +
         sum(pm.ref[:nw][n][:consumer][i]["bid_price"] * JuMP.value(pm.var[:nw][n][:ql][i]) for (i, consumer) in pm.ref[:nw][n][:consumer])) for n in nws)

         B =  sum( pm.data["rho"]*827 * pm.data["gravitational_acceleration"]*9.8  * sum(pm.ref[:nw][n][:pump][i]["electricity_price"]/900  * JuMP.value(pm.var[:nw][n][:q_pump][i]) *100 * JuMP.value((pm.var[:nw][n][:H][pump["to_junction"]]) -
         JuMP.value(pm.var[:nw][n][:H][pump["fr_junction"]])) / (0.966 * 0.95 * JuMP.value(pm.var[:nw][n][:eta][i])) / 1000 for (i, pump) in pm.ref[:nw][n][:pump]) for n in nws)

         B2 =  sum(sum(JuMP.value((pm.var[:nw][n][:H][pump["to_junction"]]) -
         JuMP.value(pm.var[:nw][n][:H][pump["fr_junction"]]))/ 1000 for (i, pump) in pm.ref[:nw][n][:pump]) for n in nws)


         # C = sum(sum( JuMP.value(pm.var[:nw][n][:q_tank][i]) for (i, tank) in pm.ref[:nw][n][:tank]) * pm.data["baseQ"] * 3600 for n in nws)
         # println(C)
         println("economic term = ")
         println(pm.data["rho"]  )
         println( pm.data["gravitational_acceleration"]  )
         println( pm.ref[:nw][n][:pump][1]["electricity_price"] )
         println(A*3600)
         println("power term")
         println(B)
         println("objective func=")
         println((A*3600-B))

        for n=0
     for i in sort(collect(ids(pm, :junction)))
         push!(H_values, (JuMP.value(pm.var[:nw][n][:H][i])) )
     end
        println("_H_values = ", H_values*100)
        # println("_H_values = ", H_values)
          println()
    for i in sort(collect(ids(pm, :pump)))
        push!(q_pump_values, (JuMP.value(pm.var[:nw][n][:q_pump][i])) )
    end
   println("q_pump_values = ", q_pump_values*3600)
   # println("q_pump_values = ", q_pump_values)

   for i in sort(collect(ids(pm, :pump)))
       push!(eta_values, (JuMP.value(pm.var[:nw][n][:eta][i])) )
   end
   for i in sort(collect(ids(pm, :pump)))
       push!(w_values, (JuMP.value(pm.var[:nw][n][:w][i])) )
   end
   println("eta = ", eta_values)
   println()
   println("w_values=",w_values)



     for i in sort(collect(ids(pm, :producer)))
          push!(qg_value, JuMP.value(pm.var[:nw][n][:qg][i]) )
     end

    println("producer flow=", qg_value*3600)
    # println("producer flow=", qg_value)
    println()

     for i in sort(collect(ids(pm, :consumer)))
          push!(ql_value, JuMP.value(pm.var[:nw][n][:ql][i]) )
     end
      println("consumer flow=", ql_value*3600)
      # println("consumer flow=", ql_value)
      println()










        end
    end
end
end
