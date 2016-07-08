from sys import argv
from functools import reduce
import re
from pathlib import Path
from io import StringIO
from pandas import read_table, Series, concat
from IPython import embed
from datetime import datetime

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
    with open(fn) as f:
        text = ''
        for line in f:
            text += clean(line)+'\n'
        cleaned = StringIO(text)
        df = read_table(cleaned, header=None, delim_whitespace=True,
                    index_col=0, dtype=int,names=["id","easting","northing","elevation"])
        n = Path(f.name).stem
        df['collection'] = Series([n]*len(df), index=df.index)
        for i in ['northing','easting','elevation']:
            df[i] /= 1000
        return df

data = concat([read_data(fn) for fn in argv[1:]])
data.to_excel("../data/theodolite/raw-theodolite-data.xlsx")

embed()
