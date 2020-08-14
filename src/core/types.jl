# TODO add references to different models docstrings
"MINLP models"
abstract type AbstractMINLPModel <: AbstractPetroleumModel end


"MIP models"
abstract type AbstractMIPModel <: AbstractPetroleumModel end


"MISOCP models"
abstract type AbstractMISOCPModel <: AbstractPetroleumModel end


"NLP models"
abstract type AbstractNLPModel <: AbstractPetroleumModel end


"LP models"
abstract type AbstractLPModel <: AbstractPetroleumModel end


"LP Model Type"
mutable struct LPPetroleumModel <: AbstractLPModel @pm_fields end


"MIP Model Type"
mutable struct MIPPetroleumModel <: AbstractMIPModel @pm_fields end


"NLP Model Type"
mutable struct NLPPetroleumModel <: AbstractNLPModel @pm_fields end


"MISOCP Model Type"
mutable struct MISOCPPetroleumModel <: AbstractMISOCPModel @pm_fields end


"MINLP Model Type"
mutable struct MINLPPetroleumModel <: AbstractMINLPModel @pm_fields end


"Union of MI Models"
AbstractMIModels = Union{AbstractMISOCPModel, AbstractMINLPModel}
