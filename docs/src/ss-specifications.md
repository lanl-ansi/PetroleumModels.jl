# Steady State Problem Specifications

## Optimal Petroleum Flow (OPF)

### Variables
```julia
variable_head(pm)
variable_volume_flow_pipe(pm)
variable_volume_flow_pump(pm)
variable_pump_rotation(pm)
variable_pump_efficiency(pm)
variable_production_volume_flow(pm)
variable_demand_volume_flow(pm)
variable_tank_intake(pm)
variable_tank_offtake(pm)
```

### Objective

```julia
objective_min_expenses_max_benefit(pm)
```

### Constraints
```julia
for i in ids(pm, :pipe)
    constraint_leibenzon(pm, i)
end

for i in ids(pm, :pump)
    constraint_pump_head_difference_bounds(pm, i)
    constraint_pump_efficiency(pm, i)
    constraint_pump_head_difference(pm,i)
end

for i in ids(pm, :junction)
    constraint_junction_volume_flow_balance(pm, i)
end
```
