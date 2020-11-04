function mpc = lib1

mpc.density                    = 851.5;    % petroleum density, kg per cubic m
mpc.viscosity                  = 11.6e-6;  % petroleum viscosity, squared m per second
mpc.gravitational_acceleration = 9.8;
mpc.base_density               = 850;      % petroleum base density, kg per m3
mpc.base_viscosity             = 11.6e-6;  % base viscosity, m2 / s
mpc.base_head                  = 100;      % base head, m
mpc.base_length                = 542;      % m
mpc.base_flow                  = 1.0;     % petroleum volume flow rate, m3 per hour
mpc.base_diameter              = 0.75;     % m
mpc.base_energy                = 900;      % pump base energy, kw*h
mpc.units                      = 'si';
mpc.is_per_unit                = 0;
mpc.time_step                  = 0;


%% junction data
%  junction_i type head_min head_max elevation status
mpc.junction = [
  1   1  353 353   332.8 1
  3   0  40  950   332.8 1
  4   0  40  950   332.8 1
  5   0  40  950   352   1
  6   0  40  950   537.5 1
  7   0  40  950   526.5 1
  8   0  40  950   526.5 1
  9   0  40  950   526.5 1
  10  0  40  950   595   1
  11  0  40  950   573.3 1
  12  0  30  950   482   1
  13  0  40  950   367.4 1
  14  0  40  950   367.4 1
  15  0  40  950   565   1
  16  0  40  950   391.2 1
];

%% pipeline data
% pipeline_i fr_junction to_junction diameter length flow_min flow_max friction_factor status
mpc.pipe = [
  15  15 16    1.04  137.5e3 0.1389 1.3889  0.0246 1
  14  14 15    1.04  96.1e3  0.1389 1.3889  0.0246 1
  12  12 13    1.04  133.3e3 0.1389 1.3889  0.0246 1
  11  11 12    1.04  126.5e3 0.1389 1.3889  0.0246 1
  10  10 11    1.04  111.9e3 0.1389 1.3889  0.0246 1
  9   9  10    1.04  123.9e3 0.1389 1.3889  0.0246 1
  6   6  7     1.04  126.9e3 0.1389 1.3889  0.0246 1
  5   5  6     1.04  107.7e3 0.1389 1.3889  0.0246 1
  4   4  5     1.04  128e3   0.1389 1.3889  0.0246 1
];

%% pump data
% pump_i fr_junction to_junction station_i rotation_coefficient flow_coefficient flow_nom flow_max delta_head_min delta_head_max pump_efficiency_min pump_efficiency_max rotation_nom rotation_min rotation_max electricity_price status electric_motor_efficiency mechanical_transmission_efficiency
mpc.pump = [
  13  13  14     3  319.1 70.3728  1.25    1.5    160 280 0.6 0.87  50 40  60 0.000019  1 0.966 0.95
  8   8   9      1  371   193.104  0.8681  1.0417 161 277 0.6 0.87  50 40  60 0.000033  1 0.966 0.95
  7   7   8      1  371   193.104  0.8681  1.0417 161 277 0.6 0.87  50 40  60 0.000033  1 0.966 0.95
  3   3   4      1  371   193.104  0.8681  1.0417 161 277 0.6 0.87  50 40  60 0.000028  1 0.966 0.95
  1   1   3      1  371   193.104  0.8681  1.0417 161 277 0.6 0.87  50 40  60 0.000028  1 0.966 0.95
];


%% producer
% producer_i junction injection_min injection_max injection_nominal status dispatchable offer_price
mpc.producer = [
  1  1  0.0833  1.1667  0.0583  1 1 150
  2  12 0.0278  0.0583  0.0583  1 1 150
  3  13 0.0278  0.0417  0.0388  1 1 150
];

%% consumer
% consumer_i junction withdrawal_min withdrawal_max withdrawal_nominal status dispatchable bid_price
mpc.consumer = [
  1	 16	1.1111 1.3889 1.12 1 1 270
];


end
