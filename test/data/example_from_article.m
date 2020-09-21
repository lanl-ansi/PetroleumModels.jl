function mpc = lib1
mpc.beta = 0.0246; % s/m2, assume turbulent flow
mpc.rho = 851.5;  % petroleum density, kg per cubic m
mpc.nu = 11.6e-6;  % petroleum viscosity, squared m per second
mpc.gravitational_acceleration = 9.8;
mpc.base_rho = 850; % petroleum base density, kg per m3
mpc.base_nu  = 11.6e-6;  % base viscosity, m2 / s
mpc.baseH = 100; % base head, m
mpc.base_length   = 542; % m
mpc.baseQ = 3600; % petroleum volume flow rate, m3 per hour
mpc.base_z = 100; % base elevation, m
mpc.base_a = 100 ; % base a coefficient
mpc.base_b = 100 ; % base b coefficient
mpc.base_volume = 1000;
mpc.base_diameter = 1.04; % m
mpc.Q_pipe_dim = 3600; % petroleum pipe flow coefficient
mpc.Q_pump_dim = 1; % petroleum pump flow coefficient
mpc.units    = 'si';

mpc.per_unit = 1;
mpc.time_step = 0;


%% junction data
%  junction_i type Hmin Hmax z status
mpc.junction = [
1  1  350 353  332.8 1
3  0  40 950  332.8 1
4  0  40 950  332.8 1
5  0  40 950  352   1
6  0  40 950  537.5 1
7  0  40 950  526.5 1
8  0  40 950 526.5 1
9  0  40 950 526.5 1

10  0  40 950 595 1
11  0  40 950  573.3 1
12  0  30 950  482 1
13  0  40 950  367.4 1
14  0  40 950  367.4 1

15  0  40 950  565 1
16  0  40 950  391.2 1
];

%% pipeline data
% pipeline_i fr_junction to_junction diameter length Qmin Qmax status
mpc.pipe = [
15  15 16    1.04  137.5e3 500 5000  1
14  14 15    1.04  96.1e3 500 5000  1

12  12 13    1.04  133.3e3 500 5000  1
11  11 12    1.04  126.5e3 500 5000  1
10  10 11    1.04  111.9e3 500 5000  1
9   9 10     1.04  123.9e3 500 5000  1

6  6 7       1.04  126.9e3 500 5000  1
5  5 6       1.04  107.7e3 500 5000  1
4  4 5       1.04  128e3  500 5000  1
];

%% pump data
% pump_i fr_junction to_junction station_i a b q_nom delta_Hmax delta_Hmin min_pump_efficiency max_pump_efficiency w_nom min_w max_w electricity_price status
mpc.pump = [
13  13  14   3  319.1 5.43e-6 4500  160 280 0.6 0.87  3000 2400  3600 0.07  1

8  8  9      1  371  14.9e-6  3125  161 277 0.6 0.87  3000 2400  3600 0.12  1
7  7  8      1  371  14.9e-6  3125  161 277 0.6 0.87  3000 2400  3600 0.12  1

3  3  4      1  371  14.9e-6  3125  161 277 0.6 0.87  3000 2400  3600 0.1  1

1  1  3      1  371  14.9e-6  3125  161 277 0.6 0.87  3000 2400  3600 0.1  1
];


%% producer
% producer_i junction qgmin qgmax qg status dispatchable price
mpc.producer = [
1  1  300 4200 1.125 1 1 150
2  12 100 210 209.7 1 1 150
3  13 100 150 139.8 1 1 150
];

%% consumer
% consumer_i junction qlmin qlmax ql status dispatchable price
mpc.consumer = [
1	 16	4000 5000 1.12 1 1 270

];


%% tank
% tank_i fr_junction to_junction vessel_pressure_head radius Min_Capacity_Limitation Max_Capacity_Limitation Initial_Volume Min_Load_Flow_Rate Max_Load_Flow_Rate Min_Unload_Flow_Rate Max_Unload_Flow_Rate Cd status price p_price
mpc.tank = [

];



end
