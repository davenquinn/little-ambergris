SELECT
  id,
  unit_id,
  ST_Buffer(geometry, 1) geometry
FROM mapping.unit_point
