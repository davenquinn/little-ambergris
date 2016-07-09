SELECT
  t.id,
	t.collection,
	g.easting,
	g.northing,
	g.elevation,
	t.raw_easting raw_easting,
	t.raw_northing raw_northing,
	t.raw_elevation raw_elevation
FROM mapping.theodolite_reference r
JOIN mapping.dgps_data g ON g.id = r.dgps_point
JOIN mapping.theodolite_data t ON t.id = r.theodolite_point;
