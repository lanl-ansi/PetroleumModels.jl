function mpc = lib1
mpc.beta = 0.0246; % s/m2, assume turbulent flow
mpc.rho = 827;  % petroleum density, kg per cubic m
mpc.nu = 4.9e-6;  % petroleum viscosity, squared m per second
mpc.gravitational_acceleration = 9.8;
mpc.base_rho = 827; % petroleum base density, kg per m3
mpc.base_nu       = 4.9e-6;  % base viscosity, m2 / s
mpc.baseH = 100; % base head, m
mpc.base_length   = 542; % m
mpc.baseQ = 3600; % petroleum volume flow rate, m3 per hour
mpc.base_z = 100; % base elevation, m
mpc.base_a = 100 ; % base a coefficient
mpc.base_b = 100 ; % base b coefficient
mpc.base_volume = 1000;
mpc.base_diameter = 0.8; % m
mpc.Q_pipe_dim = 3600; % petroleum pipe flow coefficient
mpc.Q_pump_dim = 1; % petroleum pump flow coefficient
mpc.E_base = 900; % pump base energy, kw*h
mpc.units    = 'si';

mpc.is_per_unit = 0;
mpc.time_step = 0;


%% junction data
%  junction_i type head_min head_max z status
mpc.junction = [
1  1  30 800 220 1
2  0  30 800 100 1
];

%% pipeline data
% pipeline_i fr_junction to_junction diameter length flow_min flow_max status
mpc.pipe = [
30  1  2  0.8  10.0e3 360 5000 1
];

%% producer
% producer_i junction injection_min injection_max qg status dispatchable offer_price
mpc.producer = [
1  1  360 3600 0.3 1 1 300
];

%% consumer
% consumer_i junction wthdrawal_min withdrawal_max ql status dispatchable bid_price
mpc.consumer = [
1	 2	360 3600 0.302 1 1 350
];

end
