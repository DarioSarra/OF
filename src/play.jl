using Plots
using GroupedErrors

dir = "/home/beatriz/mainen.flipping.5ht@gmail.com/Flipping/run_task_photo/OF"
file = "LB2019-04-05T15_05_10.csv"
filepath = joinpath(dir,"tracking",file)
CSVFiles.read(filepath, delim = ' ')
DataIndex = get_DataIndex(dir)
DataIndex = @filter DataIndex (!occursin("test",:MouseID)) &&
    (!occursin("prova",:MouseID)) &&
    (occursin("SD",:MouseID))



DataIndex
final = combine_sessions(DataIndex)

union(select(DataIndex,:MouseID))
###

scatter(select(clean,:Distance),select(clean,:Speed))

g = @filter final (:StimFreq !=17) && (:StimFreq !=25) && (:StimFreq !=12)

plt= @> final begin
    @splitby _.Block
    @across _.MouseID
    @x -100:100 :discrete
    @y _.Speed
    @plot plot() :ribbon
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
