CREATE OR REPLACE FUNCTION merge_website(website text, contact_website text) RETURNS text AS
$$
SELECT CASE
           WHEN website != '' THEN
               website
           ELSE
               contact_website
           END;
$$
    LANGUAGE SQL
    IMMUTABLE;
