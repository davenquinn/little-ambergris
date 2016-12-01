om=$(data)/drone-mapping/orthomosaics
build=$(om)/build

$(build):
	mkdir -p $@

$(build)/%.vrt: $(om)/%.tif | $(build)
	gdalwarp -t_srs EPSG:3857 -r lanczos -of VRT $^ $@

drone_data: $(build)/full_res_orthomosaic_no_ctrl_pts.mbtiles
