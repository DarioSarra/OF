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

function speed(dist_vec,time_vec)
    elapsed_t = time_vec - lag(time_vec, default= NaN)
    speed = dist_vec ./ time_vec
end

function speed(trk::IndexedTable)
    @transform_vec trk {Speed = speed(:Distance,:Time)}
end



function prepare_trk(w::String)
    t = parse_bonsai(w)
    zX = nanZ(select(t,:X))
    zY = nanZ(select(t,:Y))
    trk = pushcol(t, [:zX=>zX, :zY =>zY])
    @with trk :Time .= :Time/1000
    clean = @apply trk begin
        @transform {cleanX = abs(:zX) > 2 ? NaN : :zX}
        @transform {cleanY = abs(:zY) > 2 ? NaN : :zY}
        @transform_vec {Distance = distance(:cleanX,:cleanY)}
        @transform_vec {Speed = speed(:Distance,:Time)}
    end
    return clean
end

function prepare_trk(row::NamedTuple)
    prepare_trk(row.trk_file)
end
