-- etldoc: layer_landmark[shape=record fillcolor=lightpink, style="rounded,filled",
-- etldoc:     label="layer_landmark | <z12> z12 | <z13> z13 | <z14_> z14+" ] ;

CREATE OR REPLACE FUNCTION layer_landmark(bbox geometry, zoom_level integer, pixel_width numeric)
RETURNS TABLE(osm_id bigint, geometry geometry, name text, name_en text, name_de text, tags hstore, class text, "rank" int) AS $$
    SELECT osm_id_hash AS osm_id, geometry, NULLIF(name, '') AS name,
        COALESCE(NULLIF(name_en, ''), name) AS name_en,
        COALESCE(NULLIF(name_de, ''), name, name_en) AS name_de,
        tags,
        landmark_class(mapping_key, mapping_value) AS class,
        row_number() OVER (
            PARTITION BY LabelGrid(geometry, 100 * pixel_width)
            ORDER BY CASE WHEN name = '' THEN 2000 ELSE landmark_class_rank(landmark_class(mapping_key, mapping_value)) END ASC
        )::int AS "rank"
    FROM (
        -- etldoc: osm_landmark_point ->  layer_landmark:z12
        -- etldoc: osm_landmark_point ->  layer_landmark:z13
        SELECT *,
            osm_id*10 AS osm_id_hash FROM osm_landmark_point
            WHERE geometry && bbox
                AND zoom_level BETWEEN 12 AND 13
                AND mapping_key = 'railway' AND mapping_value = 'station'
        
        UNION ALL

        -- etldoc: osm_landmark_point ->  layer_landmark:z14_
        SELECT *,
            osm_id*10 AS osm_id_hash FROM osm_landmark_point
            WHERE geometry && bbox
                AND zoom_level >= 14
                AND NOT (mapping_key = 'historic' AND mapping_value = 'memorial' AND memorial NOT IN ('stele', 'obelisk'))
                AND NOT (mapping_key = 'man_made' AND mapping_value = 'tower' AND tower_type NOT IN 
                    ('communication', 'elevator_test', 'observation', 'defensive', 'monument'))
                AND NOT (tower_type = 'monument' AND historic != 'yes')
                AND NOT (mapping_key = 'landuse' AND mapping_value = 'recreation_ground' AND sport != 'swimming')
        
        UNION ALL

        -- etldoc: osm_landmark_polygon ->  layer_landmark:z12
        -- etldoc: osm_landmark_polygon ->  layer_landmark:z13
        SELECT *,
            CASE WHEN osm_id<0 THEN -osm_id*10+4
                ELSE osm_id*10+1
            END AS osm_id_hash
        FROM osm_landmark_polygon
            WHERE geometry && bbox
                AND zoom_level BETWEEN 12 AND 13
                AND mapping_key = 'railway' AND mapping_value = 'station'
        
        UNION ALL
        
        -- etldoc: osm_landmark_polygon ->  layer_landmark:z14_
        SELECT *,
            CASE WHEN osm_id<0 THEN -osm_id*10+4
                ELSE osm_id*10+1
            END AS osm_id_hash
        FROM osm_landmark_polygon
            WHERE geometry && bbox
                AND zoom_level >= 14
                AND NOT (mapping_key = 'historic' AND mapping_value = 'memorial' AND memorial NOT IN ('stele', 'obelisk'))
                AND NOT (mapping_key = 'man_made' AND mapping_value = 'tower' AND tower_type NOT IN 
                    ('communication', 'elevator_test', 'observation', 'defensive', 'monument'))
                AND NOT (tower_type = 'monument' AND historic != 'yes')
                AND NOT (mapping_key = 'landuse' AND mapping_value = 'recreation_ground' AND sport != 'swimming')
                
        ) as landmark_union
    ORDER BY "rank"
    ;
$$ LANGUAGE SQL IMMUTABLE;
