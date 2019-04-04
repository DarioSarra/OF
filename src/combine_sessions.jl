function combine_sessions(DataIndex)
    r = select(DataIndex,(:bhv_file,:trk_file))[1]
    ongoing = combine_BhvTrk(r)
    for i = 2:length(DataIndex)
        r = select(DataIndex,(:bhv_file,:trk_file))[i]
        provisory = combine_BhvTrk(r)
        ongoing = merge(ongoing,provisory)
    end
    return ongoing
end
