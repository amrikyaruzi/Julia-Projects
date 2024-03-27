using Pkg;

Pkg.add(
    ["Cascadia", "DataFrames", "DataFramesMeta", "GLM", "Gumbo", "HTTP", "JSON", "Tidier",
    "UrlDownload", "CSV", "IJulia", "Conda", "Distributions", "StatsBase", "Pipe", "Chain",
    "TidierVest", "Printf", "ToolipsCrawl", "PrettyTables", "XLSX", "ToolipsCrawl", "Format",
    "RCall", "TickTock", "Glob"]
    )

pkg"add https://www.github.com/bicycle1885/Fmt.jl"

#julia --project

Pkg.status()

using IJulia
notebook(dir = pwd())
#notebook(dir = "E:/Documents/Work/Projects/0. Important Installs")

#import Pkg; Pkg.add("juliaup")
#using juliaup
#juliaup update