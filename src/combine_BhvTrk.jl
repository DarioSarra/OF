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
function add_events(bhv::IndexedTable,trace::IndexedTable)
    pre_in = find_events(select(trace,:Stim_vec),:in)
    pre_out= find_events(select(trace,:Stim_vec),:out)
    ##
    if length(pre_in) == length(pre_out)
        if length(bhv) == length(pre_in)-1
            b2 = pushcol(bhv,:In,pre_in[2:end])
            b3 = pushcol(b2,:Out,pre_out[2:end])
            return b3
        elseif length(bhv) == length(pre_in)
            b2 = pushcol(bhv,:In,pre_in)
            b3 = pushcol(b2,:Out,pre_out)
            return b3
        elseif length(bhv) < length(trace)
            trace = ghosts_buster(trace)
            pre_in = find_events(select(trace,:Stim_vec),:in)
            pre_out= find_events(select(trace,:Stim_vec),:out)
            b2 = pushcol(bhv,:In,pre_in[2:end])
            b3 = pushcol(b2,:Out,pre_out[2:end])
            return b3
        end
    else
        println("in and out not matching")
        println("in length = $(length(pre_in)), out length = $(length(pre_out))")
    end
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
    if first(r[1]) < 0
        r[1] = 1:last(r[1])
    end
    output = pushcol(t,:Range,r)
end


"""
`add_traces`
"""
function add_traces(ongoing,trace)
    l = length(ongoing)
    return pushcol(ongoing, (name => fill(select(trace, name), l) for name in [:cleanX,:cleanY,:Time_sec,:Speed,:Distance]))
end

function combine_BhvTrk(Bhv::String,Traces::String)
    traces = CSV.read(Traces, allowmissing = :auto, truestrings = ["true"], falsestrings = ["false"]) |> table
    #traces = loadtable(Traces)
    bhv = loadtable(Bhv)
    bhv = setcol(bhv,:Gen,gen.(select(bhv,:MouseID)))
    ongoing1 = add_events(bhv,traces)
    ongoing = set_range(ongoing1)
    final = add_traces(ongoing,traces)
    return final
end

function combine_BhvTrk(row::NamedTuple)
    d = combine_BhvTrk(row.bhv_file,row.traces_file)
    b = setcol(d,:Day, fill(parse.(Float64,row.Day),length(d)))
end
