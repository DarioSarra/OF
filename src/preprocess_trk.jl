function load_trk(w::String)
    try
    t = CSV.read(w,delim = ' ',datarow = 2,allowmissing=:all)|>table
    if length(t[1]) == 6
        t = CSV.read(w,delim = ' ',datarow = 2,header =[:Stim_vec,:X,:Y,:Time,:Area,:r])|>table
        t = popcol(t, :r)
    elseif length(t[1]) == 5
        t = CSV.read(w,delim = ' ',datarow = 2,header =[:Stim_vec,:X,:Y,:Time,:Area])|>table
    elseif length(t[1]) == 8
        try
            t = CSV.read(w,delim = ' ',datarow = 2,header =[:Stim_vec,:X,:Y,:Time,:Ref1_x,:Ref1_y,:Ref2_x,:Ref2_y])|>table
        catch
            t = CSV.read(w,delim = ' ',datarow = 2,header =[:Stim_vec,:X,:Y,:Time,:Ref1_x,:Ref1_y,:Ref2_x,:Ref2_y,:r])|>table
            t = popcol(t, :r)
        end
    elseif length(t[1]) == 9
        try
            t = CSV.read(w,delim = ' ',datarow = 2,header =[:Stim_vec,:X,:Y,:Time,:Area,:Ref1_x,:Ref1_y,:Ref2_x,:Ref2_y])|>table
        catch
            t = CSV.read(w,delim = ' ',datarow = 2,header =[:Stim_vec,:X,:Y,:Time,:Area,:Ref1_x,:Ref1_y,:Ref2_x,:Ref2_y,:r])|>table
            t = popcol(t, :r)
        end
    elseif length(t[1]) == 10
        t = CSV.read(w,delim = ' ',datarow = 2,header =[:Stim_vec,:X,:Y,:Time,:Area,:Ref1_x,:Ref1_y,:Ref2_x,:Ref2_y,:r])|>table
        t = popcol(t, :r)
    end
catch ex
        println(ex)
        return nothing
    end
    for n in [:X,:Y,:Time,:Area,:Ref1_x,:Ref1_y,:Ref2_x,:Ref2_y]
        if in(n,colnames(t))
            v = convert(Vector{Float64},select(t,n))
            t = setcol(t,n =>v)
        end
    end
    v = convert(Vector{String},select(t,:Stim_vec))
    v2 = occursin.("ue",v)
    t = setcol(t,:Stim_vec =>v2)
    return t
end

function prepare_trk_old(t::IndexedTable)
    clean = @apply t begin
        @transform_vec {cm_X = convert_px(:X,:Area,45.4*33)}
        @transform_vec {cm_Y = convert_px(:Y,:Area,45.4*33)}
        @transform_vec {zX = nanZ(:X)}
        @transform_vec {zY = nanZ(:Y)}
        @transform {cleanX = abs(:zX) > 2 ? NaN : :cm_X}
        @transform {cleanY = abs(:zY) > 2 ? NaN : :cm_Y}
        @transform_vec {Distance = distance(:cleanX,:cleanY)}
        @transform_vec {Time_ms = conv_time(:Time)}
        @transform {Time_sec = :Time_ms/1000}
        @transform_vec {Speed = speed(:Distance,:Time_sec)}
        @transform_vec {ZSpeed = nanZ(:Speed)}
    end
    return clean
end

function prepare_trk_new(t::IndexedTable)
    clean = @apply t begin
        @transform_vec {ref_distance = distance(:Ref1_x,:Ref1_y,:Ref2_x,:Ref2_y)}
        @transform_vec {cm_X = convert_px(:X,:ref_distance,30)}
        @transform_vec {cm_Y = convert_px(:Y,:ref_distance,30)}
        @transform_vec {zX = nanZ(:X)}
        @transform_vec {zY = nanZ(:Y)}
        @transform {cleanX = abs(:zX) > 2 ? NaN : :cm_X}
        @transform {cleanY = abs(:zY) > 2 ? NaN : :cm_Y}
        @transform_vec {Distance = distance(:cleanX,:cleanY)}
        @transform_vec {Time_ms = conv_time(:Time)}
        @transform {Time_sec = :Time_ms/1000}
        @transform_vec {Speed = speed(:Distance,:Time_sec)}
        @transform_vec {ZSpeed = nanZ(:Speed)}
    end
    return clean
end

function prepare_old(row::NamedTuple)
    prepare_trk(row.trk_file)
end

function verify_trk(Trk,Bhv)
    t = load_trk(Trk)
    if in(:Ref1_x,colnames(t))
        trk = prepare_trk_new(t)
    else
        trk = prepare_trk_old(t)
    end
    bhv = loadtable(Bhv)
    pre_in = find_events(select(trk,:Stim_vec),:in)
    pre_out= find_events(select(trk,:Stim_vec),:out)
    if length(pre_in) == length(pre_out)
        if (length(bhv) == length(pre_in)-1) || (length(bhv) == length(pre_in))
            return trk
        elseif length(bhv) < length(trk)
            gb = ghosts_buster(trk)
            pre_in = find_events(select(gb,:Stim_vec),:in)
            pre_out= find_events(select(gb,:Stim_vec),:out)
            if (length(bhv) == length(pre_in)-1) || (length(bhv) == length(pre_in))
                return gb
            elseif length(bhv) < length(pre_in)-1
                pg = poltergeist_buster(gb)
                pre_in = find_events(select(pg,:Stim_vec),:in)
                pre_out= find_events(select(pg,:Stim_vec),:out)
                if (length(bhv) == length(pre_in)-1) || (length(bhv) == length(pre_in))
                    return pg
                else
                    short = extra_finder(pg,bhv)
                    pre_in = find_events(select(short,:Stim_vec),:in)
                    if (length(bhv) == length(pre_in)-1) || (length(bhv) == length(pre_in))
                        return short
                    else
                        println("ghosts_buster activated unsuccessfully")
                        println("bhv length = $(length(bhv)), trk events length = $(length(pre_in))")
                    end
                end
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
    catch ex
        println("couldn't preprocess $(r.trk_file)")
        println(ex)
    end
end

function preprocess_trk(DataIndex::IndexedTable)
    for idx = 1:length(DataIndex)
        println(idx)
        r = DataIndex[idx]
        if !ispath(r.traces_file)
            preprocess_trk(r)
        end
    end
end
