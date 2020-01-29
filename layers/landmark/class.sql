CREATE OR REPLACE FUNCTION landmark_class_rank(class TEXT)
RETURNS INT AS $$
    SELECT CASE class
        WHEN 'railway' THEN 100
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
