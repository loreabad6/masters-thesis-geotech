-- ORGANIZE NEWLY CREATED TABLES

-- delete existing tables

DROP TABLE IF EXISTS received.sa_full_line;
DROP TABLE IF EXISTS received.sa_full_point;
DROP TABLE IF EXISTS received.sa_full_polygon;
DROP TABLE IF EXISTS received.sa_full_roads;
DROP TABLE IF EXISTS received.sa_ways;
DROP TABLE IF EXISTS received.sa_ways_int;

-- move tables to received schema
ALTER TABLE IF EXISTS public.sa_full_line SET SCHEMA received;
ALTER TABLE IF EXISTS public.sa_full_point SET SCHEMA received;
ALTER TABLE IF EXISTS public.sa_full_polygon SET SCHEMA received;
ALTER TABLE IF EXISTS public.sa_full_roads SET SCHEMA received;

-- drop unused tables
DROP TABLE IF EXISTS received.sa_all_pointsofinterest;
DROP TABLE IF EXISTS received.sa_bike_pointsofinterest;

-- drop unused columns
ALTER TABLE IF EXISTS received.sa_all_ways DROP COLUMN IF EXISTS tag_id;
ALTER TABLE IF EXISTS received.sa_all_ways DROP COLUMN IF EXISTS length;
ALTER TABLE IF EXISTS received.sa_all_ways DROP COLUMN IF EXISTS length_m;
ALTER TABLE IF EXISTS received.sa_all_ways DROP COLUMN IF EXISTS x1;
ALTER TABLE IF EXISTS received.sa_all_ways DROP COLUMN IF EXISTS y1;
ALTER TABLE IF EXISTS received.sa_all_ways DROP COLUMN IF EXISTS x2;
ALTER TABLE IF EXISTS received.sa_all_ways DROP COLUMN IF EXISTS y2;
ALTER TABLE IF EXISTS received.sa_all_ways DROP COLUMN IF EXISTS cost;
ALTER TABLE IF EXISTS received.sa_all_ways DROP COLUMN IF EXISTS reverse_cost;
ALTER TABLE IF EXISTS received.sa_all_ways DROP COLUMN IF EXISTS cost_s;
ALTER TABLE IF EXISTS received.sa_all_ways DROP COLUMN IF EXISTS reverse_cost_s;
ALTER TABLE IF EXISTS received.sa_all_ways DROP COLUMN IF EXISTS rule;
ALTER TABLE IF EXISTS received.sa_all_ways DROP COLUMN IF EXISTS maxspeed_forward;
ALTER TABLE IF EXISTS received.sa_all_ways DROP COLUMN IF EXISTS maxspeed_backward;
ALTER TABLE IF EXISTS received.sa_all_ways DROP COLUMN IF EXISTS source_osm;
ALTER TABLE IF EXISTS received.sa_all_ways DROP COLUMN IF EXISTS target_osm;
ALTER TABLE IF EXISTS received.sa_all_ways DROP COLUMN IF EXISTS priority;
ALTER TABLE IF EXISTS received.sa_all_ways DROP COLUMN IF EXISTS one_way;
ALTER TABLE IF EXISTS received.sa_all_ways DROP COLUMN IF EXISTS oneway;

ALTER TABLE IF EXISTS received.sa_all_ways_vertices_pgr DROP COLUMN IF EXISTS cnt;
ALTER TABLE IF EXISTS received.sa_all_ways_vertices_pgr DROP COLUMN IF EXISTS chk;
ALTER TABLE IF EXISTS received.sa_all_ways_vertices_pgr DROP COLUMN IF EXISTS ein;
ALTER TABLE IF EXISTS received.sa_all_ways_vertices_pgr DROP COLUMN IF EXISTS eout;
ALTER TABLE IF EXISTS received.sa_all_ways_vertices_pgr DROP COLUMN IF EXISTS lon;
ALTER TABLE IF EXISTS received.sa_all_ways_vertices_pgr DROP COLUMN IF EXISTS lat;

