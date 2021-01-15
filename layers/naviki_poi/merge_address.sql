CREATE OR REPLACE FUNCTION merge_address(street text, housenumber text, postcode text, city text) RETURNS text as
$$
BEGIN
    RETURN street ||
           CASE
               WHEN street != ''
                   THEN ' ' || housenumber
               ELSE housenumber
               END
        ||
           CASE
               WHEN housenumber != ''
                   THEN ', ' || postcode
               ELSE postcode
               END
        ||
           CASE
               WHEN postcode != ''
                   THEN ' ' || city
               ELSE city
               END;
END;
$$ LANGUAGE plpgsql
   IMMUTABLE PARALLEL SAFE;
