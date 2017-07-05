SELECT
  id,
  geometry::geometry geometry,
  arbitrary,
  certainty,
  'contact' AS type,
  null AS map_width,
  null AS pixel_width,
  null AS created
FROM mapping.contact
