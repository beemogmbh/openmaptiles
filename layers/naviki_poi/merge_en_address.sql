CREATE OR REPLACE FUNCTION merge_en_address(street text, street_en text, housenumber text, postcode text, city text,
                                            city_en text) RETURNS text as
$$
BEGIN
    RETURN
        CASE
            WHEN street_en = '' AND city_en = ''
                THEN ''
            ELSE CASE
                     WHEN street_en = ''
                         THEN street
                     ELSE street_en
                     END
                ||
                 CASE
                     WHEN street_en != '' or street != ''
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
                         THEN ' '
                     END
                ||
                 CASE
                     WHEN city_en != ''
                         THEN city_en
                     ELSE city
                     END
            END;
END;
$$ LANGUAGE plpgsql
   IMMUTABLE;
