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
    fromCoords = augment(N.array(ref.iloc[:,4:7])).transpose()
    toCoords = N.array(ref.iloc[:,1:4]).transpose()

    # Affine transformation matrix (3x4)
    # can be augmented with a final [0,0,0,1] if desired
    A = toCoords@N.linalg.pinv(fromCoords)

    # trans_matrix, residuals, rank, sv = N.linalg.lstsq(augment(fromCoords), toCoords)

    sol = A@fromCoords

    errors = toCoords-sol
    print(A, errors)

    # Apply transformation to dataset
    loc = theodolite_data['collection'] == coll
    points = N.array(theodolite_data.ix[loc,0:3])
    data = A@augment(points).transpose()
    theodolite_data.ix[loc,4:7] = data.transpose()

theodolite_data.to_sql('theodolite_data', db, schema='mapping',
    if_exists='replace', index=True)

embed()

