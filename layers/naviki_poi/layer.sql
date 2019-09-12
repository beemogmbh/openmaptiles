CREATE OR REPLACE FUNCTION layer_naviki_poi(bbox geometry, zoom_level integer, pixel_width numeric)
RETURNS TABLE(osm_id bigint, geometry geometry, name text, name_en text, name_de text, category text, website text, layer integer, level integer, indoor integer, "rank" int) AS $$
    SELECT * FROM 
    (
        SELECT 
            osm_id_hash AS osm_id, 
            geometry, 
            NULLIF(name, '') AS name,
            COALESCE(NULLIF(name_en, ''), NULLIF(name, '')) AS name_en,
            COALESCE(NULLIF(name_de, ''), NULLIF(name, ''), NULLIF(name_en, '')) AS name_de,
            NULLIF(category, ''),
            NULLIF(website, '') AS website,
            NULLIF(layer, 0) AS layer,
            "level",
            CASE WHEN indoor=TRUE THEN 1 ELSE NULL END as indoor,
            row_number() OVER (
                PARTITION BY LabelGrid(geometry, 100 * pixel_width), category
                ORDER BY priority DESC
            )::int AS "rank"
        FROM 
        (
            SELECT *,
            osm_id*10 AS osm_id_hash FROM osm_naviki_poi_point
            WHERE geometry && bbox AND category IS NOT NULL
           
            UNION ALL

            SELECT *,
            CASE 
                WHEN osm_id<0 THEN -osm_id*10+4
                ELSE osm_id*10+1
            END AS osm_id_hash FROM osm_naviki_poi_polygon
            WHERE geometry && bbox  AND category IS NOT NULL
        ) as poi_naviki_union 
        ORDER BY "rank") as poi_naviki_union_union 
    WHERE 
    (
        ("rank" <= 5 and zoom_level < 14) OR
        (zoom_level >= 14) 
    )
    ;
$$ LANGUAGE SQL IMMUTABLE;
