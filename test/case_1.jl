using PyPlot

###################
##  Create Data  ##
###################



z = [273, 273, 273, 293, 293, 201, 266, 266, 180, 153, 153, 146, 146, 146, 107, 106, 92, 92, 202, 202, 95, 95, 2] #elevation, m
L = [0, 0, 0, 153, 153, 156.8, 288.8, 288.8, 395.1, 431.1, 431.1, 596.1, 596.1, 596.1, 599, 599.91, 683.11, 693.81, 780.8, 780.8, 954.41, 954.41, 968]  #length, m
L2 = [0, 153, 156.8, 288.8, 395.1, 431.1, 596.1, 599, 599.91, 683.11, 693.81, 780.8, 954.41, 968]  #length, m

node = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 19, 20, 21, 22, 23]  #length, m
L_head = [0, 0, 0, 100, 280, 280, 430]  #length, m
H = [190,359,527,416,585,675,532,700,724,596,740,38,253,468,494,495,497,495,165,363,30,174,232]
Q = [1109,1109,1109,1109,1109,3449,3449,3449,500,500,500,2552,2552,2552]

pump_id = [1, 2, 3, 4, 5, 6, 7, 8, 9]
eta = [0.73521691,0.73521691,0.735218018,0.735218018,0.868238719,0.863730319,0.86373051,0.828762666,0.861380511]
omega = [2400.009388,2400.009388,2400.005631,2400.005631,2725.420776,3118.962078,3118.958625,2821.469352,2487.178049]
H_max = [740, 740]
H_min = [30, 30]


##########
#  Plot  1#
##########
fig = figure("multiaxis",figsize=(20,6))
p = plot(L, H, linestyle="-",color="blue",marker="o") # Plot a basic line
ax = gca()
# PyPlot.title("Multi-axis Plot")
p = plot([0,968],H_max,color="red",linestyle="--",label="max head")
p = plot([0,968],H_min,color="green",linestyle="--",label="min head")

xlabel("Pipeline length, km")
font1 = Dict("color"=>"blue")
ylabel("Head, m",fontdict=font1)
setp(ax.get_yticklabels(),color="blue") # Y Axis font formatting
ax.legend()
################
#  Other Axes  #
################
new_position = [0.08;0.08;0.67;0.81] # Position Method 2
ax.set_position(new_position) # Position Method 2: Change the size and position of the axis
#fig.subplots_adjust(right=0.85) # Position Method 1

ax2 = ax.twinx() # Create another axis on top of the current axis
font2 = Dict("color"=>"purple")
ylabel("Elevation, m",fontdict=font2)
p = plot(L,z,color="purple",linestyle=":",marker="*",label="elevation") # Plot a basic line
ax2.set_position(new_position) # Position Method 2
setp(ax2.get_yticklabels(),color="purple") # Y Axis font formatting


ax3 = ax.twinx() # Create another axis on top of the current axis
ax3.spines["right"].set_position(("axes",1.12)) # Offset the y-axis label from the axis itself so it doesn't overlap the second axis
font3 = Dict("color"=>"black")
ylabel("Flow rate, m3/h",fontdict=font3)
p = plot(L2,Q,color="black",linestyle="-.",marker="s",label="flow rate") # Plot a basic line
ax3.set_position(new_position) # Position Method 2
# setp(ax.get_yticklabels(),color="black") # Y Axis font formatting

axis("tight")

# Enable just the right part of the frame
ax3.set_frame_on(true) # Make the entire frame visible
ax3.patch.set_visible(false) # Make the patch (background) invisible so it doesn't cover up the other axes' plots
ax3.spines["top"].set_visible(false) # Hide the top edge of the axis
ax3.spines["bottom"].set_visible(false) # Hide the bottom edge of the axis

fig.canvas.draw() # Update the figure
