"""
`parse_bonsai`
load the table from a string
"""
function parse_bonsai(pre_t::AbstractString)
    df = CSV.read(pre_t, delim = ' ', allowmissing = :auto, truestrings = ["True"], falsestrings = ["False"])
    t = table(df)
    renamecol(t, 1 => :Stim_vec, 2 => :X, 3 => :Y, 4 => :Time, 5 => :Area)
end

parse_bonsai(row::NamedTuple) = parse_bonsai(row.trk_file)
