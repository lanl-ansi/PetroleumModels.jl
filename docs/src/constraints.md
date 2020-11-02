# Constraints

```@meta
CurrentModule = PetroleumModels
```

## Constraint Templates
Constraint templates help simplify data wrangling across multiple Petro Flow formulations by providing an abstraction layer between the network data and network constraint definitions. The constraint template's job is to extract the required parameters from a given network data structure and pass the data as named arguments to the Petroleum Flow formulations.

These templates should be defined over `AbstractPetroleumModel` and should not refer to model variables. For more details, see the files: `core/constraint_template.jl` and `core/constraint.jl`.

## Junction Constraints

### Volume flow balance constraints

The primary constraints related to junctions ensure that volume flow is balanced at these nodes.

```@docs
constraint_junction_volume_flow_balance
```

## Pipe Constraints

### Bernoulli equation

The primary constraints related to pipes ensure that that head change and flow across a pipe is represented by Bernoulli equation. In this constraint head loss across a pipe is related through the Leibenzon relationship. Here, the naming convention `ne` is used to denote the form of the constraint used for expansion pipes.

```@docs
constraint_leibenzon
```

## Pump Constraints

### Operation constraints

The primary constraints related to pumps ensure that the pumps operate within the limits of their capability (head difference, volume flow, rotational speed and pump efficiency). These constraints use the `ne` naming conventions to denote constraints where the pump is an expansion option.

```@docs
constraint_pump_efficiency_and_rotation
```

## Tank Constraints

### Flow balance constraints

Tanks are used to model storage nodes in a pipeline system. The primary constraint ensures the head and flow on both sides of tanks are within the limits capability of the connected to them pipes.

```@docs
constraint_tank_volume_balance
```
