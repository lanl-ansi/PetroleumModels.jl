# TODO add references to different models docstrings

"BP models"
abstract type AbstractBPModel <: AbstractPetroleumModel end


"BP Model Type"
mutable struct BPPetroleumModel <: AbstractBPModel @pm_fields end
