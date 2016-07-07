#include satellite.mk

all: theodolite_data database #satellite

theodolite=../data/theodolite

theodolite_data: theodolite-processing/read-datafiles.py $(wildcard $(theodolite)/raw-data/*.GSI)
	echo "Processing"
	dos2unix $^
	python $^

database: setup-database.sql
	cat $^ | psql little-ambergris
