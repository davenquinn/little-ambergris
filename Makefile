#include satellite.mk

all: theodolite_data database #satellite

dbname=little-ambergris
data=../remote-data
theodolite=../data/theodolite

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
