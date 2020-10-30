using Documenter, PetroleumModels

makedocs(
    modules = [PetroleumModels],
    format = Documenter.HTML(analytics = "UA-367975-10", mathengine = Documenter.MathJax()),
    sitename = "PetroleumModels",
    authors = "Elena Khlebnikova and contributors.",
    pages = [
        "Home" => "index.md",
        "Manual" => [
            "Getting Started" => "quickguide.md",
            "Input Data Formats" => "data-format.md",
            "Network Data Format" => "network-data.md",
            "Result Data Format" => "result-data.md",
            "Mathematical Model" => "math-model.md",
        ],
        "Library" => [
            "Network Formulations" => "formulations.md",
            "Steady State Specifications" => [
                "Problem Specifications" => "ss-specifications.md",
                "Objective" => "objective.md",
                "Variables" => "variables.md",
                "Constraints" => "constraints.md",
            ],
            "Transient Specifications" => "transient-specifications.md",
            "File IO" => "parser.md",
        ],
        "Developer" => "developer.md",
        "Examples" => "examples.md",
    ],
)

deploydocs(repo = "github.com/lanl-ansi/PetroleumModels.jl.git")
