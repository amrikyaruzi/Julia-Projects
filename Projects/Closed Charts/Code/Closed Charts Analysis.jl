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

## All departments except A&E
### Before July 2023
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


df = read_csvs(path)
df[!, "Sample"]
select!(df, Not(["Sample"]))


println(names(df))
length(names(df))

for column in names(df)
    if column in names(df)
        println("COLUMN: $column is of TYPE: $(eltype(df[!, column]))")
    else
        println("")
    end
end

### July 2023 onwards

path2 = "./Data/1. Raw data/2023/All/July 2023 onwards/"

function read_xlsxs_after_july2023(path)
    
    files2 = glob("*.xlsx", path)
    dfs2 = Vector{DataFrame}(undef, length(files2)) #Create a vector of empty dataframes.

    for i in eachindex(files2)
        dfs2[i] = DataFrame(XLSX.readtable(files2[i], "sheet1"))
        
        rename!(dfs2[i],
        ["S.No", "MR.No", "Visit/Adm No", "Patient Name", "Visit/Adm Date", "Consultant Code",
         "Consultant", "Department", "Ward Name", "Document Name", "Document Type",	"Doc SNN",
         "Documented", "Timely", "Legible",	"Complete",	"Accurate"])
    end

    dfs2 = vcat(dfs2...)    
end

@time df2 = read_xlsxs_after_july2023(path2)


for column in names(df2)
    println("Column: $column is of type $(eltype(df2[!, column]))")
end


## A&E
### Before July 2023

df_ae_bjuly2023 = DataFrame(XLSX.readtable("./Data/1. Raw data/2023/All/Before July 2023/A&E/Microsoft Forms/A&E Closed Charts Audit(1-392).xlsx", "Sheet1"))
select!(df_ae_bjuly2023, Not(Between("ID", "Name")))

"""
@chain df_ae_bjuly2023 begin
    stack(_, Between("1.1 - Physician Initial Assessment All components - P",
                      last(names(df_ae_bjuly2023))))
    
    select(_, Between("variable", last(names(_))))
end #variable = DOCUMENTS, value = Values
"""

df_ae_bjuly2023 = stack(df_ae_bjuly2023, Between("1.1 - Physician Initial Assessment All components - P",
                                         last(names(df_ae_bjuly2023))))

transform!(df_ae_bjuly2023, :value => ByRow(x -> ismissing(x) ? [missing] : string.(split(x, ";"))) => :value)
df_ae_bjuly2023 = flatten(df_ae_bjuly2023, "value")

# filter(row -> !(ismissing(row.value) || row.value == ""), df_ae_bjuly2023)

filter!(row -> !ismissing(row.value) && row.value != "", df_ae_bjuly2023)

"""
emergency_bj223 <- emergency_bj223 %>% separate_wider_delim(cols = Values, delim = "-", names = c("Values", "Responses"))

emergency_bj223 <- emergency_bj223 %>% separate_wider_delim(cols = DOCUMENTS,
                                                delim = " - ",
                                                names = c("SNN", "DOCUMENTS", "TYPE"))


emergency_bj223 <- emergency_bj223 %>%
  group_by(`PATIENT NAMES`, `MR Number`, Month, Year, DOCTOR, RMO, NURSE, SNN, DOCUMENTS, TYPE,
           Values) %>% filter(n() == 1) %>% ungroup()


### July 2023 onwards
"""