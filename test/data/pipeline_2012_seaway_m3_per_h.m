function mpc = lib1

mpc.density                    = 827;     % petroleum density, kg per cubic m
mpc.viscosity                  = 4.9e-6;  % petroleum viscosity, squared m per second
mpc.gravitational_acceleration = 9.8;
mpc.base_density               = 827;     % petroleum base density, kg per m3
mpc.base_viscosity             = 4.9e-6;  % base viscosity, m2 / s
mpc.base_head                  = 100;     % base head, m
mpc.base_length                = 542;     % m
mpc.base_flow                  = 3600;    % petroleum volume flow rate, m3 per hour
mpc.base_volume                = 1000;
mpc.base_diameter              = 0.75;    % m
mpc.base_energy                = 900;     % pump base energy, kw*h
mpc.units                      = 'si';
mpc.is_per_unit                = 0;
mpc.time_step                  = 0;

%% junction data
%  junction_i type head_min head_max elevation status
mpc.junction = [
  1   1  190 190  273 1
  2   0  30  740  273 1
  3   0  30  740  273 1
  4   0  30  740  293 1
  5   0  30  740  293 1
  6   0  30  740  201 1
  7   0  30  740  266 1
  8   0  30  740  266 1
  9   0  30  740  180 1
  10  0  30  740  153 1
  11  0  30  740  153 1
  12  0  30  740  146 1
  13  0  30  740  146 1
  14  0  30  740  146 1
  15  0  30  740  107 1
  16  0  30  740  106 1
  17  0  30  740  92  1
  18  0  30  740  92  1
  19  0  30  740  202 1
  20  0  30  740  202 1
  21  0  30  740  95  1
  22  0  30  740  95  1
  23  0  30  740  2   1
];

%% pipeline data
% pipeline_i fr_junction to_junction diameter length flow_min flow_max friction_factor status
mpc.pipe = [
  22 22 23  0.75  13.62e3 500 5000  0.0246 1
  20 20 21  0.75  173.6e3 500 5000  0.0246 1
  18 18 19  0.75  87e3    500 5000  0.0246 1
  17 17 18  0.75  10.7e3  500 5000  0.0246 1
  16 16 17  0.75  83.2e3  500 5000  0.0246 1
  15 15 16  0.75  0.87e3  500 5000  0.0246 1
  14 14 15  0.75  2.94e3  500 5000  0.0246 1
  11 11 12  0.75  165e3   500 5000  0.0246 1
  9  9  10  0.75  36e3    500 5000  0.0246 1
  8  8  9   0.75  106.3e3 500 5000  0.0246 1
  6  6  7   0.75  132e3   500 5000  0.0246 1
  5  5  6   0.75  3.8e3   500 5000  0.0246 1
  3  3  4   0.75  154e3   500 5000  0.0246 1
];


%% pump data
% pump_i fr_junction to_junction station_i rotation_coefficient flow_coefficient flow_nom flow_max delta_head_min delta_head_max pump_efficiency_min pump_efficiency_max w_nom rotation_min rotation_max electricity_price status electric_motor_efficiency mechanical_transmission_efficiency
mpc.pump = [
  21  21  22     1  276.8  7.1e-6  3600  4320 144 217 0.6 0.87  3000 2400  3600 0.14  1 0.966 0.95
  19  19  20     1  276.8  7.1e-6  3600  4320 144 217 0.6 0.87  3000 2400  3600 0.08  1 0.966 0.95
  13  13  14     1  276.8  7.1e-6  3600  4320 144 217 0.6 0.87  3000 2400  3600 0.15  1 0.966 0.95
  12  12  13     1  276.8  7.1e-6  3600  4320 144 217 0.6 0.87  3000 2400  3600 0.15  1 0.966 0.95
  10  10  11     1  276.8  7.1e-6  3600  4320 144 217 0.6 0.87  3000 2400  3600 0.12  1 0.966 0.95
  7   7   8      1  276.8  7.1e-6  3600  4320 144 217 0.6 0.87  3000 2400  3600 0.11  1 0.966 0.95
  4   4   5      1  276.8  7.1e-6  3600  4320 144 217 0.6 0.87  3000 2400  3600 0.13  1 0.966 0.95
  2   2   3      1  276.8  7.1e-6  3600  4320 144 217 0.6 0.87  3000 2400  3600 0.12  1 0.966 0.95
  1   1   2      1  276.8  7.1e-6  3600  4320 144 217 0.6 0.87  3000 2400  3600 0.12  1 0.966 0.95
];
%% producer
% producer_i junction injection_min injection_max injection_nominal status dispatchable offer_price
mpc.producer = [
  1  1  360  3000 1440 1 1 300
  2  9  360  3000 1440 1 1 300
  3  18 360  3000 1440 1 1 300
];

%% consumer
% consumer_i junction withdrawal_min withdrawal_max withdrawal_nominal status dispatchable bid_price
mpc.consumer = [
  1	 15	288 3060 1100 1 1 310
  2	 23	288 3060 1100 1 1 310
];


end
