-- Set up a database for mapping Little Ambergris Cay
CREATE EXTENSION "postgis";
CREATE EXTENSION "postgis_topology";
CREATE SCHEMA IF NOT EXISTS "mapping";

-- CREATE topology in UTM zone 19N (WGS84)
SELECT topology.CreateTopology('map_topology',32619);

CREATE TABLE IF NOT EXISTS mapping.facies (
  id    char(255) PRIMARY KEY,
  color text
)
-- COPY mapping.facies FROM ../data/facies.txt (DELIMITER(','));


CREATE TABLE IF NOT EXISTS contact (
    id serial PRIMARY KEY,
    arbitrary boolean DEFAULT false
);
SELECT topology.AddTopoGeometryColumn('map_topology','mapping','contact','geometry','LINESTRING');

CREATE TABLE IF NOT EXISTS mapping.facies_point (
    id serial PRIMARY KEY,
    facies_id char(255) REFERENCES mapping.facies (id) ON UPDATE CASCADE,
    geometry geometry('Point',32619)
);

