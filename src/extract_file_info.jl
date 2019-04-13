
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
    pre_process_dir = joinpath(dirname(dirname(trk[1])),"processed_traces")
    if !ispath(pre_process_dir)
        mkdir(pre_process_dir)
    end
    traces = joinpath.(pre_process_dir,("traces".*session_t.*".csv"))
    indexed_table = table((Day = d_t, MouseID = m_t, Session = session_t, trk_file = trk,traces_file = traces))
end
