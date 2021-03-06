from pandas import read_sql
from sqlalchemy import create_engine

db = create_engine("postgresql:///little-ambergris")

def run_query(fn, **kwargs):
    if "SELECT" in str(fn):
        # We are working with a query string instead of
        # an SQL file.
        sql = fn
    else:
        with open(fn) as f:
            sql = f.read()

    return read_sql(sql,db,**kwargs)

