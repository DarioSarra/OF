using JuliaDBMeta
using ShiftedArrays
using Statistics
using StatsBase
using NaNMath
using CSV

include("search_files.jl")
include("extract_file_info.jl")
include("preprocess_trk.jl")
include("bonsai_parser.jl")
include("tracking_manipulation.jl")
include("combine_BhvTrk.jl")
include("combine_sessions.jl")
