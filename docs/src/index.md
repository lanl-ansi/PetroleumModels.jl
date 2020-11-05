# PetroleumModels.jl Documentation

```@meta
CurrentModule = PetroleumModels
```

## Overview

PetroleumModels.jl is a Julia/JuMP package for Petroleum Network Optimization. It provides utilities for parsing and modifying network data (see [PetroleumModels Network Data Format](@ref) for details), and is designed to enable computational evaluation of emerging petroleum network formulations and algorithms in a common platform. It includes support for steady-state formulations.

The code is engineered to decouple [Steady State Problem Specifications](@ref) (e.g. Optimal Petroleum Flow, ...) from [Network Formulations](@ref) (e.g. LP, ...). This enables the definition of a wide variety of petroleum network formulations and their comparison on common problem specifications.

## Installation

The latest stable release of PetroleumModels is installed using the Julia package manager with

```julia
add PetroleumModels
```

For the current development version, "checkout" this package with

```julia
checkout PetroleumModels
```

At least one optimizer is required for running PetroleumModels.  The open-source optimizer Ipopt is recommended and can be used to solve a wide variety of the problems and network formulations provided in PetroleumModels.  The Ipopt optimizer can be installed via the package manager with

```julia
add Ipopt
```

Test that the package works by running

```julia
test PetroleumModels
```
