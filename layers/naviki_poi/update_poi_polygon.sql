DROP TRIGGER IF EXISTS trigger_flag ON osm_naviki_poi_polygon;
DROP TRIGGER IF EXISTS trigger_refresh ON naviki_poi_polygon.updates;

CREATE OR REPLACE FUNCTION update_naviki_poi_polygon() RETURNS VOID AS $$
BEGIN
  UPDATE osm_naviki_poi_polygon
  SET geometry =
           CASE WHEN ST_NPoints(ST_ConvexHull(geometry))=ST_NPoints(geometry)
           THEN ST_Centroid(geometry)
           ELSE ST_PointOnSurface(geometry)
    END
  WHERE ST_GeometryType(geometry) <> 'ST_Point';

  ANALYZE osm_naviki_poi_polygon;
END;
$$ LANGUAGE plpgsql;

SELECT update_naviki_poi_polygon();

-- Handle updates

CREATE SCHEMA IF NOT EXISTS naviki_poi_polygon;

CREATE TABLE IF NOT EXISTS naviki_poi_polygon.updates(id serial primary key, t text, unique (t));
CREATE OR REPLACE FUNCTION naviki_poi_polygon.flag() RETURNS trigger AS $$
BEGIN
    INSERT INTO naviki_poi_polygon.updates(t) VALUES ('y')  ON CONFLICT(t) DO NOTHING;
    RETURN null;
END;
$$ language plpgsql;

CREATE OR REPLACE FUNCTION naviki_poi_polygon.refresh() RETURNS trigger AS
  $BODY$
  BEGIN
    RAISE LOG 'Refresh naviki_poi_polygon';
    PERFORM update_naviki_poi_polygon();
    DELETE FROM naviki_poi_polygon.updates;
    RETURN null;
  END;
  $BODY$
language plpgsql;

CREATE TRIGGER trigger_flag
    AFTER INSERT OR UPDATE OR DELETE ON osm_naviki_poi_polygon
    FOR EACH STATEMENT
    EXECUTE PROCEDURE naviki_poi_polygon.flag();

CREATE CONSTRAINT TRIGGER trigger_refresh
    AFTER INSERT ON naviki_poi_polygon.updates
    INITIALLY DEFERRED
    FOR EACH ROW
    EXECUTE PROCEDURE naviki_poi_polygon.refresh();