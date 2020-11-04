# MatlabPetroleum Format (.m)

Here we detail the parameters that can be inputted using the matpetroleum format. They can be inputted in the order they appear here, or selectively, in the case where some data is not required, by using the following (example) header format.

```matlab
%% junction data
% junction_i type head_min head_max elevation status
```

See case files in `test/data/` for examples of file syntax.

## Junctions (mpc.junction)

These components model “point” locations in the system, i.e. locations of withdrawal or injection, or simply connection points between pipes. Each junction may have multiple pipes attached.

| Parameter     | Type    | Name             | Standard Units (SI) | United States Customary Units | Required           | Description                                                           |
| ------------- | ------- | ---------------- | ------------------- | ----------------------------- | ------------------ | --------------------------------------------------------------------- |
| junction_i    | Int     | Junction id      |                     |                               | Y                  | Unique id for junctions                                               |
| type          | Int     | Junction Type    |                     |                               | Y                  | Classification of the junction: 0 = standard node, 1 = slack node     |
| head_min      | Float64 | Head Minimum     | m                   | ft                            | Y                  |  Minimum operating head used in line pack calculations, which is higher than the minimum allowable |
| head_max      | Float64 | Head Maximum     | m                   | ft                            | Y                  | Maximum operating head used in line pack calculations, which is lower than the maximum allowable |                                                                          
| elevation     | Float64 | Elevation        | m                   | ft                            |                    | Elevation of the junction                                             |
| status        | Int     | Junction Status  |                     |                               | Y                  | Determines if the component is active in the model                    |

## Pipes (mpc.pipe)

These components model pipelines which connect two junctions.

| Parameter                         | Type    | Name                 | Standard Units (SI) | United States Customary Units | Required | Description                                                 |
| --------------------------------- | ------- | -------------------  | ------------------- | ----------------------------- | -------- | ----------------------------------------------------------- |
| pipeline_i                        | Int     | Pipe id              |                     |                               | Y        | Unique id for pipes                                         |
| fr_junction                       | Int     | From Junction id     |                     |                               | Y        | Unique id of the junction on the from side                  |
| to_junction                       | Int     | To Junction id       |                     |                               | Y        | Unique id of the junction on the to side                    |
| diameter                          | Float64 | Diameter             | m                   | ft                            | Y        | Pipe diameter                                               |
| length                            | Float64 | Length               | m                   | ft                            | Y        | Pipe Length                                                 |
| fiction_factor                    | Float64 | Friction coefficient | s^2/m               | s^2/ft                        |          | Coefficient in the Leibenzon equation for turbulent flow    |
| flow_min                          | Float64 | Flow Rate Minimum    | m^3/s               | ft3/h                         | Y        | Minimum allowable operating flow rate, usually depends on pipe diameter |
| flow_max                          | Float64 | Flow Rate Maximum    | m^3/s               | ft3/h                         | Y        | Maximum allowable operating flow rate, usually depends on pipe diameter |
| status                            | Int     | Pipe status          |                     |                               | Y        | Determines if the component is active in the model          |

## Pumps (mpc.pump)

These components model infrastructure used to boost pressure between two nodes.

| Parameter                          | Type    | Name                                  | Standard Units (SI) | United States Customary Units | Required | Description                                      |
| ---------------------------------- | ------- | ------------------------------------- | ------------------- | ----------------------------- | -------- | ------------------------------------------------ |
| pump_i                             | Int     | Pump id                               |                     |                               | Y        | Unique id for pump                               |
| fr_junction                        | Int     | From Junction id                      |                     |                               | Y        | Unique id of the junction on the from side       |
| to_junction                        | Int     | To Junction id                        |                     |                               | Y        | Unique id of the junction on the to side         |
| station_i                          | Int     | Pump station id                       |                     |                               | Y        | Unique id of the station including up to 3 pumps |
| rotation_coefficient               | Float64 | Pump rotation coefficient             | m                   | ft                            | Y        | Pump coefficient required to define pump head    |
| flow_coefficient                   | Float64 | Pump flow coefficient                 | s^2/m^5               | h2/ft5                        | Y        | Pump coefficient required to define pump head    |
| flow_nom                           | Float64 | Nominal flow rate                     | m^3/s                | ft3/h                         | Y        | Pump nominal flow rate                           |
| flow_max                           | Float64 | Maximum flow rate                     | m^3/s                | ft3/h                         | Y        | Pump maximum flow rate                           |
| delta_head_max                     | Float64 | Maximum head difference               | m                   | ft                            | Y        | Maximum pump head difference                     |
| delta_head_min                     | Float64 | Minimum head difference               | m                   | ft                            | Y        | Minimum pump head difference                     |
| pump_efficiency_min                | Float64 | Minimum inlet pressure                |                     |                               | Y        | Minimum pump efficiency inlet                    |
| pump_efficiency_max                | Float64 | Maximum inlet pressure                |                     |                               | Y        | Maximum pump efficiency inlet                    |
| rotation_nom                       | Int     | Nominal rotational speed              | rotations/s         | rotations/minute              | Y        | Nominal pump rotational speed                    |
| rotation_min                       | Int     | Minimum rotational speed              | rotations/s         | rotations/minute              | Y        | Minimum pump rotational speed                    |
| rotation_max                       | Int     | Maximum rotational speed              | rotations/s         | rotations/minute              | Y        | Maximum pump rotational speed                    |
| electricity_price                  | Float64 | Electricity price                     | $/(kW*s)            | $/(kW*h)                      | Y        | Electricity price for every pump maintain        |
| status                             | Int     | Pump status                           |                     |                               | Y        | Determines if the component is active in the model |
| electric_motor_efficiency          | Float64 | Efficiency of the pump's motor        |                     |                               | Y        | Pump constant for computing pump efficiency      |
| mechanical_transmission_efficiency | Float64 | Efficiency of the pump's transmission |                     |                               | Y        | Pump constant for computing pump efficiency      |

