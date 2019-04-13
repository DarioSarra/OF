function ghosts_finder(trk::IndexedTable)
    times = select(trk,:Time_sec)
    ins = find_events(select(trk,:Stim_vec), :in)
    next_ins = ins[2:end]
    outs = find_events(select(trk,:Stim_vec), :out)[1:end-1]
    delta =  times[next_ins] - times[outs]
    intervals = table((outs = outs, next_ins = next_ins, out_to_in = delta))
    ghosts = @filter intervals :out_to_in < 2
end

function ghosts_buster(trk)
    stim_vec = select(trk,:Stim_vec)
    ghosts = ghosts_finder(trk)
    for idx = 1:length(ghosts)
        start = select(ghosts,:outs)[idx]
        stop = select(ghosts,:next_ins)[idx]
        select(trk,:Stim_vec)[start:stop] .= true
    end
    return trk
end
