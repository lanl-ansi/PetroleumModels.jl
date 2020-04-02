using PyPlot


# H1 = [225,440,655,438,653,740,506,721,671,551,695,30,174,318,345,346,348,346,83,229,30,177,246]
# H2 = [285,492,699,445,654,740,474,691,616,523,740,197,414,631,660,661,663,661,269,486,30,212,261]
# H3 = [300,495,690,458,653,740,494,711,651,565,740,231,448,665,695,696,697,696,292,509,30,174,221]
x = [0, 0, 0, 154, 154, 157.8, 289.8,289.8, 396.1, 432.1, 432.1, 597.1,597.1,597.1,600.04,
600.91, 684.11, 694.81, 781.81,781.81, 955.41,955.41,969.03]

x1 = [0, 0]
x2=[154, 154]
x3=[289.8,289.8]
x4=[432.1, 432.1]
x5=[597.1,597.1]
x6=[781.81,781.81]
x7=[955.41,955.41]



z = [273,273,273, 293,293, 201, 266,266, 180, 153, 153, 146,146,146, 107, 106, 92,92,202,202,95,95,2]
L = [154,157.8,289.8,396.1,432.1,597.1,600.04,600.91,684.11,694.81,781.81,955.41,969.03]


H1 = [190,355,519,375,539,628,457,621,621,580,724,418,562,706,740,740,686,677,459,616,507,664,740]
H2 = [243,432,621,427,619,706,493,694,660,530,740,30,247,464,490,491,493,491,156,373,30,224,282]
H3 = [268,434,600,464,629,718,554,720,725,596,740,30,247,464,490,491,493,491,156,373,30,174,232]

Q1 = [1328,1328,1328,1328,1328,1328,1328,1328, 2161,2161,2161,2161,2161,2161, 1337,1337,1337, 1697,1697,1697,1697,1697,1697]
Q2 = [1606,1606,1606,1606,1606,1606,1606,1606, 3472,3472,3472,3472,3472,3472, 500,500,500, 2584,2584,2584,2584,2584,2584]
Q3 = [1276,1276,1276,1276,1276,1276,1276,1276, 3472,3472,3472,3472,3472,3472, 500,500,500, 2584,2584,2584,2584,2584,2584]
# pump_id = [1, 2, 3]
eta1 = [0.617,0.617,0.617,0.617,0.816,0.816,0.816,0.723,0.723]
eta2 = [0.666,0.666,0.663,0.653,0.866,0.865,0.865,0.809,0.824]
eta3 = [0.600,0.600,0.600,0.600,0.867,0.865,0.865,0.809,0.854]
omega1 = [2400,2400,2400,2400,2400,2400,2400,2400,2400]
omega2 = [2596,2597,2612,2671,3098,3137,3137,2932,2801]
omega3 = [2400,2400,2400,2400,2732,3137,3137,2932,2495]
H_max = [740, 740]
H_min = [30, 30]


##########
#  Plot  1#
##########
fig = figure("multiaxis",figsize=(12,12))
# p = plot(L_head_1, H1, linestyle="-",color="blue",marker="o") # Plot a basic line
# p = plot(L_head_2, H2, linestyle="-",color="blue",marker="o") # Plot a basic line
ax = gca()
setp(ax.get_xticklabels(),color="black", size=14)
# PyPlot.title("Multi-axis Plot")
# p = plot(x1,[30,740],color="grey",linestyle="-", linewidth=0.5)
# p = plot(x2,[30,740],color="grey",linestyle="-", linewidth=0.5)
# p = plot(x3,[30,740],color="grey",linestyle="-", linewidth=0.5)
# p = plot(x4,[30,740],color="grey",linestyle="-", linewidth=0.5)
# p = plot(x5,[30,740],color="grey",linestyle="-", linewidth=0.5)
# p = plot(x6,[30,740],color="grey",linestyle="-", linewidth=0.5)
# p = plot(x7,[30,740],color="grey",linestyle="-", linewidth=0.5)
# p = plot([0,969.03],H_max,color="red",linestyle="--",label="max head")
# p = plot([0,969.03],H_min,color="green",linestyle="--",label="min head")
# p = plot([1,9],[0.87,0.87],color="red",linestyle="-",label="max efficiency")
# p = plot([1,9],[0.6,0.6],color="green",linestyle="-",label="min efficiency")

