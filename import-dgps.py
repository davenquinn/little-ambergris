from sys import argv
from pandas import read_table
from sqlalchemy import create_engine
from IPython import embed

df = read_table(argv[1], delimiter=',', index_col=0)

df.drop([
    "Elevation (Final Averaged)",
    "Northing (Final Averaged)",
    "Easting (Final Averaged)",
    "Ellipsoid Height",
    "Latitude",
    "Longitude"],
    axis=1, inplace=True)

df.index.name = 'id'
df.columns = map(str.lower, df.columns)
_ = lambda x: x.replace(' ','_')
df.columns = map(_, df.columns)

engine = create_engine("postgresql:///little-ambergris")

df.to_sql('dgps_data', engine, schema='mapping',
    if_exists='replace', index=True)

embed()

