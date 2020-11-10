# The PetroleumModels Mathematical Model

As PetroleumModels implements a variety of petroleum network optimization problems, the implementation is the best reference for precise mathematical formulations.  This section provides a mathematical specification for a prototypical Petroleum Optimal Flow problem, to provide an overview of the typical mathematical models in PetroleumModels.


## Steady State Petroleum Flow

PetroleumModels implements a steady-state model of petroleum flow based on the Bernoulli equations using the Leibenzon relationship
that is based on the 1-D hydrodynamic equations for petroleum gas flow in a pipe. In the following paragraphs, a derivation of the steady state equations used in PetroleumModels is shown. To that end, we first assume that the flow is steady. Given this assumption, the mechanical energy conservation equation for the flow of petroleum in a pipe is given by

```math
\frac{d p}{\rho} + \lambda \frac{dx}{D}\frac{u^2}{2} + d \frac{u^2}{2} + gdz = 0.
```

where $\rho$ is pressure, $\lambda$ is the hydraulic resistance, $u$ is the flow velocity, and $D$ is the diameter of the pipe.
Because the fluid is weakly compressible and homogeneous, $\rho$ is roughly constant and $d p/d x = 0$. Since the pipe diameter is constant, the velocity, $u(x)$, of the fluid is also constant throughout the pipe. In the steady-state equation, the value of $d p/\rho$ represents the work of a unit of mass of fluid moving along the area $dx$. This work overcomes the resistive frictional forces of turbulence, the change in fluid kinetic energy, and the lifting of fluid over a height difference, $\Delta z$. After integrating the equation of mechanical energy conservation
along the length of the pipe, $L$, the relationship between endpoint pressure variables $p(0)$ and $p(L)$ and the flow velocity $u$ is given by

```math
\frac{p(0) - p(L)}{\rho g} &= \lambda \frac{L}{D}\frac{{u}^{2}}{2g}+\Delta z.
```

The values $h(0)\equiv p(0)/(\rho g)$ and $h(L)\equiv p(L)/(\rho g)$ denote the heights the liquid is lifted to under the pressures $p(0)$ and $p(L)$ at either end of the pipe. The value $h$ is referred to as head.  A general equation that is used to determine the coefficient of hydraulic resistance $\lambda$ is given as follows:

```math
\lambda = \frac{A}{Re^m},
```

where $A$ is the cross-sectional area of the pipe and $m$ is a Reynolds constant corresponding to the fluid motion regime. Using $Re = 4q/(\pi D \nu)$, where $q$ is the volumetric flow rate and $\nu$ is the petroleum kinematic viscosity, we Leibenzon formula is obtained [1]

```math
1.02  \beta \frac{q^{2-m} \nu^m} {D^{5-m}}
```

For turbulent flow in smooth pipes, parameters of $m$ = 0.25 and $\beta$ = 0.0246$ (friction factor) is often used. However, the parameter $m$ can be adjusted to reflect the laminarization effects of anti-turbulent drag reduction additives that are widely used to facilitate petroleum transport. Given these relationships the total head loss between the ends, $(i,j)$,, of a pipe is equal to the sum of losses caused by friction and the head difference arising from pipeline elevation.

```math
h_i - h_j = z_j - z_i + 1.02 \beta_{ij} \frac{q_{ij}^{2-m} \nu^m} {D_{ij}^{5-m}} L_{ij}   
```
where $z$ is the elevation of the pipe on either end.


To create a better numerically conditioned problem, it is very useful to non-dimensionalize the units. Here we use a typical head $h_0$ and a typical volumetric flow $q_0$ and normalize the equations. This yields

```math
  \tilde{h}_i - \tilde{h}_j = \tilde{z}_j - \tilde{z}_i + 1.02 \beta_{ij} \frac{\tilde{q}_{ij}^{2-m} \nu^m} {D_{ij}^{5-m}} L_{ij * \frac{q_0}{p_0}}
```

where $\tilde{q}=\frac{q}{f_q}$ and $\tilde{h}=\frac{h}{h_0}$ are the dimensionless volumetric flow and head, respectively, and are both of order one. While not strictly necessary in steady-state formulations, length, $L$, can also be made non dimensional in a similar way and is often useful for transient modeling. For notational convenience, the non-dimensionalization constants and pipeline constants (diameter, length, etc.) can be lumped as a single constant *resistance*, $\gamma=\frac{1.02 \beta \nu^m L q_0}{D^{5-m} h_0}$ yielding a non dimensional equation of the form

```math
  \tilde{h}_i - \tilde{h}_j = \tilde{z}_j - \tilde{z}_i + \gamma_{ij} \tilde{q}_{ij}^{2-m}
```

## Steady State Pump Flow


