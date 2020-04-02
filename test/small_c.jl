#Check the second order cone model on load shedding
# @testset "test input4" begin
#     @testset "input4 case" begin
#         println("input4 - MISCOP")
#         ipopt_solver = with_optimizer(Ipopt.Optimizer)
#         data = parse_file("input4.m")
#         result = run_ls(data,  MISOCPPetroleumModel, ipopt_solver)
#         println("------")
#         println(typeof(result))
#         @test result["status"] == :LocalOptimal || result["status"] == :Optimal
#         # @test result["status"] == :Optimal
#     end
# end

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

#Check the second order cone model on load shedding
# function check_head_status(sol, pm)
#     println()
#     for (idx,val) in sol["junction"]
#         @test val["H"] <= pm.ref[:nw][pm.cnw][:junction][parse(Int64,idx)]["Hmax"]
#         # pm = build_generic_model(data, MISOCPPetroleumModel, post_ls_)
#         # check_head_status(result["solution"], pm)
# # println(JuMP.value(val["H"]))
# # println(dual_status((val["H"]))
# # println("&&&&&&&&&&")
# # println(((pm.var[:nw][0][:H])))
#     end
# end


#Check the second order code model
# @testset "test ----------" begin
#     @testset "-------" begin
#         println("Testing ----------------")
#         data = parse_file("../test/data/input1.m")
#         result = run_ls("../test/data/input1.m", MISOCPPetroleumModel, cvx_solver)
#         @test result["status"] == :LocalOptimal || result["status"] == :Optimal
#         # @test isapprox(result["objective"], 0; atol = 1e-6)
#         pm = build_generic_model(data, MISOCPPetroleumModel, post_ls_)
#         check_head_status(result["solution"], pm)
#
# end
# end