p = plot([1,23],[5000,5000],color="red",linestyle="-",label="max flow rate")
p = plot([1,23],[500,500],color="green",linestyle="-",label="min flow rate")
p = plot(1:23,Q1, color="blue",marker="*",linestyle="-",label="flow rate in Formulation #1")
p = plot(1:23,Q2, color="orange",marker="o",linestyle="--",label="flow rate in Formulation #2")
p = plot(1:23,Q3, color="black",marker="x",linestyle="-.",label="flow rate in Formulation #3")

# p = plot(1:9,eta1, color="royalblue",marker="*",linestyle=":",label="efficiency in Formulation #1")
# p = plot(1:9,eta2, color="orange",marker="o",linestyle="--",label="efficiency in Formulation #2")
# p = plot(1:9,eta3, color="magenta",marker="x",linestyle="-.",label="efficiency in Formulation #3")

# xlabel("Pipeline length, km", size=18)
xlabel("Node #", size=18)
font1 = Dict("color"=>"black")
ylabel("Flow rate, m3/h",fontdict=font1, size=18)
# ylabel("Efficiency",fontdict=font1, size=18)
# ylabel("Rotational speed, rpm",fontdict=font1, size=18)
# p = plot([1,9],[3600,3600],color="red",linestyle="-", label="max rotational speed")
# p = plot([1,9],[2400,2400],color="green",linestyle="-", label="min rotational speed")
#
# p = plot(1:9,omega1, color="royalblue",marker="s",linestyle=":",label="rotational speed in Formulation #1")
# p = plot(1:9,omega2, color="orange",marker="D",linestyle="--",label="rotational speed in Formulation #2")
# p = plot(1:9,omega3, color="magenta",marker="v",linestyle="-.",label="rotational speed in Formulation #3")
setp(ax.get_yticklabels(),color="black", size=14) # Y Axis font formatting
ax.legend(loc=2)
################
#  Other Axes  #
################
new_position = [0.15;0.1;0.7;0.83]  # Position Method 2
ax.set_position(new_position) # Position Method 2: Change the size and position of the axis
#fig.subplots_adjust(right=0.85) # Position Method 1
ax2= gca()
setp(ax2.get_xticklabels(),color="black", size=14)

ax2 = ax.twinx() # Create another axis on top of the current axis
font2 = Dict("color"=>"purple")
ylabel("Rotational speed, rpm",fontdict=font2, size=18)
p = plot([1,9],[3600,3600],color="red",linestyle="-", label="max rotational speed")
p = plot([1,9],[2400,2400],color="green",linestyle="-", label="min rotational speed")

p = plot(1:9,omega1, color="royalblue",marker="s",linestyle=":",label="rotational speed in Formulation #1")
p = plot(1:9,omega2, color="orange",marker="D",linestyle="--",label="rotational speed in Formulation #2")
p = plot(1:9,omega3, color="magenta",marker="v",linestyle="-.",label="rotational speed in Formulation #3")
# p = plot(x,z,color="purple",linestyle=":",marker="*",label="elevation", linewidth = 0.8) # Plot a basic line
ax2.set_position(new_position) # Position Method 2
setp(ax2.get_yticklabels(),color="purple", size=14) # Y Axis font formatting
ax2.legend(loc=2)

# ax3 = ax.twinx() # Create another axis on top of the current axis
# ax3.spines["right"].set_position(("axes",1.12)) # Offset the y-axis label from the axis itself so it doesn't overlap the second axis
# font3 = Dict("color"=>"green")
# ylabel("Elevation, m",fontdict=font3)
# p = plot(L,z,color="green",linestyle="-",marker="*",label="elevation") # Plot a basic line
# ax3.set_position(new_position) # Position Method 2
# setp(ax.get_yticklabels(),color="green") # Y Axis font formatting

axis("tight")

