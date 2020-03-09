CREATE OR REPLACE FUNCTION osm_type(tags hstore, category text) RETURNS text AS
$$
SELECT CASE
           WHEN category IN ('garage_store',
                             'clothing',
                             'sports_outdoor_travel',
                             'mall_supermarket',
                             'books_magazines',
                             'electronics',
                             'culture_hobby',
                             'stationery_gifts',
                             'do_it_yourself',
                             'interior_furniture') THEN
               CASE
                   WHEN tags ? 'shop' THEN tags -> 'shop'
                   ELSE ''
                   END
           WHEN category IN ('renting', 'grocery', 'health_beauty') THEN
               CASE
                   WHEN tags ? 'amenity' THEN tags -> 'amenity'
                   WHEN tags ? 'shop' THEN tags -> 'shop'
                   ELSE ''
                   END
           WHEN category in ('parking',
                             'compressed_air',
                             'charging_station',
                             'bicycle_tube',
                             'restaurant',
                             'cafe',
                             'ice_cream',
                             'beer_garden',
                             'biergarten',
                             'fast_food',
                             'pub_bar',
                             'vending_machine',
                             'fuel',
                             'police',
                             'postal_service',
                             'car_rental',
                             'taxi') THEN
               CASE
                   WHEN tags ? 'amenity' THEN tags -> 'amenity'
                   ELSE ''
                   END
           WHEN category IN ('drinking_water') THEN
               CASE
                   WHEN tags ? 'amenity' THEN tags -> 'amenity'
                   WHEN tags ? 'natural' THEN tags -> 'natural'
                   ELSE ''
                   END
           WHEN category in ('nature_landscape') THEN
               CASE
                   WHEN tags ? 'amenity' THEN tags -> 'amenity'
                   WHEN tags ? 'leisure' THEN tags -> 'leisure'
                   WHEN tags ? 'natural' THEN tags -> 'natural'
                   WHEN tags ? 'tourism' THEN tags -> 'tourism'
                   WHEN tags ? 'landuse' THEN tags -> 'landuse'
                   WHEN tags ? 'geological' THEN tags -> 'geological'
                   WHEN tags ? 'building' THEN tags -> 'building'
                   ELSE ''
                   END
           WHEN category in ('culture') THEN
               CASE
                   WHEN tags ? 'amenity' THEN tags -> 'amenity'
                   WHEN tags ? 'tourism' THEN tags -> 'tourism'
                   WHEN tags ? 'historic' THEN tags -> 'historic'
                   WHEN tags ? 'landuse' THEN tags -> 'landuse'
                   WHEN tags ? 'man_made' THEN tags -> 'man_made'
                   ELSE ''
                   END
           WHEN category IN ('sports', 'ship') THEN
               CASE
                   WHEN tags ? 'amenity' THEN tags -> 'amenity'
                   WHEN tags ? 'leisure' THEN tags -> 'leisure'
                   ELSE ''
                   END
           WHEN category IN ('wellness') THEN
               CASE
                   WHEN tags ? 'amenity' THEN tags -> 'amenity'
                   WHEN tags ? 'shop' THEN tags -> 'shop'
                   WHEN tags ? 'leisure' THEN tags -> 'leisure'
                   ELSE ''
                   END
           WHEN category IN ('fun_games') THEN
               CASE
                   WHEN tags ? 'amenity' THEN tags -> 'amenity'
                   WHEN tags ? 'leisure' THEN tags -> 'leisure'
                   WHEN tags ? 'tourism' THEN tags -> 'tourism'
                   ELSE ''
                   END
           WHEN category IN ('entertainment') THEN
               CASE
                   WHEN tags ? 'amenity' THEN tags -> 'amenity'
                   WHEN tags ? 'tourism' THEN tags -> 'tourism'
                   WHEN tags ? 'leisure' THEN tags -> 'leisure'
                   ELSE ''
                   END
           WHEN category IN ('business') THEN
               CASE
                   WHEN tags ? 'office' THEN tags -> 'office'
                   WHEN tags ? 'shop' THEN tags -> 'shop'
                   ELSE ''
                   END
           WHEN category IN ('finance') THEN
               CASE
                   WHEN tags ? 'amenity' THEN tags -> 'amenity'
                   WHEN tags ? 'shop' THEN tags -> 'shop'
                   WHEN tags ? 'office' THEN tags -> 'office'
                   ELSE ''
                   END
           WHEN category IN ('health') THEN
               CASE
                   WHEN tags ? 'amenity' THEN tags -> 'amenity'
                   WHEN tags ? 'shop' THEN tags -> 'shop'
                   WHEN tags ? 'craft' THEN tags -> 'craft'
                   ELSE ''
                   END
           WHEN category IN ('craft') THEN
               CASE
                   WHEN tags ? 'craft' THEN tags -> 'craft'
                   ELSE ''
                   END
           WHEN category IN ('tourism_information',
                             'hotel',
                             'apartment',
                             'hostel',
                             'camping',
                             'hut') THEN
               CASE
                   WHEN tags ? 'tourism' THEN tags -> 'tourism'
                   ELSE ''
                   END
           WHEN category IN ('education') THEN
               CASE
                   WHEN tags ? 'amenity' THEN tags -> 'amenity'
                   WHEN tags ? 'office' THEN tags -> 'office'
                   ELSE ''
                   END
           WHEN category IN ('administration') THEN
               CASE
                   WHEN tags ? 'amenity' THEN tags -> 'amenity'
                   WHEN tags ? 'office' THEN tags -> 'office'
                   WHEN tags ? 'building' THEN tags -> 'building'
                   ELSE ''
                   END
           WHEN category IN ('organisation') THEN
               CASE
                   WHEN tags ? 'office' THEN tags -> 'office'
                   ELSE ''
                   END
           WHEN category IN ('religious_site') THEN
               CASE
                   WHEN tags ? 'amenity' THEN tags -> 'amenity'
                   WHEN tags ? 'landuse' THEN tags -> 'landuse'
                   ELSE ''
                   END
           WHEN category IN ('railway') THEN
               CASE
                   WHEN tags ? 'railway' THEN tags -> 'railway'
                   WHEN tags ? 'building' THEN tags -> 'building'
                   ELSE ''
                   END
           WHEN category IN ('bus') THEN
               CASE
                   WHEN tags ? 'amenity' THEN tags -> 'amenity'
                   WHEN tags ? 'highway' THEN tags -> 'highway'
                   ELSE ''
                   END
           WHEN category IN ('aircraft') THEN
               CASE
                   WHEN tags ? 'aeroway' THEN tags -> 'aeroway'
                   ELSE ''
                   END
           WHEN category IN ('cable_car') THEN
               CASE
                   WHEN tags ? 'aerialway' THEN tags -> 'aerialway'
                   WHEN tags ? 'railway' THEN tags -> 'railway'
                   ELSE ''
                   END
           WHEN category IN ('emergency') THEN
               CASE
                   WHEN tags ? 'amenity' THEN tags -> 'amenity'
                   WHEN tags ? 'emergency' THEN tags -> 'emergency'
                   WHEN tags ? 'highway' THEN tags -> 'highway'
                   ELSE ''
                   END
           ELSE ''
           END
$$
    LANGUAGE SQL
    IMMUTABLE;
