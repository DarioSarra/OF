function set_range(v::AbstractArray{<:Real};r = -5:5,fps = 30)
    start = r.start*fps
    stop = r.stop*fps
    [x + start : x + stop for x in v]
end
