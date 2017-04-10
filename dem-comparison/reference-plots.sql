SELECT
m.*
FROM mapping.dem_reference m
JOIN mapping.theodolite_data t
  ON t.id = m.id
  AND m.type = 'theodolite'
  WHERE m.collection != 'July7';
