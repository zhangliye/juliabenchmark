#=
main:
- Julia version:
- Author: zhangly
- Date: 2018-12-25
=#
using JuliaDB

"""
returnt [(lon,lat),...] of the given `stop_id`
"""
function get_stop_pos(frm_stop::IndexedTable, stop_id::String)
    sub_frm = filter(p->p.stop_id==stop_id, frm_stop)
    if length(sub_frm)>0
        return (sub_frm[1][:stop_lon], sub_frm[1][:stop_lat])
    else
        return (nothing, nothing)
    end
end

"""
return `shape_id` of the given `trip_id`
"""
function get_shape(frm_trip::IndexedTable, trip_id::String)
    sub_frm = filter(p->p.trip_id==trip_id, frm_trip)

    if length(sub_frm)>0
        return sub_frm[1][:shape_id] # return the first row value
    else
        return nothing
    end
end

"""
return [stop_id1, ...] of the given `trip_id`
"""
function get_stops(frm_st, trip_id)
    stops = Vector{String}()
    sub_frm = filter(p->p.trip_id==trip_id, frm_st)

    for i in 1:length(sub_frm)
        push!(stops, sub_frm[i][:stop_id])
    end
    return stops
end

"""
get shape points
"""
function get_points(frm_shape, shape_id)
    pts = Vector{Tuple{Float64,Float64}}()

    sub_frm = filter(p->p.shape_id==shape_id, frm_shape)
    for i in 1:length(sub_frm)
        push!( pts, (sub_frm[i][:shape_pt_lon], sub_frm[i][:shape_pt_lat]) )
    end
    return pts
end

"""
pt1-(lon,lat), pt2-(lon, lat)
"""
function dist_meter(pt1::Tuple{Float64,Float64}, pt2::Tuple{Float64,Float64})
    dst = sqrt( (pt1[1]-pt2[1])^2 + (pt1[2]-pt2[2])^2 )
    return dst*110*1000
end

function nearest_pos(pt::Tuple{Float64,Float64}, shape_pts::Vector{Tuple{Float64,Float64}})
    dst_near = typemax(Int)
    idx = -1
    for i in 1:length(shape_pts)
        dst = dist_meter(pt, shape_pts[i])
        if dst<dst_near
            dst_near = dst
            idx = i
        end
    end
    return (idx, dst_near)
end

"""
    segements: {(from_id, to_id):[(x1, y1),...], ...}
    stops: [stop_id1,...]
    stop_pts: [(x1,y1), ...]
    stop_pts: [(x1,y1), ...]
"""
function process_trip(segements::Dict{Tuple{String, String},Vector{Tuple{Float64, Float64}}},
        stops::Vector{String}, stop_pts::Vector{Tuple{Float64, Float64}},
        shape_pts::Vector{Tuple{Float64, Float64}})
    n_error = 0
    for i in 1:(length(stops)- 1)
        from_stop = stops[i]
        to_stop = stops[i + 1]
        from_pos = stop_pts[i]
        to_pos = stop_pts[i + 1]
        if haskey(segements, (from_stop, to_stop)) || haskey(segements, (to_stop ,from_stop))
            continue
        end

        i_idx1, dst1 = nearest_pos(from_pos, shape_pts)
        i_idx2, dst2 = nearest_pos(to_pos, shape_pts)
        if -1 == i_idx1 || -1 == i_idx2 || i_idx1 == i_idx2
            println("Point not found: ", i_idx1, i_idx2)
            n_error += 1
            continue
        end

        if dst1 > 300 || dst2 > 300
            println("Point too far: ", from_stop, to_stop)
            n_error += 1
            continue
        end

        if i_idx1 < i_idx2
            segements[(from_stop, to_stop)] = shape_pts[i_idx1:(i_idx2)]
        else
            segements[(from_stop, to_stop)] = shape_pts[i_idx2:(i_idx1)]  # two direction are the same
        end
    end
    n_error > 0 && println("error stops: ", n_error)
end
"""
:param segements: {(from_id, to_id):[(x1, y1),...], ...}
:param frm_trip:
:param frm_stop:
:param frm_stop_time:
:param frm_shape:
:return:
"""
function extract_segment(segements::Dict{Tuple{String, String},Vector{Tuple{Float64, Float64}}},
        frm_trip::IndexedTable, frm_stop::IndexedTable,
        frm_stop_time::IndexedTable, frm_shape::IndexedTable; testing=false)
    stop_chain_key = Dict{String, Int}()  # 'key':0
    n = 0
    k1 = ""
    for i in 1:length(frm_trip)
        i % 100 == 0 && println(i, " found: ", n)
        i>500 && break
        trip_id = frm_trip[i][:trip_id]
        stops = get_stops(frm_stop_time, trip_id)  # [stop_id1,...]

        # k1=str(stops)
        k1 = string(stops)  # [stop_id1, ...]
        haskey(stop_chain_key, k1) && continue

        shape_id = frm_trip[i][:shape_id]
        shape_pts = get_points(frm_shape, shape_id)  # [(x1,y1), ...]

        # check all stops are avaliable
        stop_pts = Vector{Tuple{Float64, Float64}}()
        for stop_id in stops
            pt = get_stop_pos(frm_stop, stop_id)
            if pt[1] == nothing
                println("found one error")
                continue
            end
            push!(stop_pts, pt)
        end

        process_trip(segements, stops, stop_pts, shape_pts)

        stop_chain_key[k1] = -1
        # stop_chain_key[str(stops.reverse())] = -1
        reverse!(stops)
        stop_chain_key[string(stops)] = -1

        n += 1
        testing && break
    end
    return segements
end
