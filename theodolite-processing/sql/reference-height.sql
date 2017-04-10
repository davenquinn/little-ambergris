-- Second step optimization
/*
Basically, this first part
defines an identity transformation,
but we also append all items with
external elevation control
*/
SELECT
  t.id,
	t.collection,
	t.easting easting,
	t.northing northing,
	t.elevation elevation,
  -- Coordinates to reference
	t.easting raw_easting,
	t.northing raw_northing,
	t.elevation raw_elevation
FROM mapping.theodolite_reference r
JOIN mapping.theodolite_data t
  ON t.id = r.theodolite_point
WHERE r.use = true
  AND r.dgps_point IS NOT NULL
UNION ALL
SELECT
  t.id,
	t.collection,
	t.easting,
	t.northing,
	r.elevation, -- Only grab the new elevation data
  -- Now, we treat the first-step
  -- data as raw but add corrections by height
  t.easting raw_easting,
  t.northing raw_northing,
  t.elevation raw_elevation
FROM mapping.theodolite_reference r
JOIN mapping.theodolite_data t ON t.id = r.theodolite_point
WHERE r.use = true
  -- Items for which there is not a DGPS point
  AND r.dgps_point IS NULL;
