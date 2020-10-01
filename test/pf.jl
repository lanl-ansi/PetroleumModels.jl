
  @testset "test SeawayPipeline System" begin
      data = parse_file("../test/data/pipeline_2012_seaway_m3_per_h.m")
      result = run_pf(data, MISOCPPetroleumModel, ipopt_solver)
       # @test result["status"] == :LocalOptimal || result["status"] == :Optimal
        # @test isapprox(result["objective"], -1.54334e1, atol=1e-1)
        # @show (result["solution"]["consumer"])
        # @show (data["is_per_unit"])
        if (data["is_si_units"]) == false
            # @show keys(result["solution"]["pipe"])
            @test isapprox(result["solution"]["pipe"]["3"]["q_pipe"]*data["baseQ"],  1284.22, atol = 1e-1)
            @test isapprox(result["solution"]["pipe"]["9"]["q_pipe"]*data["baseQ"],  3472.03, atol = 1e-1)
            @test isapprox(result["solution"]["pipe"]["15"]["q_pipe"]*data["baseQ"], 500.0, atol = 1e-1)
            @test isapprox(result["solution"]["pipe"]["22"]["q_pipe"]*data["baseQ"], 2584.12, atol = 1e-1)
        else
            @test isapprox(result["solution"]["pipe"]["3"]["q_pipe"],  1284.22, atol = 1e-1)
            @test isapprox(result["solution"]["pipe"]["9"]["q_pipe"],  3472.03, atol = 1e-1)
            @test isapprox(result["solution"]["pipe"]["15"]["q_pipe"], 500.0, atol = 1e-1)
            @test isapprox(result["solution"]["pipe"]["22"]["q_pipe"], 2584.12, atol = 1e-1)
        end
        # @show(keys(result["solution"]["pipe"]))
        # make_si_units!(result["solution"])
        # @show make_si_units!(result["solution"])
        # @show (data["is_si_units"])
        # @show (result["solution"]["pipe"])
    end

        @testset "test one pipe" begin
          data = parse_file("../test/data/one_pipe.m")
          result = run_pf(data, MISOCPPetroleumModel, ipopt_solver)

            if (data["is_si_units"]) == false
                @test isapprox(result["solution"]["pipe"]["30"]["q_pipe"]*data["baseQ"],  3600, atol = 1e-1)
            else
                @test isapprox(result["solution"]["pipe"]["30"]["q_pipe"],  3600, atol = 1e-1)
            end

        end

        @testset "test example from article" begin
              data = parse_file("../test/data/example_from_article.m")
              result = run_pf(data, MISOCPPetroleumModel, ipopt_solver)
                if (data["is_si_units"]) == false
                    # @show keys(result["solution"]["pipe"])
                    @test isapprox(result["solution"]["pipe"]["4"]["q_pipe"]*data["baseQ"],  3750., atol = 1e-1)
                    @test isapprox(result["solution"]["pipe"]["10"]["q_pipe"]*data["baseQ"], 3750., atol = 1e-1)
                    @test isapprox(result["solution"]["pipe"]["12"]["q_pipe"]*data["baseQ"], 3960, atol = 1e-1)
                    @test isapprox(result["solution"]["pipe"]["15"]["q_pipe"]*data["baseQ"], 4110, atol = 1e-1)
                else
                    @test isapprox(result["solution"]["pipe"]["4"]["q_pipe"],  3750., atol = 1e-1)
                    @test isapprox(result["solution"]["pipe"]["10"]["q_pipe"], 3750., atol = 1e-1)
                    @test isapprox(result["solution"]["pipe"]["12"]["q_pipe"], 3960, atol = 1e-1)
                    @test isapprox(result["solution"]["pipe"]["15"]["q_pipe"], 4110, atol = 1e-1)
                end

        end
        @testset "test case" begin
              data = parse_file("../test/data/case.m")
              result = run_pf(data, MISOCPPetroleumModel, ipopt_solver)
                if (data["is_si_units"]) == false
                    # @show keys(result["solution"]["pipe"])
                    @test isapprox(result["solution"]["pipe"]["33"]["q_pipe"]*data["baseQ"],  1275.59, atol = 1e-1)
                else
                    @test isapprox(result["solution"]["pipe"]["33"]["q_pipe"],  1275.59, atol = 1e-1)
                end

        end
        @testset "test small case" begin
              data = parse_file("../test/data/small_case.m")
              result = run_pf(data, MISOCPPetroleumModel, ipopt_solver)
                if (data["is_si_units"]) == false
                    # @show keys(result["solution"]["pipe"])
                    @test isapprox(result["solution"]["pipe"]["33"]["q_pipe"]*data["baseQ"],  2638.84, atol = 1e-1)
                else
                    @test isapprox(result["solution"]["pipe"]["33"]["q_pipe"], 2638.84, atol = 1e-1)
                end

        end
