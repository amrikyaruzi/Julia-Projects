read(run(`powershell cls`), String)

using TickTock
using Glob
using CSV
using XLSX
using DataFrames
using DataFramesMeta
using Chain
using RCall

"""time1 = time()
#tick()"""


month_abb = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
what_months = month_abb[1:3] # start from Jan to current end month
what_year = 2023

# Reading files in
path = "./Data/1. Raw data/2023/All/Before July 2023"

function read_csvs(path)
    files = glob("*.csv", path)
    dfs = DataFrame.(CSV.File.(files))

    for i in eachindex(dfs)
        dfs[i][!, :Sample] .= i # I called the new col sample
    end

    df = reduce(vcat, dfs)
    return df
end

@time df = read_csvs(path)

df[!, :Sample]


#tock()
"""time2 = time()
time2 - time1"""