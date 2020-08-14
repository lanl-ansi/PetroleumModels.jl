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
mpc.per_unit = 1;



%% junction data
%  id type Hmin Hmax H z status
mpc.junction = [
111  0  0  740   0   273 1
222  0  0  740   0   273 1
333  0  30 740 0   273 1
444  0  30 740 0   273 1
88  0  30 740 0   293 1

];

%% pipeline data
% pipeline_i fr_junction to_junction diameter length Qmin Qmax status
mpc.pipe = [

33  444  88 0.75  154e3   0.138 1.388 1
];

%% booster_pump data
% pump_i fr_junction to_junction station_i a b q_nom delta_Hmax delta_Hmin min_pump_efficiency max_pump_efficiency w_nom min_w max_w electricity_price status
mpc.booster_pump = [
6  12  2  1  276.8  7.1e-6  1  144 217 0.6 0.87  3000 2400  3600 0.14 1
];

%% pump data
% pump_i fr_junction to_junction station_i a b q_nom delta_Hmax delta_Hmin min_pump_efficiency max_pump_efficiency w_nom min_w max_w electricity_price status
mpc.pump = [
22  333   444  1  276.8  7.1e-6  1  144 217 0.6 0.87  3000 2400  3600 0.12 1
15  222   333  1  276.8  7.1e-6  1  144 217 0.6 0.87  3000 2400  3600 0.12 1
];
%% producer
% producer_i junction_id qgmin qgmax qg status is_dispatchable offer_price
mpc.producer = [
1	 111	0.01 1.35 1440 1 1 300
];

%% consumer
% consumer_i junction_id qlmin qlmax ql status is_dispatchable bid_price
mpc.consumer = [
1	 88	0.2 1.35 0.305 1 1 310
];


%% tank
% tank_i fr_junction to_junction vessel_pressure_head radius Min_Capacity_Limitation Max_Capacity_Limitation Initial_Volume Min_Load_Flow_Rate Max_Load_Flow_Rate Min_Unload_Flow_Rate Max_Unload_Flow_Rate Cd status price p_price
mpc.tank = [
31  111 222 0 14.25 459 10283 10000 0.138 1.138 0.01 1.35 0.94 1 0.00800458 300
];

end
