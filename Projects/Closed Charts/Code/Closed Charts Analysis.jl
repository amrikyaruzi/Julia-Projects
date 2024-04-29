read(run(`powershell cls`), String)

using TickTock
using Glob
using CSV
using XLSX
using DataFrames
using DataFramesMeta
using Missings
using Chain
using RCall



month_abb = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
what_months = month_abb[1:3] # start from Jan to current end month
what_year = 2023

# Reading files in
tick()
## All departments except A&E
### Before July 2023
path = "./Data/1. Raw data/2023/All/Before July 2023"

dfs = [CSV.read(file, DataFrame) for file in glob("*.csv", path)]
vcat(dfs...)

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

tock()
# length(names(df))


#for column in names(df)
#    if column in names(df)
#        println("COLUMN: $column is of TYPE: $(eltype(df[!, column]))")
#    else
#        println("");
#    end
#end


### July 2023 onwards

path2 = "./Data/1. Raw data/2023/All/July 2023 onwards/"


tick()

function read_xlsxs_after_july2023(path2)
    
    dfs2 = [DataFrame(XLSX.readtable(file, "sheet1")) for file in glob("*.xlsx", path2)]

    for i in eachindex(dfs2)
        rename!(dfs2[i],
        ["S.No", "MR.No", "Visit/Adm No", "Patient Name", "Visit/Adm Date", "Consultant Code",
        "Consultant", "Department", "Ward Name", "Document Name", "Document Type",	"Doc SNN",
        "Documented", "Timely", "Legible",	"Complete",	"Accurate"])
    end
    vcat(dfs2...)
end

read_xlsxs_after_july2023(path2)

tock()


"""
tick()
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

df2 = read_xlsxs_after_july2023(path2)
tock()
"""


## A&E
### Before July 2023

ae_bjuly23 = DataFrame(XLSX.readtable("./Data/1. Raw data/2023/All/Before July 2023/A&E/Microsoft Forms/A&E Closed Charts Audit(1-392).xlsx", "Sheet1"))
select!(ae_bjuly23, Not(Between("ID", "Name")))


ae_bjuly23 = stack(ae_bjuly23, Between("1.1 - Physician Initial Assessment All components - P",
                                         last(names(ae_bjuly23))))

"""
transform!(ae_bjuly23, :value => ByRow(passmissing(x -> string.(split(x, ";")))) => :value)
transform!(ae_bjuly23, :value => ByRow(passmissing(x -> flatten.(x))) => :value)
"""


transform!(ae_bjuly23, :value => ByRow(x -> ismissing(x) ? [missing] : string.(split(x, ";"))) => :value)
ae_bjuly23 = flatten(ae_bjuly23, "value")


dropmissing!(ae_bjuly23, "value")
filter!(row -> !(ismissing(row.value) || row.value == ""), ae_bjuly23)

# filter!(row -> !ismissing(row.value) && row.value != "", ae_bjuly23)

transform!(ae_bjuly23, "value" => ByRow(x -> ismissing(x) ? [missing, missing] : split(x, "-")) => ["value", "Responses"])
ae_bjuly23."variable" = replace.(ae_bjuly23."variable", Ref("2.2 - Nursing Re-Assessment (MEWS, PEWS & MEOWS) - N" => "2.2 - Nursing Re_Assessment (MEWS, PEWS & MEOWS) - N"))

transform!(ae_bjuly23, "variable" => ByRow(x -> split(x, "-"#, limit = 3
                                        )) => ["SNN", "DOCUMENTS", "TYPE"])

ae_bjuly23."DOCUMENTS" = replace.(ae_bjuly23."DOCUMENTS", Ref(" Nursing Re_Assessment (MEWS, PEWS & MEOWS) " => " Nursing Re-Assessment (MEWS, PEWS & MEOWS) "))


ae_bjuly23 = @chain ae_bjuly23 begin
    groupby(_,["PATIENT NAMES", "MR Number", "Month", "Year", "DOCTOR", "RMO",
               "NURSE", "SNN", "DOCUMENTS", "TYPE", "value"])
    filter(g -> nrow(g) == 1, _)
    DataFrame(_)
end


