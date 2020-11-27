-- TODO use materialized views later
CREATE OR REPLACE VIEW route_z10 AS (
    SELECT member, geometry, type, network, ref, name FROM osm_route_relation_members_gen4
);
CREATE OR REPLACE VIEW route_z11 AS (
    SELECT member, geometry, type, network, ref, name FROM osm_route_relation_members_gen3
);
CREATE OR REPLACE VIEW route_z12 AS (
    SELECT member, geometry, type, network, ref, name FROM osm_route_relation_members_gen2
);
CREATE OR REPLACE VIEW route_z13 AS (
    SELECT member, geometry, type, network, ref, name FROM osm_route_relation_members_gen1
);

CREATE OR REPLACE VIEW route_z14 AS (
    SELECT member, geometry, type, network, ref, name FROM osm_route_relation_members
);

CREATE OR REPLACE FUNCTION layer_route(bbox geometry, zoom_level integer)
RETURNS TABLE(osm_id bigint, geometry geometry, class text, network text, ref text, name text) AS $$
    SELECT member AS osm_id, geometry, type AS class, network, ref, name
    FROM (

        SELECT * FROM route_z10 WHERE zoom_level = 10
        
        UNION ALL

        SELECT * FROM route_z11 WHERE zoom_level = 11
        
        UNION ALL

        SELECT * FROM route_z12 WHERE zoom_level = 12
        
        UNION ALL

        SELECT * FROM route_z13 WHERE zoom_level = 13
        
        UNION ALL

        SELECT * FROM route_z14 WHERE zoom_level >= 14

    ) AS zoom_levels
    WHERE geometry && bbox;

$$ LANGUAGE SQL IMMUTABLE;
