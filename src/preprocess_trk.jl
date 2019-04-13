function prepare_trk(w::String)
    t = load_trk(w)
    clean = @apply t begin
        @transform_vec {cm_X = convert_px(:X,:Area)}
        @transform_vec {cm_Y = convert_px(:Y,:Area)}
        @transform_vec {zX = nanZ(:X)}
        @transform_vec {zY = nanZ(:Y)}
        @transform {cleanX = abs(:zX) > 2 ? NaN : :cm_X}
        @transform {cleanY = abs(:zY) > 2 ? NaN : :cm_Y}
        @transform_vec {Distance = distance(:cleanX,:cleanY)}
        @transform_vec {Time_ms = conv_time(:Time)}
        @transform {Time_sec = :Time_ms/1000}
        @transform_vec {Speed = speed(:Distance,:Time_sec)}
    end
    return clean
end

function prepare_trk(row::NamedTuple)
    prepare_trk(row.trk_file)
end

function verify_trk(Trk,Bhv)
    trk = prepare_trk(Trk)
    bhv = loadtable(Bhv)
    pre_in = find_events(select(trk,:Stim_vec),:in)
    pre_out= find_events(select(trk,:Stim_vec),:out)
    if length(pre_in) == length(pre_out)
        if (length(bhv) == length(pre_in)-1) || (length(bhv) == length(pre_in))
            return trk
        elseif length(bhv) < length(trk)
            x = ghosts_buster(trk)
            pre_in = find_events(select(x,:Stim_vec),:in)
            pre_out= find_events(select(x,:Stim_vec),:out)
            if (length(bhv) == length(pre_in)-1) || (length(bhv) == length(pre_in))
                return x
            end
        elseif length(bhv) > length(pre_in)
            println("bhv longer than trk")
            println("bhv length = $(length(bhv)), trk events length = $(length(pre_in))")
            return nothing
        end

    else
        println("in and out not matching")
        println("in length = $(length(pre_in)), out length = $(length(pre_out))")
        return nothing
    end
end

function verify_trk(row::NamedTuple)
    Trk = row.trk_file
    Bhv = row.bhv_file
    verify_trk(Trk,Bhv)
end

function preprocess_trk(r::NamedTuple)
    traces = verify_trk(r)
    try
        CSV.write(r.traces_file,traces)
    catch
        println("couldn't preprocess $(r.trk_file)")
    end
end

function preprocess_trk(DataIndex::IndexedTable)
    for idx = 1:length(DataIndex)
        r = DataIndex[idx]
        if !ispath(r.traces_file)
            preprocess_trk(r)
        end
    end
end
