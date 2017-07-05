SELECT
  id,
  name,
  color
FROM mapping.unit u
WHERE u.id IN (SELECT unit_id FROM mapping.unit_point)
