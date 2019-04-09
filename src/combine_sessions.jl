function combine_sessions(DataIndex)
    r = select(DataIndex,(:bhv_file,:trk_file))[1]
    ongoing = combine_BhvTrk(r)
    for i = 2:length(DataIndex)
        r = select(DataIndex,(:bhv_file,:trk_file))[i]
        try
            provisory = combine_BhvTrk(r)
            ongoing = merge(ongoing,provisory)
        catch
            #@warn("Session not processed: DataIndex $i")
            println("Session not processed: DataIndex $i")
            continue
        end
    end
    return ongoing
end
