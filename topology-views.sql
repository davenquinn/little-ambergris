-- The subunits of a unit
CREATE OR REPLACE FUNCTION mapping.subunits(text) RETURNS text[] AS $$
    SELECT ARRAY(SELECT id
      FROM mapping.unit_tree
      WHERE $1 = ANY(tree));
$$ LANGUAGE SQL;

CREATE OR REPLACE VIEW mapping.unit_tree AS
 WITH RECURSIVE t(member_of) AS (
         SELECT unit.member_of,
            unit.id::text AS id,
            ARRAY[unit.id::text] AS hierarchy,
            1 AS n_levels
           FROM mapping.unit
        UNION ALL
         SELECT u2.member_of,
            t_1.id,
            u2.id::text || t_1.hierarchy,
            t_1.n_levels + 1
           FROM t t_1
             JOIN mapping.unit u2 ON t_1.member_of = u2.id
        )
 SELECT DISTINCT ON (t.id) t.id,
    t.hierarchy AS tree,
    t.n_levels
   FROM t
  ORDER BY t.id, t.n_levels DESC;

-- Map face
DROP MATERIALIZED VIEW IF EXISTS map_topology.face_data CASCADE;
CREATE MATERIALIZED VIEW map_topology.face_data AS
  WITH face AS (
    SELECT
      face_1.face_id,
      ST_GetFaceGeometry('map_topology', face_1.face_id)::geometry AS geometry
    FROM map_topology.face face_1
    WHERE face_1.face_id <> 0),
  point AS (
    SELECT
      p.unit_id,
      p.geometry
    FROM mapping.unit_point p
    LEFT JOIN mapping.unit unit ON p.unit_id = unit.id)
  SELECT DISTINCT ON (face.face_id)
    face.face_id,
    face.geometry,
    unit.id AS unit_id,
    unit.color
  FROM face
    LEFT JOIN point ON ST_Intersects(face.geometry, point.geometry)
    LEFT JOIN mapping.unit unit ON point.unit_id = unit.id
  WHERE face.geometry IS NOT NULL;

CREATE OR REPLACE VIEW mapping.contact_data AS
  WITH edges AS (
      SELECT
        edge_id,
        geom,
        lf.unit_id left_unit,
        rf.unit_id right_unit
      FROM map_topology.edge_data e
      LEFT OUTER JOIN map_topology.face_data lf ON e.left_face = lf.face_id
      LEFT OUTER JOIN map_topology.face_data rf ON e.right_face = rf.face_id
      WHERE lf.face_id != rf.face_id),
  edge_intersection AS (
    SELECT
      edges.*,
      ARRAY (SELECT UNNEST(lt.tree) INTERSECT SELECT UNNEST(rt.tree)) tree_intersection
    FROM edges
    JOIN mapping.unit_tree lt ON left_unit = lt.id
    JOIN mapping.unit_tree rt ON right_unit = rt.id
    WHERE lt.tree != rt.tree)
  SELECT
    *,
    coalesce(array_length(tree_intersection,1),0) commonality
  FROM edge_intersection;