-- change column names
ALTER TABLE IF EXISTS received.sa_all_ways RENAME COLUMN gid TO road_id;
ALTER TABLE IF EXISTS received.sa_all_ways RENAME COLUMN the_geom TO geom;
ALTER TABLE IF EXISTS received.sa_all_ways RENAME COLUMN source TO intersection_from;
ALTER TABLE IF EXISTS received.sa_all_ways RENAME COLUMN target TO intersection_to;

ALTER TABLE IF EXISTS received.sa_all_ways_vertices_pgr RENAME COLUMN id TO int_id;
ALTER TABLE IF EXISTS received.sa_all_ways_vertices_pgr RENAME COLUMN the_geom TO geom;

-- change names of tables
ALTER TABLE IF EXISTS received.sa_all_ways RENAME TO sa_ways;
ALTER TABLE IF EXISTS received.sa_all_ways_vertices_pgr RENAME TO  sa_ways_int;

-- create new columns

ALTER TABLE IF EXISTS received.sa_ways ADD COLUMN IF NOT EXISTS functional_class TEXT;
ALTER TABLE IF EXISTS received.sa_ways ADD COLUMN IF NOT EXISTS path_id INTEGER;
ALTER TABLE IF EXISTS received.sa_ways ADD COLUMN IF NOT EXISTS speed_limit INT;
ALTER TABLE IF EXISTS received.sa_ways ADD COLUMN IF NOT EXISTS one_way_car VARCHAR(2);
ALTER TABLE IF EXISTS received.sa_ways ADD COLUMN IF NOT EXISTS one_way VARCHAR(2);
ALTER TABLE IF EXISTS received.sa_ways ADD COLUMN IF NOT EXISTS width INT;
ALTER TABLE IF EXISTS received.sa_ways ADD COLUMN IF NOT EXISTS ft_bike_infra TEXT;
ALTER TABLE IF EXISTS received.sa_ways ADD COLUMN IF NOT EXISTS ft_bike_infra_width FLOAT;
ALTER TABLE IF EXISTS received.sa_ways ADD COLUMN IF NOT EXISTS tf_bike_infra TEXT;
ALTER TABLE IF EXISTS received.sa_ways ADD COLUMN IF NOT EXISTS tf_bike_infra_width FLOAT;
ALTER TABLE IF EXISTS received.sa_ways ADD COLUMN IF NOT EXISTS ft_lanes INT;
ALTER TABLE IF EXISTS received.sa_ways ADD COLUMN IF NOT EXISTS tf_lanes INT;
ALTER TABLE IF EXISTS received.sa_ways ADD COLUMN IF NOT EXISTS ft_cross_lanes INT;
ALTER TABLE IF EXISTS received.sa_ways ADD COLUMN IF NOT EXISTS tf_cross_lanes INT;
ALTER TABLE IF EXISTS received.sa_ways ADD COLUMN IF NOT EXISTS twltl_cross_lanes INT;
ALTER TABLE IF EXISTS received.sa_ways ADD COLUMN IF NOT EXISTS ft_park INT;
ALTER TABLE IF EXISTS received.sa_ways ADD COLUMN IF NOT EXISTS tf_park INT;
ALTER TABLE IF EXISTS received.sa_ways ADD COLUMN IF NOT EXISTS ft_seg_stress INT;
ALTER TABLE IF EXISTS received.sa_ways ADD COLUMN IF NOT EXISTS ft_int_stress INT;
ALTER TABLE IF EXISTS received.sa_ways ADD COLUMN IF NOT EXISTS tf_seg_stress INT;
ALTER TABLE IF EXISTS received.sa_ways ADD COLUMN IF NOT EXISTS tf_int_stress INT;
ALTER TABLE IF EXISTS received.sa_ways ADD COLUMN IF NOT EXISTS xwalk INT;

ALTER TABLE IF EXISTS received.sa_ways_int ADD COLUMN IF NOT EXISTS legs INT;
ALTER TABLE IF EXISTS received.sa_ways_int ADD COLUMN IF NOT EXISTS signalized BOOLEAN;
ALTER TABLE IF EXISTS received.sa_ways_int ADD COLUMN IF NOT EXISTS stops BOOLEAN;
ALTER TABLE IF EXISTS received.sa_ways_int ADD COLUMN IF NOT EXISTS rrfb BOOLEAN;
ALTER TABLE IF EXISTS received.sa_ways_int ADD COLUMN IF NOT EXISTS island BOOLEAN;

