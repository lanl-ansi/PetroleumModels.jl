# File IO

```@meta
CurrentModule = PetroleumModels
```

## General Data Formats

The json file format is a direct JSON serialization of PetroleumModels internal data model. As such, the json file format is intended to be a temporary storage format. PetroleumModels does not maintain backwards compatibility with serializations of earlier versions of the Petroleum Models internal data model.

```@docs
parse_file
parse_json
```

## Matpetro Data Files

The following method is the main methods for parsing Matpetro data files:

```@docs
parse_matpetro
```

We also provide the following (internal) helper methods:

```@autodocs
Modules = [PetroleumModels]
Pages   = ["io/matpetro.jl"]
Order   = [:function]
Private  = true
```

This format was designed to have a similar look a feel to the Matlab MatPower format (in the case of PetroleumModels, we refer to it as the MatPetro format), however, it standardizes around data requirements developed by the PetroleumModels development team. It is largely stable. Additional fields for each component in the MatPetro format can be incorporated using the Matlab extensions developed in InfrastructureModels.jl.

The top of the file contains global information about the network like its name, liquid density, etc.

```
function mpc = case5

mpc.density                    = 827;     % petroleum density, kg per cubic m
mpc.viscosity                  = 4.9e-6;  % petroleum viscosity, squared m per second
mpc.gravitational_acceleration = 9.8;
mpc.base_head                  = 100;     % base head, m
mpc.base_length                = 542;     % m
mpc.base_flow                  = 0.5;     % petroleum volume flow rate, m3 per hour
mpc.units                      = 'si';
mpc.is_per_unit                = 0;
mpc.time_step                  = 0;
```

Junction data is defined with the following tabular format

```
%% junction data
%  junction_i type head_min head_max elevation status
mpc.junction = [
...
]
```

The reader is referred to [Matpetro Format (.m)](@ref) for a detailed description of each column in the above table.

Pipeline data is defined with the following tabular format

```
%% pipe data
% pipeline_i fr_junction to_junction diameter length flow_min flow_max friction_factor status
mpc.pipe = [
...
]
```

The reader is referred to [Matpetro Format (.m)](@ref) for a detailed description of each column in the above table.

Pump data is defined with the following tabular format

```
%% pump data
% pump_i fr_junction to_junction station_i rotation_coefficient flow_coefficient flow_nom flow_max delta_head_min delta_head_max pump_efficiency_min pump_efficiency_max rotation_nom rotation_min rotation_max electricity_price status electric_motor_efficiency mechanical_transmission_efficiency
mpc.pump = [
...
```

The reader is referred to [Matpetro Format (.m)](@ref) for a detailed description of each column in the above table.

Producer data is defined with the following tabular format

```
%% producer data
% producer_i junction injection_min injection_max injection_nominal status dispatchable offer_price
mpc.producer = [
...
```

The reader is referred to [Matpetro Format (.m)](@ref) for a detailed description of each column in the above table.

Consumer data is defined with the following tabular format

```
%% consumer data
% consumer_i junction withdrawal_min withdrawal_max withdrawal_nominal status dispatchable bid_price
mpc.consumer = [
...
```

The reader is referred to [Matpetro Format (.m)](@ref) for a detailed description of each column in the above table.

Tank data is defined with the following tabular format

```
%% tank data
% tank_i fr_junction to_junction vessel_pressure_head radius capacity_min capacity_max initial_volume intake_min intake_max offtake_min offtake_max Cd status price p_price
mgc.tank = [
...
```

The reader is referred to [Matpetro Format (.m)](@ref) for a detailed description of each column in the above table.
