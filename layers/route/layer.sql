CREATE OR REPLACE VIEW route_z7toz14 AS
SELECT member AS osm_id, type, network, ref, name, geometry
FROM osm_route_relation_members;