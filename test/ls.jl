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

H_values1         = []
H_values2         = []
delta_H_values   = []
q_values         = []
w_values         = []
eta_values       = []

ii = []
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

@testset "test" begin
          @info "Testing"
          data = parse_file("../test/data/pipeline_2012_seaway_m3_per_s.m")
          @test !InfrastructureModels.ismultinetwork(data)
          mn_data = InfrastructureModels.make_multinetwork(data, _pm_global_keys)
          # data = parse_file("../test/data/small_case.m")
          # pm = instantiate_model(mn_data, MISOCPPetroleumModel, post_ls_)
          result = run_ls(mn_data, MISOCPPetroleumModel, ipopt_solver)
          # println(collect(sort(result["solution"]["nw"]["2"]["junction"])))
          for i in keys(sort((result["solution"]["nw"]["1"]["junction"])))
                      push!(ii, parse(Int64, i))
                      # println((result["solution"]))
                      # println(ii, " = ", make_si_unit!(result["solution"]["junction"][i]["H"]));
                      push!(H_values1, ((result["solution"]["nw"]["1"]["junction"][i]["H"])))
          end
          println("H_values for nw = 1: ",H_values1 * 100)

          for i in keys(sort((result["solution"]["nw"]["2"]["junction"])))
                      push!(ii, parse(Int64, i))
                      # println((result["solution"]))
                      # println(ii, " = ", make_si_unit!(result["solution"]["junction"][i]["H"]));
                      push!(H_values2, ((result["solution"]["nw"]["2"]["junction"][i]["H"])))
          end
          println("H_values for nw = 2: ", H_values2 * 100)

          @test result["status"] == :LocalOptimal || result["status"] == :Optimal
          # @test result["termination_status"] == LOCALLY_SOLVED || result["termination_status"] == OPTIMAL || result["termination_status"] == :Suboptimal
          make_si_unit!(data, result["solution"])


end

      # @testset "test value output" begin
      #     data = parse_file("../test/data/article.m")
      #     result = run_ls(data, MISOCPPetroleumModel, ipopt_solver)
      #
      #     # make_si_unit!(result["solution"])
      #     # @testset "111111" begin
      #         # for (i, pump) in result["solution"]["pump"]
      #             print("jikjhilhi;oh         ",result["solution"]["producer"]["2"]["qg"])
      #             # @test haskey(pump, "1")
      #             # @test haskey(pump, "efficiency")
      #             # @test isapprox(pump["1"]["efficiency"], 0.8545977; atol = 1e-3) # Expected result for case14
      #
      #         # end
      #     # end
      #
      #
      # end
      #

#
# @testset "test misocp ls" begin
#     @testset "case 1" begin
#         println("Test 1")
#         result = run_ls("../test/data/article.m",  MISOCPPetroleumModel, cvx_solver)
#         @test result["status"] == :LocalOptimal || result["status"] == :Optimal
#
#         for i in keys(sort((result["solution"]["junction"])))
#             push!(ii, parse(Int64, i))
#             println((result["solution"]))
#             # println(ii, " = ", make_si_unit!(result["solution"]["junction"][i]["H"]));
#             push!(H_values, ((result["solution"]["junction"][i]["H"])))
#        end
#
#
#         # for i in keys(sort((result["solution"]["junction"])))
#         #     println(JuMP.dual(UpperBoundRef(pm.var[:nw][0][:H][i])))
#         # end
#
#
#            println()
#
#        node_values   = [sort(ii) H_values]
#        writedlm("head_values_1.csv", node_values, ",")
#        println()
#
#       println()
#        deleteat!(H_values, H_values .>= 0)
#        end

# end




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
