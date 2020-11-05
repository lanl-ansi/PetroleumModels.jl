
@testset "Seaway Pipeline Test" begin
    data = parse_file("../test/data/case_seaway.m")
    result = run_opf(data, LPPetroleumModel, ipopt_solver)
    make_si_units!(result["solution"])

    @test isapprox(result["objective"],-15.429, atol=1e-2)
    @test result["termination_status"] == LOCALLY_SOLVED || result["termination_status"] == OPTIMAL
    @test isapprox(result["solution"]["pipe"]["3"]["q_pipe"],  0.3567, atol = 1e-1)
    @test isapprox(result["solution"]["pipe"]["9"]["q_pipe"],  0.9644, atol = 1e-1)
    @test isapprox(result["solution"]["pipe"]["15"]["q_pipe"], 0.1389, atol = 1e-1)
    @test isapprox(result["solution"]["pipe"]["22"]["q_pipe"], 0.7178, atol = 1e-1)
end

@testset "One Pipe Test" begin
    data = parse_file("../test/data/case_one_pipe.m")
    result = run_opf(data, LPPetroleumModel, ipopt_solver)
    make_si_units!(result["solution"])

    @test isapprox(result["objective"],-50.0, atol=1e-2)
    @test result["termination_status"] == LOCALLY_SOLVED || result["termination_status"] == OPTIMAL
    @test isapprox(result["solution"]["pipe"]["30"]["q_pipe"], 1.0, atol = 1e-1)
end

@testset "Bekker Test" begin
    data = parse_file("../test/data/case_bekker.m")
    result = run_opf(data, LPPetroleumModel, ipopt_solver)
    make_si_units!(result["solution"])

    @test isapprox(result["objective"],-136.997, atol=1e-2)
    @test result["termination_status"] == LOCALLY_SOLVED || result["termination_status"] == OPTIMAL
    @test isapprox(result["solution"]["pipe"]["4"]["q_pipe"],  1.04166666667, atol = 1e-2)
    @test isapprox(result["solution"]["pipe"]["10"]["q_pipe"], 1.04166666667, atol = 1e-2)
    @test isapprox(result["solution"]["pipe"]["12"]["q_pipe"], 1.1, atol = 1e-2)
    @test isapprox(result["solution"]["pipe"]["15"]["q_pipe"], 1.14166666667, atol = 1e-2)
end

@testset "Tank Test" begin
    data = parse_file("../test/data/case_tank.m")
    result = run_opf(data, LPPetroleumModel, ipopt_solver)
    make_si_units!(result["solution"])

    @test isapprox(result["objective"],-274.258, atol=1e-2)
    @test result["termination_status"] == LOCALLY_SOLVED || result["termination_status"] == OPTIMAL
end

@testset "5 Junction Test" begin
    data = parse_file("../test/data/case5.m")
    result = run_opf(data, LPPetroleumModel, ipopt_solver)
    make_si_units!(result["solution"])

    @test isapprox(result["objective"],-7.329, atol=1e-2)
    @test result["termination_status"] == LOCALLY_SOLVED || result["termination_status"] == OPTIMAL
    @test isapprox(result["solution"]["pipe"]["33"]["q_pipe"], 0.733, atol = 1e-1)
end
