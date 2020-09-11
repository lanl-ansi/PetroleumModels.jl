
    using InfrastructureModels
    const _IM = InfrastructureModels

    import InfrastructureModels: ids, ref, var, con, sol, nw_ids, nws, optimize_model!, @im_fields, ismultinetwork

    using JSON
    using JuMP
    using Memento
    using Printf
    using MathOptInterface

    using Dates
    using Dierckx

    const MOI = MathOptInterface
    const MOIU = MathOptInterface.Utilities

    # Create our module level logger (this will get precompiled)
    const _LOGGER = Memento.getlogger(@__MODULE__)

    # Register the module level logger at runtime so that folks can access the logger via `getlogger(PetroleumModels)`
    # NOTE: If this line is not included then the precompiled `PetroleumModels.LOGGER` won't be registered at runtime.
    __init__() = Memento.register(_LOGGER)

    "Suppresses information and warning messages output by PetroleumModels, for fine grained control use the Memento package"
    function silence()
        Memento.info(_LOGGER, "Suppressing information and warning messages for the rest of this session.  Use the Memento package for more fine-grained control of logging.")
        Memento.setlevel!(Memento.getlogger(InfrastructureModels), "error")
        Memento.setlevel!(Memento.getlogger(PetroleumModels), "error")
    end

    "alows the user to set the logging level without the need to add Memento"
    function logger_config!(level)
        Memento.config!(Memento.getlogger("PetroleumModels"), level)
    end


const _pm_global_keys = Set(["time_series_block", "per_unit", "nu", "base_h_loss", "rho", "gravitational_acceleration",
"baseH", "baseQ", "base_a", "base_z", "base_b", "base_length", "base_diameter", "base_rho", "base_nu"])
include("core/base.jl")
include("core/data.jl")
# include("core/types.jl")
include("core/constraint.jl")
include("core/constraint_template.jl")
include("core/objective.jl")
include("core/solution.jl")
include("core/variable.jl")
include("core/common.jl")
include("io/grail.jl")
include("core/misocp.jl")

include("io/matl.jl")

include("prob/ls.jl")
