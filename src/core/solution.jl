""
function _IM.solution_preprocessor(pm::AbstractPetroleumModel, solution::Dict)
    solution["is_per_unit"]    = pm.data["is_per_unit"]
    solution["multinetwork"]   = ismultinetwork(pm.data)
    solution["base_head"]      = pm.ref[:base_head]
    solution["base_flow"]      = pm.ref[:base_flow]
    solution["base_elevation"] = pm.ref[:base_elevation]
    solution["base_length"]    = pm.ref[:base_length]
    solution["base_diameter"]  = pm.ref[:base_diameter]
    solution["base_density"]   = pm.ref[:base_density]
    solution["base_viscosity"] = pm.ref[:base_viscosity]
end
