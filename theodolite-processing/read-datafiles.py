from sys import argv
from functools import reduce
import re
from pathlib import Path
from io import StringIO
from pandas import read_table, read_excel, Series, concat
from IPython import embed
from datetime import datetime
from sqlalchemy import create_engine
import numpy as N

subs = [
    ("\+0+"," +0"),
    ("-0+"," -0"),
    ("^110",""),
    ("\s+"," ")]
for i in (81,82,83):
    subs.append(("{}\.\.00".format(i)," "))

subs = [(re.compile(s),v) for s,v in subs]
def clean(text):
    for s,v in subs:
        text = re.sub(s,v,text)
    return text

def read_data(fn):
    names = ["easting","northing","elevation"]
    raw_names = ['raw_'+i for i in names]
    with open(fn) as f:
        text = ''
        for line in f:
            text += clean(line)+'\n'
        cleaned = StringIO(text)
        df = read_table(cleaned, header=None, delim_whitespace=True,
                    index_col=0, dtype=int,
                    names=["id"]+raw_names)
        n = Path(f.name).stem
        df['collection'] = Series([n]*len(df), index=df.index)
        for i in raw_names:
            df[i] /= 1000
        for i in names:
            df[i] = N.nan
        df['origin_distance'] = N.linalg.norm(df.loc[:,['raw_easting','raw_northing']],axis=1)
        return df

# Collect and deal with staff height
meas = read_excel(argv[1], index_col=2)
meas.drop(
    ['Depth to 1st first crust','Depth to 2nd crust','Date'],
    inplace=True, axis=1)
meas.rename(
    columns={
        'Deepest Depth Measurement (cm)':'depth',
    }, inplace=True)
meas.rename(columns=lambda x: x.lower(), inplace=True)

data = concat([read_data(fn) for fn in argv[2:]],
        ignore_index=True)

# Get rid of data inconsistencies
data.drop([1,2,3,4,15], inplace=True)

data.set_index('id',inplace=True)

data = data.join(meas)
assumed_staff_height = 1.5
correction = assumed_staff_height - data['staff height']
data['raw_elevation'] += correction

engine = create_engine("postgresql:///little-ambergris")

data.to_sql('theodolite_data', engine, schema='mapping',
    if_exists='replace')

