"""
`parse_row`

take one string coming from bonsai tracking.csv file and parse it in columns changing the types
"""
function parse_row(r::String)
    splitted = split(r," ")[1:end-1]
    stim = [occursin("ue",splitted[1])]
    x = [parse(Float64,splitted[2])]
    y = [parse(Float64,splitted[3])]
    time = [parse(Float64,splitted[4])]
    ongoing = table((Stim_vec = stim, X = x, Y = y, Time = time ))
end

"""
`parse_bonsai`
function with 2 methods
    method1 takes a bonsai tracking table and parse each row using parse_row(t)
    method2 load the table from a string
"""

function parse_bonsai(t::IndexedTable)
    r = select(t,1)[2]
    ongoing = parse_row(r)
    for i = 2:length(t)
        r = select(t,1)[i]
        prov = parse_row(r)
        ongoing = merge(ongoing,prov)
    end
    return ongoing
end

function parse_bonsai(pre_t::String)
    t = JuliaDB.loadtable(pre_t)
    parse_bonsai(t)
end

function parse_bonsai(row::NamedTuple)
    t = JuliaDB.loadtable(row.trk_file)
    parse_bonsai(t)
end
