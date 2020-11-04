# Petroleum Model

```@meta
CurrentModule = PetroleumModels
```

All methods for constructing petroleummodels should be defined on the following type:

```@docs
AbstractPetroleumModel
```

which utilizes the following (internal) functions:

```@docs
build_ref
```

# Network Formulations

## Type Hierarchy
We begin with the top of the hierarchy, where we can distinguish between the physics of petroleum flow models. There is currently one formulation supported in PetroluemModels, a full non convex formulation.

```julia
AbstractLPModel <: AbstractGasModel
```

## Petroleum Models
Each of these forms can be used as the type parameter for a PetroleumModel, i.e.:

```julia
LPPetroleumModel <: AbstractLPForm
```

For details on `AbstractPetroleumModel`, see the section on [Petroleum Model](@ref).

## User-Defined Abstractions

The user-defined abstractions begin from a root abstract like the `AbstractPetroleumModel` abstract type, i.e.

```julia
AbstractMyFooModel <: AbstractPetroleumModel

StandardMyFooForm <: AbstractFooModel
FooPetroleumModel = AbstractPetroleumModel{StandardFooForm}
```

## Supported Formulations

All formulation names refer to how underlying physics of a gas network is modeled. For example, the `LP` model uses a non convex form of the Bernoulli equations using the Leibenzon relationship.

| Formulation      | Steady-State         | Transient             | Description           |
| ---------------- | -------------------- | --------------------- | --------------------- |
| WP               |       Y              |          Y            | Physics is modeled using nonlinear equations. |
| DWP              |       Y              |          N            | Physics is modeled using nonlinear equations. Directionality of flow is modeled using discrete variables |
| CRDWP            |       Y              |          N            | Physics is modeled using convex equations. Directionality of flow is modeled using discrete variables |
| LRDWP            |       Y              |          N            | Physics is modeled using linear equations. Directionality of flow is modeled using discrete variables |
| LRWP             |       Y              |          N            | Physics is modeled using linear equations. |
