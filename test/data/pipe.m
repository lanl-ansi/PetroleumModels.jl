function mpc = lib1

mpc.rho = 827;  % petroleum density, kg per cubic m
mpc.nu = 4.9e-6;  % petroleum viscosity, squared m per second
mpc.gravitational_acceleration = 9.8;
mpc.standard_density = 850; % petroleum base density, kg per m3
mpc.baseQ = 1; % petroleum volume flow rate, m3 per hour
mpc.units    = 'si';
mpc.baseH = 100; % base head, m
mpc.base_z = 100; % base inclination, m
mpc.base_h_loss = 100; % base head loss
mpc.base_a = 100 ; % base a coefficient
mpc.base_b = 100 ; % base b coefficient
mpc.per_unit = 0;

%% junction data
%  junction_i type Hmin Hmax H z status
mpc.junction = [
1  0  30 800 0   220 1
2  0  30 800 0   100 1


];

%% pipeline data
% pipeline_i fr_junction to_junction diameter length Qmin Qmax status
mpc.pipe = [
30  1  2  0.8  10.0e3 0.1 1.388 1
];

%% booster_pump data
% pump_i fr_junction to_junction station_i a b q_nom delta_Hmax delta_Hmin min_pump_efficiency max_pump_efficiency w_nom min_w max_w electricity_price status
mpc.booster_pump = [
6  1  2  1  276.8  7.1e-6  1  144 217 0.6 0.87  3000 2400  3600 0.14 1
];

%% pump data
% pump_i fr_junction to_junction station_i a b q_nom delta_Hmax delta_Hmin min_pump_efficiency max_pump_efficiency w_nom min_w max_w electricity_price status
mpc.pump = [



];
%% producer
% producer_i junction qgmin qgmax qg status dispatchable price
mpc.producer = [
1  1  0.015  1 0.3 1 1 300

];

%% consumer
% consumer_i junction qlmin qlmax ql status dispatchable price
mpc.consumer = [
1	 2	0.305 1.706 0.302 1 1 350
];


%% tank
% tank_i fr_junction to_junction vessel_pressure_head radius Min_Capacity_Limitation Max_Capacity_Limitation Initial_Volume Min_Load_Flow_Rate Max_Load_Flow_Rate Min_Unload_Flow_Rate Max_Unload_Flow_Rate Cd status price p_price
mpc.tank = [

];

end
