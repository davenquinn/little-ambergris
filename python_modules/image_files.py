from pathlib import Path
from os import getenv

project = Path(getenv('PROJECT_DIR'))
datadir = project/'remote-data'

DEM = datadir/"drone-dem-07-Mar-2017/drone-dem/AmbergrisDEM_UTM19N.tif"
