data="/Users/Daven/Projects/Turks\ and\ Caicos/data"
build=$(data)/derived

gdal_translate=/usr/local/Cellar/gdal-20/HEAD/bin/gdal_translate

all: $(build)/little-ambergris-visible.mbtiles | $(build)

$(build):
	mkdir -p $@

$(build)/little-ambergris-visible.mbtiles: $(data)/Mosaic/Mosaic_WV2_50cm_Orthomosaic.tif
	 $(gdal_translate) -of mbtiles $^ $@
