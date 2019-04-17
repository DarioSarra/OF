"""
`ghosts_finder`

this  events incorrectly cut during the 3 second
"""

function ghosts_finder(trk::IndexedTable; thrs = 2)
    times = select(trk,:Time_sec)
    ins = find_events(select(trk,:Stim_vec), :in)
    next_ins = ins[2:end]
    outs = find_events(select(trk,:Stim_vec), :out)[1:end-1]
    delta =  times[next_ins] - times[outs]
    intervals = table((outs = outs, next_ins = next_ins, out_to_in = delta))
    ghosts = @filter intervals :out_to_in < thrs
end

function ghosts_buster(trk; thrs = 2)
    #stim_vec = select(trk,:Stim_vec)
    ghosts = ghosts_finder(trk; thrs = thrs)
    for idx = 1:length(ghosts)
        start = select(ghosts,:outs)[idx]
        stop = select(ghosts,:next_ins)[idx]
        select(trk,:Stim_vec)[start:stop] .= true
    end
    return trk
end

"""
`poltergeist_finder`

this are events in between 2 trial that occur with short over threshold events
"""

function poltergeist_finder(gb::IndexedTable; thrs = 0.6)
    ins = find_events(select(gb,:Stim_vec),:in)
    outs= find_events(select(gb,:Stim_vec),:out)
    dur = select(gb,:Time_sec)[outs].- select(gb,:Time_sec)[ins]
    intervals = table((ins = ins, outs = outs, dur = dur))
    poltergeists = @filter intervals :dur < thrs
end

function poltergeist_buster(gb; thrs = 0.6)
    poltergeists = poltergeist_finder(gb; thrs = thrs)
    for idx = 1:length(poltergeists)
        start = select(poltergeists,:ins)[idx]
        stop = select(poltergeists,:outs)[idx]
        select(gb,:Stim_vec)[start:stop] .= false
    end
    return gb
end


"""
`extra_finder`

this are extra events due to delay in stopping arduino
"""
function extra_finder(pg::IndexedTable,bhv::IndexedTable; thrs = 6)
    pre_in = find_events(select(pg,:Stim_vec),:in)
    pre_out= find_events(select(pg,:Stim_vec),:out)
    span_trk = (select(pg,:Time_sec)[pre_in[end]] - select(pg,:Time_sec)[pre_in[2]])
    span_bhv = (select(bhv,:millis)[end] - select(bhv,:millis)[1])/1000
    diff = span_trk - span_bhv
    if diff > thrs
        println("Trk duration over Bhv duration of $(diff)secs")
        select(pg,:Stim_vec)[pre_in[end]:end].=false
        println("last event eliminated")
        return pg
    else
        println("extra finder activated unsuccessfully Trk duration over Bhv duration of $(diff)secs ")
        return nothing
    end

end
