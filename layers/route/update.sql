DROP TRIGGER IF EXISTS trigger_flag ON osm_route_relation_members;
DROP TRIGGER IF EXISTS trigger_refresh ON route_relation_members.updates;

-- etldoc: osm_route_relation_members -> osm_route_relation_members_mat1
DROP MATERIALIZED VIEW IF EXISTS osm_route_relation_members_mat1 CASCADE;
CREATE MATERIALIZED VIEW osm_route_relation_members_mat1 AS (
  SELECT osm_id, member, ST_Simplify(geometry, 10) AS geometry, type, network, ref, name
  FROM osm_route_relation_members
);
CREATE INDEX IF NOT EXISTS osm_route_relation_members_mat1_geom ON osm_route_relation_members_mat1 USING gist (geometry);
CREATE INDEX IF NOT EXISTS osm_route_relation_members_mat1_osm_id_idx ON osm_route_relation_members_mat1 USING btree (osm_id ASC NULLS LAST);

-- etldoc: osm_route_relation_members -> osm_route_relation_members_mat2
DROP MATERIALIZED VIEW IF EXISTS osm_route_relation_members_mat2 CASCADE;
CREATE MATERIALIZED VIEW osm_route_relation_members_mat2 AS (
  SELECT osm_id, member, ST_Simplify(geometry, 20) AS geometry, type, network, ref, name
  FROM osm_route_relation_members_mat1
);
CREATE INDEX IF NOT EXISTS osm_route_relation_members_mat2_geom ON osm_route_relation_members_mat2 USING gist (geometry);
CREATE INDEX IF NOT EXISTS osm_route_relation_members_mat2_osm_id_idx ON osm_route_relation_members_mat2 USING btree (osm_id ASC NULLS LAST);

-- etldoc: osm_route_relation_members -> osm_route_relation_members_mat3
DROP MATERIALIZED VIEW IF EXISTS osm_route_relation_members_mat3 CASCADE;
CREATE MATERIALIZED VIEW osm_route_relation_members_mat3 AS (
  SELECT osm_id, member, ST_Simplify(geometry, 40) AS geometry, type, network, ref, name
  FROM osm_route_relation_members_mat2
);
CREATE INDEX IF NOT EXISTS osm_route_relation_members_mat3_geom ON osm_route_relation_members_mat3 USING gist (geometry);
CREATE INDEX IF NOT EXISTS osm_route_relation_members_mat3_osm_id_idx ON osm_route_relation_members_mat3 USING btree (osm_id ASC NULLS LAST);

-- etldoc: osm_route_relation_members -> osm_route_relation_members_mat4
DROP MATERIALIZED VIEW IF EXISTS osm_route_relation_members_mat4 CASCADE;
CREATE MATERIALIZED VIEW osm_route_relation_members_mat4 AS (
  SELECT osm_id, member, ST_Simplify(geometry, 80) AS geometry, type, network, ref, name
  FROM osm_route_relation_members_mat3
);
CREATE INDEX IF NOT EXISTS osm_route_relation_members_mat4_geom ON osm_route_relation_members_mat4 USING gist (geometry);
CREATE INDEX IF NOT EXISTS osm_route_relation_members_mat4_osm_id_idx ON osm_route_relation_members_mat4 USING btree (osm_id ASC NULLS LAST);

-- Handle updates

CREATE SCHEMA IF NOT EXISTS route_relation_members;

CREATE TABLE IF NOT EXISTS route_relation_members.updates(id serial primary key, t text, unique (t));
CREATE OR REPLACE FUNCTION route_relation_members.flag() RETURNS trigger AS $$
BEGIN
    INSERT INTO route_relation_members.updates(t) VALUES ('y')  ON CONFLICT(t) DO NOTHING;
    RETURN null;
END;
$$ language plpgsql;

CREATE OR REPLACE FUNCTION route_relation_members.refresh() RETURNS trigger AS
  $BODY$
  BEGIN
    RAISE LOG 'Refresh route_relation';
    REFRESH MATERIALIZED VIEW osm_route_relation_members_mat1;
    REFRESH MATERIALIZED VIEW osm_route_relation_members_mat2;
    REFRESH MATERIALIZED VIEW osm_route_relation_members_mat3;
    REFRESH MATERIALIZED VIEW osm_route_relation_members_mat4;
    DELETE FROM route_relation_members.updates;

    -- use materialized views after update
    CREATE OR REPLACE VIEW route_z10 AS (
        SELECT member, geometry, type, network, ref, name FROM osm_route_relation_members_mat4
    );
    CREATE OR REPLACE VIEW route_z11 AS (
        SELECT member, geometry, type, network, ref, name FROM osm_route_relation_members_mat3
    );
    CREATE OR REPLACE VIEW route_z12 AS (
        SELECT member, geometry, type, network, ref, name FROM osm_route_relation_members_mat2
    );
    CREATE OR REPLACE VIEW route_z13 AS (
        SELECT member, geometry, type, network, ref, name FROM osm_route_relation_members_mat1
    );

    RETURN null;
  END;
  $BODY$
language plpgsql;

CREATE TRIGGER trigger_flag
    AFTER INSERT OR UPDATE OR DELETE ON osm_route_relation_members
    FOR EACH STATEMENT
    EXECUTE PROCEDURE route_relation_members.flag();

CREATE CONSTRAINT TRIGGER trigger_refresh
    AFTER INSERT ON route_relation_members.updates
    INITIALLY DEFERRED
    FOR EACH ROW
    EXECUTE PROCEDURE route_relation_members.refresh();