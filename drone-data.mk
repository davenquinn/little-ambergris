om=$(data)/drone-mapping/orthomosaics
build=$(om)/build

$(build):
	mkdir -p $@

$(build)/%.tif: $(om)/%.tif | $(build)
	gdalwarp -t_srs $(web_mercator) -r lanczos -of GTiff $^ $@

$(build)/%.mbtiles: $(build)/%.tif
	gdal_translate -of mbtiles $^ $@
	gdaladdo -r average $@ $(mbtiles_overview_levels)

drone_data: $(build)/full_res_orthomosaic_no_ctrl_pts.mbtiles
