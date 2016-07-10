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

DROP VIEW mapping.reference_errors;
CREATE VIEW mapping.reference_errors AS
  WITH q AS (SELECT
      t.id,
      t.collection,
      ST_SetSRID(ST_MakeLine(
        ST_Point(g.easting, g.northing),
        ST_Point(t.easting, t.northing)),32619) geometry,
      g.elevation
    FROM mapping.theodolite_reference r
    JOIN mapping.dgps_data g ON g.id = r.dgps_point
    JOIN mapping.theodolite_data t ON t.id = r.theodolite_point)
  SELECT
    *,
    ST_Length(geometry) length
  FROM q;

DROP VIEW mapping.elevation_data;
CREATE VIEW mapping.elevation_data AS
  WITH dgps AS (
    SELECT
      id,
      'dgps'::text instrument,
      geometry,
      elevation
    FROM mapping.dgps),
    theodolite AS (
      SELECT
        -id id,
        'theodolite'::text instrument,
        geometry,
        elevation
      FROM mapping.theodolite)
  SELECT * FROM dgps
  UNION ALL
  SELECT * FROM theodolite;
