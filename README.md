# PetroleumModels.jl

<img src="https://lanl-ansi.github.io/PetroleumModels.jl/docs/src/assets/PetroleumModels.png" align="left" width="200" alt="PetroleumModels logo">

Release: [![](https://img.shields.io/badge/docs-stable-blue.svg)](https://lanl-ansi.github.io/PetroleumModels.jl/stable)

Dev:
[![Build Status](https://travis-ci.org/lanl-ansi/PetroleumModels.jl.svg?branch=master)](https://travis-ci.org/lanl-ansi/PetroleumModels.jl)
[![codecov](https://codecov.io/gh/lanl-ansi/PetroleumModels.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/lanl-ansi/PetroleumModels.jl)
[![](https://img.shields.io/badge/docs-latest-blue.svg)](https://lanl-ansi.github.io/PetroleumModels.jl/latest)

PetroleumModels.jl is a Julia/JuMP package for Steady-State Petroleum (petroleum products) Network Optimization.
It is designed to optimize the operations of existing single liquid commodity pipeline systems subject to physical flow and pump engineering constraints. The code is engineered to decouple problem specifications from the network formulations. This enables the definition of a variety of liquid network formulations and their comparison on common problem specifications.

**Core Problem Specifications**

* Optimal Petro Flow (opf)

**Core Network Formulations**

*LP

## Basic Usage


Once PetroleumModels is installed, a optimizer is installed, and a network data file has been acquired, a Petro Flow can be executed with,
```
using PetroleumModels
using <solver_package>

run_opf("foo.m", FooPetroleumModel, FooSolver())
```

Similarly, an expansion optimizer can be executed with,
```
run_ne("foo.m", FooPetroleumModel, FooSolver())
```

where FooPetroleumModel is the implementation of the mathematical program of the Petroleum equations you plan to use (i.e. ) and FooSolver is the JuMP optimizer you want to use to solve the optimization problem (i.e. IpoptSolver).


## Acknowledgments

This code has been developed as part of the Advanced Network Science Initiative at Los Alamos National Laboratory.
The primary developer is Elena Khlebnikova, with significant contributions from Kaarthik Sundar and Russell Bent.



## License

This code is provided under a BSD license as part of the Multi-Infrastructure Control and Optimization Toolkit (MICOT) project, LA-CC-13-108.
