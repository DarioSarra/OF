function combine_sessions(DataIndex)
    r = DataIndex[1]
    ongoing = combine_BhvTrk(r)
    for i = 2:length(DataIndex)
        r = DataIndex[i]
        try
            provisory = combine_BhvTrk(r)
            append!(rows(ongoing), rows(provisory))
        catch ex
            #@warn("Session not processed: DataIndex $i")
            println("Session not processed: DataIndex $i")
            show(ex)
            continue
        end
    end
    findoffset(row) = OffsetArray(row.Range, -row.In+first(row.Range))
    ongoing = setcol(ongoing, :Offsets => map(findoffset, ongoing))
    return ongoing
end
