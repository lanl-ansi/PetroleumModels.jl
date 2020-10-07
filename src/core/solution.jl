function _IM.solution_preprocessor(pm::AbstractPetroleumModel, solution::Dict)

    solution["is_per_unit"] = pm.data["is_per_unit"]
    solution["multinetwork"] = ismultinetwork(pm.data)
    solution["baseH"] = pm.ref[:baseH]
    solution["baseQ"] = pm.ref[:baseQ]
    solution["base_z"] = pm.ref[:base_z]
    solution["base_a"] = pm.ref[:base_a]
    solution["base_b"] = pm.ref[:base_b]
    solution["base_length"] = pm.ref[:base_length]
    solution["base_diameter"] = pm.ref[:base_diameter]
    solution["base_rho"] = pm.ref[:base_rho]
    solution["base_nu"] = pm.ref[:base_nu]

end
