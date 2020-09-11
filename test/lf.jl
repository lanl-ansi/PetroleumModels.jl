@testset "test lf" begin
    @testset "test crdwp lf" begin
        @info "Testing crdwp lf"
        result = run_lf("../test/data/pipeline_2012_seaway_m3_per_s.m", CRDWPGasModel, misocp_solver)
        @test result["termination_status"] == LOCALLY_SOLVED || result["termination_status"] == OPTIMAL
        @test isapprox(result["objective"], 0; atol = 1e-6)
        data = GasModels.parse_file("../test/data/pipeline_2012_seaway_m3_per_s.m")
        pm = GasModels.instantiate_model(data, CRDWPGasModel, GasModels.build_lf)
        check_pressure_status(result["solution"], pm)
        check_compressor_ratio(result["solution"], pm)

        result = run_lf("../test/data/gaslib/GasLib-Integration.zip", CRDWPGasModel, misocp_solver)
        @test result["termination_status"] == LOCALLY_SOLVED || result["termination_status"] == OPTIMAL
    end

    @testset "test lrdwp lf" begin
        @info "Testing lrdwp lf"
        result = run_lf("../test/data/matgas/case-6-lf.m", LRDWPGasModel, mip_solver)
        @test result["termination_status"] == LOCALLY_SOLVED || result["termination_status"] == OPTIMAL
        @test isapprox(result["objective"], 0; atol = 1e-6)
    end

    @testset "test lrwp lf" begin
        @info "Testing lrwp lf"
        result = run_lf("../test/data/pipeline_2012_seaway_m3_per_s.m", LRWPGasModel, lp_solver)
        @test result["termination_status"] == LOCALLY_SOLVED || result["termination_status"] == OPTIMAL || result["termination_status"] == ALMOST_LOCALLY_SOLVED
        @test isapprox(result["objective"], 0; atol = 1e-6)
    end

    @testset "test wp lf" begin
        @info "Testing wp lf"
        result = run_lf("../test/data/pipeline_2012_seaway_m3_per_s.m", WPGasModel, nlp_solver)
        @test result["termination_status"] == LOCALLY_SOLVED || result["termination_status"] == OPTIMAL
        @test isapprox(result["objective"], 0; atol = 1e-6)

        result = run_lf("../test/data/gaslib/GasLib-Integration.zip", WPGasModel, minlp_solver)
        @test result["termination_status"] == LOCALLY_SOLVED || result["termination_status"] == OPTIMAL
    end

    @testset "test dwp lf" begin
        @info "Testing dwp lf"
        result = run_lf("../test/data/pipeline_2012_seaway_m3_per_s.m", DWPGasModel, minlp_solver)
        @test result["termination_status"] == LOCALLY_SOLVED || result["termination_status"] == OPTIMAL
        @test isapprox(result["objective"], 0; atol = 1e-6)

        result = run_lf("../test/data/gaslib/GasLib-Integration.zip", DWPGasModel, minlp_solver)
        @test result["termination_status"] == LOCALLY_SOLVED || result["termination_status"] == OPTIMAL
    end
end
