WITH a AS (
SELECT
  CASE WHEN unit_id = 'desiccated_mat' THEN
    'blister_mat'
  ELSE unit_id END AS unit_id,
  geometry,
  is_mat
FROM map_topology.face_data
-- Ignore mixed units and non-mat area
WHERE secondary_unit_id IS NULL
  AND unit_id NOT IN (
    'ocean',
    'overgrown_channel',
    'dessicated_mat',
    'other_channel',
    'alkaline_pool')
),
b AS (
SELECT
  unit_id,
  ST_Multi(ST_Union(geometry)) geom
FROM a
GROUP BY unit_id
)
SELECT
  b.*,
  u.color,
  (u.member_of = 'mat' OR u.id = 'crusty_bay') is_mat,
  u.name
FROM b
JOIN mapping.unit u
  ON unit_id = u.id

