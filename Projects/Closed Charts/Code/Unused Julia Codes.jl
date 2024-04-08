# @time df = read_csvs(path)
# t1 = time(); t2 = time(), t2-t1




"""
function read_xlsxs_after_july2023_multithreaded(path)
    
    files = glob("*.xlsx", path)
    dfs = Vector{DataFrame}(undef, length(files)) #Create a vector of empty dataframes.

    Threads.@threads for i in eachindex(files)
        dfs[i] = DataFrame(XLSX.readtable(files[i], "sheet1"))
        
        rename!(dfs[i],
        ["S.No", "MR.No", "Visit/Adm No", "Patient Name", "Visit/Adm Date", "Consultant Code",
         "Consultant", "Department", "Ward Name", "Document Name", "Document Type",	"Doc SNN",
         "Documented", "Timely", "Legible",	"Complete",	"Accurate"])
    end

    dfs = vcat(dfs...)    
end

@time df2 = read_xlsxs_after_july2023_multithreaded(path2)
"""


"""
# Asynchronous using asyncmap

files = glob("*.xlsx", path2)
dfs = Vector{DataFrame}(undef, length(files))


function read_xlsxs_after_july2023_async(file)
    
    df = DataFrame(XLSX.readtable(file, "sheet1"))
    rename!(df,
            ["S.No", "MR.No", "Visit/Adm No", "Patient Name", "Visit/Adm Date", "Consultant Code",
             "Consultant", "Department", "Ward Name", "Document Name", "Document Type",	"Doc SNN",
             "Documented", "Timely", "Legible",	"Complete",	"Accurate"])
    return df

end


@time data = asyncmap(files; ntasks = 100) do file
        data = read_xlsxs_after_july2023_async(file)
        return data
end |> (x -> dfs .= x)
"""


