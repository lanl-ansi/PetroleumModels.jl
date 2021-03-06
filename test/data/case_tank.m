function mpc = lib1

mpc.density                    = 851.5;    % petroleum density, kg per cubic m
mpc.viscosity                  = 11.6e-6;  % petroleum viscosity, squared m per second
mpc.gravitational_acceleration = 9.8;
mpc.base_head                  = 100;      % base head, m
mpc.base_length                = 542;      % m
mpc.base_flow                  = 1.0;     % petroleum volume flow rate, m3 per hour
mpc.units                      = 'si';
mpc.is_per_unit                = 0;
mpc.time_step                  = 0;

%% junction data
%  id type head_min head_max elevation status
mpc.junction = [
  111  1  30  740   273 1
  222  0  30  740   273 1
  333  0  30  740   273 1
  444  0  30  740   273 1
  88   0  30  740   293 1
];

%% pipeline data
% pipeline_i fr_junction to_junction diameter length flow_min flow_max friction_factor status
mpc.pipe = [
  33  444  88 0.75  154e3   0.139 1.139 0.019832 1
];


%% pump data
% pump_i fr_junction to_junction station_i rotation_coefficient flow_coefficient flow_nom flow_max delta_head_min delta_head_max pump_efficiency_min pump_efficiency_max rotation_nom rotation_min rotation_max electricity_price status electric_motor_efficiency mechanical_transmission_efficiency
mpc.pump = [
  22  333   444  1  276.8  92  1.0  1.2 144 217 0.6 0.87  50 40  60 0.00000033 1 0.966 0.95
  15  222   333  1  276.8  92  1.0  1.2 144 217 0.6 0.87  50 40  60 0.00000033 1 0.966 0.95
];

%% producer
% producer_i junction_id injection_min injection_max injection_nominal status is_dispatchable offer_price
mpc.producer = [
  1	 111	0.1 1.35 0.4 1 1 300
];

%% consumer
% consumer_i junction_id withdrawal_min withdrawal_max withdrawal_nominal status is_dispatchable bid_price
mpc.consumer = [
  1	 88	0.1 1.35 0.305 1 1 310
];

%% tank
% tank_i fr_junction to_junction vessel_pressure_head radius capacity_min capacity_max initial_volume intake_min intake_max offtake_min offtake_max Cd status price p_price
mpc.tank = [
  31  111 222 0 14.25 459 10283 10000 0.138 1.138 0.01 1.35 0.94 1 0.00800458 300
];

end
