using PetroleumModels

import InfrastructureModels
import Memento
import JuMP
import Ipopt

using Test


ipopt_solver = JuMP.optimizer_with_attributes(
    Ipopt.Optimizer,
    "print_level" => 5,
    "tol" => 1e-10,
)

cvx_solver = ipopt_solver

@testset "Petroleum" begin
    include("pf.jl")
end
