dir = "/home/beatriz/mainen.flipping.5ht@gmail.com/Flipping/run_task_photo/OF"
DataIndex = get_DataIndex(dir)
ex_t = select(DataIndex,:trk_file)[1];
trk = parse_bonsai(ex_t)
ex_b = select(DataIndex,:bhv_file)[1];
b1 = loadtable(ex_b)
ongoing1 = add_events(b1,t)
ongoing = set_range(ongoing1)
ranges = select(ongoing,:Range)
shifts = select(ongoing,:In)
trace = select(trk,:Stim_vec)
final = add_traces(ongoing,t)

using Plots
using GroupedErrors

plt= @> final begin
    @splitby _.Stim
    @across _.Block
    @x -100:100 :discrete
    @y _.X
    @plot plot() :ribbon
end

plt



reduce_vec(mean,select(final,:X),-5:5)

select(final,:Stim_vec)[40][-5:5]


tt = [1,3,54,6,7,2,47,2,5,7,2,34,7,12,6,3,1,42,434,36]
tt= [true,false,true,false,true,true]

ShiftedArray(tt,-4,default=NaN)
