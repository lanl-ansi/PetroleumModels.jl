
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
pump_deltaHmax_dual       = []
pump_deltaHmin_dual       = []
H_dual_up = []
H_dual_low = []
q_dual_node = []
q_dual_up = []
q_dual_low = []
w_dual_up = []
w_dual_low = []
eta_dual_up = []
eta_dual_low = []
min_pump_efficiency = []
max_pump_efficiency = []
min_w = []
max_w = []
Hmax = []
Hmin = []
q_max = []
q_min = []
q_pump_values =[]




@testset "test ----------" begin
    @testset "-------" begin
        println("Testing ----------------")
        data = parse_file("../test/data/pipeline_2012_seaway_m3_per_h.m")

    for i=1:1
        data_new = deepcopy(data)

         pm = instantiate_model(data_new, MISOCPPetroleumModel, build_ls)
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

         B =  sum( pm.data["rho"] * pm.data["gravitational_acceleration"]  * sum(pm.ref[:nw][n][:pump][i]["electricity_price"] * JuMP.value(pm.var[:nw][n][:q_pump][i]) /  3600 * JuMP.value((pm.var[:nw][n][:H][pump["to_junction"]]) -
         JuMP.value(pm.var[:nw][n][:H][pump["fr_junction"]])) / (0.966 * 0.95 * JuMP.value(pm.var[:nw][n][:eta][i])) / 1000 for (i, pump) in pm.ref[:nw][n][:pump]) for n in nws)

         B2 =  sum(sum(JuMP.value((pm.var[:nw][n][:H][pump["to_junction"]]) -
         JuMP.value(pm.var[:nw][n][:H][pump["fr_junction"]]))/ 1000 for (i, pump) in pm.ref[:nw][n][:pump]) for n in nws)


         # C = sum(sum( JuMP.value(pm.var[:nw][n][:q_tank][i]) for (i, tank) in pm.ref[:nw][n][:tank]) * pm.data["baseQ"] * 3600 for n in nws)
         # println(C)
         println("economic term = ")
         # # println(( JuMP.value(pm.var[:nw][n][:q_tank][31]) ))
         # println(A*3600)
         # println("power term")
         # println(B*100*827*3600)
         # # println(B2)
         # println((A*3600-B*100*827*3600))

         println(A)
         println("power term")
         println(B)
         println("objective func=")
         println((A-B))

