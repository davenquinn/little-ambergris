data=../data
build=$(data)/derived

gdal=/usr/local/Cellar/gdal-20/HEAD/bin

all: $(build)/little-ambergris-visible.mbtiles

$(build):
	mkdir -p $@

$(build)/little-ambergris-visible.vrt: $(data)/Mosaic/Mosaic_WV2_50cm_Orthomosaic.tif
	$(gdal)/gdalwarp -t_srs EPSG:900913 -of VRT $^ $@

$(build)/little-ambergris-visible.mbtiles: $(data)/Mosaic/Mosaic_WV2_50cm_Orthomosaic.tif | $(build)
	 $(gdal)/gdal_translate -of mbtiles $^ $@
