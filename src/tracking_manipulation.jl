function nanZ(v::Vector)
    (v.-NaNMath.mean(v))./NaNMath.std(v)
end

function prepare_trk(w::String)
    t = parse_bonsai(w)
    zX = nanZ(select(t,:X))
    zY = nanZ(select(t,:Y))
    trk = pushcol(t, [:zX=>zX, :zY =>zY])
    clean = @apply trk begin
        @transform {cleanX = abs(:zX) > 2 ? NaN : :zX}
        @transform {cleanY = abs(:zY) > 2 ? NaN : :zY}
    end
    return clean
end

function prepare_trk(row::NamedTuple)
    prepare_trk(row.trk_file)
end
