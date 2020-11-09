# Quick Start Guide

Once Petroleum Models is installed, Ipopt is installed, and a network data file (e.g. `"test/data/case5.m"`) has been acquired, a Petroleum Flow can be executed with,

```julia
using PetroleumModels
using Ipopt
using JuMP

ipopt_solver = JuMP.optimizer_with_attributes(
    Ipopt.Optimizer,
    "print_level" => 5,
    "tol" => 1e-10,
)

PetroleumModels.run_opf("test/data/case5.m", LPPetroleumModel, ipopt_solver)
```

## Getting Results

The run commands in PetroleumModels return detailed results data in the form of a dictionary.
This dictionary can be saved for further processing as follows,

```julia
result = GasModels.run_opf("test/data/case5.m", LPPetroleumModel, ipopt_solver)
```

For example, the algorithm's runtime, final objective value, and status can be accessed with,

```
result["solve_time"]
result["objective"]
result["termination_status"]
```

The `"solution"` field contains detailed information about the solution produced by the run method.
For example, the following dictionary comprehension can be used to inspect the junction pressures in the solution,

```
Dict(name => data["h"] for (name, data) in result["solution"]["junction"])
```

For more information about PetroleumModels result data see the [PetroleumModels Result Data Format](@ref) section.


## Accessing Different Formulations

The generic `run_opf()` allows one to solve a petroleum optimal flow problem with any petroleum network formulation implemented in PetroleumModels.  For example, the full non convex Petroleum Flow can be run with,

```julia
run_opf("test/data/case5.m", LPPetroleumModel, ipopt_solver)
```

## Modifying Network Data
The following example demonstrates one way to perform multiple PetroleumModels solves while modify the network data in Julia,

```julia
network_data = PetroleumModels.parse_file("test/data/case5.m")

run_opf(network_data, LPPetroleumModel, ipopt_solver)

network_data["junction"]["24"]["head_min"] = 0.0

run_opf(network_data, LPPetroleumModel, ipopt_solver)
```

For additional details about the network data, see the [PetroleumModels Network Data Format](@ref) section.

## Inspecting the Formulation
The following example demonstrates how to break a `run_opf` call into separate model building and solving steps.  This allows inspection of the JuMP model created by PetroleumModels for the petroleum flow problem,

```julia
pm = instantiate_model("test/data/case5.m", LPPetroleumModel, PetroleumModels.build_opf)
print(pm.model)
JuMP.set_optimizer(pm.model, ipopt_solver)
JuMP.optimize!(pm.model, ipopt_solver)
```

## Solution conversion

The default behavior of PetroleumModels produces solution results in non-dimensionalized units. To recover solutions in SI units, the following function can be used

```julia
PetroleumModels.make_si_units!(result["solution"])
```
