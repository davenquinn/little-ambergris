-- Get points from database
SELECT
  id,
  'theodolite' as type,
  easting,
  northing,
  elevation
FROM theodolite
WHERE id != 0
UNION ALL
SELECT
  id,
  'dgps' as type,
  easting,
  northing,
  elevation
FROM dgps
WHERE id IS NOT NULL and easting != 0;

