"""
`get_data`

Function designed to collect filenames of OF experiment \n
It expect to find inside a directory 2 more subdirectories named behaviour and tracking
then it returns a tuple of vectors (bhv,trk) containing the filepath of csv files found
"""
function get_data(dirname)
    files = readdir(dirname)
    if (!in("behaviour",files)) && (!in("tracking",files))
        return println("missing folder")
    end
    bhv = joinpath(dirname,"behaviour")
    trk = joinpath(dirname,"tracking")
    bhv_array = Vector{String}()
    track_array = Vector{String}()
    bhv_list = readdir(bhv)
    trk_list = readdir(trk)
    for file in bhv_list
        if occursin(Regex(".csv"), file)
            complete_filename = joinpath(bhv,file)
            push!(bhv_array,complete_filename)
        end
    end
    for file in trk_list
        if occursin(Regex(".csv"), file)
            complete_filename = joinpath(trk,file)
            push!(track_array,complete_filename)
        end
    end
    return bhv_array, track_array
end

"""
`get_session`

it returns the filename given a filepath
"""
function get_session(v::Vector{String})
    [splitpath(x)[end] for x in v]
end


"""
`get_bhv_date_info`

given a string of a typical bhv filename from OF experiment extract the date
"""
function get_bhv_date_info(v::String)
    pre_date = split(v,"_")[2][1:6]
    date = string(pre_date)
end

"""
`get_bhv_mouse_info`

given a string of a typical bhv filename from OF experiment extract the Mouse ID
"""
function get_bhv_mouse_info(v::String)
    string(split(v,"_")[1])
end

"""
`get_bhv_info`

given a vector of typical bhv filenames from OF experiment extract info and return a JuliaDB table with the infos
"""
function get_bhv_info(bhv::Vector{String})
    b = get_session(bhv)
    d_b = get_bhv_date_info.(b)
    m_b = get_bhv_mouse_info.(b)
    session_b = m_b.*"_".*d_b
    indexed_table = table((Day = d_b, MouseID = m_b, Session = session_b,bhv_file = bhv))

end

"""
`get_bhv_date_info`

given a string of a typical trk filename from OF experiment extract the date
"""
function get_trk_date_info(v::String)
    r = match(r"T\d{2}+_\d{2}+_\d{2}+.[a-z]{3}",v)
    if isempty(r.match)
        return println("unrecognized tracking file")
    else
        session = replace(v,string(r.match)=>"")
    end
    r = match(r"\d{4}+-\d{2}+-\d{2}",session)
    pre_date = string(r.match)
    date = string(replace(pre_date[3:end],"-"=>""))
    return date
end

"""
`get_trk_mouse_info`

given a string of a typical trk filename from OF experiment extract the Mouse ID
"""
function get_trk_mouse_info(v::String)
    r = match(r"T\d{2}+_\d{2}+_\d{2}+.[a-z]{3}",v)
    if isempty(r.match)
        return println("unrecognized tracking file")
    else
        session = replace(v,string(r.match)=>"")
    end
    r = match(r"\d{4}+-\d{2}+-\d{2}",session)

    pre_MouseID = replace(session,string(r.match)=>"")

    if occursin("_",pre_MouseID)
        MouseID = replace(pre_MouseID,"_"=>"")
    else
        MouseID = pre_MouseID
    end
    return MouseID
end

"""
`get_trk_info`

given a vector of typical trk filenames from OF experiment extract info and return a JuliaDB table with the infos
"""
function get_trk_info(trk::Vector{String})
    t = get_session(trk)
    d_t = get_trk_date_info.(t)
    m_t = get_trk_mouse_info.(t)
    session_t = m_t.*"_".*d_t
    indexed_table = table((Day = d_t, MouseID = m_t, Session = session_t, trk_file = trk))

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