## Producers (mpc.producer)

These components model producers of product.

| Parameter            | Type    | Name                  | Standard Units (SI) | United States Customary Units | Required | Description                                                           |
| -------------------- | ------- | --------------------- | ------------------- | ----------------------------- | -------- | --------------------------------------------------------------------- |
| producer_i           | Int     | producer id           |                     |                               | Y        | Unique id for producer                                                |
| junction_id          | Int     | Junction id           |                     |                               | Y        | Unique id of Junction to which component is connected                 |
| injection_min        | Float64 | Minimum injection     | m^3/s               | ft3/h                         | Y        | Minimum flow rate that can be injected                                |
| injection_max        | Float64 | Maximum Injection     | m^3/s               | ft3/h                         | Y        | Maximum flow rate that can be injected                                |
| qg                   | Float64 | Fixed flow rate       | m^3/s               | ft3/h                         | Y        | Producer flow rate if it's fixed                                      |
| status               | Int     | producer status       |                     |                               | Y        | Determines if the component is active in the model                    |
| is_dispatchable      | Int     | Dispatchable          |                     |                               | Y        | If the component is marked as dispatchable, it means that it can vary its injection between its minimum and maximum. If not, then the component is injecting exactly at the fixed injection rate |
| offer_price          | Float64 | Offer Price           | $/m^3               | $/ft^3                        |          | Offer price                                                           |

## Consumers (mpc.consumer)

| Parameter             | Type    | Name                  | Standard Units (SI) | United States Customary Units | Required | Description                                                           |
| -------------------- | ------- | --------------------- | ------------------- | ----------------------------- | -------- | --------------------------------------------------------------------- |
| consumer_i           | Int     | consumer id           |                     |                               | Y        | Unique id for consumer                                                |
| junction_id          | Int     | Junction id           |                     |                               | Y        | Unique id of Junction to which component is connected                 |
| withdrawal_min       | Float64 | Minimum Withdrawal    | m^3/s               | ft3/h                         | Y        | Minimum flow rate that can be withdrawn                               |
| withdrawal_max       | Float64 | Maximum Withdrawal    | m^3/s               | ft3/h                         | Y        | Maximum flow rate that can be withdrawn                               |
| ql                   | Float64 | Fixed flow rate       | m^3/s               | ft3/h                         | Y        | Consumer flow rate if it's fixed                                      |
| status               | Int     | consumer status       |                     |                               | Y        | Determines if the component is active in the model                    |
| is_dispatchable      | Int     | Dispatchable          |                     |                               | Y        | If the component is marked as dispatchable, it means that it can vary its withdrawal between its minimum and maximum. If not, then the component is withdrawal_nominal exactly at the fixed flow rate |
| bid_price            | Float64 | Bid Price             |  $/m3               | $/ft3                         |          | Bid price                                                             |


## Network Parameters (mpc._parameter_)

| Parameter                    | Type    | Name                   | Standard Units (SI) | United States Customary Units | Required | Description                                                        |
| ---------------------------- | ------- | ---------------------- | ------------------- | ----------------------------- | -------- | ------------------------------------------------------------------ |
| density                      | Float64 | Density                | kg/m^3              | lbm/ft3                       |          | Liquid density                                                     |
| viscosity                    | Float64 | Viscosity              | m^s2/s              | ft2/s                         |          | Liquid kinematic viscosity                                         |
| gravitational_acceleration   | Float64 | Gravity                | m/s^2               | ft/s2                         |          | Gravitational acceleration                                         |
| base_head                    | Float64 | Base Head              | m                   | ft                            |          | Base head                                                          |
| base_length                  | Float64 | Base Length            | m                   | ft                            |          | Base length                                                        |
| base_flow                    | Float64 | Base Flow Rate         | m^3/s               | ft3/h                         |          | Base flow rate                                                     |
| units                        | String  | Units                  |                     |                               |          | 'si' for standard units or 'usc' for United States customary units |
| is_per_unit                  | Int     | Per-unit               |                     |                               |          | If data is already in per-unit (non-dimensionalized)               |


## Matlab extensions

The matlab format supports extensions which allow users to define arbitrary components and data which are used in customized problems and formulations. For example, the syntax

```julia
  %column_names% data_field_name1, data_field_name2, ...
  mpc.component_data = [
  data1, data2
  data1, data2
  ...
  ]
```

is used to add data to standard components. In this example, the data dictionary for `component` will be augmented with fields called `data_field_name1`, `data_field_name2`, etc. The names trailing the keyword `%column_name%` are used as the keys in the data dictionary for each `component`. The key word `mpc.component_data` is used to indicate the component the new data should be associated with.  For example, `mpc.pipe_data` adds the data to pipes. The data should be listed in the same order as used by the tables that specify the required data for the component. The syntax

```julia
  %column_names% data_field_name1, data_field_name2, ...
  mpc.component = [
  data1, data2
  data1, data2
  ...
  ]
```

is then used to specify completely new components which are not specified in the default format. This example would create an entry from components called `component` in the data dictionary.
