# PetroleumModels Network Data Format

## The Network Data Dictionary

Internally PetroleumModels utilizes a dictionary to store network data. The dictionary uses strings as key values so it can be serialized to JSON for algorithmic data exchange. PetroleumModels can utilize this serialization as a text file, however PetroleumModels does not support backwards compatibility for such serializations. When used as serialization, the data is assumed to be in per_unit (non dimenisionalized) or SI units.

The network data dictionary structure is roughly as follows:

```json
{
"name":<string>,                         # a name for the model
"density":<float>,                       # petroleum density, kg per cubic m
"viscosity":<float>,                     # petroleum viscosity, squared m per second
"gravitational_acceleration":<float>,    # accerlation due to gravity, squared m per second
"base_head":<float>,                     # Base for non-dimensionalizing head. SI units are m
"base_length":<float>,                   # Base for non-dimensionalizing length. SI units are m
"base_flow":<float>,                     # Base for non-dimensionalizing flow. SI units are m^3/s
"units":<string>,                        # Non-dimensonilized units. Options are "si" and "asu"
"is_per_unit":<string>,                  # Whether or not the file is in per unit (non dimensional units) or SI units.
"time_step":<int>,                        # size of the time step.
"junction":{
    "1":{
      "type": <int> ,         # the type of the junction
      "head_min": <float>,    # minimum head. SI units are meters
      "head_max": <float>,    # maximum head. SI units are meters
      "elevation":<float>,    # elevation of the junction. SI units are meters
      "status": <int>,        # status of the component (0 = off, 1 = on). Default is 1.
       ...
    },
    "2":{...},
    ...
},
"delivery":{
    "1":{
      "junction_id": <float>,  # junction id
      "withdrawal_max": <float>,  # the maximum mass flow demand. SI units are kg/s.
      "withdrawal_min": <float>,  # the minimum mass flow demand. SI units are kg/s.
      "withdrawal_nominal": <float>, # nominal mass flow demand. SI units are kg/s.
      "priority": <float>, # priority for serving the variable load. High numbers reflect a higher desired to serve this load.
      "bid_price": <float>, # price for buying gas at the delivery.
      "is_dispatchable": <int>,  # whether or not the unit is dispatchable (0 = delivery should consume withdrawl_nominal, 1 = delivery can consume between withdrawal_min and withdrawal_max).
      "status": <int>,   # status of the component (0 = off, 1 = on). Default is 1.
       ...
    },
    "2":{...},
    ...
},
"receipt":{
    "1":{
      "junction_id": <float>,         # junction id
      "injection_min": <float>,       # the minimum mass flow gas production. SI units are kg/s.
      "injection_max": <float>,       # the maximum mass flow gas production. SI units are kg/s.
      "injection_nominal": <float>,   # nominal mass flow production at standard density. SI units are kg/s.
      "dispatchable": <int>,          # whether or not the unit is dispatchable (0 = receipt should produce injection_nominal, 1 = receipt can produce between injection_min and injection_max).
      "offer_price": <float>,         # price for selling gas at the receipt.
      "status": <int>,                # status of the component (0 = off, 1 = on). Default is 1.
       ...
    },
    "2":{...},
    ...
},
"transfer":{
    "1":{
        "junction_id": <float>,         # junction id
        "withdrawal_max": <float>,      # the maximum mass flow demand. SI units are kg/s.
        "withdrawal_min": <float>,      # the minimum mass flow demand. SI units are kg/s. (can be negative, in which case it is gas injection)
        "withdrawal_nominal": <float>,  # nominal mass flow demand. SI units are kg/s.
        "offer_price": <float>,         # price for selling gas at the receipt.
        "bid_price": <float>,           # price for buying gas at the delivery.
        "is_dispatchable": <int>,       # whether or not the unit is dispatchable (0 = transfer should consume withdrawl_nominal, 1 = transfer can consume between withdrawal_min and withdrawal_max).
        "status": <int>,                # status of the component (0 = off, 1 = on). Default is 1.
        ...
    },
    "2":{...},
    ...
},
"pipe":{
    "1":{
      "length": <float>,            # the length of the connection. SI units are m.
      "fr_junction": <int>,         # the "from" side junction id
      "to_junction": <int>,         # the "to" side junction id
      "friction_factor": <float>,   # the friction component of the resistance term of the pipe. Non dimensional.
      "diameter": <float>,          # the diameter of the connection. SI units are m.
      "status": <int>,              # status of the component (0 = off, 1 = on). Default is 1.
      "p_max": <float>,             # maximum pressure. SI units are pascals
      "p_min": <float>,             # minimum pressure. SI units are pascals
      "is_bidirectional": <int>,    # flag for whether or not flow can go in both directions
        ...
    },
    "2":{...},
    ...
},
"compressor":{
    "1":{
      "fr_junction": <int>,         # the "from" side junction id
      "to_junction": <int>,         # the "to" side junction id
      "c_ratio_min": <float>,       # minimum multiplicative pressure change (compression or decompressions). Compression only goes from f_junction to t_junction (1 if flow reverses).
      "c_ratio_max": <float>,       # maximum multiplicative pressure change (compression or decompressions). Compression only goes from f_junction to t_junction (1 if flow reverses).
      "status": <int>,              # status of the component (0 = off, 1 = on). Default is 1.
      "operating_cost": <float>,    # The cost per W of running the compressor
      "power_max": <float>,         # Maximum power consumed by the compressor. SI units is W
      "type": <int>,                # type of the compressor (two way compression or not, one way flow or not, etc.)
        ...
    },
    "2":{...},
    ...
}
"short_pipe":{
    "1":{
      "fr_junction": <int>,         # the "from" side junction id
      "to_junction": <int>,         # the "to" side junction id
      "status": <int>,              # status of the component (0 = off, 1 = on). Default is 1.
      "is_bidirectional": <int>,    # flag for whether or not flow can go in both directions
        ...
    },
    "2":{...},
    ...
}
"valve":{
    "1":{
      "fr_junction": <int>,             # the "from" side junction id
      "to_junction": <int>,             # the "to" side junction id
      "status": <int>,                  # status of the component (0 = off, 1 = on). Default is 1.
      "is_bidirectional": <int>,        # flag for whether or not flow can go in both directions
        ...
    },
    "2":{...},
    ...
}
"regulator":{
    "1":{
      "fr_junction": <int>,             # the "from" side junction id
      "to_junction": <int>,             # the "to" side junction id
      "reduction_factor_min": <float>,  # minimum multiplicative pressure change (compression or decompressions). Compression only goes from f_junction to t_junction (1 if flow reverses).
      "reduction_factor_max": <float>,  # maximum multiplicative pressure change (compression or decompressions). Compression only goes from f_junction to t_junction (1 if flow reverses).
      "status": <int>,                  # status of the component (0 = off, 1 = on). Default is 1.
      "is_bidirectional": <int>,        # flag for whether or not flow can go in both directions
        ...
    },
    "2":{...},
    ...
}
"resistor":{
    "1":{
      "fr_junction": <int>,          # the "from" side junction id
      "to_junction": <int>,          # the "to" side junction id
      "drag": <float>,              # the drag factor of resistors. Non dimensional.
      "status": <int>,              # status of the component (0 = off, 1 = on). Default is 1.
      "is_bidirectional": <int>,    # flag for whether or not flow can go in both directions
        ...
    },
    "2":{...},
    ...
}
"loss_resistor":{
    "1":{
      "fr_junction": <int>,         # the "from" side junction id
      "to_junction": <int>,         # the "to" side junction id
      "p_loss": <float>,            # constant pressure loss along the edge
      "status": <int>,              # status of the component (0 = off, 1 = on). Default is 1.
      "is_bidirectional": <int>,    # flag for whether or not flow can go in both directions
        ...
    },
    "2":{...},
    ...
}
"storage":{
    "1":{
        "id": <int>,                                # id of the junction in which storage is located
        "well_diameter": <float>,                   # diameter of the wells
        "well_depth": <float>,                      # depth of the wells
        "well_friction_factor": <float>,            # friction factor of the wells
        "reservoir_p_max": <float>,                 # maximum pressure of the reservoir
        "base_gas_capacity": <float>,               # base gas capacity in reservoir (SI units: kg)
        "total_field_capacity": <float>,            # total gas capacity in reservoir (SI units: kg)
        "initial_field_capacity_percent": <float>,  # initial gas in reservoir as a percentage of total capacity
        "reduction_factor_max": <float>             # maximum reduction factor of the regulator
        "c_ratio_max": <float>,                     # maximum compression ratio of the compressor
        "status": <int>,                            # status of the component (0=off, 1=on). Default is 1.
        "flow_injection_rate_min": <float>,         # minimum flow rate at which gas can be injected into storage. SI units is kg/s
        "flow_injection_rate_max": <float>,         # maximum flow rate at which gas can be injected into storage. SI units is kg/s
        "flow_withdrawal_rate_min": <float>,        # minimum flow rate at which gas can be withdrawn from storage. SI units is kg/s
        "flow_withdrawal_rate_max": <float>,        # maxium flow rate at which gas can be withdrawn storage. SI units is kg/s  
        ...
    },
    "2":{...},
    ...
}
}
```

All data is assumed to have consistent units (i.e. SI units or non-dimensionalized units)

The following commands can be used to explore the network data dictionary,

```julia
network_data = GasModels.parse_file("gaslib-40.m")
display(network_data)
```
