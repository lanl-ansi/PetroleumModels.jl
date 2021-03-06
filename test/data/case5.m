function mpc = lib1

mpc.density                    = 827;     % petroleum density, kg per cubic m
mpc.viscosity                  = 4.9e-6;  % petroleum viscosity, squared m per second
mpc.gravitational_acceleration = 9.8;
mpc.base_head                  = 10;     % base head, m
mpc.base_length                = 542;     % m
mpc.base_flow                  = 1.0;    % petroleum volume flow rate, m3 per hour
mpc.units                      = 'si';
mpc.is_per_unit                = 0;
mpc.time_step                  = 0;

%% junction data
%  junction_i type head_min head_max elevation status
mpc.junction = [
  222  1  30 30    273 1
  333  0  30 740   273 1
  444  0  30 740   273 1
  88   0  30 740   293 1
];

%% pipeline data
% pipeline_i fr_junction to_junction diameter length flow_min flow_max friction_factor status
mpc.pipe = [
  33  444  88 0.75  154e3   0.139 1.139 0.0246 1
];

%% pump data
% pump_i fr_junction to_junction station_i rotation_coefficient flow_coefficient flow_nom flow_max delta_head_min delta_head_max pump_efficiency_min pump_efficiency_max rotation_nom rotation_min rotation_max electricity_price status electric_motor_efficiency mechanical_transmission_efficiency
mpc.pump = [
  22  333   444  1  276.8  92  1.0  1.2 144 217 0.6 0.87  50 40  60 0.00000033 1 0.966 0.95
  15  222   333  1  276.8  92  1.0  1.2 144 217 0.6 0.87  50 40  60 0.00000033 1 0.966 0.95
];

%% producer
% producer_i junction injection_min injection_max injection_nominal status dispatchable offer_price
mpc.producer = [
  1	 222	0.1 1.35 0.4 1 1 300
];

%% consumer
% consumer_i junction withdrawal_min withdrawal_max withdrawal_nominal status dispatchable bid_price
mpc.consumer = [
  1	 88	0.1 1.35 0.305 1 1 310
];

end