# SNN, TYPE
select!(ae_bjuly23, Not("variable"))
ae_bjuly23 = unstack(ae_bjuly23, "value", "Responses")

@chain ae_bjuly23 begin
    transform!(_, :Year => ByRow(x -> parse(Int, x)) => :Year)
    transform!(_, :SNN => ByRow(x -> parse(Float64, x)) => :SNN)
end

rename!(ae_bjuly23, [strip(name) for name in names(ae_bjuly23)])

transform!(ae_bjuly23, Between("DOCUMENTS", "COMPLETE") .=> ByRow(x -> ismissing(x) ? missing :  strip.(x)), renamecols = false)

# @time rename!(ae_bjuly23, Dict(name => strip(name) for name in names(ae_bjuly23)))


ae_bjuly23 = transform(ae_bjuly23) do df
    transform(df) do row
        if row.DOCUMENTED == "ND" &&
                !((row.Year == 2022 && row.Month in ["October", "November", "December"]) ||
                (row.Year == 2023 && row.Month in ["January", "February", "March"]))
            for col in ["TIMELY", "LEGIBLE", "COMPLETE"]
                row[col] = "-"
            end
        end
        return row
    end
end


"""
for item in unique(ae_bjuly23.DOCUMENTS)
    println(item)
end
"""

transform!(ae_bjuly23) do df
    # Convert "NA" strings to missing values across columns DOCUMENTED to COMPLETE
    cols1 = names(df, Between("DOCUMENTED", "COMPLETE"))
    for col in cols1
        df[!, col] .= ifelse.(ismissing.(df[!, col]) .| (df[!, col] .== "NA"), missing, df[!, col])
    end

    # Convert "" strings to missing values in the RMO and NURSE columns
    cols2 = ["RMO", "NURSE"]
    for col in cols2
        df[!, col] .= ifelse.(ismissing.(df[!, col]) .| (df[!, col] .== ""), missing, df[!, col])
    end

    # Convert PATIENT NAMES to upper case
    transform!(df, "PATIENT NAMES" => ByRow(x -> uppercase(x)) => "PATIENT NAMES")

end

# Printing unique values in those columns
for col in names(ae_bjuly23, Between("DOCUMENTED", "COMPLETE"))
    println(unique(ae_bjuly23[!, col]))
end


"""

#To take care of A&E's "D == 100%" performance in later iterations

ae_bjuly23 <- ae_bjuly23 %>% mutate(across(c(DOCUMENTED:COMPLETE), ~na_if(.x, "NA")),
                                  across(c(RMO, NURSE), ~na_if(.x, "")),
                                  `PATIENT NAMES` = str_to_upper(`PATIENT NAMES`))

ae_bjuly23 <- ae_bjuly23 %>% filter(!is.na(DOCUMENTED))

colnames(ae_bjuly23) <- c("PATIENT.NAMES", "MR.Number", "Month", "Year", "DOCTOR", "RMO", "NURSE",
                         "SNN", "DOCUMENTS", "TYPE", "DOCUMENTED", "TIMELY", "LEGIBLE", "COMPLETE")

ae_bjuly23 <- ae_bjuly23 %>% mutate(Quarter = case_when(Month %in% c("January", "February", "March") ~ "Q1",
                                                      Month %in% c("April", "May", "June") ~ "Q2",
                                                      Month %in% c("July", "August", "September") ~ "Q3",
                                                      Month %in% c("October", "November", "December") ~ "Q4"))

ae_bjuly23 <- ae_bjuly23 %>% filter(DOCUMENTED %in% c("D", "ND"))

ae_bjuly23 <- ae_bjuly23 %>% mutate(DEPT = "A&E") %>%
  mutate(MET = case_when(
    
    DOCUMENTED %in% "D" & TIMELY %in% "Y" & LEGIBLE %in% "Y" & COMPLETE %in% "Y" ~ "M",
    TRUE ~ "NM")
    
  )

ae_bjuly23 <- ae_bjuly23 %>%
  select(MR.Number, Month, Year, Quarter, DOCTOR, DEPT, SNN, DOCUMENTS, TYPE, DOCUMENTED, TIMELY,
         LEGIBLE, COMPLETE, MET, RMO, NURSE) %>%
  rename(AKNO = MR.Number)




### July 2023 onwards
"""