# Enable just the right part of the frame
# ax3.set_frame_on(true) # Make the entire frame visible
# ax3.patch.set_visible(false) # Make the patch (background) invisible so it doesn't cover up the other axes' plots
# ax3.spines["top"].set_visible(false) # Hide the top edge of the axis
# ax3.spines["bottom"].set_visible(false) # Hide the bottom edge of the axis

fig.canvas.draw() # Update the figure













using PyPlot


Prod_price = [280,285,290,295,300,305,310,315,320,325]
Con_price = [280,285,290,295,300,305,310,315,320,325]
Economic_term = [90614,81851,73089,64327,55565,49316,47270,45470,43670,41870]
Power_term = [1921.69,1921.6,1921.69,1921.69,1921.69,1874.33,1868.41,1868.41,1868.41,1868]



##########
#  Plot  1#
##########
fig = figure("multiaxis",figsize=(12,12))
# p = plot(L_head_1, H1, linestyle="-",color="blue",marker="o") # Plot a basic line
# p = plot(L_head_2, H2, linestyle="-",color="blue",marker="o") # Plot a basic line
ax = gca()
setp(ax.get_xticklabels(),color="black", size=14)
# PyPlot.title("Multi-axis Plot")

p = plot(Prod_price,Economic_term, color="blue",marker="*",linestyle="-")

xlabel("Price of producer #N9(2), \$/m3", size=18)
font1 = Dict("color"=>"blue")
ylabel("Economic term, \$/h",fontdict=font1, size=18)
setp(ax.get_yticklabels(),color="blue", size=14) # Y Axis font formatting
ax.legend()
################
#  Other Axes  #
################
new_position = [0.15;0.1;0.7;0.83] # Position Method 2
ax.set_position(new_position) # Position Method 2: Change the size and position of the axis
#fig.subplots_adjust(right=0.85) # Position Method 1

ax2 = ax.twinx() # Create another axis on top of the current axis
font2 = Dict("color"=>"purple")
ylabel("Power term, \$/h",fontdict=font2)
p = plot(Prod_price,Power_term, color="purple",linestyle="-.",marker="*") # Plot a basic line
ax2.set_position(new_position) # Position Method 2
setp(ax2.get_yticklabels(),color="purple", size=14) # Y Axis font formatting

axis("tight")

fig.canvas.draw() # Update the figure




# Efficiency and speed for different formulations
using PyPlot


Pump_n = [1,2,3,4,5,6,7,8,9]
Speed_1 = [2757.64,2757.72,2758.66,2778.74,3091.18,3136.65,3136.65,2932.10,2764.09]
Speed_2 = [2400,2400,2400,2400,2441.381596,2441.381596,2441.381596,2400,2400]
Speed_3 = [2781.7,2781.7,2781.7,2781.8,3016.3,3136.6,3136.6,2932.1,2494.7]
Eff_1 = [0.605,0.605,0.605,0.608,0.870,0.870,0.870,0.793,0.770]
Eff_2 = [0.6000,0.6000,0.6000,0.6000,0.6794,0.6794,0.6794,0.6349,0.6349]
Eff_3 = [.600000034,0.600,0.600,0.600,0.869,0.870,0.870,0.793,0.729]

##########
#  Plot  1#
##########
fig = figure("multiaxis",figsize=(12,12))
# p = plot(L_head_1, H1, linestyle="-",color="blue",marker="o") # Plot a basic line
# p = plot(L_head_2, H2, linestyle="-",color="blue",marker="o") # Plot a basic line
ax = gca()
setp(ax.get_xticklabels(),color="black", size=14)
# PyPlot.title("Multi-axis Plot")
p = plot([1,9],[3600,3600],color="red",linestyle="--",label="max rotational speed")
p = plot([1,9],[2400,2400],color="green",linestyle="--",label="min rotational speed")
p = plot(Pump_n, Speed_1, color="blue",marker="*",linestyle="-", label="Formulation 1")
p = plot(Pump_n, Speed_2, color="purple",marker="o",linestyle="--", label="Formulation 2")
p = plot(Pump_n, Speed_3, color="black",marker="s",linestyle="-.", label="Formulation 3")