# for n in 1:length(pm.ref[:nw])
    for n=0
     for i in sort(collect(ids(pm, :junction)))
         push!(H_values, (JuMP.value(pm.var[:nw][n][:H][i])) )
     end
        # println("_H_values = ", H_values*100)
        println("_H_values = ", H_values)
          println()
    for i in sort(collect(ids(pm, :pump)))
        push!(q_pump_values, (JuMP.value(pm.var[:nw][n][:q_pump][i])) )
    end
   # println("q_pump_values = ", q_pump_values*3600)
   println("q_pump_values = ", q_pump_values)

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

    # println("producer=", qg_value*3600)
    println("producer flow=", qg_value)
    println()

     for i in sort(collect(ids(pm, :consumer)))
          push!(ql_value, JuMP.value(pm.var[:nw][n][:ql][i]) )
     end
      # println("consumer=", ql_value*3600)
      println("consumer flow=", ql_value)
      println()



     # for i in sort(collect(ids(pm, :producer)))
     #      println(JuMP.value(pm.var[:nw][0][:qg][i]))
     # end
     # println()
     #
     # for i in sort(collect(ids(pm, :consumer)))
     #      println(JuMP.value(pm.var[:nw][0][:ql][i]))
     # end
     # println()
     #
     #


     # println("length = ", length(collect(ids(pm, :pump))))
     # for j = 2:length(H_values)
     #           delta_H_values = H_values[j] - H_values[j-1]
     #           # println(delta_H_values)
     # end
     #
     #
     # for i in sort(collect(ids(pm, :junction)))
     #     push!( q_dual_node, JuMP.dual(pm.con[:nw][n][:junction_volume_flow_balance][i]) )
     #     push!(H_dual_up, (JuMP.dual(UpperBoundRef(pm.var[:nw][n][:H][i]))) * pm.data["baseH"] )
     #     push!(Hmax,  pm.ref[:nw][n][:junction][i]["Hmax"] * pm.data["baseH"] )
     #     push!(Hmin,  pm.ref[:nw][n][:junction][i]["Hmin"] * pm.data["baseH"] )
     #     push!(H_dual_low, (JuMP.dual(LowerBoundRef(pm.var[:nw][n][:H][i]))) * pm.data["baseH"] )
     # end

     # for i in sort(collect(ids(pm, :pipe)))
     #     push!(q_values, JuMP.value(pm.var[:nw][n][:q][i]) * pm.data["baseQ"] * 3600 )
     #     # push!(q_dual_up, (JuMP.dual(UpperBoundRef(pm.var[:nw][n][:q][i]))) * pm.data["baseQ"] * 3600 )
     #     # push!(q_dual_low, (JuMP.dual(LowerBoundRef(pm.var[:nw][n][:q][i]))) * pm.data["baseQ"] * 3600 )
     #     push!(q_max, pm.ref[:nw][n][:pipe][i]["Qmax"]  * pm.data["baseQ"] * 3600 )
     #     push!(q_min, pm.ref[:nw][n][:pipe][i]["Qmin"]  * pm.data["baseQ"] * 3600 )
     #     push!(nodal_volume_balance, JuMP.dual(pm.con[:nw][n][:nodal_volume_balance][i]) )
     # end


     # for i in sort(collect(ids(pm, :connection))), k in 1:2
     #     println(JuMP.value(pm.var[:nw][0][:q][i]) * pm.data["baseQ"])
     #     ii = convert(Int64, i/10)
     #     if JuMP.value(pm.var[:nw][0][:q][i]) == JuMP.value(pm.var[:nw][0][:ql][k])
     #
     #         q_max[ii] = pm.ref[:nw][0][:consumer][k]["qlmax"] * pm.data["baseQ"]
     #         q_min[ii] = pm.ref[:nw][0][:consumer][k]["qlmin"] * pm.data["baseQ"]
     #     end
     #     if JuMP.value(pm.var[:nw][0][:q][i]) == JuMP.value(pm.var[:nw][0][:qg][k])
     #
     #         q_max[ii] = pm.ref[:nw][0][:producer][k]["qgmax"] * pm.data["baseQ"]
     #         q_min[ii] = pm.ref[:nw][0][:producer][k]["qgmin"] * pm.data["baseQ"]
     #
     #         # println(pm.ref[:nw][0][:producer][2]["qgmax"] * pm.data["baseQ"])
     #
     #     end
     # end

     # for i in 4:5
     #     q_max[i] = pm.ref[:nw][0][:max_volume_flow] * 3600
     #     q_min[i] = pm.ref[:nw][0][:min_volume_flow] * 3600
     # end



 # println(keys(q_max), q_max)
 # println(keys(q_min), q_min)

     for i in sort(collect(ids(pm, :pump)))
         push!(eta_values, JuMP.value(pm.var[:nw][n][:eta][i]) )
         push!(w_values, JuMP.value(pm.var[:nw][n][:w][i]) )
         push!(w_dual_up, (JuMP.dual(UpperBoundRef(pm.var[:nw][n][:w][i]))) )
         push!(Eta_con, JuMP.dual(pm.con[:nw][n][:eta_con][i]) )
         push!(Pump_head_con, JuMP.dual(pm.con[:nw][n][:pump_head_con][i]) )
         push!(pump_deltaHmax_dual, JuMP.dual(pm.con[:nw][n][:delta_Hmax_con][i]) )
         push!(pump_deltaHmin_dual, JuMP.dual(pm.con[:nw][n][:delta_Hmin_con][i]) )
         push!(w_dual_low, (JuMP.dual(LowerBoundRef(pm.var[:nw][n][:w][i]))) )
         push!(eta_dual_up, (JuMP.dual(UpperBoundRef(pm.var[:nw][n][:eta][i]))) )

     end
     println("eta_values=",eta_values)
     println()
      println("w_values=",w_values)

     # for i in sort(collect(ids(pm, :pump)))
     #
     #     push!(eta_dual_low, (JuMP.dual(LowerBoundRef(pm.var[:nw][n][:eta][i]))))
     #     push!(min_pump_efficiency, pm.ref[:nw][n][:pump][i]["min_pump_efficiency"] )
     #     push!(max_pump_efficiency, pm.ref[:nw][n][:pump][i]["max_pump_efficiency"] )
     #     push!(max_w, pm.ref[:nw][n][:pump][i]["max_w"] )
     #     push!(min_w, pm.ref[:nw][n][:pump][i]["min_w"] )
     #
     # end
     # println(sort(collect(ids(pm, :pipe))))
     # println(q_dual_low)
     # println((pm.ref[:nw][0][:pipe][3]["Qmin"]*3600))
     # println(round.(q_values))
     # println(round.(pm.ref[:nw][0][:pipe]["Qmax"]*3600))
     # println(q_dual_up)

     # println(JuMP.value(objective_min_energy))
     # sort(collect(ids(pm, :pump))) = ["P1", "P2", "P3"]

     # node_values      = [ "Node #" "Head, m"; sort(collect(ids(pm, :junction))) H_values]


     # dual_values      = ["Producer 1 price" "Producer 2 price" "Producer 3 price" "Consumer 1 price" "Consumer 2 price" "";
     #                     (pm.ref[:nw][n][:producer][1]["price"] ) (pm.ref[:nw][n][:producer][2]["price"] ) pm.ref[:nw][n][:producer][3]["price"] (pm.ref[:nw][n][:consumer][1]["price"]) (pm.ref[:nw][n][:consumer][2]["price"] ) "" ;
     #                      "" "" "" "" "" "";
     #                     "Economic term" "Power term" "Objective" "" "" "";
     #                     A B A-B "" "" ""; "" "" "" "" "" "";
     #                       "" "" "Head values" "" "" ""; "Node #" "Dual low head value" "Low boundary" "Variable" "Up boundary" "Dual up head value"; sort(collect(ids(pm, :junction))) round.(H_dual_low) Hmin round.(H_values) Hmax round.(H_dual_up);
     #                       "" "" "" "" "" "";
     #                     "" "" "Pump efficiency" "" "" ""; "Pump id" "Dual low" "Low boundary" "Variable" "Up boundary" "Dual up"; sort(collect(ids(pm, :pump))) round.(eta_dual_low) min_pump_efficiency eta_values max_pump_efficiency round.(eta_dual_up);
     #                     "" "" "" "" "" ""; "" "" "Rotation speed" "" "" "";
     #                       "Pump id" "Dual low" "Low boundary" "Variable" "Up boundary" "Dual up"; sort(collect(ids(pm, :pump))) round.(w_dual_low) min_w round.(w_values) max_w round.(w_dual_up);
     #                       "" "" "" "" "" ""; "" "" "Flow rate" "" "" ""; "Element id" "Dual low" "Low boundary" "Variable" "Up boundary" "Dual up"; sort(collect(ids(pm, :pipe))) q_dual_low q_min q_values q_max q_dual_up]
     #

    # pump_values   = ["Pump id" "Efficiency" "Rotation speed"; sort(collect(ids(pm, :pump))) eta_values w_values]
    # writedlm("pump_values_$n.csv", pump_values, ",")

    # # Prices                 = ["Producer 1 price" "Producer 2 price" "Producer 3 price" "Consumer 1 price" "Consumer 2 price";
    # #                           pm.ref[:nw][0][:producer][1]["price"] pm.ref[:nw][0][:producer][2]["price"] pm.ref[:nw][0][:producer][3]["price"] pm.ref[:nw][0][:consumer][1]["price"]  pm.ref[:nw][0][:consumer][2]["price"] ""]
    #
    # Head_values             = ["Node #" "Dual low head value" "Low boundary" "Variable" "Up boundary" "Dual up head value";
    #                           sort(collect(ids(pm, :junction))) round.(H_dual_low) Hmin round.(H_values) Hmax round.(H_dual_up)]
    #
    # Pump_efficiency         = ["Pump id" "Dual low" "Low boundary" "Variable" "Up boundary" "Dual up";
    #                           sort(collect(ids(pm, :pump))) round.(eta_dual_low) min_pump_efficiency eta_values max_pump_efficiency round.(eta_dual_up)]
    # Rotation_speed          = ["Pump id" "Dual low" "Low boundary" "Variable" "Up boundary" "Dual up";
    #                           sort(collect(ids(pm, :pump))) round.(w_dual_low) min_w round.(w_values) max_w round.(w_dual_up)]
    # Pipe_flow_rate          = ["Element id" "Dual low" "Low boundary" "Variable" "Up boundary" "Dual up";
    #                           sort(collect(ids(pm, :pipe))) q_dual_low q_min round.(q_values) q_max q_dual_up]

    # CP_q_values             = ["Producer id" "Flow rate";
    #                             sort(collect(ids(pm, :producer))) round.(qg_value);
    #                             "Consumer id" "Flow rate";
    #                             sort(collect(ids(pm, :consumer))) round.(ql_value)]
    # #
    #
    # q_dual_node_values      = ["Junction" "Dual value";
    #                           sort(collect(ids(pm, :junction)))  round.(q_dual_node)]
    #
    #
    # CP_q_values_dual        = ["Producer 1 flow price" "Producer 2 flow price" "Producer 3 flow price" "Consumer 1 flow price" "Consumer 2 flow price";
                              # round.(q_dual_node[1])  round.(q_dual_node[9])  round.(q_dual_node[18])  round.(q_dual_node[15])  round.(q_dual_node[23])]

    # pump_constraint_dual_values    = ["Pump id " "min delta H dual" "max delta H dual" "Pump head dual" "Pump efficiency dual";
    #                                 sort(collect(ids(pm, :pump))) round.(pump_deltaHmin_dual) round.(pump_deltaHmax_dual) round.(Pump_head_con) round.(Eta_con)]
    # writedlm("all_values_$i.csv", dual_values, ",")
    # writedlm("Consumer_producer_flow_rate_$n.csv",  CP_q_values, ",")


