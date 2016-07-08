DROP VIEW mapping.dgps;
CREATE VIEW mapping.dgps AS
  SELECT
    *,
    ST_SetSRID(ST_Point(easting, northing),32619) geometry
  FROM mapping.dgps_data;