# p = plot([1,9],[0.87,0.87],color="red",linestyle="--",label="max efficiency")
# p = plot([1,9],[0.6,0.6],color="green",linestyle="--",label="min efficiency")
# p = plot(Pump_n, Eff_1, color="blue",marker="*",linestyle="-", label="Formulation 1")
# p = plot(Pump_n, Eff_2, color="purple",marker="o",linestyle="--", label="Formulation 2")
# p = plot(Pump_n, Eff_3, color="black",marker="s",linestyle="-.", label="Formulation 3")

xlabel("Pump #", size=18)
font1 = Dict("color"=>"black")
ylabel("Rotational speed, rpm",fontdict=font1, size=18)
# ylabel("Pump efficiency",fontdict=font1)
setp(ax.get_yticklabels(),color="black", size=14) # Y Axis font formatting
ax.legend()
setp(ax.get_xticklabels(),color="black", size=14)
################
#  Other Axes  #
################
new_position = [0.15;0.1;0.7;0.83]  # Position Method 2
ax.set_position(new_position) # Position Method 2: Change the size and position of the axis
#fig.subplots_adjust(right=0.85) # Position Method 1

ax2 = ax.twinx() # Create another axis on top of the current axis
font2 = Dict("color"=>"purple")
ylabel("Pump efficiency",fontdict=font2, size=18)
p = plot(Con_price,Power_term, color="purple",linestyle="-",marker="*") # Plot a basic line
ax2.set_position(new_position) # Position Method 2
setp(ax2.get_yticklabels(),color="purple", size=14) # Y Axis font formatting

axis("tight")

fig.canvas.draw() # Update the figure


# Consumer prices (4 different)
using PyPlot


Pump_n = [1,2,3,4,5,6,7,8,9]
# Speed_1 = [2400,2400,2400,2400,2732,3137,3137,2932,2495] #295 producer 2
# Speed_2 = [2400,2400,2400,2400,2732,3137,3137,2932,2495] #300
# Speed_3 = [2790,2790,2830,2830,2949,2949,2949,3043,2624] #305
# Speed_4 = [2850,2850,2850,2850,2917,2917,2917,3043,2624] #310

# Speed_1 = [2400,2400,2400,2400,2400,2400,2400,3022,2600] #295
# Speed_2 = [2400,2400,2400,2400,2400,2400,2400,3043,2624] #300
# Speed_3 = [2400,2400,2400,2400,2533,2965,2965,3043,2624] #305
# Speed_4 = [2400,2400,2400,2400,2732,3137,3137,2932,2495] #310


# Eff_1 = [0.600,0.600,0.600,0.600,0.867,0.865,0.865,0.809,0.854] #295
# Eff_2 = [0.600,0.600,0.600,0.600,0.867,0.865,0.865,0.809,0.854] #300
# Eff_3 = [0.736,0.736,0.730,0.730,0.817,0.817,0.817,0.849,0.870] #305
# Eff_4 = [0.750,0.750,0.750,0.750,0.801,0.801,0.801,0.849,0.870] #310

# Eff_1 = [0.678,0.678,0.678,0.678,0.767,0.767,0.767,0.844,0.869] #295
# Eff_2 = [0.679,0.679,0.679,0.679,0.767,0.767,0.767,0.849,0.870] #300
# Eff_3 = [0.600,0.600,0.600,0.600,0.862,0.824,0.824,0.849,0.870] #305
# Eff_4 = [0.600,0.600,0.600,0.600,0.867,0.865,0.865,0.809,0.854] #310

# H_1 = [268,434,600,464,629,718,554,720,725,596,740,30,247,464,490,491,493,491,156,373,30,174,232]
# H_2 = [268,434,600,464,629,718,554,720,725,596,740,30,247,464,490,491,493,491,156,373,30,174,232]
# H_3 = [300,510,720,437,654,740,450,667,572,500,717,272,489,706,737,738,740,738,320,537,30,174,219]
# H_4 = [300,517,734,424,641,726,413,630,516,454,671,272,489,706,737,738,740,738,320,537,30,174,219]


# H_1 = [190,351,511,332,493,581,379,540,516,489,641,401,553,705,740,740,700,693,290,507,30,174,221]
# H_2 = [190,351,511,332,492,580,378,539,515,488,640,399,551,703,737,738,740,738,320,537,30,174,219]
# H_3 = [215,381,547,411,576,665,501,667,672,596,740,273,490,707,737,738,740,738,320,537,30,174,219]
# H_4 = [268,434,600,464,629,718,554,720,725,596,740,30,247,464,490,491,493,491,156,373,30,174,232]

