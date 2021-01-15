CREATE OR REPLACE FUNCTION layer_rcn_ref_label(bbox geometry, zoom_level integer)
RETURNS TABLE(osm_id bigint, geometry geometry, rcn_ref_num text) AS $$
    SELECT id AS osm_id, geometry, rcn_ref_num
    FROM osm_rcn_ref_point
    WHERE zoom_level >= 10 AND zoom_level <= 14 AND geometry && bbox;
$$ LANGUAGE SQL IMMUTABLE;
