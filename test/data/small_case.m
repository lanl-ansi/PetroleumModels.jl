function mgc = lib1

mgc.rho = 850;  % petroleum density, kg per cubic m
mgc.nu = 9e-4;  % petroleum viscosity, squared m per second
mgc.gravitational_acceleration = 9.8;
mgc.standard_density = 850; % petroleum base density, kg per m3
mgc.baseQ = 1; % petroleum volume flow rate, m3 per hour
mgc.baseH = 100; % base head, m
mgc.base_z = 100; % base inclination, m
mgc.base_h_loss = 100; % base head loss
mgc.base_a = 100 ; % base a coefficient
mgc.base_b = 100 ; % base b coefficient
mgc.per_unit = 1;
mgc.time_network = 1;
mgc.time_step = 1;

%% junction data
%  junction_i type Hmin Hmax H z status
mgc.junction = [
1  1  100 260 0   220 1
2  0  30 800 0   220 1
3  0  30 800 0   220 1
4  0  30 800 0   200 1
5  0  30 800 0   300 1
6  0  30 800 0   300 1
7  0  30 800 0   280 1
8  0  30 800 0   250 1


];

%% pipeline data
% pipeline_i f_junction t_junction diameter length Qmin Qmax status
mgc.pipe = [
30  3  4  0.8  80.0e3 0.1 1.388 1
40  4  5  0.8  70.0e3 0.1 1.388 1
70  6  7  0.512  30.0e3 0.1 1.388 1
80  6  8  0.512  25.0e3 0.1 1.388 1


];

%% booster_pump data
% pump_i f_junction t_junction station_i a b q_nom delta_Hmax delta_Hmin min_pump_efficiency max_pump_efficiency w_nom min_w max_w electricity_price status
mgc.booster_pump = [
6  1  2  1  276.8  7.1e-6  1  144 217 0.6 0.87  3000 2400  3600 0.14 1
];

%% pump data
% pump_i f_junction t_junction station_i a b q_nom delta_Hmax delta_Hmin min_pump_efficiency max_pump_efficiency w_nom min_w max_w electricity_price status
mgc.pump = [
10  1  2     2  251  0.812e-5 0.69  283 324 0.6 0.85  3000 2400  3600 0.1 1
20  2  3     2  251  0.812e-5 0.69  283 324 0.6 0.85  3000 2400  3600 0.12 1
50  5  6     2  251  0.812e-5 0.69  283 324 0.6 0.85  3000 2400  3600 0.12 1


];
%% producer
% producer_i junction qgmin qgmax qg status dispatchable price
mgc.producer = [
1  1  0.015  1 0.1 1 1 300
2  4  0.015  1 0.1 1 1 300

];

%% consumer
% consumer_i junction qlmin qlmax ql status dispatchable price
mgc.consumer = [
1	 7	0.305 0.706 0.302 1 0 350
2	 8	0.305 0.606 0.302 1 0 350
];

end
