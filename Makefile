#include satellite.mk

all: theodolite_data database #satellite

dbname=little-ambergris
data=../remote-data
theodolite=../data/theodolite

psql=psql $(dbname)

theodolite: $(wildcard $(theodolite)/raw-data/*.GSI)
	$(psql) -c "DROP VIEW IF EXISTS mapping.theodolite;"
	$(psql) -c "DROP VIEW IF EXISTS mapping.reference_errors;"
	python theodolite-processing/read-datafiles.py $^
	python theodolite-processing/reference-theodolite.py
	$(psql) -f create-views.sql

database:
	-$(psql) -f setup-database.sql
	$(psql) -f create-views.sql

dgps: import-dgps.py $(data)/DGPS/all-data.txt
	$(psql) -c "DROP VIEW IF EXISTS mapping.dgps;"
	$(psql) -c "DROP VIEW IF EXISTS mapping.reference_errors;"
	python $^
	$(psql) -f create-views.sql
