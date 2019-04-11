function combine_sessions(DataIndex)
    r = select(DataIndex,(:bhv_file,:trk_file))[1]
    ongoing = combine_BhvTrk(r)
    for i = 2:length(DataIndex)
        r = select(DataIndex,(:bhv_file,:trk_file))[i]
        try
            provisory = combine_BhvTrk(r)
            ongoing = append!(rows(ongoing), rows(provisory))
        catch
            #@warn("Session not processed: DataIndex $i")
            println("Session not processed: DataIndex $i")
            continue
        end
    end
    findoffset(row) = OffsetArray(row.Range, -row.In+first(row.Range))
    ongoing = setcol(ongoing, :Offsets => map(findoffset, ongoing))
    return ongoing
end
