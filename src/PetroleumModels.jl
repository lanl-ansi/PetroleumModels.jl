using JSON
using JuMP
using InfrastructureModels
using Compat
using Memento

# Create our module level logger (this will get precompiled)
const LOGGER = getlogger(@__MODULE__)

# Register the module level logger at runtime so that folks can access the logger via `getlogger(PetroleumModels)`
# NOTE: If this line is not included then the precompiled `PetroleumModels.LOGGER` won't be registered at runtime.
__init__() = Memento.register(LOGGER)

"Suppresses information and warning messages output by PetroleumModels, for fine grained control use the Memento package"
function silence()
    info(LOGGER, "Suppressing information and warning messages for the rest of this session.  Use the Memento package for more fine-grained control of logging.")
    setlevel!(getlogger(InfrastructureModels), "error")
    setlevel!(getlogger(PetroleumModels), "error")
end
import MathOptInterface
const MOI = MathOptInterface
const MOIU = MathOptInterface.Utilities

const _pm_global_keys = Set(["time_series_block", "per_unit", "nu", "base_h_loss", "rho", "gravitational_acceleration",
"baseH", "baseQ", "base_a", "base_z", "base_b"])

include("core/data.jl")
include("core/base.jl")
include("core/constraint.jl")
include("core/constraint_template.jl")
include("core/objective.jl")
include("core/solution.jl")
include("core/variable.jl")
include("core/common.jl")
# include("core/type.jl")
include("core/misocp.jl")

include("io/matl.jl")

include("prob/ls.jl")
