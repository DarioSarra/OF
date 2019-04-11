using Plots
using Recombinase
using Recombinase: aroundindex
plot(rand(10))
include("OF.jl")

dir = "/home/pietro/pietro.vertechi@neuro.fchampalimaud.org/Flipping/run_task_photo/OF/"
file = "LB2019-04-05T15_05_10.csv"
filepath = joinpath(dir,"tracking",file)
DataIndex = get_DataIndex(dir)
DataIndex = @filter DataIndex (!occursin("test",:MouseID)) &&
    (!occursin("prova",:MouseID)) &&
    (occursin("SD",:MouseID))


DataIndex
final = combine_sessions(DataIndex);
colnames(final)
union(select(DataIndex,:MouseID))
###

using Recombinase: fitvec
using OnlineStats: Mean, Variance

traces = (aroundindex(row.Speed, row.In, row.Range .- row.In) for row in rows(final))
first(traces)
s = rand(100, 10)
fitvec(Mean, traces, -100:100)
using OffsetArrays
x = rand(100)
view(x, OffsetArray(axes(x, 1), -5))

# prendi nome da cosa che usi
# double slider per range
# x vettore fai view
# add widgets for keywords

s = fitvec((Mean, Variance), traces, -10000:100)
axes(s, 1)

table(parent(s))

min_nobs

####
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
