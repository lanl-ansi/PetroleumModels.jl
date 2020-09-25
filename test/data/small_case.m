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
mpc.base_diameter = 0.75; % m
mpc.Q_pipe_dim = 3600; % petroleum pipe flow coefficient
mpc.Q_pump_dim = 1; % petroleum pump flow coefficient
mpc.E_base = 900; % pump base energy, kw*h
mpc.units    = 'si';

mpc.per_unit = 1;
mpc.time_step = 0;

%% junction data
%  junction_i type Hmin Hmax z status
mpc.junction = [

222  0  30  30   273 1
333  0  30 740   273 1
444  0  30 740   273 1
88  0  30 740    293 1

];

%% pipeline data
% pipeline_i fr_junction to_junction diameter length Qmin Qmax status
mpc.pipe = [
33  444  88 0.75  154e3   500 5000 1
];

%% pump data
% pump_i fr_junction to_junction station_i a b q_nom delta_Hmax delta_Hmin min_pump_efficiency max_pump_efficiency w_nom min_w max_w electricity_price status
mpc.pump = [
22  333   444  1  276.8  7.1e-6  3600  144 217 0.6 0.87  3000 2400  3600 0.12 1
15  222   333  1  276.8  7.1e-6  3600  144 217 0.6 0.87  3000 2400  3600 0.12 1

];
%% producer
% producer_i junction qgmin qgmax qg status dispatchable price
mpc.producer = [
1	 222	360 4860 1440 1 1 300
];

%% consumer
% consumer_i junction qlmin qlmax ql status dispatchable price
mpc.consumer = [
1	 88	720 4860 1098 1 1 310
];

%% tank
% tank_i fr_junction to_junction vessel_pressure_head radius Min_Capacity_Limitation Max_Capacity_Limitation Initial_Volume Min_Load_Flow_Rate Max_Load_Flow_Rate Min_Unload_Flow_Rate Max_Unload_Flow_Rate Cd status price p_price
mpc.tank = [
];



end
