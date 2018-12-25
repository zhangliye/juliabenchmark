from pathlib import Path
import pandas as pd
import time

import sys
lib_path = Path("../src").resolve()
print(lib_path)
sys.path.append( lib_path.as_posix() )
import extract_segment

def show_t(t0, t1):
    print("  %.2f seconds" % (t1 - t0))

gtfs_dir = Path("../data/google_transit_manhattan").resolve()
print(gtfs_dir)

print("Open `shapes.txt`")
t0 = time.time()
frm_shape = pd.read_csv(gtfs_dir.joinpath("shapes.txt").as_posix(), dtype={'shape_id': str})
t1 = time.time()
show_t(t0, t1)

## get stop ids of shape
print("Open `stop_times.txt`")
t0 = time.time()
frm_stop_time = pd.read_csv(gtfs_dir.joinpath("stop_times.txt").as_posix(), dtype={'stop_id': str, 'shape_id': str})
t1 = time.time()
show_t(t0, t1)

print("Open `trips.txt`")
t0 = time.time()
frm_trip = pd.read_csv(gtfs_dir.joinpath("trips.txt").as_posix(), dtype={'trip_id': str, 'shape_id': str})
t1 = time.time()
show_t(t0, t1)

print("Open `stops.txt`")
t0 = time.time()
frm_stop = pd.read_csv(gtfs_dir.joinpath("stops.txt").as_posix(), dtype={'stop_id': str})
t1 = time.time()
show_t(t0, t1)

print("The running time of processing 500 rows")
t0 = time.time()
segements = {}
extract_segment.extract_segment(segements, frm_trip, frm_stop, frm_stop_time, frm_shape)
t1 = time.time()
show_t(t0, t1)
