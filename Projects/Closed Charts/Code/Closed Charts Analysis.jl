read(run(`powershell cls`), String)

using TickTock
using Glob
using CSV
using XLSX
using DataFrames
using DataFramesMeta
using Chain
using RCall



month_abb = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
what_months = month_abb[1:3] # start from Jan to current end month
what_year = 2023

# Reading files in
## All other departments
### Before July 2023
path = "./Data/1. Raw data/2023/All/Before July 2023"


"""
function readcsvs(path)
    files=glob("*.csv", path) #Vector of filenames. Glob allows you to use the asterisk.
    numfiles=length(files)    #Number of files to read.
    tempdfs=Vector{DataFrame}(undef, numfiles) #Create a vector of empty dataframes.
    for i in 1:numfiles
        tempdfs[i]=CSV.read(files[i]) #Read each CSV into its own dataframe.
    end
    masterdf=outerjoin(tempdfs..., on="Column In Common") #Join the temporary dataframes into one dataframe.
end
"""

function read_csvs(path)
    files = glob("*.csv", path)
    dfs = DataFrame.(CSV.File.(files))

    for i in eachindex(dfs)
        dfs[i][!, :Sample] .= i # I called the new col sample
    end

    df = reduce(vcat, dfs)
    #df = vcat(dfs...)
    return df
end


df = read_csvs(path)
# @time df = read_csvs(path)
# t1 = time(); t2 = time(), t2-t1

df[!, "Sample"]

select!(df, Not(["Sample"]))

"""
@chain df begin
    select(_, "Sample")
    unique(_, "Sample")
end
"""

println(names(df))
length(names(df))

for column in names(df)
    println("COLUMN: $column is of TYPE: $(eltype(df[!, column]))")
end

### July 2023 onwards
path2 = "./Data/1. Raw data/2023/All/July 2023 onwards/"
files2 = glob("*.xlsx", path2)

"""
dfs2 = Vector{DataFrame}(undef, length(files2))

for file in files2
    tempdf = DataFrame(XLSX.readtable(file, "sheet1"))
    #println(tempdf)
    push!(dfs2, tempdf)
end
"""

dfs2 = Vector{DataFrame}(undef, length(files2)) #Create a vector of empty dataframes.

for i in eachindex(files2)
    dfs2[i] = DataFrame(XLSX.readtable(files2[i], "sheet1"))
end

for i in eachindex(dfs2)
    rename!(dfs2[i], ["S.No", "MR.No",	"Visit/Adm No",	"Patient Name",	"Visit/Adm Date", "Consultant Code",
    "Consultant", "Department", "Ward Name", "Document Name", "Document Type",	"Doc SNN",
    "Documented",	"Timely",	"Legible",	"Complete",	"Accurate"])
end

dfs2 = vcat(dfs2...)

dfs2


"""
dfs_ = DataFrame.(XLSX.readtable.(files2, "sheet1"))
"""