In liquid pipeline transportation, the flow of the commodity through the system is managed by pumping machinery, which is located at pumping stations throughout the system.
PetroleumModels uses a simple relationships between a minimal set of physical and mechanical variables that describe the relationship between rotation frequency, pump efficiency, and flow.
The dependence of pump efficiency on flow at nominal rotational speed is modeled by a pump-specific characteristic curve $\eta = f(Q)$. This curve is often approximated analytically
using the quadratic function

```math
\eta^{pump} = b_0+b_1 q+b_2 q^2,
```
where $b_0$, $b_1$, and $b_2$ are approximation coefficients obtained by the least squares method and $q$ is the flow rate through the pump. We use affinity Laws to define the pump efficiency. The values of the actual and nominal flow rates $q$ and $q^{nom}$ and heads $h$ and $h^{nom}$ when operating at actual and nominal rotational pump speeds $\omega$ and $\omega^{nom}$, respectively, are related by the ratios

```math
\begin{align}
\frac{q}{q^{nom}} &= \frac{\omega}{\omega^{nom}} \\
\frac{h}{h^{nom}} &= \left(\frac{\omega}{\omega^{nom}}\right)^2
\end{align}
```

Thus, pump efficiency as a function of rotational speed is then written as

```math
\eta^{pump} &= b_0+b_1\frac{q^{nom}}{\omega^{nom}}\omega+b_2\left( \frac{q^{nom}}{\omega^{nom}}\right)^2\omega^2
```

The laws of affinity require the use of a nominal point on the curve to determine the new rotational speed.
PetroleumModels uses the equation given by [2] to provide an analytical relationship between actual and nominal rotational speeds $\omega$ and $\omega^{nom}$ and corresponding efficiencies
$\eta$ and $\eta^{nom}$:

```math
\eta &= 1 – (1 - \eta^{nom})\left(\frac{\omega^{nom}}{\omega}\right)^{0.1}.
```

Therefore, for large pumps the change in efficiency can be neglected if the frequency is within 33\% of its nominal value. However, this does not mean the pump will perform at the same efficiency when installed in the pipeline system, because the operating point is determined by the intersection of the pump curve with the system curve. Thus, we model the dependence of pump efficiency on flow at a constant speed using a second-degree polynomial [3]:

```math
\eta^{pump} = b_1 q^{nom}-b_2 (q^{nom})^2,
```

which is rewritten as

```math
\eta^{pump} = 2\frac{\eta^{nom}}{q^{nom}}q-\frac{\eta^{nom}}{(q^{nom})^2}q^2,
```

where $\eta^{nom} = b_1^2/(4b_2)$ and $q^{nom} = b_1/(2b_2)$. It follows that the dependence of efficiency on the actual flow rate can be approximated with

```math
\eta^{pump} = 2\frac{\eta^{nom}}{q^{nom}}q \frac{\omega^{nom}}{\omega}-\frac{\eta^{nom}}{(q^{nom})^2}q^2 \left(\frac{\omega^{nom}}{\omega}\right)^2.
```

This equation is transformed using the technique of completing the square to yield

```math
\eta^{pump} = \eta^{nom} - \left(q - q^{nom}\frac{\omega}{\omega^{nom}}\right)^2 \cdot \frac{\eta^{nom}}{(q^{nom})^2} \cdot \left(\frac{\omega^{nom}}{\omega}\right)^2.
```

Thus, by modulating the power applied to a pump $(i,j)\in \mathcal E_{p}$, it is possible to make the engine drive shaft rotational speed $\omega_{ij}$ lower or higher than a nominal value $\omega_{ij}^{nom}$. The relationship between the drive frequency, head difference, and through flow for a variable frequency drive pump can then be approximated by equations

```math
\begin{align}
h_{j} - h_i  = \alpha_{ij}^0 \left(\frac{\omega_{ij}}{\omega_{ij}^{nom}}\right)^2 - \alpha_{ij}^1 Q_{ij}^2\\
\eta_{ij}  = \eta_{ij}^{nom} - \left(\frac{q_{ij}}{q_{ij}^{nom}} - \frac{\omega_{ij}}{\omega_{ij}^{nom}}\right)^2 \eta_{ij}^{nom} \left(\frac{\omega_{ij}^{nom}}{\omega_{ij}}\right)^2
\end{align}
```

where $a_{ij}^0$ and $a_{ij}^1$ are constant parameters and  $q_{ij}^{nom}$, $\omega_{ij}^{nom}$, and $\eta_{ij}^{nom}$ are nominal values of flow rate, drive shaft frequency, and pumping efficiency, respectively.



## Steady State Mathematical Model


A complete petroleum flow mathematical model is the defined by

