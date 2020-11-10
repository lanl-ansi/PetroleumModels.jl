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
"consumer":{
    "1":{
      "junction_id": <float>,  # junction id
      "withdrawal_max": <float>,  # the maximum mass flow demand. SI units are m^3/s.
      "withdrawal_min": <float>,  # the minimum mass flow demand. SI units are m^3/s.
      "withdrawal_nominal": <float>, # nominal mass flow demand. SI units are m^3/s.
      "bid_price": <float>, # price for buying gas at the delivery. SI units are $/m^3
      "is_dispatchable": <int>,  # whether or not the unit is dispatchable (0 = consumer should consume withdrawl_nominal, 1 = consumer can consume between withdrawal_min and withdrawal_max).
      "status": <int>,   # status of the component (0 = off, 1 = on). Default is 1.
       ...
    },
    "2":{...},
    ...
},
"producer":{
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
"pipe":{
    "1":{
      "length": <float>,            # the length of the connection. SI units are m.
      "fr_junction": <int>,         # the "from" side junction id
      "to_junction": <int>,         # the "to" side junction id
      "friction_factor": <float>,   # the friction component of the resistance term of the pipe. SI units are s^2/ft.
      "diameter": <float>,          # the diameter of the connection. SI units are m.
      "status": <int>,              # status of the component (0 = off, 1 = on). Default is 1.
      "flow_max": <float>,          # maximum volumetric flow. SI units are m^3/s
      "flow_min": <float>,          # minimum volumetric flow. SI units are m^3/s
        ...
    },
    "2":{...},
    ...
},
"pump":{
    "1":{
      "fr_junction": <int>,                           # the "from" side junction id
      "to_junction": <int>,                           # the "to" side junction id
      "status": <int>,                                # status of the component (0 = off, 1 = on). Default is 1.
      "electricity_price": <float>,                   # the cost per kW of running the compressor
      "station_i": <int>,                             # the pump station id for this pumps
      "rotation_coefficient": <float>,                # pump rotation coefficient, SI units are m
      "flow_coefficient": <float>,                    # pump flow coefficient, SI units are s^2/m^5
      "flow_nom": <float>,                            # normal flow through the pump. SI units are m^3/s
      "flow_max": <float>,                            # maximum flow through the pump. SI units are m^3/s
      "delta_head_min": <float>,                      # minimum pressure difference through the pump. SI units are m.
      "delta_head_max": <float>,                      # maximum pressure difference through the pump. SI units are m.
      "pump_efficiency_min": <float>,                 # minimum pump efficiency. Non dimensional
      "pump_efficiency_max": <float>,                 # maximum pump efficiency. Non dimensional
      "rotation_nom": <float>,                        # normal rotation speed. SI units are rotations per second
      "rotation_min": <float>,                        # minimum rotation speed. SI units are rotations per second
      "rotation_max": <float>,                        # maximum rotation speed. SI units are rotations per second
      "electric_motor_efficiency": <float>,           # efficiency of the pump's motor. Non dimensional.
      "mechanical_transmission_efficiency": <float>,  # efficiency of the pump's transmission. Non dimensional.
        ...
    },
    "2":{...},
    ...
},
"tank":{
    "1":{
      "fr_junction": <int>,              # the "from" side junction id
      "to_junction": <int>,              # the "to" side junction id
      "status": <int>,                   # status of the component (0 = off, 1 = on). Default is 1.
      "vessel_pressure_head": <float>,   # TODO
      "radius": <float>,                 # radius of the tank. SI units are m.
      "capacity_min": <float>,           # minimum capcity of the tank. SI units are m^3.
      "capacity_max": <float>,           # maximum capcity of the tank. SI units are m^3.
      "initial_volume": <float>,         # initial volume of the tank. SI units are m^3.
      "intake_min": <float>,             # minimum flow into the tank. SI units are m^3/s.
      "intake_max": <float>,             # maximum flow into the tank. SI units are m^3/s.
      "offtake_min": <float>,            # minimum flow out of the tank. SI units are m^3/s.
      "offtake_max": <float>,            # maximum flow out of the tank. SI units are m^3/s.
      "Cd": <float>,                     # Todo
      "price": <float>,                  # Todo
      "p_price": <float>,                # Todo
        ...
    },
    "2":{...},
    ...
  },
}
```

All data is assumed to have consistent units (i.e. SI units or non-dimensionalized units)

The following commands can be used to explore the network data dictionary,

```julia
network_data = PetroleumModels.parse_file("case5.m")
display(network_data)
```
