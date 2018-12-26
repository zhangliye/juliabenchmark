using JuliaDB
using Test
include("../src/extract_segment.jl")

@testset "Julia Version RunningTime without precompile" begin
    gtfs_dir = "../data/google_transit_manhattan"

    @info "---------------Julia without precompile"
    @info "Check the time of loading CSV files"
    dtype=Dict("shape_id"=>String)
    @info "Open `shapes.txt`"
    @time frm_shape = loadtable(joinpath(gtfs_dir, "shapes.txt"), colparsers=dtype)
    @info "Open `stop_times.txt`"
    @time frm_stop_time = loadtable( joinpath(gtfs_dir, "stop_times.txt"), colparsers=Dict("stop_id"=>String, "shape_id"=>String) )
    @info "Open `trips.txt`"
    @time frm_trip = loadtable( joinpath(gtfs_dir, "trips.txt"), colparsers=Dict("trip_id"=>String, "shape_id"=>String) )
    @info "Open `stops.txt`"
    @time frm_stop = loadtable( joinpath(gtfs_dir, "stops.txt"), colparsers=Dict("stop_id"=>String) )

    segements = Dict{Tuple{String, String},Vector{Tuple{Float64, Float64}}}()
    @info "The running time of processing 500 rows:"
    @time extract_segment(segements, frm_trip, frm_stop, frm_stop_time, frm_shape)
end

@testset "Julia Version RunningTime (precompile)" begin
    gtfs_dir = "../data/google_transit_manhattan"

    @info "---------------Julia with precompile"
    @info "Check the time of loading CSV files"
    dtype=Dict("shape_id"=>String)
    @info "Open `shapes.txt`"
    loadtable(joinpath(gtfs_dir, "shapes.txt"), colparsers=dtype)
    @time frm_shape = loadtable(joinpath(gtfs_dir, "shapes.txt"), colparsers=dtype)
    @info "Open `stop_times.txt`"
    loadtable( joinpath(gtfs_dir, "stop_times.txt"), colparsers=Dict("stop_id"=>String, "shape_id"=>String) )
    @time frm_stop_time = loadtable( joinpath(gtfs_dir, "stop_times.txt"), colparsers=Dict("stop_id"=>String, "shape_id"=>String) )
    @info "Open `trips.txt`"
    loadtable( joinpath(gtfs_dir, "trips.txt"), colparsers=Dict("trip_id"=>String, "shape_id"=>String) )
    @time frm_trip = loadtable( joinpath(gtfs_dir, "trips.txt"), colparsers=Dict("trip_id"=>String, "shape_id"=>String) )
    @info "Open `stops.txt`"
    loadtable( joinpath(gtfs_dir, "stops.txt"), colparsers=Dict("stop_id"=>String) )
    @time frm_stop = loadtable( joinpath(gtfs_dir, "stops.txt"), colparsers=Dict("stop_id"=>String) )

    segements = Dict{Tuple{String, String},Vector{Tuple{Float64, Float64}}}()

    @info "The running time of processing 500 rows:"
    extract_segment(segements, frm_trip, frm_stop, frm_stop_time, frm_shape, testing=true)
    @time extract_segment(segements, frm_trip, frm_stop, frm_stop_time, frm_shape)
end
