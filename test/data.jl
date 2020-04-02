@testset "src/core/data2.jl" begin
    @testset "make_multinetwork shamir" begin
        network_data = parse_file("../test/data/pipeline_2012_seaway_m3_per_s.m")

        @test !InfrastructureModels.ismultinetwork(network_data)
        @test haskey(network_data, "time_series")
        @test isapprox(network_data["time_series"]["consumer"]["1"]["price"][1], 310, rtol=1.0e-4)

        # network_data["time_series"] = time_series_block
        ts_length = network_data["time_series"]["num_steps"]
        mn_data = InfrastructureModels.make_multinetwork(network_data, _pm_global_keys)
        mn_data
        @test InfrastructureModels.ismultinetwork(mn_data)
        @test !haskey(mn_data, "time_series")
        @test length(mn_data["nw"]) == ts_length
        # num_time_points = length(keys(pm.ref[:nw]))


        @test isapprox(mn_data["nw"]["1"]["consumer"]["1"]["price"][1], 310, rtol=1.0e-4)
    end
end
