"""
`find_events`
return the index of a squarewave signal either begins or ends
"""
function find_events(squarewave,which)
    digital_trace = Bool.(squarewave)
    if which == :in
        indexes = findall(.!digital_trace[1:end-1] .& digital_trace[2:end])
    elseif which == :out
        indexes = findall(digital_trace[1:end-1] .& .!digital_trace[2:end])
    end
    return indexes
end

"""
`add_events`
"""
function add_events(bhv::IndexedTable,trk::IndexedTable)
    pre_in = find_events(select(trk,:Stim_vec),:in)
    pre_out= find_events(select(trk,:Stim_vec),:out)
    ##
    if length(bhv) == length(pre_in)-1
        b2 = pushcol(bhv,:In,pre_in[2:end])
    else
        println("bhv length = ",length(bhv), " trk in length = ", length(pre_in))
    end
    if length(b2) == length(pre_out)-1
        b3 = pushcol(b2,:Out,pre_out[2:end])
    else
        println("bhv length = ",length(b2), " trk out length = ", length(pre_out))
    end
end


"""
`add_traces`
"""
function add_traces(ongoing,trk)
    ranges = select(ongoing,:Range)
    shifts = select(ongoing,:In)
    for name in colnames(t)
        trace = select(t,name)
        provisory = [ShiftedArray(trace[r],s) for (r,s) in zip(ranges,shifts)]
        ongoing = pushcol(ongoing, name, provisory)
    end
    return ongoing
end

"""
`set_range`
"""
function set_range(v::AbstractArray{<:Real};r = -5:5,fps = 30)
    start = r.start*fps
    stop = r.stop*fps
    [x + start : x + stop for x in v]
end
function set_range(t::IndexedTable;r = -5:5,fps = 30)
    v = select(t,:In)
    r = set_range(v,r=r,fps=fps)
    output = pushcol(t,:Range,r)
end
