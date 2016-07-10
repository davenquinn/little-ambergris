from IPython import embed
from database import db,run_query
from affine import Affine
import numpy as N

def augment(a):
    """Add a final column of ones to input data"""
    arr = N.ones((a.shape[0],a.shape[1]+1))
    arr[:,:-1] = a
    return arr

ref_data = run_query("theodolite-processing/sql/reference-data.sql",
            index_col='id')

theodolite_data = run_query("SELECT * FROM mapping.theodolite_data",
            index_col='id')

collections = ref_data['collection'].unique()

for coll in collections:
    loc = ref_data['collection'] == coll
    ref = ref_data.ix[loc]
    fromCoords = augment(N.array(ref.iloc[:,4:7]))

    from_coords = ref.iloc[:,4:7]
    to_coords = ref.iloc[:,1:4]

    center = lambda x: x-x.mean()

    from_centered = from_coords-from_coords.mean()
    to_centered = to_coords-to_coords.mean()

    X = N.array(from_centered).transpose()
    Y = N.array(to_centered).transpose()

    cov = X@Y.transpose()

    U,s,V = N.linalg.svd(cov,full_matrices=False)
    A = N.eye(U.shape[1])
    A[-1,-1] = N.linalg.det(V@U.T)

    R = -V@A@U.transpose()
    T = N.array(to_coords.mean())-R@N.array(from_coords.mean())

    # Apply transformation to dataset
    loc = theodolite_data['collection'] == coll
    points = N.array(theodolite_data.ix[loc,0:3])#-N.array(from_coords.mean())
    data = points@R.T+T

    print(coll)
    print(R)
    print(T)

    theodolite_data.ix[loc,4:7] = data

theodolite_data.to_sql('theodolite_data', db, schema='mapping',
    if_exists='replace', index=True)

