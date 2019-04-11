
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
