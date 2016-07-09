DROP VIEW mapping.dgps;
CREATE VIEW mapping.dgps AS
  SELECT
    *,
    ST_SetSRID(ST_Point(easting, northing),32619) geometry
  FROM mapping.dgps_data;

DROP VIEW mapping.theodolite;
CREATE VIEW mapping.theodolite AS
  SELECT
    t.*,
    ST_SetSRID(ST_Point(t.easting, t.northing),32619) geometry,
    (r.theodolite_point IS NOT NULL) reference_point
  FROM mapping.theodolite_data t
  LEFT JOIN mapping.theodolite_reference r ON r.theodolite_point = t.id;
