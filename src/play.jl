using Plots
using GroupedErrors
include("OF.jl")
dir = "/home/beatriz/mainen.flipping.5ht@gmail.com/Flipping/run_task_photo/OF"
file = "SD102019-04-08T17_28_58.csv"
filepath = joinpath(dir,"tracking",file)
##
bhv, trk = get_data(dir)
trk_db = get_trk_info(trk)
prepare_trk(trk_db[1])


ojkokd

DataIndex = get_DataIndex(dir)
DataIndex = @filter DataIndex (!occursin("test",:MouseID)) &&
    (!occursin("prova",:MouseID)) &&
    (occursin("SD",:MouseID))

final = combine_sessions(DataIndex)

union(select(DataIndex,:MouseID))
###

scatter(select(clean,:Distance),select(clean,:Speed))

g = @filter final (:Block <4) && (:StimFreq !=25) && (:StimFreq !=12)

plt= @> g begin
    @splitby _.Block
    @across _.MouseID
    @x -100:100 :discrete
    @y _.Speed
    @plot plot(fillalpha = 0.2,line =3) :ribbon
end



errors = [7,9,10,13]
DataIndex[13]

i = 9
Trk = select(DataIndex,:trk_file)[i]
Bhv = select(DataIndex,:bhv_file)[i]

trk = prepare_trk(Trk)
bhv = loadtable(Bhv)
ongoing1 = add_events(bhv,trk)
ongoing = set_range(ongoing1)
final = add_traces(ongoing,trk)
