dir = "/home/beatriz/mainen.flipping.5ht@gmail.com/Flipping/run_task_photo/OF"
DataIndex = get_DataIndex(dir)
ex_t = select(DataIndex,:trk_file)[1];
t = parse_bonsai(ex_t)
ex_b = select(DataIndex,:bhv_file)[1];
b1 = loadtable(ex_b)
ongoing1 = add_events(b1,t)
ongoing = set_range(ongoing1)

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

add_traces(ongoing,t)

#@transform ongoing {ShiftedArray(trace[:Range],:In)}