Q_1 =[1276,1276,1276,1276,3472,3472,3472,500,500,500,2584,2584,2584]
Q_2 =[1276,1276,1276,1276,3472,3472,3472,500,500,500,2584,2584,2584]
Q_3 =[2034,2034,2034,2034,2666,2666,2666,500,500,500,3088,3088,3088]
Q_4 =[2151,2151,2151,2151,2511,2511,2511,500,500,500,3088,3088,3088]

# Q_1 =[1528,1528,1528,1528,1888,1888,1888,1168,1168,1168,3001,3001,3001]
# Q_2 =[1530,1530,1530,1530,1890,1890,1890,500,500,500,3088,3088,3088]
# Q_3 =[1276,1276,1276,1276,2742,2742,2742,500,500,500,3088,3088,3088]
# Q_4 =[1276,1276,1276,1276,3472,3472,3472,500,500,500,2584,2584,2584]

##########
#  Plot  1#
##########
fig = figure("multiaxis",figsize=(12,12))
# p = plot(L_head_1, H1, linestyle="-",color="blue",marker="o") # Plot a basic line
# p = plot(L_head_2, H2, linestyle="-",color="blue",marker="o") # Plot a basic line
ax = gca()
setp(ax.get_xticklabels(),color="black", size=14)
# PyPlot.title("Multi-axis Plot")
# p = plot([1,9],[3600,3600],color="red",linestyle="--",label="max rotational speed")
# p = plot([1,9],[2400,2400],color="green",linestyle="--",label="min rotational speed")
# p = plot(Pump_n, Speed_1, color="blue",marker="*",linestyle="-", label="producer 2 price: 295 \$/m3")
# p = plot(Pump_n, Speed_2, color="purple",marker="o",linestyle="--", label="producer 2 price: 300 \$/m3")
# p = plot(Pump_n, Speed_3, color="orange",marker="s",linestyle="-.", label="producer 2 price: 305 \$/m3")
# p = plot(Pump_n, Speed_4, color="black",marker="d",linestyle=":", label="producer 2 price: 310 \$/m3")

# p = plot([1,9],[0.87,0.87],color="red",linestyle="--",label="max efficiency")
# p = plot([1,9],[0.6,0.6],color="green",linestyle="--",label="min efficiency")
# p = plot(Pump_n, Eff_1, color="blue",marker="*",linestyle="-", label="producer 2 price: 295 \$/m3")
# p = plot(Pump_n, Eff_2, color="purple",marker="o",linestyle="--", label="producer 2 price: 300 \$/m3")
# p = plot(Pump_n, Eff_3, color="orange",marker="s",linestyle="-.", label="producer 2 price: 305 \$/m3")
# p = plot(Pump_n, Eff_4, color="black",marker="d",linestyle=":", label="producer 2 price: 310 \$/m3")

# p = plot([1,23],[740,740],color="red",linestyle="--",label="max head")
# p = plot([1,23],[30,30],color="green",linestyle="--",label="min head")
# p = plot(1:23, H_1, color="blue",marker="*",linestyle="-", label="producer 2 price: 295 \$/m3")
# p = plot(1:23, H_2, color="purple",marker="o",linestyle="--", label="producer 2 price: 300 \$/m3")
# p = plot(1:23, H_3, color="orange",marker="s",linestyle="-.", label="producer 2 price: 305 \$/m3")
# p = plot(1:23, H_4, color="black",marker="d",linestyle=":", label="producer 2 price: 310 \$/m3")

p = plot([1,13],[5000,5000],color="red",linestyle="--",label="max flow rate")
p = plot([1,13],[500,500],color="green",linestyle="--",label="min flow rate")
p = plot(1:13, Q_1, color="blue",marker="*",linestyle="-", label="producer 2 price: 295 \$/m3")
p = plot(1:13, Q_2, color="purple",marker="o",linestyle="--", label="producer 2 price: 300 \$/m3")
p = plot(1:13, Q_3, color="orange",marker="s",linestyle="-.", label="producer 2 price: 305 \$/m3")
p = plot(1:13, Q_4, color="black",marker="d",linestyle=":", label="producer 2 price: 310 \$/m3")


