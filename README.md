# PetroleumModels.jl

<img src="https://lanl-ansi.github.io/PetroleumModels.jl/dev/assets/logo.svg" align="left" width="200" alt="PetroleumModels logo">

Release: [![](https://img.shields.io/badge/docs-stable-blue.svg)](https://lanl-ansi.github.io/PetroleumModels.jl/stable)

Dev:
[![Build Status](https://travis-ci.org/lanl-ansi/GasModels.jl.svg?branch=master)](https://travis-ci.org/lanl-ansi/GasModels.jl)
[![codecov](https://codecov.io/gh/lanl-ansi/GasModels.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/lanl-ansi/GasModels.jl)
[![](https://img.shields.io/badge/docs-latest-blue.svg)](https://lanl-ansi.github.io/GasModels.jl/latest)

PetroleumModels.jl is a Julia/JuMP package for Steady-State Petroleum (petroleum products) Network Optimization. 
It is designed to optimize the operations of existing single liquid commodity pipeline systems subject to physical flow and pump engineering constraints. The code is engineered to decouple problem specifications from the network formulations. This enables the definition of a variety of liquid network formulations and their comparison on common problem specifications.

**Core Problem Specifications**
* Petro Flow (pf)

**Core Network Formulations**


## Basic Usage


Once PetroleumModels is installed, a optimizer is installed, and a network data file has been acquired, a Petro Flow can be executed with,
```
using PetroleumModels
using <solver_package>

run_pf("foo.m", FooPetroleumModel, FooSolver())
```

Similarly, an expansion optimizer can be executed with,
```
run_ne("foo.m", FooPetroleumModel, FooSolver())
```

where FooPetroleumModel is the implementation of the mathematical program of the Petroleum equations you plan to use (i.e. ) and FooSolver is the JuMP optimizer you want to use to solve the optimization problem (i.e. IpoptSolver).


## Acknowledgments

This code has been developed as part of the Advanced Network Science Initiative at Los Alamos National Laboratory.
The primary developer is Russell Bent, with significant contributions from .

Special thanks to Miles Lubin for his assistance in integrating with Julia/JuMP.


## License

This code is provided under .

