DROP TABLE IF EXISTS received.sa_ways_net_vert;
DROP TABLE IF EXISTS received.sa_ways_net_link;

-- create new tables
CREATE TABLE received.sa_ways_net_vert (
    vert_id SERIAL PRIMARY KEY,
    road_id INTEGER,
    vert_cost INTEGER,
    geom geometry(point,?sa_crs)
);

CREATE TABLE received.sa_ways_net_link (
    link_id SERIAL PRIMARY KEY,
    int_id INTEGER,
    turn_angle INTEGER,
    int_crossing BOOLEAN,
    int_stress INTEGER,
    source_vert INTEGER,
    source_road_id INTEGER,
    source_road_dir VARCHAR(2),
    source_road_azi INTEGER,
    source_road_length INTEGER,
    source_stress INTEGER,
    target_vert INTEGER,
    target_road_id INTEGER,
    target_road_dir VARCHAR(2),
    target_road_azi INTEGER,
    target_road_length INTEGER,
    target_stress INTEGER,
    link_cost INTEGER,
    link_stress INTEGER,
    geom geometry(linestring,?sa_crs)
);

-- create vertices
INSERT INTO received.sa_ways_net_vert (road_id, geom)
SELECT  ways.road_id,
        ST_LineInterpolatePoint(ways.geom,0.5)
FROM    received.sa_ways ways;

-- index
CREATE INDEX sidx_sa_ways_net_vert_geom ON received.sa_ways_net_vert USING gist (geom);
CREATE INDEX idx_sa_ways_net_vert_roadid ON received.sa_ways_net_vert (road_id);
ANALYZE received.sa_ways_net_vert;

---------------
-- add links --
---------------
-- two-way to two-way
INSERT INTO received.sa_ways_net_link (int_id, source_vert, target_vert, geom)
SELECT  ints.int_id,
        vert1.vert_id,
        vert2.vert_id,
        ST_Makeline(vert1.geom,vert2.geom)
FROM    received.sa_ways_int ints,
        received.sa_ways_net_vert vert1,
        received.sa_ways roads1,
        received.sa_ways_net_vert vert2,
        received.sa_ways roads2
WHERE   vert1.road_id = roads1.road_id
AND     vert2.road_id = roads2.road_id
AND     ints.int_id IN (roads1.intersection_from, roads1.intersection_to)
AND     ints.int_id IN (roads2.intersection_from, roads2.intersection_to)
AND     roads1.one_way IS NULL
AND     roads2.one_way IS NULL
AND     roads1.road_id != roads2.road_id;

-- two-way to from-to
INSERT INTO received.sa_ways_net_link (int_id, source_vert, target_vert, geom)
SELECT  ints.int_id,
        vert1.vert_id,
        vert2.vert_id,
        ST_Makeline(vert1.geom,vert2.geom)
FROM    received.sa_ways_int ints,
        received.sa_ways_net_vert vert1,
        received.sa_ways roads1,
        received.sa_ways_net_vert vert2,
        received.sa_ways roads2
WHERE   vert1.road_id = roads1.road_id
AND     vert2.road_id = roads2.road_id
AND     ints.int_id IN (roads1.intersection_from, roads1.intersection_to)
AND     ints.int_id = roads2.intersection_from
AND     roads1.one_way IS NULL
AND     roads2.one_way = 'ft'
AND     roads1.road_id != roads2.road_id;

-- two-way to to-from
INSERT INTO received.sa_ways_net_link (int_id, source_vert, target_vert, geom)
SELECT  ints.int_id,
        vert1.vert_id,
        vert2.vert_id,
        ST_Makeline(vert1.geom,vert2.geom)
FROM    received.sa_ways_int ints,
        received.sa_ways_net_vert vert1,
        received.sa_ways roads1,
        received.sa_ways_net_vert vert2,
        received.sa_ways roads2
WHERE   vert1.road_id = roads1.road_id
AND     vert2.road_id = roads2.road_id
AND     ints.int_id IN (roads1.intersection_from, roads1.intersection_to)
AND     ints.int_id = roads2.intersection_to
AND     roads1.one_way IS NULL
AND     roads2.one_way = 'tf'
AND     roads1.road_id != roads2.road_id;

-- from-to to two-way
INSERT INTO received.sa_ways_net_link (int_id, source_vert, target_vert, geom)
SELECT  ints.int_id,
        vert1.vert_id,
        vert2.vert_id,
        ST_Makeline(vert1.geom,vert2.geom)
FROM    received.sa_ways_int ints,
        received.sa_ways_net_vert vert1,
        received.sa_ways roads1,
        received.sa_ways_net_vert vert2,
        received.sa_ways roads2
WHERE   vert1.road_id = roads1.road_id
AND     vert2.road_id = roads2.road_id
AND     ints.int_id = roads1.intersection_to
AND     ints.int_id IN (roads2.intersection_from, roads2.intersection_to)
AND     roads1.one_way = 'ft'
AND     roads2.one_way IS NULL
AND     roads1.road_id != roads2.road_id;