-- indexes
DROP INDEX IF EXISTS received.idx_sa_ways_osm;
DROP INDEX IF EXISTS received.idx_sa_ways_int_osm;
DROP INDEX IF EXISTS received.idx_sa_all_fullways;
DROP INDEX IF EXISTS received.idx_sa_all_fullpoints;
CREATE INDEX idx_sa_ways_osm ON received.sa_ways (osm_id);
CREATE INDEX idx_sa_ways_int_osm ON received.sa_ways_int (osm_id);
CREATE INDEX idx_sa_all_fullways ON received.sa_full_line (osm_id);
CREATE INDEX idx_sa_all_fullpoints ON received.sa_full_point (osm_id);

ANALYZE received.sa_ways (osm_id,geom);
ANALYZE received.sa_bike_ways (the_geom);
ANALYZE received.sa_ways_int (osm_id);
ANALYZE received.sa_full_line (osm_id);
ANALYZE received.sa_full_point (osm_id);

-- add in cycleway data that is missing from first osm2pgrouting call
INSERT INTO received.sa_ways (
    name, intersection_from, intersection_to, osm_id, geom
)
SELECT  name,
        (SELECT     i.int_id
        FROM        received.sa_ways_int i
        WHERE       i.geom <#> received.sa_bike_ways.the_geom < 20
        ORDER BY    ST_Distance(ST_StartPoint(received.sa_bike_ways.the_geom),i.geom) ASC
        LIMIT       1),
        (SELECT     i.int_id
        FROM        received.sa_ways_int i
        WHERE       i.geom <#> received.sa_bike_ways.the_geom < 20
        ORDER BY    ST_Distance(ST_EndPoint(received.sa_bike_ways.the_geom),i.geom) ASC
        LIMIT       1),
        osm_id,
        the_geom
FROM    received.sa_bike_ways
WHERE   NOT EXISTS (
            SELECT  1
            FROM    received.sa_ways w2
            WHERE   w2.osm_id = received.sa_bike_ways.osm_id
);

DROP INDEX IF EXISTS received.idx_sa_ways_ints_stop;
DROP INDEX IF EXISTS received.idx_sa_ways_rrfb;
DROP INDEX IF EXISTS received.idx_sa_ways_island;
CREATE INDEX idx_sa_ways_ints_stop ON received.sa_ways_int (signalized,stops);
CREATE INDEX idx_sa_ways_rrfb ON received.sa_ways_int (rrfb);
CREATE INDEX idx_sa_ways_island ON received.sa_ways_int (island);

ALTER TABLE IF EXISTS received.sa_ways ALTER COLUMN geom TYPE geometry(linestring,?sa_crs)
USING ST_Transform(geom,?sa_crs);
ALTER TABLE IF EXISTS received.sa_bike_ways ALTER COLUMN the_geom TYPE geometry(linestring,?sa_crs)
USING ST_Transform(the_geom,?sa_crs);
ALTER TABLE IF EXISTS received.sa_ways_int ALTER COLUMN geom TYPE geometry(point,?sa_crs)
USING ST_Transform(geom,?sa_crs);
ALTER TABLE IF EXISTS received.sa_full_line ALTER COLUMN way TYPE geometry(linestring,?sa_crs)
USING ST_Transform(way,?sa_crs);
ALTER TABLE IF EXISTS received.sa_full_point ALTER COLUMN way TYPE geometry(point,?sa_crs)
USING ST_Transform(way,?sa_crs);
ALTER TABLE IF EXISTS received.sa_full_polygon ALTER COLUMN way TYPE geometry(polygon,?sa_crs)
USING ST_Transform(way,?sa_crs);
ALTER TABLE IF EXISTS received.sa_full_roads ALTER COLUMN way TYPE geometry(linestring,?sa_crs)
USING ST_Transform(way,?sa_crs);