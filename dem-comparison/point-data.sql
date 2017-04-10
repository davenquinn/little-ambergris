-- Get points from database
SELECT
  id,
  'theodolite' as type,
  easting,
  northing,
  elevation,
  collection
FROM theodolite
WHERE id != 0
  -- Get rid of this for now because it is
  -- misreferenced
  AND collection != 'July7'
UNION ALL
SELECT
  id,
  'dgps' as type,
  easting,
  northing,
  elevation,
  'dgps' as collection
FROM dgps
WHERE id IS NOT NULL
  AND easting != 0
  -- Only get well-correlated measurements
  AND rms_elevation < 0.1;
