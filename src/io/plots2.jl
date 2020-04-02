using PyPlot

###################
##  Create Data  ##
###################

x1 = [0, 153, 156.8, 288.8, 395.1, 431.1, 596.1, 599, 599.91, 683.11, 693.81, 780.8, 954.41, 968]
Q = [1329, 1329, 1329, 1329, 1329, 2161, 2161, 2161, 541, 541, 541, 3601, 3601, 541]

x2 = [0, 0, 0, 153, 153, 156.8, 288.8, 288.8, 395.1, 431.1, 431.1, 596.1, 596.1, 596.1, 599, 599.91, 683.11, 693.81, 780.8, 780.8, 954.41, 954.41, 968]
H = [190, 355, 519, 375, 539, 628, 456, 621, 621, 579, 723, 418, 562, 706, 739, 740, 740, 738, 325, 528, 30, 174, 220]

x_H_Q   = [0, 968]
H_max = [740, 740]
H_min = [30, 30]

Q_max = [5000, 5000]
Q_min = [500, 500]

Z = [273, 273, 273, 293, 293, 201, 266, 266, 180, 153, 153, 146, 146, 146, 107, 106, 92, 92, 202, 202, 95, 95, 2]
##########
#  Plot  #
##########
fig = figure("multiaxis",figsize=(12,12))
p = plot(x1,Q,linestyle="-",marker="o",label="First") # Plot a basic line
ax = gca()
# PyPlot.title("Multi-axis Plot")
p = plot(x_H_Q,Q_max,color="red",linestyle="--",label="max flow rate")
p = plot(x_H_Q,Q_min,color="green",linestyle="--",label="min flow rate")

xlabel("Pipeline length, km")
font1 = Dict("color"=>"blue")
ylabel("Flow rate, m3/h",fontdict=font1)
setp(ax.get_yticklabels(),color="blue") # Y Axis font formatting

################
#  Other Axes  #
################
new_position = [0.06;0.06;0.67;0.81] # Position Method 2
ax.set_position(new_position) # Position Method 2: Change the size and position of the axis
#fig.subplots_adjust(right=0.85) # Position Method 1

ax2 = ax.twinx() # Create another axis on top of the current axis
font2 = Dict("color"=>"purple")
ylabel("Head in the system, m",fontdict=font2)
p = plot(x2,H,color="purple",linestyle="-",marker="o",label="Second") # Plot a basic line
ax2.set_position(new_position) # Position Method 2
setp(ax2.get_yticklabels(),color="purple") # Y Axis font formatting

p = plot(x_H_Q,H_max,color="red",linestyle="--",label="max head")
p = plot(x_H_Q,H_min,color="red",linestyle="--",label="min head")




ax3 = ax.twinx() # Create another axis on top of the current axis
ax3.spines["right"].set_position(("axes",1.12)) # Offset the y-axis label from the axis itself so it doesn't overlap the second axis
font3 = Dict("color"=>"green")
ylabel("Elevation, m",fontdict=font3)
p = plot(x2,Z,color="green",linestyle="--",marker="*",label="elevation") # Plot a basic line
ax3.set_position(new_position) # Position Method 2
setp(ax.get_yticklabels(),color="green") # Y Axis font formatting

axis("tight")

# Enable just the right part of the frame
ax3.set_frame_on(true) # Make the entire frame visible
ax3.patch.set_visible(false) # Make the patch (background) invisible so it doesn't cover up the other axes' plots
ax3.spines["top"].set_visible(false) # Hide the top edge of the axis
ax3.spines["bottom"].set_visible(false) # Hide the bottom edge of the axis

fig.canvas.draw() # Update the figure