-- from-to to from-to
INSERT INTO received.sa_ways_net_link (int_id, source_vert, target_vert, geom)
SELECT  ints.int_id,
        vert1.vert_id,
        vert2.vert_id,
        ST_Makeline(vert1.geom,vert2.geom)
FROM    received.sa_ways_int ints,
        received.sa_ways_net_vert vert1,
        received.sa_ways roads1,
        received.sa_ways_net_vert vert2,
        received.sa_ways roads2
WHERE   vert1.road_id = roads1.road_id
AND     vert2.road_id = roads2.road_id
AND     ints.int_id = roads1.intersection_to
AND     ints.int_id = roads2.intersection_from
AND     roads1.one_way = 'ft'
AND     roads2.one_way = 'ft'
AND     roads1.road_id != roads2.road_id;

-- from-to to to-from
INSERT INTO received.sa_ways_net_link (int_id, source_vert, target_vert, geom)
SELECT  ints.int_id,
        vert1.vert_id,
        vert2.vert_id,
        ST_Makeline(vert1.geom,vert2.geom)
FROM    received.sa_ways_int ints,
        received.sa_ways_net_vert vert1,
        received.sa_ways roads1,
        received.sa_ways_net_vert vert2,
        received.sa_ways roads2
WHERE   vert1.road_id = roads1.road_id
AND     vert2.road_id = roads2.road_id
AND     ints.int_id = roads1.intersection_to
AND     ints.int_id = roads2.intersection_to
AND     roads1.one_way = 'ft'
AND     roads2.one_way = 'tf'
AND     roads1.road_id != roads2.road_id;

-- to-from to two-way
INSERT INTO received.sa_ways_net_link (int_id, source_vert, target_vert, geom)
SELECT  ints.int_id,
        vert1.vert_id,
        vert2.vert_id,
        ST_Makeline(vert1.geom,vert2.geom)
FROM    received.sa_ways_int ints,
        received.sa_ways_net_vert vert1,
        received.sa_ways roads1,
        received.sa_ways_net_vert vert2,
        received.sa_ways roads2
WHERE   vert1.road_id = roads1.road_id
AND     vert2.road_id = roads2.road_id
AND     ints.int_id = roads1.intersection_from
AND     ints.int_id IN (roads2.intersection_from, roads2.intersection_to)
AND     roads1.one_way = 'tf'
AND     roads2.one_way IS NULL
AND     roads1.road_id != roads2.road_id;

-- to-from to to-from
INSERT INTO received.sa_ways_net_link (int_id, source_vert, target_vert, geom)
SELECT  ints.int_id,
        vert1.vert_id,
        vert2.vert_id,
        ST_Makeline(vert1.geom,vert2.geom)
FROM    received.sa_ways_int ints,
        received.sa_ways_net_vert vert1,
        received.sa_ways roads1,
        received.sa_ways_net_vert vert2,
        received.sa_ways roads2
WHERE   vert1.road_id = roads1.road_id
AND     vert2.road_id = roads2.road_id
AND     ints.int_id = roads1.intersection_from
AND     ints.int_id = roads2.intersection_to
AND     roads1.one_way = 'tf'
AND     roads2.one_way = 'tf'
AND     roads1.road_id != roads2.road_id;

-- to-from to from-to
INSERT INTO received.sa_ways_net_link (int_id, source_vert, target_vert, geom)
SELECT  ints.int_id,
        vert1.vert_id,
        vert2.vert_id,
        ST_Makeline(vert1.geom,vert2.geom)
FROM    received.sa_ways_int ints,
        received.sa_ways_net_vert vert1,
        received.sa_ways roads1,
        received.sa_ways_net_vert vert2,
        received.sa_ways roads2
WHERE   vert1.road_id = roads1.road_id
AND     vert2.road_id = roads2.road_id
AND     ints.int_id = roads1.intersection_from
AND     ints.int_id = roads2.intersection_from
AND     roads1.one_way = 'tf'
AND     roads2.one_way = 'ft'
AND     roads1.road_id != roads2.road_id;

-- index
CREATE INDEX idx_sa_ways_net_vert_road_id ON received.sa_ways_net_vert (road_id);
CREATE INDEX idx_sa_ways_net_link_int_id ON received.sa_ways_net_link (int_id);
CREATE INDEX idx_sa_ways_net_link_src_trgt ON received.sa_ways_net_link (source_vert,target_vert);
CREATE INDEX idx_sa_ways_net_link_src_rdid ON received.sa_ways_net_link (source_road_id);
CREATE INDEX idx_sa_ways_net_link_tgt_rdid ON received.sa_ways_net_link (target_road_id);
ANALYZE received.sa_ways_net_link;

--set source and target roads
UPDATE  received.sa_ways_net_link
SET     source_road_id = s_vert.road_id,
        target_road_id = t_vert.road_id
FROM    received.sa_ways_net_vert s_vert,
        received.sa_ways_net_vert t_vert
