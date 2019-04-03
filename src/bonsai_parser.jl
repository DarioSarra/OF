function parse_row(r::String)
    splitted = split(r," ")[1:end-1]
    stim = [occursin(splitted[1],"ue")]
    x = [parse(Float64,splitted[2])]
    y = [parse(Float64,splitted[3])]
    time = [parse(Float64,splitted[4])]
    ongoing = table((Stim = stim, X = x, Y = y, Time = time ))
end

function parse_bonsai(t)
    r = select(t,1)[2]
    ongoing = parse_row(r)    
    for i = 2:length(t)
        r = select(t,1)[i]
        prov = parse_row(r)
        ongoing = merge(ongoing,prov)
    end
    return ongoing
end
