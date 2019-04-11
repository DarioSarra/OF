"""
`get_data`

Function designed to collect filenames of OF experiment \n
It expect to find inside a directory 2 more subdirectories named behaviour and tracking
then it returns a tuple of vectors (bhv,trk) containing the filepath of csv files found
"""
function get_data(dirname)
    bhv_array = get_bhv_data(dirname)
    track_array = get_trk_data(dirname)
    return bhv_array, track_array
end

function get_bhv_data(dirname)
    files = readdir(dirname)
    if (!in("behaviour",files))
        return println("missing folder")
    end
    bhv = joinpath(dirname,"behaviour")
    bhv_array = Vector{String}()
    bhv_list = readdir(bhv)
    for file in bhv_list
        if occursin(Regex(".csv"), file)
            complete_filename = joinpath(bhv,file)
            push!(bhv_array,complete_filename)
        end
    end
    return bhv_array
end

function get_trk_data(dirname)
    files = readdir(dirname)
    if (!in("tracking",files))
        return println("missing folder")
    end
    trk = joinpath(dirname,"tracking")
    track_array = Vector{String}()
    trk_list = readdir(trk)
    for file in trk_list
        if occursin(Regex(".csv"), file)
            complete_filename = joinpath(trk,file)
            push!(track_array,complete_filename)
        end
    end
    return track_array
end

"""
`get_DataIndex`

given a directory of OF experiments containing a folder for bhv and a folder for tracking it returns a juliaDB with matching pathways
"""
function get_DataIndex(dir::String)
    bhv, trk = get_data(dir)
    bhv_db = get_bhv_info(bhv)
    trk_db = get_trk_info(trk)
    DataIndex = join(bhv_db,trk_db,how = :inner,lkey = (:Session,:Day,:MouseID),rkey = (:Session,:Day,:MouseID))
end
