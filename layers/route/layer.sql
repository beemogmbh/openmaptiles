CREATE OR REPLACE FUNCTION layer_route(bbox geometry, zoom_level integer)
RETURNS TABLE(osm_id bigint, geometry geometry, class text, network text, ref text, name text) AS $$
    SELECT member AS osm_id, geometry, type AS class, network, ref, name
    FROM osm_route_relation_members
    WHERE zoom_level >= 10 AND zoom_level <= 14 AND geometry && bbox;
$$ LANGUAGE SQL IMMUTABLE;
