all: theodolite database drone_data #satellite

dbname=little-ambergris
data:=/Volumes/Lilienthal/Ambergris-2016
mbtiles_overview_levels:=2 4 8 16 32 64 128 256 512 1024 2048 4096 8192
theodolite=../data/theodolite

web_mercator=EPSG:3857

%.mbtiles: %.vrt
	gdal_translate -of mbtiles $^ $@
	gdaladdo -r average $@ $(mbtiles_overview_levels)

include drone-data.mk
#include satellite.mk

psql=psql $(dbname)

drop_views:
	$(psql) -c "DROP VIEW IF EXISTS mapping.elevation_data;"
	$(psql) -c "DROP VIEW IF EXISTS mapping.dgps;"
	$(psql) -c "DROP VIEW IF EXISTS mapping.theodolite;"
	$(psql) -c "DROP VIEW IF EXISTS mapping.reference_errors;"

heights=$(theodolite)/theodolite-data-updated-staff.xlsx
theodolite: $(heights) $(wildcard $(theodolite)/raw-data/*.GSI) | drop_views
	python theodolite-processing/read-datafiles.py $^
	python theodolite-processing/reference-theodolite.py
	$(psql) -f create-views.sql

database:
	-$(psql) -f setup-database.sql
	$(psql) -f create-views.sql

dgps: import-dgps.py $(data)/DGPS/all-data.txt | drop_views
	python $^
	$(psql) -f create-views.sql
