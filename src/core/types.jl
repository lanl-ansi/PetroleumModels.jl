# TODO add references to different models docstrings

"LP models - Leibenzon Physics"
abstract type AbstractBPModel <: AbstractPetroleumModel end


"LP Model Type - Leibenzon Physics"
mutable struct LPPetroleumModel <: AbstractBPModel @pm_fields end
