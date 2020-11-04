""
function _IM.solution_preprocessor(pm::AbstractPetroleumModel, solution::Dict)
    solution["is_per_unit"]    = pm.data["is_per_unit"]
    solution["multinetwork"]   = ismultinetwork(pm.data)
    solution["base_head"]      = pm.ref[:base_head]
    solution["base_flow"]      = pm.ref[:base_flow]
    solution["base_length"]    = pm.ref[:base_length]
end
