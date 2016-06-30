#!/usr/bin/env python
"""
Script to build bandmaps for 8-band WV2 imagery.
Takes band_data, srcfile, and dst-dir input arguments.
"""
from sys import argv
from subprocess import run
from pandas import read_csv
from os.path import join

gdal_translate = "/usr/local/Cellar/gdal-20/HEAD/bin/gdal_translate"

band_data = read_csv(argv[1]).applymap(str)
srcfile = argv[2]
dstdir = argv[3]

for i,row in band_data.iterrows():
    out = join(
        dstdir,
        "little-ambergris-{band_1}{band_2}{band_3}_{id}.vrt"
        .format(**row.to_dict()))

    cmd = [gdal_translate,'-b',row.band_1,
           '-b',row.band_2,'-b',row.band_3,
           '-of','VRT','-ot','Byte','-scale', srcfile, out]
    print(" ".join(cmd))
    run(cmd)
