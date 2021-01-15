CREATE OR REPLACE FUNCTION layer_power_line(bbox geometry, zoom_level integer)
RETURNS TABLE(osm_id bigint, geometry geometry, cables text) AS $$
    SELECT osm_id, geometry, cables
    FROM osm_power_lines_gen1
    WHERE geometry && bbox AND zoom_level >= 14;
$$ LANGUAGE SQL IMMUTABLE
                PARALLEL SAFE;