#     global w_values         = zeros(Float64,0)
#     global eta_values       = zeros(Float64,0)
#     global H_dual_up        = zeros(Float64,0)
#     global H_dual_low       = zeros(Float64,0)
#     global q_dual_node      = zeros(Float64,0)
#     global q_values         = zeros(Float64,0)
#     global q_dual_up        = zeros(Float64,0)
#     global q_dual_low       = zeros(Float64,0)
#     global w_dual_up        = zeros(Float64,0)
#     global w_dual_low       = zeros(Float64,0)
#     global eta_dual_up      = zeros(Float64,0)
#     global eta_dual_low     = zeros(Float64,0)
#     global H_values         = zeros(Float64,0)
#     global delta_H_values   = zeros(Float64,0)
#     global pump_deltaHmax_dual = zeros(Float64,0)
#     global Eta_con          = zeros(Float64,0)
#     global Pump_head_con    = zeros(Float64,0)
#     global pump_deltaHmin_dual = zeros(Float64,0)
#     global qg_value         = zeros(Float64,0)
#     global ql_value         = zeros(Float64,0)
#     global min_pump_efficiency = zeros(Float64,0)
#     global max_pump_efficiency = zeros(Float64,0)
#     global min_w               = zeros(Float64,0)
#     global max_w               = zeros(Float64,0)
#     global Hmax                = zeros(Float64,0)
#     global Hmin                = zeros(Float64,0)
#     global q_max               = zeros(Float64,0)
#     global q_min               = zeros(Float64,0)
# end
#
#
# global A                   = zeros(Float64,0)
# global B                   = zeros(Float64,0)
     # H_dual_values    = ["Node #" "Dual up head value" "Dual low head value"; sort(collect(ids(pm, :junction))) H_dual_low H_dual_up]
     # q_dual_values    = ["Element id" "Dual low" "Dual up"; sort(collect(ids(pm, :connection))) q_dual_low q_dual_up]
     # w_dual_values    = ["Pump id" "Dual low" "Dual up"; sort(collect(ids(pm, :pump))) w_dual_low w_dual_up]
     # eta_dual_values  = ["Pump id" "Dual low" "Dual up"; sort(collect(ids(pm, :pump))) eta_dual_low eta_dual_up]

     # node_values_2 = ["Element id" "Flow rate"; sort(collect(ids(pm, :connection))) q_values*3600]
     # pump_values   = ["Pump id" "Efficiency" "Rotation speed"; sort(collect(ids(pm, :pump))) eta_values w_values]

     # println(H_dual_values)
     # writedlm("head_values_$i.csv", node_values, ",")
     # deleteat!(H_values, H_values .>= 0)
     # deleteat!(Hmax, Hmax .>= 0)
     # deleteat!(Hmin, Hmin .>= 0)
     #

     # writedlm(" Prices_$i.csv",  Prices, ",")
     # writedlm(" Head_values_$i.csv",  Head_values, ",")
     # writedlm(" Pump_efficiency_$i.csv",  Pump_efficiency, ",")
     # writedlm(" Rotation_speed_$i.csv",  Rotation_speed, ",")
     # writedlm(" Pipe_flow_rate_$i.csv",  Pipe_flow_rate, ",")
     #
      # writedlm(" CP_q_values_dual_$i.csv",  CP_q_values_dual, ",")
      # writedlm("Rotation_speed_$i.csv",  Rotation_speed, ",")
     # writedlm(" q_dual_node_values_$i.csv",  q_dual_node_values, ",")
     # deleteat!(H_dual_up, H_dual_up .>= 0)
     # deleteat!(H_dual_low, H_dual_low .>= 0)
     #
     #
     # # writedlm("flow_rate_dual_$i.csv", q_dual_values, ",")
     # deleteat!(q_dual_up, q_dual_up .>= 0)
     # deleteat!(q_dual_low, q_dual_low .>= 0)
     #
     # # writedlm("speed_dual_$i.csv", w_dual_values, ",")
     # deleteat!(w_dual_up, w_dual_up .>= 0)
     # deleteat!(w_dual_low, w_dual_low .>= 0)
     #
     # # writedlm("efficiency_dual_$i.csv", eta_dual_values, ",")
     # deleteat!(eta_dual_up, eta_dual_up .>= 0)
     # deleteat!(eta_dual_low, eta_dual_low .>= 0)
     #
     # writedlm("flow_rate_values_$i.csv", node_values_2, ",")
     # deleteat!(q_values, q_values .>= 0)
     # deleteat!(q_min, q_min .>= 0)
     # deleteat!(q_max, q_max .>= 0)
     #
     # # writedlm("pump_values_$i.csv", pump_values, ",")
     # deleteat!(eta_values, eta_values .>= 0)
     # deleteat!(max_pump_efficiency, max_pump_efficiency .>= 0)
     # deleteat!(min_pump_efficiency, min_pump_efficiency .>= 0)
     #
     # deleteat!(w_values, w_values .>= 0)
     # deleteat!(max_w, max_w .>= 0)
     # deleteat!(min_w, min_w .>= 0)




        # node_values      = ["Node #" "Head, m"; sort(collect(ids(pm, :junction))) H_values]
        # H_dual_values    = ["Node #" "Dual up head value" "Dual low head value"; sort(collect(ids(pm, :junction))) round.(H_dual_low) round.(H_dual_up)]
        # q_dual_values    = ["Element id" "Dual low" "Dual up"; sort(collect(ids(pm, :connection))) q_dual_low q_dual_up]
        # w_dual_values    = ["Pump id" "Dual low" "Dual up"; sort(collect(ids(pm, :pump))) w_dual_low w_dual_up]
        # eta_dual_values  = ["Pump id" "Dual low" "Dual up"; sort(collect(ids(pm, :pump))) eta_dual_low eta_dual_up]
        #
        # node_values_2 = ["Elenent id" "Flow rate"; sort(collect(ids(pm, :connection))) q_values]
        # pump_values   = ["Pump id" "Efficiency" "Rotation speed"; sort(collect(ids(pm, :pump))) eta_values w_values]
        #

        # writedlm("head_values_$i.csv", node_values, ",")
        # deleteat!(H_values, H_values .>= 0)

        # writedlm("head_dual_$i.csv", H_dual_values, ",")


        # deleteat!(H_dual_low, H_dual_low .>= 0)
        #
        # writedlm("flow_rate_dual_$i.csv", q_dual_values, ",")
        # deleteat!(q_dual_up, q_dual_up .>= 0)
        # deleteat!(q_dual_low, q_dual_low .>= 0)
        #
        # writedlm("speed_dual_$i.csv", w_dual_values, ",")
        # deleteat!(w_dual_up, w_dual_up .>= 0)
        # deleteat!(w_dual_low, w_dual_low .>= 0)
        #
        # writedlm("efficiency_dual_$i.csv", eta_dual_values, ",")
        # deleteat!(eta_dual_up, eta_dual_up .>= 0)
        # deleteat!(eta_dual_low, eta_dual_low .>= 0)


        # writedlm("flow_rate_values_$i.csv", node_values_2, ",")
        # deleteat!(q_values, q_values .>= 0)
    end
        end
    end
