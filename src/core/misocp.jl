# Define MISOCP implementations of Petroleum Models

export
    MISOCPPetroleumModel, StandardMISOCPForm

""
abstract type AbstractMISOCPForm <: AbstractPetroleumModel end

mutable struct MISOCPPetroleumModel <: AbstractMISOCPForm @pm_fields end# the standard MISCOP model

"default MISOCP constructor"
MISOCPPetroleumModel(data::Dict{String,Any}; kwargs...) = AbstractPetroleumModel(data, StandardMISOCPForm)

function variable_flow(pm::AbstractMISOCPForm, n::Int=pm.cnw; bounded::Bool=true)
variable_volume_flow(pm, n; bounded=bounded)
    variable_head(pm, n; bounded=bounded)
    variable_pump_rotation(pm, n; bounded=bounded)
    variable_pump_efficiency(pm, n; bounded=bounded)
    # variable_tank_in(pm, n; bounded=bounded)
    # variable_tank_out(pm, n; bounded=bounded)
     # variable_tank_volume(pm, n; bounded=bounded)
end