@testset "test ----------" begin
    @testset "-------" begin
        println("Testing ----------------")
        # data = parse_file("../test/data/pipeline_2012_seaway_m3_per_s.m")
        data = parse_file("../test/data/small_case.m")
        # result = run_ls("../test/data/input1.m", MISOCPPetroleumModel, cvx_solver)
        # @test result["status"] == :LocalOptimal || result["status"] == :Optimal
        # @test isapprox(result["objective"], 0; atol = 1e-6)
    for i=1:1
        data_new = deepcopy(data)
        # data_new["producer"]["1"]["price"] = data["producer"]["1"]["price"] + 20*i
        # data_new["producer"]["2"]["price"] = data["producer"]["2"]["price"] + 10*i
        # data_new["consumer"]["1"]["price"] = data["consumer"]["1"]["price"] + 10*i
        # data_new["consumer"]["2"]["price"] = data["consumer"]["2"]["price"] + 10*i
        # data_new["electricity_price"] = data["electricity_price"] + 0.05*i

        # println(data_new["consumer"]["price"])
         # @show "head_values_$i.csv"
         pm = build_generic_model(data_new, MISOCPPetroleumModel, post_ls_)
         ipopt = JuMP.with_optimizer(Ipopt.Optimizer, print_level=5)
         # solution = pm.optimize_model!(pm, ipopt)
         a = JuMP.optimize!(pm.model, ipopt)

         # solution = pm.optimize_model!(pm, ipopt)
         # e = pm.ref[:nw][0][:pump][i]["electricity_price"]
         e = 0
         n=0
         # A = (-sum(pm.ref[:nw][n][:producer][i]["price"] * JuMP.value(pm.var[:nw][n][:qg][i]) for (i, producer) in pm.ref[:nw][n][:producer]) +
         # sum(pm.ref[:nw][n][:consumer][i]["price"] * JuMP.value(pm.var[:nw][n][:ql][i]) for (i, consumer) in pm.ref[:nw][n][:consumer])) * pm.data["baseQ"] * 3600
         A = 0
         B =  pm.data["rho"] * pm.data["gravitational_acceleration"]  * sum(pm.ref[:nw][0][:pump][i]["electricity_price"] * JuMP.value(pm.var[:nw][0][:q][i]) * pm.data["baseQ"] * JuMP.value((pm.var[:nw][0][:H][pump["t_junction"]]) -
         JuMP.value(pm.var[:nw][0][:H][pump["f_junction"]])) * pm.data["baseH"] / (0.966 * 0.95 * JuMP.value(pm.var[:nw][n][:eta][i])) for (i, pump) in pm.ref[:nw][0][:pump]) / 3600 / 1000 * 3600
         println("economical term = ")
         println(A)
         println()
         println("power term")
         println(B)
          println()
     for i in sort(collect(ids(pm, :junction)))

         push!(H_values, (JuMP.value(pm.var[:nw][0][:H][i])) * pm.data["baseH"])

     end
     println(H_values)
     println()


     # println("1 = ", JuMP.value(pm.var[:nw][0][:q][1]))
     # println("9 = ", JuMP.value(pm.var[:nw][0][:q][9]) )
     # println("19 = ", JuMP.value(pm.var[:nw][0][:q][18]) )
     #
     # println("15 = ", JuMP.value(pm.var[:nw][0][:q][15]) )
     # println("22 = ", JuMP.value(pm.var[:nw][0][:q][22]) )


     for i in sort(collect(ids(pm, :producer)))
          push!(qg_value, JuMP.value(pm.var[:nw][0][:qg][i]) * pm.data["baseQ"] * 3600)
     end
     println("qg_value = ", qg_value)

     for i in sort(collect(ids(pm, :consumer)))
          push!(ql_value, JuMP.value(pm.var[:nw][0][:ql][i]) * pm.data["baseQ"] * 3600)
     end

     println("ql_value = ", ql_value)

     for i in sort(collect(ids(pm, :pump)))
         println("eta = ", JuMP.value(pm.var[:nw][0][:eta][i]))
         println()
         println("omega = ", JuMP.value(pm.var[:nw][0][:w][i]))
     end

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


     println("length = ", length(collect(ids(pm, :pump))))
     for j = 2:length(H_values)
               delta_H_values = H_values[j] - H_values[j-1]
               # println(delta_H_values)
     end


     for i in sort(collect(ids(pm, :junction)))
         push!( q_dual_node, JuMP.dual(pm.con[:nw][0][:junction_volume_flow_balance][i]))
         push!(H_dual_up, (JuMP.dual(UpperBoundRef(pm.var[:nw][0][:H][i]))) * pm.data["baseH"])
         push!(Hmax,  pm.ref[:nw][0][:junction][i]["Hmax"] * pm.data["baseH"])
         push!(Hmin,  pm.ref[:nw][0][:junction][i]["Hmin"] * pm.data["baseH"])
         push!(H_dual_low, (JuMP.dual(LowerBoundRef(pm.var[:nw][0][:H][i]))) * pm.data["baseH"])
     end

     for i in sort(collect(ids(pm, :pipe)))
         push!(q_values, JuMP.value(pm.var[:nw][0][:q][i]) * pm.data["baseQ"] * 3600)
         push!(q_dual_up, (JuMP.dual(UpperBoundRef(pm.var[:nw][0][:q][i]))) * pm.data["baseQ"] * 3600)
         push!(q_dual_low, (JuMP.dual(LowerBoundRef(pm.var[:nw][0][:q][i]))) * pm.data["baseQ"] * 3600)
         push!(q_max, pm.ref[:nw][0][:pipe][i]["Qmax"]  * pm.data["baseQ"] * 3600)
         push!(q_min, pm.ref[:nw][0][:pipe][i]["Qmin"]  * pm.data["baseQ"] * 3600)
         push!(nodal_volume_balance, JuMP.dual(pm.con[:nw][0][:nodal_volume_balance][i]))
     end

     println("q_values=", q_values)


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
         push!(eta_values, JuMP.value(pm.var[:nw][0][:eta][i]))
         push!(w_values, JuMP.value(pm.var[:nw][0][:w][i]))
         push!(w_dual_up, (JuMP.dual(UpperBoundRef(pm.var[:nw][0][:w][i]))))
         push!(Eta_con, JuMP.dual(pm.con[:nw][0][:eta_con][i]))
         push!(Pump_head_con, JuMP.dual(pm.con[:nw][0][:pump_head_con][i]))
         push!(pump_deltaHmax_dual, JuMP.dual(pm.con[:nw][0][:delta_Hmax_con][i]))
         push!(pump_deltaHmin_dual, JuMP.dual(pm.con[:nw][0][:delta_Hmin_con][i]))
         push!(w_dual_low, (JuMP.dual(LowerBoundRef(pm.var[:nw][0][:w][i]))))
         push!(eta_dual_up, (JuMP.dual(UpperBoundRef(pm.var[:nw][0][:eta][i]))))

     end

     #
     for i in sort(collect(ids(pm, :pump)))

         push!(eta_dual_low, (JuMP.dual(LowerBoundRef(pm.var[:nw][0][:eta][i]))))
         push!(min_pump_efficiency, pm.ref[:nw][0][:pump][i]["min_pump_efficiency"])
         push!(max_pump_efficiency, pm.ref[:nw][0][:pump][i]["max_pump_efficiency"])
         push!(max_w, pm.ref[:nw][0][:pump][i]["max_w"])
         push!(min_w, pm.ref[:nw][0][:pump][i]["min_w"])

     end
     # println(sort(collect(ids(pm, :pipe))))
     # println(q_dual_low)
     # println((pm.ref[:nw][0][:pipe][3]["Qmin"]*3600))
     # println(round.(q_values))
     # println(round.(pm.ref[:nw][0][:pipe]["Qmax"]*3600))
     # println(q_dual_up)

     # println(JuMP.value(objective_min_energy))
     # sort(collect(ids(pm, :pump))) = ["P1", "P2", "P3"]

     # node_values      = [ "Node #" "Head, m"; sort(collect(ids(pm, :junction))) H_values]

     dual_values      = ["Producer 1 price" "Producer 2 price" "Consumer 1 price" "Consumer 2 price" "" "";
                         pm.ref[:nw][0][:producer][1]["price"] pm.ref[:nw][0][:producer][2]["price"] pm.ref[:nw][0][:consumer][1]["price"]  pm.ref[:nw][0][:consumer][2]["price"] ""; "" "" "" "" "" "";
                         "Economic term" "Power term" "Objective" "" "" "";
                         A B B-A "" "" ""; "" "" "" "" "" "";
                           "" "" "Head values" "" "" ""; "Node #" "Dual low head value" "Low boundary" "Variable" "Up boundary" "Dual up head value"; sort(collect(ids(pm, :junction))) round.(H_dual_low) Hmin round.(H_values) Hmax round.(H_dual_up);
                           "" "" "" "" "" "";
                         "" "" "Pump efficiency" "" "" ""; "Pump id" "Dual low" "Low boundary" "Variable" "Up boundary" "Dual up"; sort(collect(ids(pm, :pump))) round.(eta_dual_low) min_pump_efficiency eta_values max_pump_efficiency round.(eta_dual_up);
                         "" "" "" "" "" ""; "" "" "Rotation speed" "" "" "";
                           "Pump id" "Dual low" "Low boundary" "Variable" "Up boundary" "Dual up"; sort(collect(ids(pm, :pump))) round.(w_dual_low) min_w round.(w_values) max_w round.(w_dual_up);
                           "" "" "" "" "" ""; "" "" "Flow rate" "" "" ""; "Element id" "Dual low" "Low boundary" "Variable" "Up boundary" "Dual up"; sort(collect(ids(pm, :pipe))) q_dual_low q_min q_values q_max q_dual_up]

    # Prices                 = ["Producer 1 price" "Producer 2 price" "Producer 3 price" "Consumer 1 price" "Consumer 2 price";
    #                           pm.ref[:nw][0][:producer][1]["price"] pm.ref[:nw][0][:producer][2]["price"] pm.ref[:nw][0][:producer][3]["price"] pm.ref[:nw][0][:consumer][1]["price"]  pm.ref[:nw][0][:consumer][2]["price"] ""]


    Head_values             = ["Node #" "Dual low head value" "Low boundary" "Variable" "Up boundary" "Dual up head value";
                              sort(collect(ids(pm, :junction))) round.(H_dual_low) Hmin round.(H_values) Hmax round.(H_dual_up)]

    Pump_efficiency         = ["Pump id" "Dual low" "Low boundary" "Variable" "Up boundary" "Dual up";
                              sort(collect(ids(pm, :pump))) round.(eta_dual_low) min_pump_efficiency eta_values max_pump_efficiency round.(eta_dual_up)]
    Rotation_speed          = ["Pump id" "Dual low" "Low boundary" "Variable" "Up boundary" "Dual up";
                              sort(collect(ids(pm, :pump))) round.(w_dual_low) min_w round.(w_values) max_w round.(w_dual_up)]
    Pipe_flow_rate          = ["Element id" "Dual low" "Low boundary" "Variable" "Up boundary" "Dual up";
                              sort(collect(ids(pm, :pipe))) q_dual_low q_min round.(q_values) q_max q_dual_up]
    # CP_q_values             = ["Producer id" "Flow rate" "Consumer id" "Flow rate" ;
    #                           sort(collect(ids(pm, :producer))) round.(qg_value) sort(collect(ids(pm, :consumer)))  round.(ql_value)]

    q_dual_node_values      = ["Junction" "Dual value";
                              sort(collect(ids(pm, :junction)))  round.(q_dual_node)]


    # CP_q_values_dual        = ["Producer 1 flow price" "Producer 2 flow price" "Producer 3 flow price" "Consumer 1 flow price" "Consumer 2 flow price";
    #                           round.(q_dual_node[1])  round.(q_dual_node[9])  round.(q_dual_node[18])  round.(q_dual_node[15])  round.(q_dual_node[23])]

    pump_constraint_dual_values    = ["Pump id " "min delta H dual" "max delta H dual" "Pump head dual" "Pump efficiency dual";
                                    sort(collect(ids(pm, :pump))) round.(pump_deltaHmin_dual) round.(pump_deltaHmax_dual) round.(Pump_head_con) round.(Eta_con)]

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
     writedlm("all_values_$i.csv", dual_values, ",")
     # writedlm(" Prices_$i.csv",  Prices, ",")
     # writedlm(" Head_values_$i.csv",  Head_values, ",")
     # writedlm(" Pump_efficiency_$i.csv",  Pump_efficiency, ",")
     # writedlm(" Rotation_speed_$i.csv",  Rotation_speed, ",")
     # writedlm(" Pipe_flow_rate_$i.csv",  Pipe_flow_rate, ",")
     # writedlm(" Consumer_producer_flow_rate_$i.csv",  CP_q_values, ",")
     #
     #  writedlm(" CP_q_values_dual_$i.csv",  CP_q_values_dual, ",")
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
        global H_dual_up        = zeros(Float64,0)
        global H_dual_low       = zeros(Float64,0)
        global q_dual_node      = zeros(Float64,0)
        global q_values      = zeros(Float64,0)
        global q_dual_up        = zeros(Float64,0)
        global q_dual_low       = zeros(Float64,0)
        global w_dual_up        = zeros(Float64,0)
        global w_dual_low       = zeros(Float64,0)
        global eta_dual_up      = zeros(Float64,0)
        global eta_dual_low     = zeros(Float64,0)
        global H_values         = zeros(Float64,0)
        global delta_H_values   = zeros(Float64,0)
        global pump_deltaHmax_dual = zeros(Float64,0)
        global Eta_con          = zeros(Float64,0)
        global Pump_head_con    = zeros(Float64,0)
        global pump_deltaHmin_dual = zeros(Float64,0)
        # global nodal_volume_balance         = zeros(Float64,0)
        # global q_values_2         = zeros(Float64,0)
        global qg_value         = zeros(Float64,0)
        global ql_value         = zeros(Float64,0)
        global w_values         = zeros(Float64,0)
        global eta_values       = zeros(Float64,0)
        global min_pump_efficiency = zeros(Float64,0)
        global max_pump_efficiency = zeros(Float64,0)
        global min_w               = zeros(Float64,0)
        global max_w               = zeros(Float64,0)
        global Hmax                = zeros(Float64,0)
        global Hmin                = zeros(Float64,0)
        global q_max               = zeros(Float64,0)
        global q_min               = zeros(Float64,0)

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
        #
        # writedlm("pump_values_$i.csv", pump_values, ",")
        # deleteat!(eta_values, eta_values .>= 0)
        # deleteat!(w_values, w_values .>= 0)



            #println(pm.var[:nw][0][:H][2])
        # end
        # check_head_status(result["solution"], pm)
        # println()
        # println(result)
        # println()
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
