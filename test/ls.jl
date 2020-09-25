

@testset "test ls" begin
  #Check the second order cone model on load shedding
  @testset "test MISOCPPetroleumModel" begin
      @info "Testing petrolib ls"
      result = run_ls("../test/data/pipeline_2012_seaway_m3_per_h.m", MISOCPPetroleumModel, ipopt_solver)
       # @test result["status"] == :LocalOptimal || result["status"] == :Optimal
        @test isapprox(result["objective"], -5.3955e4, atol=1e-1)

    end
end