end


#
# @testset "test misocp ls" begin
#     @testset "case 2" begin
#         println("Test 1")
#         result = run_ls("../test/data/input2.m",  MISOCPPetroleumModel, cvx_solver)
#         @test result["status"] == :LocalOptimal || result["status"] == :Optimal
#         for i in keys(sort((result["solution"]["junction"])))
#             push!(H_values, result["solution"]["junction"][i]["H"] )
#         end
#         node_values_2   = [sort(ii) H_values]
#         writedlm("head_values_2.csv", node_values_2, ",")
#         deleteat!(H_values, H_values .>= 0)
#         end
#
#    end
#         # node_values   = [sort(ii) H_values]
#         # writedlm("head_values_2.csv", node_values, ",")
#         # return(node_values)
#
#
#         #  for i in keys(sort((result["solution"]["junction"])))
#         #
#         #         push!(H_values_2, result["solution"]["junction"][i]["H"] )
#         # end
#         # node_values   = [sort((result["solution"]["junction"])) H_values_2]
#         # node_values_2 = [sort(collect(ids(pm, :connection))) q_values*3600]
#         # pump_values   = [sort(collect(ids(pm, :pump))) eta_values w_values]
#
#         # writedlm("head_values_2.dat", node_values, ",")
#         # writedlm("flow_rate_values.dat", node_values_2, ",")
#         # writedlm("pump_values.dat", pump_values, ",")
#             # println(sort(ii))
#         # println(keys(result["solution"]["junction"]))
#
#         # println(JuMP.value.(pm.var[:nw][0][:H][k]))
#         # @test isapprox(result["objective"]*result["solution"]["baseQ"], 515.2312009025778; atol = 1e-1)
#
# ;
# @testset "test misocp ls" begin
#     @testset "case 3" begin
#         println("Test 1")
#         result = run_ls("../test/data/input3.m",  MISOCPPetroleumModel, cvx_solver)
#         @test result["status"] == :LocalOptimal || result["status"] == :Optimal
#         for i in keys(sort((result["solution"]["junction"])))
#             push!(H_values, result["solution"]["junction"][i]["H"] )
#         end
#         node_values_3   = [sort(ii) H_values]
#         writedlm("head_values_3.csv", node_values_3, ",")
#         deleteat!(H_values, H_values .>= 0)
#         # @test isapprox(result["objective"]*result["solution"]["baseQ"], 515.2312009025778; atol = 1e-1)
#      end
# end
#
# @testset "test misocp ls" begin
#     @testset "case 4" begin
#         println("Test 1")
#         result = run_ls("../test/data/input4.m",  MISOCPPetroleumModel, cvx_solver)
#         @test result["status"] == :LocalOptimal || result["status"] == :Optimal
#         for i in keys(sort((result["solution"]["junction"])))
#             push!(H_values, result["solution"]["junction"][i]["H"] )
#         end
#         node_values_4   = [sort(ii) H_values]
#         writedlm("head_values_4.csv", node_values_4, ",")
#         deleteat!(H_values, H_values .>= 0)
#         # @test isapprox(result["objective"]*result["solution"]["baseQ"], 515.2312009025778; atol = 1e-1)
#      end
# end
