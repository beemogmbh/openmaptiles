DROP TRIGGER IF EXISTS trigger_flag ON osm_landmark_point;
DROP TRIGGER IF EXISTS trigger_refresh ON landmark_point.updates;

-- etldoc:  osm_landmark_point ->  osm_landmark_point

CREATE OR REPLACE FUNCTION update_osm_landmark_point() RETURNS VOID AS $$
BEGIN
  UPDATE osm_landmark_point
  SET tags = update_tags(tags, geometry)
  WHERE COALESCE(tags->'name:latin', tags->'name:nonlatin', tags->'name_int') IS NULL;
END;
$$ LANGUAGE plpgsql;

SELECT update_osm_landmark_point();

-- Handle updates

CREATE SCHEMA IF NOT EXISTS landmark_point;

CREATE TABLE IF NOT EXISTS landmark_point.updates(id serial primary key, t text, unique (t));
CREATE OR REPLACE FUNCTION landmark_point.flag() RETURNS trigger AS $$
BEGIN
    INSERT INTO landmark_point.updates(t) VALUES ('y')  ON CONFLICT(t) DO NOTHING;
    RETURN null;
END;
$$ language plpgsql;

CREATE OR REPLACE FUNCTION landmark_point.refresh() RETURNS trigger AS
  $BODY$
  BEGIN
    RAISE LOG 'Refresh landmark_point';
    PERFORM update_osm_landmark_point();
    DELETE FROM landmark_point.updates;
    RETURN null;
  END;
  $BODY$
language plpgsql;

CREATE TRIGGER trigger_flag
    AFTER INSERT OR UPDATE OR DELETE ON osm_landmark_point
    FOR EACH STATEMENT
    EXECUTE PROCEDURE landmark_point.flag();

CREATE CONSTRAINT TRIGGER trigger_refresh
    AFTER INSERT ON landmark_point.updates
    INITIALLY DEFERRED
    FOR EACH ROW
    EXECUTE PROCEDURE landmark_point.refresh();
