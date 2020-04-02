using JuMP 
using Ipopt
using Juniper

include("../src/PetroleumModels.jl")

data = parse_file("../test/input/pipeline_2012_test_1.m")

optimizer = Juniper.Optimizer
params = Dict{Symbol,Any}()
params[:nl_solver] = with_optimizer(Ipopt.Optimizer, print_level=0, sb="yes")

minlp_solver = with_optimizer(optimizer, params)
nlp_solver = with_optimizer(Ipopt.Optimizer, print_level=5, sb="yes")

result = run_pf(data, MISOCPPetroleumModel, nlp_solver)
