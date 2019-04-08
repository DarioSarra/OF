function nanZ(v::Vector)
    (v.-NaNMath.mean(v))./NaNMath.std(v)
end

function distance(x_vec,y_vec)
    x = x_vec - lag(x_vec, default = NaN)
    y = y_vec - lag(y_vec, default = NaN)
    X = x.^2
    Y = y.^2
    distance = sqrt.(X.+Y)
end

function distance(trk::IndexedTable)
    @transform_vec trk {Distance = distance(:cleanX,:cleanY)}
end
#####elapsed_t already used here = Time
function speed(dist_vec,time_vec)
    elapsed_t = time_vec - lag(time_vec, default= NaN)
    speed = dist_vec ./ elapsed_t
end

function speed(trk::IndexedTable)
    @transform_vec trk {Speed = speed(:Distance,:Time)}
end

#####
function conv_time(time::Vector)
    Time = time.-time[1] #subtract the first value to every value
    difference = Time - lag(Time,default = 0) #subtract the previous to the current value, to see where it becomes negative
        c = 0
        for (idx,val) in enumerate(difference)
            if val >= 0
                    Time[idx]= Time[idx]+c
            elseif val<0
                    c +=1000
                    Time[idx]= Time[idx]+c
            end
        end
        return Time
    end
#####

function prepare_trk(w::String)
    t = parse_bonsai(w)
    clean = @apply t begin
        @transform_vec {zX = nanZ(:X)}
        @transform_vec {zY = nanZ(:Y)}
        @transform_vec {Time_ms = conv_time(:Time)}
        @transform {Time_sec = :Time_ms/1000}
        @transform {cleanX = abs(:zX) > 2 ? NaN : :zX}
        @transform {cleanY = abs(:zY) > 2 ? NaN : :zY}
        @transform_vec {Distance = distance(:cleanX,:cleanY)}
        @transform_vec {Speed = speed(:Distance,:Time_sec)}
    end
    return clean
end

function prepare_trk(row::NamedTuple)
    prepare_trk(row.trk_file)
end
