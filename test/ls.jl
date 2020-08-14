

@testset "test ls" begin
  #Check the second order cone model on load shedding
  @testset "test MISOCPPetroleumModel" begin
      @info "Testing petrolib ls"
      result = run_ls("../test/data/case.m", MISOCPPetroleumModel, ipopt_solver)
       # @test result["status"] == :LocalOptimal || result["status"] == :Optimal
        @test isapprox(result["objective"], 902554.33, atol=1e-1)

    end
end
