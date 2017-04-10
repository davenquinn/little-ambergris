SELECT
  unit_id,
  ST_Multi(ST_Union(geometry)) geom,
  coalesce(color,'none') color
FROM map_topology.face_data
-- Ignore mixed units and non-mat area
WHERE secondary_unit_id IS NULL
  AND unit_id NOT IN (
    'ocean',
    'overgrown_channel',
    'dessicated_mat',
    'other_channel',
    'alkaline_pool')
GROUP BY unit_id, color
