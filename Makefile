data=../data
build=$(data)/derived
multispectral=$(build)/little-ambergris-8band-WV2-mosaic.tif

gdal=/usr/local/Cellar/gdal-20/HEAD/bin

all: $(build)/little-ambergris-visible.mbtiles mosaic

$(build):
	mkdir -p $@

$(build)/little-ambergris-visible.vrt: $(data)/Mosaic/Mosaic_WV2_50cm_Orthomosaic.tif
	$(gdal)/gdalwarp -t_srs EPSG:900913 -of VRT $^ $@

$(build)/little-ambergris-visible.mbtiles: $(data)/Mosaic/Mosaic_WV2_50cm_Orthomosaic.tif | $(build)
	 $(gdal)/gdal_translate -of mbtiles $^ $@

images=7-24-2012_50cm_8BandPS_Ortho.tif 3-25-2013_50cm_8BandPS_Ortho.tif

$(multispectral): $(addprefix $(data)/Mosaic/,$(images))
	$(gdal)/gdalwarp -srcnodata 0 -dstalpha -t_srs EPSG:900913 $^ $@

$(build)/little-ambergris-WV2-vegetation-765.vrt: $(multispectral)
	# Vegetation index (mimics NDVI)
	$(gdal)/gdal_translate -b 7 -b 6 -b 5 -of VRT -ot Byte -scale $^ $@


PHONY: clean mosaic
clean:
	rm -f $(build)/*.vrt
mosaic: $(multispectral)
