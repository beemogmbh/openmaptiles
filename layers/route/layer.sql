CREATE OR REPLACE FUNCTION layer_route(bbox geometry, zoom_level integer)
RETURNS TABLE(osm_id bigint, geometry geometry, class text, network text, ref text, name text) AS $$
    SELECT member AS osm_id, geometry, type AS class, network, ref, name
    FROM (

        SELECT member, geometry, type, network, ref, name
        FROM osm_route_relation_members_gen5
        WHERE zoom_level = 10
        
        UNION ALL

        SELECT member, geometry, type, network, ref, name
        FROM osm_route_relation_members_gen4
        WHERE zoom_level = 11
        
        UNION ALL

        SELECT member, geometry, type, network, ref, name
        FROM osm_route_relation_members_gen3
        WHERE zoom_level = 12
        
        UNION ALL

        SELECT member, geometry, type, network, ref, name
        FROM osm_route_relation_members_gen2
        WHERE zoom_level = 13
        
        UNION ALL

        SELECT member, geometry, type, network, ref, name
        FROM osm_route_relation_members_gen1
        WHERE zoom_level >= 14

    ) AS zoom_levels
    WHERE geometry && bbox;

$$ LANGUAGE SQL IMMUTABLE;
