CREATE OR REPLACE FUNCTION landmark_class_rank(class TEXT) -- TODO
RETURNS INT AS $$
    SELECT CASE class
        WHEN 'hospital' THEN 20
        WHEN 'railway' THEN 40
        WHEN 'bus' THEN 50
        WHEN 'attraction' THEN 70
        WHEN 'harbor' THEN 75
        WHEN 'college' THEN 80
        WHEN 'school' THEN 85
        WHEN 'stadium' THEN 90
        WHEN 'zoo' THEN 95
        WHEN 'town_hall' THEN 100
        WHEN 'campsite' THEN 110
        WHEN 'cemetery' THEN 115
        WHEN 'park' THEN 120
        WHEN 'library' THEN 130
        WHEN 'police' THEN 135
        WHEN 'post' THEN 140
        WHEN 'golf' THEN 150
        WHEN 'shop' THEN 400
        WHEN 'grocery' THEN 500
        WHEN 'fast_food' THEN 600
        WHEN 'clothing_store' THEN 700
        WHEN 'bar' THEN 800
        ELSE 1000
    END;
$$ LANGUAGE SQL IMMUTABLE;

CREATE OR REPLACE FUNCTION landmark_class(mapping_key TEXT, mapping_value TEXT)
RETURNS TEXT AS $$
    SELECT CASE
        WHEN (mapping_key = 'amenity' AND mapping_value IN ('place_of_worship', 'townhall', 'hospital'))
            OR (mapping_key = 'tourism' AND mapping_value = 'museum')
            OR (mapping_key = 'man_made' AND mapping_value IN 
                ('lighthouse', 'tower', 'communications_tower', 'water_tower', 'chimney', 'crane', 'gasometer', 'mineshaft', 'telescope', 'windmill', 'obelisk'))
            OR (mapping_key = 'historic' AND mapping_value IN ('castle', 'memorial', 'monument', 'ruins')) THEN 'point'
        WHEN mapping_key = 'railway' THEN 'railway'
        ELSE 'area'
    END;
$$ LANGUAGE SQL IMMUTABLE;
