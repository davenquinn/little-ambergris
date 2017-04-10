from database import db,run_query
from affine import Affine
import numpy as N

def augment(a):
    """Add a final column of ones to input data"""
    arr = N.ones((a.shape[0],a.shape[1]+1))
    arr[:,:-1] = a
    return arr

def process_collection(ref, theodolite):
    """
    Process theodolite correction points for a single set
    of joined data (typically, a single session with the
    base station fixed).
    """

    from_coords = ref.iloc[:,4:7]
    to_coords = ref.iloc[:,1:4]

    if N.allclose(from_coords, to_coords):
        print("Identity transform")
        return from_coords

    # https://igl.ethz.ch/projects/ARAP/svd_rot.pdf

    center = lambda x: x-x.mean()

    from_centered = N.array(from_coords-from_coords.mean())
    to_centered = N.array(to_coords-to_coords.mean())

    X = from_centered.T
    Y = to_centered.T

    cov = X@Y.T

    U,s,V = N.linalg.svd(cov,full_matrices=False)
    A = N.eye(U.shape[1])
    A[-1,-1] = N.linalg.det(V.T@U.T)

    R = V.T@A@U.transpose()

    T = N.array(to_coords.mean())-R@N.array(from_coords.mean())

    sol = R@X
    err = (to_centered.T-sol)**2
    rms_ax = N.sqrt(err.sum(axis=1)/3)
    rms_pt = N.sqrt(err.sum(axis=0)/len(err))


    # Apply transformation to dataset
    points = N.array(theodolite.ix[:,0:3])

    # Convert to homogeneous coordinates and transform
    Ra = N.hstack((R,T[:,N.newaxis]))

    if R[2,2] < 0:
        # Reflect around line between tie points
        # http://ami.ektf.hu/uploads/papers/finalpdf/AMI_40_from175to186.pdf
        coords = N.array(from_coords)
        v1 = coords[1]-coords[0]
        v2 = N.array([0,0,1])
        n = N.cross(v1,v2)
        c = n/N.linalg.norm(n)

        T = N.eye(4)
        T[:3,3] = coords[0]

        Refl = N.eye(4)
        Refl[:3,:3] -= 2*N.outer(c,c)
        #Refl[:3,3] -= 2*c*coords[0]

        Tinv = N.eye(4)
        Tinv[:3,3] -= coords[0]

        Ra = Ra@T@Refl@Tinv

    data = augment(points)@Ra.T

    print(to_coords.shape)
    print(f"RMS error (pointwise): {rms_pt}")
    print(f"RMS error (x y z): {rms_ax}")
    print()
    return data

def reference_theodolite(ref_data, theodolite_data):

    collections = ref_data['collection']

    for coll in collections.unique():
        print(coll)
        ref = ref_data.ix[collections == coll]

        loc = theodolite_data.collection == coll
        theo = theodolite_data.loc[loc]

        theodolite_data.ix[loc,4:7] = process_collection(ref, theo)
    return theodolite_data

# First-stage reference data
ref_data = run_query(
    "theodolite-processing/sql/reference-data.sql",
    index_col='id')
data = run_query(
    "SELECT * FROM mapping.theodolite_data",
    index_col='id')

data = reference_theodolite(ref_data, data)

data.to_sql('theodolite_data', db, schema='mapping',
    if_exists='replace', index=True)

### TODO: Second-stage transform doesn't work yet
# Output of first stage becomes input to second
# But everything is an identity transform
# ref_data2 = run_query(
    # "theodolite-processing/sql/reference-height.sql",
    # index_col='id')
# step2data = run_query(
    # "SELECT * FROM mapping.theodolite_data",
    # index_col='id')
# data2 = reference_theodolite(ref_data2, step2data)

# data2.to_sql('theodolite_data', db, schema='mapping',
    # if_exists='replace', index=True)