```math
\begin{aligned}
\text{sets:} \\
& N & \text{junctions} \\
& A^p & \text{pipes}  \\
& A^u & \text{pumps}  \\
& A = A^p \cup A^u & \text{edges }  \\
& P, P_i & \text{producers and producers at junction $i$}   \\
& C, C_i & \text{consumers and consumers at junction $i$}    \\
%
\text{data:} \\
& \gamma_a & \text{lumped resistance factor of pipeline $a$} \\
& ql_j & \text{consumption (mass flow) at consumer $j$} \\
& qg_j & \text{production (mass flow) at producer $j$} \\
& \underline{q}_a=1, \overline{q}_a & \text{limits on volumetric flow of edge $a$} \\
& \underline{\eta}_a=1, \overline{\eta}_a & \text{limits on efficiency of pump $a$} \\
& \underline{w}_a=1, \overline{w}_a & \text{limits on rotation of pump $a$} \\
& \underline{h}_i \ge 0,\overline{h}_i & \text{limits on head at node $i$} \\
& \underline{h}_a \ge 0,\overline{h}_a & \text{limits on head at pump $a$} \\
%
\text{variables:} \\
& h_i & \text{head at node $i$} \\
& q_a & \text{volumetric flow on edge $a$} \\
& \eta & \text{efficiency of pump $a$}\\
& w & \text{rotation speed of pump $a$}\\
%
\text{constraints:} \\
& (h_i - h_j) = z_j - z_i + {\gamma}_{a} q_a^{2-m} &\text{Hydraulic equation for pipe $a$} \\
&& \text{connected from junction $i$ to junction $j$}  \\
&\sum\limits_{a=a_{ij}\in A} q_{a} - \sum\limits_{a=a_{ji} \in A} q_{a} = \sum_{j \in P_i} qg_j- \sum_{j \in C_i} ql_j & \text{volumetric flow balance at junction $i$} \\
& \h_i - h_j = \alpha_{a}^0 \left(\frac{\omega_{a}}{\omega_{a}^{nom}}\right)^2 - \alpha_{a}^1 q_{ij}^2 & \text{head boost at pump $a$} \\
&& \text{connected from junction $i$ to junction $j$}  \\
&\eta_{a}  = \eta_{a}^{nom} - \left(\frac{q_{a}}{Q_{a}^{nom}} - \frac{\omega_{a}}{\omega_{a}^{nom}}\right)^2 \eta_{a}^{nom} \left(\frac{\omega_{a}^{nom}}{\omega_{a}}\right)^2 & \text{efficiency of pump $q$} \\
&& \text{connected from junction $i$ to junction $j$}  \\
&\underline{{h}}_i \leq h_i \leq \overline{h}_i & \text{head limits at junction $i$} \\
&\underline{{\omega}}_a \leq \omega_a \leq \overline{\omega}_a & \text{rotation limits at pump $a$} \\
&\underline{{\eta}}_a \leq \eta_a \leq \overline{\eta}_a & \text{efficiency limits at pump $a$} \\
&\underline{{h}}_a \leq h_j - h_i \leq \overline{h}_a & \text{head difference limits at pump $a$} \\
&& \text{connected from junction $i$ to junction $j$}  \\
&\underline{{q}}_a \leq q_a \leq \overline{q}_a & \text{flow limits at edge $a$} \\
\end{aligned}
```

most of the optimization models of PetroleumModels are variations of this formulation.

SI Units for various parameters

| Parameter     | Description                | SI Units |
| ------------- |:--------------------------:| --------:|
| $D$           | Pipe Diameter              | m        |
| $L$           | Pipe Length                | m        |
| $A$           | Pipe Area Cross Section    | m^2      |
| $h$           | Petroleum Head             | m        |
| $\rho$        | Petroleum Density          | kg/m^3   |
| $q$           | Petroleum Volumetric Flow  | m^3/s    |
| $\eta$        | Pump efficiency            | none     |
| $\omega$      | Pump rotation              | rotations per second  |
| $\nu$         | Petroleum Viscosity        | m^2/s    |
| $g$           | Gravity                    | m/s^2    |


[1] Y. Kuzminskii, S. Shilko, V. Vyun. Mathematical modeling of effect of the anti-turbulent additives on flow rate of oil-pipeline section. Journal of Friction and Wear, 25(3):7–12, 2004.

[2] I. Sárbu, I. Borza. Energetic optimization of water pumping in distribution systems. Periodica Polytechnica Mechanical Engineering, 42(2):141–152, 1998.

[3] V. Grishin, A. Grishin. The efficiency of frequency-regulated electric pump. Automation and Informatization of electrified agricultural production. Scientific papers (inRussian). 89:118–127, 2004.
