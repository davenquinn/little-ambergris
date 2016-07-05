#include satellite.mk

all: theodolite_data #satellite

theodolite=../data/theodolite

theodolite_data: theodolite-processing/read-datafiles.py $(wildcard $(theodolite)/raw-data/*.GSI)
	echo "Processing"
	dos2unix $^
	python $^
