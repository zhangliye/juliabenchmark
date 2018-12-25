import math
import sys
import pandas as pd

def get_stop_pos(frm_stop, stop_id):
    "returnt [(lon,lat),...] of the give `stop_id`"
    sub_frm = frm_stop[frm_stop['stop_id']==stop_id]
    if sub_frm.shape[0]>0:
        return (sub_frm.iloc[0]['stop_lon'], sub_frm.iloc[0]['stop_lat'])
    else:
        return None

## get shape id
def get_shape(frm_trip, trip_id):
    "return `shape_id` of the given `trip_id`"
    sub_frm = frm_trip[frm_trip["trip_id"]==trip_id]
    if sub_frm.shape[0] > 0:
        return sub_frm.iloc[0]['shape_id']  # return the first row value
    else:
        return None

# get stops of shapes
def get_stops(frm_st, trip_id):
    "return [stop_id1, ...] of the given `trip_id`"
    stops = []
    sub_frm = frm_st[frm_st["trip_id"]==trip_id]
    for i in range(sub_frm.shape[0]):
        stops.append( sub_frm.iloc[i]['stop_id'] )
    return stops

# get shape points
def get_points(frm_shape, shape_id):
    pts = []
    sub_frm = frm_shape[frm_shape["shape_id"]==shape_id]
    for i in range(sub_frm.shape[0]):
        pts.append( (sub_frm.iloc[i]['shape_pt_lon'], sub_frm.iloc[i]['shape_pt_lat'])  )
    return pts

def dist_meter(pt1, pt2):
    """pt1-(lon,lat), pt2-(lon, lat)"""
    dst = math.sqrt( (pt1[0]-pt2[0])**2 + (pt1[1]-pt2[1])**2 )
    return dst*110*1000

def nearest_pos(pt, shape_pts):
    dst_near = sys.maxsize
    idx = -1
    for i in range(len(shape_pts)):
        dst = dist_meter(pt, shape_pts[i])
        if dst<dst_near:
            dst_near = dst
            idx = i
    return (idx, dst_near)

def process_trip(segements, stops, stop_pts, shape_pts, max_dist=300):
    """
    segements: {(from_id, to_id):[(x1, y1),...], ...}
    stops: [stop_id1,...]
    stop_pts: [(x1,y1), ...]
    stop_pts: [(x1,y1), ...]
    max_dist: Maximum distance, beyond which
    """
    n_error = 0
    for i in range(len(stops) - 1):
        from_stop = stops[i]
        to_stop = stops[i + 1]
        from_pos = stop_pts[i]
        to_pos = stop_pts[i + 1]
        if ((from_stop, to_stop) in segements) or ((to_stop, from_stop) in segements):
            continue

        i_idx1, dst1 = nearest_pos(from_pos, shape_pts)
        i_idx2, dst2 = nearest_pos(to_pos, shape_pts)
        if -1 == i_idx1 or -1 == i_idx2 or i_idx1 == i_idx2:
            print("Point not found: ", i_idx1, i_idx2)
            n_error += 1
            continue
        if dst1 > max_dist or dst2 > max_dist:
            print("Point too far: ", from_stop, to_stop)
            n_error += 1
            continue

        if i_idx1 < i_idx2:
            segements[(from_stop, to_stop)] = shape_pts[i_idx1:(i_idx2 + 1)]
        else:
            segements[(from_stop, to_stop)] = shape_pts[i_idx2:(i_idx1 + 1)]  # two direction are the same
    if n_error > 0:
        print("error stops: ", n_error)

#----------------------------------------- API
def extract_segment(segements, frm_trip, frm_stop, frm_stop_time, frm_shape, max_dist=300, testing=false):
    """

    :param segements: {(from_id, to_id):[(x1, y1),...], ...}
    :param frm_trip:
    :param frm_stop:
    :param frm_stop_time:
    :param frm_shape:
    :return:
    """
    stop_chain_key = {}  # 'key':0
    n = 0
    k1 = ''
    for i in frm_trip.index:
        if i % 100 == 0:
            print(i, "found: ", n)
        if i>500:
            break
        trip_id = frm_trip.iloc[i]['trip_id']
        stops = get_stops(frm_stop_time, trip_id)  # [stop_id1,...]

        # k1=str(stops)
        k1 = tuple(stops)  # [stop_id1, ...]
        if k1 in stop_chain_key:
            continue

        shape_id = frm_trip.iloc[i]['shape_id']
        shape_pts = get_points(frm_shape, shape_id)  # [(x1,y1), ...]

        # check all stops are avaliable
        stop_pts = []
        for stop_id in stops:
            pt = get_stop_pos(frm_stop, stop_id)
            if (pt == None):
                print("found one error")
                continue
            stop_pts.append(pt)

        process_trip(segements, stops, stop_pts, shape_pts, max_dist=max_dist)

        stop_chain_key[k1] = -1
        # stop_chain_key[str(stops.reverse())] = -1
        stops.reverse()
        stop_chain_key[tuple(stops)] = -1

        n += 1
        testing && break
    return segements
