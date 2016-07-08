#include satellite.mk

all: theodolite_data database #satellite

dbname=little-ambergris
theodolite=../data/theodolite

theodolite_data: theodolite-processing/read-datafiles.py $(wildcard $(theodolite)/raw-data/*.GSI)
	python $^

database:
	-psql $(dbname) -f setup-database.sql
	psql $(dbname) -f create-views.sql

dgps: import-dgps.py ../remote-data/DGPS/all-data.txt
	python $^