WHERE   received.sa_ways_net_link.source_vert = s_vert.vert_id
AND     received.sa_ways_net_link.target_vert = t_vert.vert_id;

--source_road_dir
UPDATE  received.sa_ways_net_link
SET     source_road_dir = CASE  WHEN received.sa_ways_net_link.int_id = road.intersection_to
                                    THEN 'ft'
                                ELSE 'tf'
                                END
FROM    received.sa_ways road
WHERE   received.sa_ways_net_link.source_road_id = road.road_id;

--target_road_dir
UPDATE  received.sa_ways_net_link
SET     target_road_dir = CASE  WHEN received.sa_ways_net_link.int_id = road.intersection_to
                                    THEN 'ft'
                                ELSE 'tf'
                                END
FROM    received.sa_ways road
WHERE   received.sa_ways_net_link.target_road_id = road.road_id;

--set azimuths and turn angles
UPDATE  received.sa_ways_net_link
SET     source_road_azi = CASE  WHEN source_road_dir = 'tf'
                                THEN degrees(ST_Azimuth(ST_LineInterpolatePoint(roads1.geom,0.5),ST_StartPoint(roads1.geom)))
                                ELSE degrees(ST_Azimuth(ST_LineInterpolatePoint(roads1.geom,0.5),ST_EndPoint(roads1.geom)))
                                END,
        target_road_azi = CASE  WHEN target_road_dir = 'tf'
                                THEN degrees(ST_Azimuth(ST_StartPoint(roads2.geom),ST_LineInterpolatePoint(roads2.geom,0.5)))
                                ELSE degrees(ST_Azimuth(ST_EndPoint(roads2.geom),ST_LineInterpolatePoint(roads2.geom,0.5)))
                                END
FROM    received.sa_ways roads1,
        received.sa_ways roads2
WHERE   source_road_id = roads1.road_id
AND     target_road_id = roads2.road_id;

UPDATE received.sa_ways_net_link
SET     turn_angle = (target_road_azi - source_road_azi + 360) % 360;

-------------------
-- set turn info --
-------------------
-- assume crossing is true unless proven otherwise
UPDATE received.sa_ways_net_link SET int_crossing = TRUE;

-- set right turns
UPDATE  received.sa_ways_net_link
SET     int_crossing = FALSE
WHERE   link_id = (
            SELECT      r.link_id
            FROM        received.sa_ways_net_link r
            WHERE       received.sa_ways_net_link.source_road_id = r.source_road_id
            AND         received.sa_ways_net_link.int_id = r.int_id
            ORDER BY    (sin(radians(r.turn_angle))>0)::INT DESC,
                        CASE    WHEN sin(radians(r.turn_angle))>0
                                THEN cos(radians(r.turn_angle))
                                ELSE -cos(radians(r.turn_angle))
                                END ASC
            LIMIT       1
);

--set lengths
UPDATE  received.sa_ways_net_link
SET     source_road_length = ST_Length(roads1.geom),
        target_road_length = ST_Length(roads2.geom)
FROM    received.sa_ways roads1,
        received.sa_ways roads2
WHERE   source_road_id = roads1.road_id
AND     target_road_id = roads2.road_id;

---------------------
-- set link stress --
---------------------
--source_stress
UPDATE  received.sa_ways_net_link
SET     source_stress = CASE WHEN received.sa_ways_net_link.int_id = road.intersection_to THEN road.ft_seg_stress
                        ELSE road.tf_seg_stress
                        END
FROM    received.sa_ways road
WHERE   received.sa_ways_net_link.source_road_id = road.road_id;

--int_stress
UPDATE  received.sa_ways_net_link
SET     int_stress = roads.ft_int_stress
FROM    received.sa_ways roads
WHERE   received.sa_ways_net_link.source_road_id = roads.road_id
AND     source_road_dir = 'ft';

UPDATE  received.sa_ways_net_link
SET     int_stress = roads.tf_int_stress
FROM    received.sa_ways roads
WHERE   received.sa_ways_net_link.source_road_id = roads.road_id
AND     source_road_dir = 'tf';

UPDATE  received.sa_ways_net_link
SET     int_stress = 1
WHERE   NOT int_crossing;;

--target_stress
UPDATE  received.sa_ways_net_link
SET     target_stress = CASE    WHEN received.sa_ways_net_link.int_id = road.intersection_to
                                    THEN road.tf_seg_stress
                                ELSE road.ft_seg_stress
                                END
FROM    received.sa_ways road
WHERE   received.sa_ways_net_link.target_road_id = road.road_id;

--link_stress
UPDATE  received.sa_ways_net_link
SET     link_stress = GREATEST(source_stress,int_stress,target_stress);

--------------
-- set cost --
--------------
UPDATE  received.sa_ways_net_link
SET     link_cost = ROUND((source_road_length + target_road_length) / 2);

-- Remark: what is vert_cost created as a column on the vertices if it is not going to be used?