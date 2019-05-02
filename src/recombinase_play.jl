using Plots
using Recombinase
using OnlineStats: Mean, Variance

plot(rand(10))
include("OF.jl")
##
dir =joinpath("/Volumes/GoogleDrive/My Drive/Flipping/run_task_photo/OF")

DataIndex = get_DataIndex(dir)
DataIndex = @filter DataIndex (!occursin("test",:MouseID)) &&
    (!occursin("prova",:MouseID)) &&
    (occursin("SD",:MouseID)) &&
    (parse(Float64,:Day) > 190428)

#preprocess_trk(DataIndex)

final = combine_sessions(DataIndex)

d = @apply final begin
    @transform {on = :StimFreq > 1}
    @transform {Sessione = :MouseID *"_"*string(:Day)}
end

##
g = @filter d (:Gen =="HET") &&
    (:Day >190429)&&
    (in(:StimFreq,[0,16,20]))
    ##(:Sessione != "SD5_190414.0")


args, kwargs = Recombinase.series2D(
    Recombinase.prediction(axis = -30:90),
    g,
    Recombinase.Group(:StimFreq),
    select = (:Offsets, :ZSpeed),
    error = :MouseID,
    ribbon = true)

plot(args...; kwargs...,
    title = "Frequencies effect HET \n only stim blocks",
    xlabel = "frame from trial start (30fps)",
    ylabel = "z-scored cm/s",
    linewidth = 1,
    fillalpha = 0.3)

###
savefolder = "/Users/dariosarra/Documents/Lab/Mainen/Presentations/Lab_meeting/Lab_meeting 2019-04-16"
fig = "Z-time-16-25-HET.pdf"
savepath = joinpath(savefolder,fig)
savefig(savepath)

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
