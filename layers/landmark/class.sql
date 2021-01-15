CREATE OR REPLACE FUNCTION landmark_class(mapping_key TEXT, mapping_value TEXT)
RETURNS TEXT AS $$
    SELECT CASE
        WHEN (mapping_key = 'amenity' AND mapping_value IN ('place_of_worship', 'townhall', 'hospital'))
            OR (mapping_key = 'tourism' AND mapping_value = 'museum')
            OR mapping_key = 'man_made'
            OR (mapping_key = 'historic' AND mapping_value IN ('castle', 'memorial', 'monument', 'ruins')) 
            OR (mapping_key = 'office' AND mapping_value = 'government') 
            OR (mapping_key = 'power' AND mapping_value IN ('plant', 'substation')) THEN 'point'
        WHEN mapping_key = 'railway' THEN 'railway'
        ELSE 'area'
    END;
$$ LANGUAGE SQL IMMUTABLE
                PARALLEL SAFE;
