sdata=$(data)/Satellite
build=$(sdata)/derived
multispectral=$(build)/little-ambergris-8band-WV2-mosaic.tif

# Requires GDAL 2.0

%.mbtiles: %.vrt
	gdal_translate -of mbtiles $^ $@
	gdaladdo -r average $@ $(mbtiles_overview_levels)

$(build):
	mkdir -p $@

$(build)/little-ambergris-visible.vrt: $(sdata)/Mosaic/Mosaic_WV2_50cm_Orthomosaic.tif
	gdalwarp -t_srs $(web_mercator) -r lanczos -of VRT $^ $@

$(build)/little-ambergris-visible.mbtiles: $(sdata)/Mosaic/Mosaic_WV2_50cm_Orthomosaic.tif | $(build)
	 gdal_translate -of mbtiles $^ $@
	 gdaladdo $@ $(mbtiles_overview_levels)

images=7-24-2012_50cm_8BandPS_Ortho.tif 3-25-2013_50cm_8BandPS_Ortho.tif

$(multispectral): $(addprefix $(sdata)/Mosaic/,$(images))
	gdalwarp -r lanczos -srcnodata 0 -t_srs $(web_mercator) $^ $@

.PHONY: clean mosaic bandmaps mbtiles satellite
clean:
	rm -f $(build)/*.vrt
mosaic: $(multispectral)

bandmap_dir=$(build)/bandmaps
$(bandmap_dir):
	mkdir -p $@

bandmaps: make-bandmaps.py band-data.csv $(multispectral) $(bandmap_dir)
	python3 $^

vrtfiles=$(wildcard $(bandmap_dir)/*.vrt)
mbtiles_files=$(subst .vrt,.mbtiles,$(vrtfiles))

mbtiles: $(mbtiles_files)

satellite: mosaic mbtiles
