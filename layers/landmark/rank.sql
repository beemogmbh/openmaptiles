CREATE OR REPLACE FUNCTION landmark_rank(mapping_key TEXT, mapping_value TEXT, building TEXT)
RETURNS INT AS $$
    SELECT CASE mapping_key
        WHEN 'railway' THEN 200
        WHEN 'amenity' THEN
            CASE mapping_value
                WHEN 'place_of_worship' THEN
                    CASE building
                        WHEN 'cathedral' THEN 100
                        WHEN 'church' THEN 200
                        WHEN 'chapel' THEN 500
                        ELSE 1000
                    END
                WHEN 'townhall' THEN 200
                ELSE 1000
            END
        WHEN 'leisure' THEN
            CASE mapping_value
                WHEN 'park' THEN 500
                ELSE 1000
            END
        WHEN 'office' THEN
            CASE mapping_value
                WHEN 'government' THEN 500
                ELSE 1000
            END
        ELSE 1000
    END;
$$ LANGUAGE SQL IMMUTABLE;