# PetroleumModels Result Data Format

## The Result Data Dictionary

PetroleumModels utilizes a dictionary to organize the results of a run command. The dictionary uses strings as key values so it can be serialized to JSON for algorithmic data exchange.
The data dictionary organization is designed to be consistent with the PetroleumModels [The Network Data Dictionary](@ref).

At the top level the results data dictionary is structured as follows:

```json
{
"optimizer":<string>,        # name of the Julia class used to solve the model
"termination_status":<type>, # optimizer status at termination
"dual_status":<type>,        # optimizer dual status at termination
"primal_status":<type>,      # optimizer primal status at termination
"solve_time":<float>,        # reported solve time (seconds)
"objective":<float>,         # the final evaluation of the objective function
"objective_lb":<float>,      # the final lower bound of the objective function (if available)
"objective_gap":<float>,     # the final gap between the lower bound and upper bound of the objective function (if available)
"machine":{...},             # computer hardware information (details below)
"data":{...},                # test case information (details below)
"solution":{...}            # complete solution information (details below)
}
```

### Machine Data

This object provides basic information about the hardware that was
used when the run command was called.

```json
{
"cpu":<string>,    # CPU product name
"memory":<string>  # the amount of system memory (units given)
}
```

### Case Data

This object provides basic information about the network cases that was
used when the run command was called.

```json
{
"name":<string>,                # the name from the network data structure
}
```

### Solution Data

The solution object provides detailed information about the solution
produced by the run command.  The solution is organized similarly to
[The Network Data Dictionary](@ref) with the same nested structure and
parameter names, when available.  A network solution most often only includes
a small subset of the data included in the network data.

For example the data for a junction, `data["junction"]["1"]` is structured as follows,

```
{
"head_min": 25.0,
"head_max": 50.0,
"elevation": 20.0,
...
}
```

A solution specifying a pressure for the same case, i.e. `result["solution"]["junction"]["1"]`, would result in,

```
{
"h": 21.0,
}
```

Because the data dictionary and the solution dictionary have the same structure
InfrastructureModels `update_data!` helper function can be used to
update a data dictionary with the values from a solution as follows,

```
InfrastructureModels.update_data!(data, result["solution"])
```

By default, all results are reported in per-unit (non-dimenionalized). Below are common outputs of implemented optimization models

```json
{
"junction":{
    "1":{
      "h": <float>,      # head. Non-dimensional quantity. Multiply by base_head to get meters
       ...
    },
    "2":{...},
    ...
},
"consumer":{
    "1":{
      "ql": <float>,  # variable volumetric flow consumed. Non-dimensional quantity. Multiply by base_flow to get m^3/s.
       ...
    },
    "2":{...},
    ...
},
"receipt":{
    "1":{
      "qg": <float>,  # variable volumetric flow produced. Non-dimensional quantity. Multiply by base_flow to get m^3/s.
    },
    "2":{...},
    ...
},
"pipe":{
    "1":{
      "q": <float>,                 # volumetric flow through the pipe.  Non-dimensional quantity. Multiply by base_flow to get m^3/s.
        ...
    },
    "2":{...},
    ...
},
"tank":{
    "1":{
      "qin": <float>,                 # volumetric flow into the tank.  Non-dimensional quantity. Multiply by base_flow to get m^3/s.
      "qout": <float>,                # volumetric flow out of the tank.  Non-dimensional quantity. Multiply by base_flow to get m^3/s.
        ...
    },
    "2":{...},
    ...
},
"pump":{
    "1":{
      "q": <float>,                 # volumetric flow through the pump.  Non-dimensional quantity. Multiply by base_flow to get m^3/s.
      "eta": <float>,               # pump efficiency. Non-dimensional quantiy.
      "w": <float>,                 # pump rotation speed in rotations per second.
        ...
    },
    "2":{...},
    ...
},
}
```
