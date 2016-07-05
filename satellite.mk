data=/Volumes/Lilienthal/Ambergris-2016/Satellite
build=$(data)/derived
multispectral=$(build)/little-ambergris-8band-WV2-mosaic.tif

gdal=/usr/local/Cellar/gdal-20/HEAD/bin

$(build):
	mkdir -p $@

$(build)/little-ambergris-visible.vrt: $(data)/Mosaic/Mosaic_WV2_50cm_Orthomosaic.tif
	$(gdal)/gdalwarp -t_srs EPSG:900913 -r lanczos -of VRT $^ $@

$(build)/little-ambergris-visible.mbtiles: $(data)/Mosaic/Mosaic_WV2_50cm_Orthomosaic.tif | $(build)
	 $(gdal)/gdal_translate -of mbtiles $^ $@
	 $(gdal)/gdaladdo $@ 2 4 8 16 32 64 128 256 512 1024 2048 4096 8192

images=7-24-2012_50cm_8BandPS_Ortho.tif 3-25-2013_50cm_8BandPS_Ortho.tif

$(multispectral): $(addprefix $(data)/Mosaic/,$(images))
	$(gdal)/gdalwarp -r lanczos -srcnodata 0 -t_srs EPSG:900913 $^ $@

PHONY: clean mosaic bandmaps mbtiles
clean:
	rm -f $(build)/*.vrt
mosaic: $(multispectral)

bandmap_dir=$(build)/bandmaps
$(bandmap_dir):
	mkdir -p $@

bandmaps: make-bandmaps.py band-data.csv $(multispectral) $(bandmap_dir)
	python3 $^

%.mbtiles: %.vrt | $(build)
	 $(gdal)/gdal_translate -of mbtiles $^ $@
	 $(gdal)/gdaladdo -r average $@ 2 4 8 16 32 64 128 256 512 1024 2048 4096 8192


vrtfiles=$(wildcard $(bandmap_dir)/*.vrt)
mbtiles_files=$(subst .vrt,.mbtiles,$(vrtfiles))

mbtiles: $(mbtiles_files)