# xlabel("Node #", size=18)
# xlabel("Pump #", size=18)
xlabel("Pipe #", size=18)
font1 = Dict("color"=>"black")
# ylabel("Rotational speed, rpm",fontdict=font1, size=18)
# ylabel("Head, m",fontdict=font1, size=18)
ylabel("Flow rate, m3/h",fontdict=font1, size=18)
# ylabel("Pump efficiency",fontdict=font1, size=18)
setp(ax.get_yticklabels(),color="black", size=14) # Y Axis font formatting
ax.legend(loc=1)

################
#  Other Axes  #
################

new_position = [0.15;0.1;0.7;0.83]
ax.set_position(new_position) # Position Method 2: Change the size and position of the axis
#fig.subplots_adjust(right=0.85) # Position Method 1

ax2 = ax.twinx() # Create another axis on top of the current axis
font2 = Dict("color"=>"purple")
ylabel("Pump efficiency",fontdict=font2, size=18)
p = plot(Con_price,Power_term, color="purple",linestyle="-",marker="*") # Plot a basic line
ax2.set_position(new_position) # Position Method 2
setp(ax2.get_yticklabels(),color="purple", size=14) # Y Axis font formatting

axis("tight")

fig.canvas.draw() # Update the figure









# Economic and power term for different consumer/producer prices
using PyPlot


Pr_price = [280,285,290,295,300,305,310,315,320,325]
Economic_term_p = [99493.83158,88511.63764,77529.44369,66547.24976,55565.05601,49388.28672,47398.4983,45598.49698,43798.49662,41998.49645]
Power_term_p = [1521.907763,1521.907765,1521.90777,1521.907781,1521.907987,1790.240113,1797.501083,1797.501083,1797.501083,1797.501083]
Economic_term_c = [15609.47443,19209.47426,22809.47388,26409.47232,30880.52286,42090.40803,42090.40803,70426.81132,85288.56662,100150.3219]
Power_term_c = [1191.948085,1191.948085,1191.948085,1191.948085,1202.475934,1442.28754,1442.28754,1521.907992,1521.907996,1521.908]
##########
#  Plot  1#
##########
fig = figure("multiaxis",figsize=(10,10))
# p = plot(L_head_1, H1, linestyle="-",color="blue",marker="o") # Plot a basic line
# p = plot(L_head_2, H2, linestyle="-",color="blue",marker="o") # Plot a basic line
ax = gca()
setp(ax.get_xticklabels(),color="black", size=14)

# PyPlot.title("Multi-axis Plot")

p = plot(Pr_price,Economic_term_p, color="blue",marker="*",linestyle="-")
# p = plot(Pr_price,Economic_term_c, color="blue",marker="*",linestyle="-")
# xlabel("Price of producer #N9(2), \$/m3", size=18)
xlabel("Price of consumer #N15(1), \$/m3", size=18)
font1 = Dict("color"=>"blue")
ylabel("Economic term, \$/h",fontdict=font1, size=18)
setp(ax.get_yticklabels(),color="blue", size=14) # Y Axis font formatting
ax.legend()
################
#  Other Axes  #
################
new_position = [0.15;0.1;0.7;0.83] # Position Method 2
ax.set_position(new_position) # Position Method 2: Change the size and position of the axis
#fig.subplots_adjust(right=0.85) # Position Method 1

ax2 = ax.twinx() # Create another axis on top of the current axis
font2 = Dict("color"=>"purple")
ylabel("Power term, \$/h",fontdict=font2, size=18)
# p = plot(Pr_price,Power_term_p, color="purple",linestyle="-.",marker="*") # Plot a basic line
p = plot(Pr_price,Power_term_c, color="purple",linestyle="-.",marker="*") # Plot a basic line
ax2.set_position(new_position) # Position Method 2
setp(ax2.get_yticklabels(),color="purple", size=14) # Y Axis font formatting

axis("tight")

fig.canvas.draw() # Update the figure
