"""
`gen`

look for a list of genotypes from the MouseID
"""
function gen(str; dir = joinpath(dirname(@__DIR__), "genotypes"))
    genotype = "missing"
    for file in readdir(dir)
        if endswith(file, ".csv")
            # df = FileIO.load(joinpath(dir, file)) |> DataFrame
            df = open(joinpath(dir, file)) do x
                readlines(x)
            end
            n = df[1]
            if str in df
                genotype = string(n)
            end
        end
    end
    genotype
end
