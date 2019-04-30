function nanZ(v::AbstractArray)
    (v.-NaNMath.mean(v))./NaNMath.std(v)
end

function convert_px(ax_vec, ref_vec,real_val)
    interval  = 7*60*30:13*60*30 #take measurements from minutes 7 to 13
    cm_px = sqrt(real_val/NaNMath.mean(ref_vec[interval]))
    ax_vec.*cm_px
end

function distance(x1_vec,y1_vec,x2_vec,y2_vec)
    x = x1_vec -x2_vec
    y = y1_vec - y2_vec
    X = x.^2
    Y = y.^2
    distance = sqrt.(X.+Y)
end

function distance(x_vec,y_vec)
    x = x_vec - lag(x_vec, default = NaN)
    y = y_vec - lag(y_vec, default = NaN)
    X = x.^2
    Y = y.^2
    distance = sqrt.(X.+Y)
end

# function distance(trk::IndexedTable)
#     @transform_vec trk {Distance = distance(:cleanX,:cleanY)}
# end
#####elapsed_t already used here = Time
function speed(dist_vec,time_vec)
    elapsed_t = time_vec .- lag(time_vec, default= NaN)
    speed = dist_vec ./ elapsed_t
end

# function speed(trk::IndexedTable)
#     @transform_vec trk {Speed = speed(:Distance,:Time)}
# end


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
