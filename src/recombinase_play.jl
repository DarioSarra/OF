using Plots
using Recombinase
using Recombinase: aroundindex
using Recombinase: fitvec
using OnlineStats: Mean, Variance

plot(rand(10))
include("OF.jl")

dir =joinpath("/Volumes/GoogleDrive/My Drive/Flipping/run_task_photo/OF")

DataIndex = get_DataIndex(dir)


final = combine_sessions(DataIndex)
union(select(final,:Stim))

d = @transform final {on = :StimFreq > 1}

g = @filter d (:Gen =="HET") &&
    (:Day > 190408) &&
    (in(:StimFreq,[0,25,30])) &&
    (:Stim==1)

args, kwargs = Recombinase.series2D(
    Recombinase.prediction(axis = -200:200),
    g,
    Recombinase.Group(:StimFreq),
    axis = -100:100,
    select = (:Offsets, :Speed),
    error = :MouseID,
    ribbon = true)

plot(args...; kwargs...,
    title = "Stim Frequency \n only stim blocks",
    xlabel = "frame from trial start \n 30fps",
    ylabel = "cm/s",
    linewidth = 2,
    fillalpha = 0.2)

###


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

s = fitvec((Mean, Variance), traces, -100:100)
select(s,:Mean)
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
