-- in review on GitHub on Nov. 15th 2018

DELETE FROM received.sa_full_line WHERE bicycle='no' and highway='path';

-- populate tables

------------------------------------------------------------------------------------------
-- one way
UPDATE  received.sa_ways SET one_way_car = NULL;

-- ft direction
UPDATE  received.sa_ways
SET     one_way_car = 'ft'
FROM    received.sa_full_line osm
WHERE   received.sa_ways.osm_id = osm.osm_id
AND     trim(osm.oneway) IN ('1','yes');

-- tf direction
UPDATE  received.sa_ways
SET     one_way_car = 'tf'
FROM    received.sa_full_line osm
WHERE   received.sa_ways.osm_id = osm.osm_id
AND     trim(osm.oneway) = '-1';


------------------------------------------------------------------------------------------
-- width
UPDATE  received.sa_ways SET width = NULL;

-- feet
UPDATE  received.sa_ways
SET     width = substring(osm.width from '\d+\.?\d?\d?')::FLOAT/3.28084
FROM    received.sa_full_line osm
WHERE   received.sa_ways.osm_id = osm.osm_id
AND     osm.width IS NOT NULL
AND     osm.width LIKE '% ft';

-- meters
UPDATE  received.sa_ways
SET     width = substring(osm.width from '\d+\.?\d?\d?')::FLOAT
FROM    received.sa_full_line osm
WHERE   received.sa_ways.osm_id = osm.osm_id
AND     osm.width IS NOT NULL
AND     osm.width LIKE '% m';

-- no units (default=meters)
UPDATE  received.sa_ways
SET     width = substring(osm.width from '\d+\.?\d?\d?')::FLOAT
FROM    received.sa_full_line osm
WHERE   received.sa_ways.osm_id = osm.osm_id
AND     osm.width IS NOT NULL
AND     substring(osm.width from '\d+\.?\d?\d?')::FLOAT < 20;

-- Things changed: I'd rather have width in meters, so I changed all the conversion factors.

------------------------------------------------------------------------------------------
-- functional_class
UPDATE  received.sa_ways SET functional_class = NULL;

UPDATE  received.sa_ways
SET     functional_class = osm.highway
FROM    received.sa_full_line osm
WHERE   received.sa_ways.osm_id = osm.osm_id
AND     osm.highway IN (
            'motorway',
            'tertiary',
            'trunk',
            'tertiary_link',
            'motorway_link',
            'secondary_link',
            'primary_link',
            'trunk_link',
            'unclassified',
            'residential',
            'secondary',
            'primary',
            'living_street'
);

UPDATE  received.sa_ways
SET     functional_class = 'track'
FROM    received.sa_full_line osm
WHERE   received.sa_ways.osm_id = osm.osm_id
AND     osm.highway = 'track'
AND     osm.tracktype = 'grade1';

UPDATE  received.sa_ways
SET     functional_class = 'path'
FROM    received.sa_full_line osm
WHERE   received.sa_ways.osm_id = osm.osm_id
AND     osm.highway IN ('cycleway','path');

UPDATE  received.sa_ways
SET     functional_class = 'path',
        xwalk = 1
FROM    received.sa_full_line osm
WHERE   received.sa_ways.osm_id = osm.osm_id
AND     osm.highway = 'footway'
AND     osm.footway = 'crossing';

UPDATE  received.sa_ways
SET     functional_class = 'path'
FROM    received.sa_full_line osm
WHERE   received.sa_ways.osm_id = osm.osm_id
AND     osm.highway = 'footway'
AND     osm.bicycle = 'designated'
AND     (osm.access IS NULL OR osm.access NOT IN ('no','private'))
AND     COALESCE(received.sa_ways.width,0) >= 8;

UPDATE  received.sa_ways
SET     functional_class = 'path'
FROM    received.sa_full_line osm
WHERE   received.sa_ways.osm_id = osm.osm_id
AND     osm.highway='service'
AND     osm.bicycle='designated';

UPDATE  received.sa_ways
SET     functional_class = 'living_street'
FROM    received.sa_full_line osm
WHERE   received.sa_ways.osm_id = osm.osm_id
AND     osm.highway = 'pedestrian'
AND     osm.bicycle IN ('yes','permissive', 'designated')
AND     (osm.access IS NULL OR osm.access NOT IN ('no','private'));

-- remove stuff that we don't want to route over
DELETE FROM received.sa_ways WHERE functional_class IS NULL;

-- remove orphans
DELETE FROM received.sa_ways
WHERE   NOT EXISTS (
            SELECT  1
            FROM    received.sa_ways w
            WHERE   received.sa_ways.intersection_to IN (w.intersection_to,w.intersection_from)
            AND     w.road_id != received.sa_ways.road_id
)
AND     NOT EXISTS (
            SELECT  1
            FROM    received.sa_ways w
            WHERE   received.sa_ways.intersection_from IN (w.intersection_to,w.intersection_from)
            AND     w.road_id != received.sa_ways.road_id
);

-- remove obsolete intersections
DELETE FROM received.sa_ways_int
WHERE NOT EXISTS (
    SELECT  1
    FROM    received.sa_ways w
    WHERE   int_id IN (w.intersection_to,w.intersection_from)
);

----------------------------------------------------------------------
-- paths
DROP TABLE IF EXISTS generated.sa_paths;
DROP INDEX IF EXISTS received.idx_sa_ways_path_id;

CREATE TABLE generated.sa_paths (
    path_id SERIAL PRIMARY KEY,
    geom geometry(multilinestring, ?sa_crs),
    road_ids INTEGER[],
    path_length INTEGER,
    bbox_length INTEGER
);

-- combine contiguous paths
INSERT INTO generated.sa_paths (geom)
SELECT  ST_CollectionExtract(
            ST_SetSRID(
                unnest(ST_ClusterIntersecting(geom)),
                ?sa_crs
            ),
            2   --linestrings
        )
FROM    received.sa_ways
WHERE   functional_class = 'path';

-- get raw lengths
UPDATE  generated.sa_paths
SET     path_length = ST_Length(geom);

-- get bounding box lengths
UPDATE  generated.sa_paths
SET     bbox_length = ST_Length(
            ST_SetSRID(
                ST_MakeLine(
                    ST_MakePoint(ST_XMin(geom), ST_YMin(geom)),
                    ST_MakePoint(ST_XMax(geom), ST_YMax(geom))
                ),
                ?sa_crs
            )
        );

-- index
CREATE INDEX sidx_sa_paths_geom ON generated.sa_paths USING GIST (geom);
ANALYZE generated.sa_paths (geom);

-- set path_id on each road segment (if path)
UPDATE  received.sa_ways
SET     path_id = (
            SELECT  paths.path_id
            FROM    generated.sa_paths paths
            WHERE   ST_Intersects(received.sa_ways.geom,paths.geom)
            AND     ST_CoveredBy(received.sa_ways.geom,paths.geom)
            LIMIT   1
        )
WHERE   functional_class = 'path';

-- get stragglers
UPDATE  received.sa_ways
SET     path_id = paths.path_id
FROM    generated.sa_paths paths
WHERE   received.sa_ways.functional_class = 'path'
AND     received.sa_ways.path_id IS NULL
AND     ST_Intersects(received.sa_ways.geom,paths.geom)
AND     ST_CoveredBy(received.sa_ways.geom,ST_Buffer(paths.geom,1));

-- set index
CREATE INDEX idx_sa_ways_path_id ON received.sa_ways (path_id);
ANALYZE received.sa_ways (path_id);

-- set road_ids
UPDATE  generated.sa_paths
SET     road_ids = array((
            SELECT  road_id
            FROM    received.sa_ways
            WHERE   received.sa_ways.path_id = generated.sa_paths.path_id
        ));

-- index
CREATE INDEX aidx_sa_paths_road_ids ON generated.sa_paths USING GIN (road_ids);
ANALYZE generated.sa_paths (road_ids);

-----------------------------------------------------------------------
-- speed_limit
UPDATE  received.sa_ways SET speed_limit = NULL;

UPDATE  received.sa_ways
SET     speed_limit = substring(osm.maxspeed from '\d+')::INT
FROM    received.sa_full_line osm
WHERE   received.sa_ways.osm_id = osm.osm_id;

-- Things changed:removed last line where they prompted for speeds in mph.

----------------------------------------------------------------------
-- lanes
UPDATE  received.sa_ways
SET     ft_lanes = NULL, tf_lanes = NULL, ft_cross_lanes = NULL, tf_cross_lanes = NULL;

UPDATE  received.sa_ways
SET     ft_lanes =
            CASE    WHEN osm."turn:lanes:forward" IS NOT NULL
                        THEN    array_length(
                                    regexp_split_to_array(
                                        osm."turn:lanes:forward",
                                        '\\|'
                                    ),
                                    1       -- only one dimension
                                )
                    WHEN osm."turn:lanes" IS NOT NULL AND received.sa_ways.one_way_car = 'ft'
                        THEN    array_length(
                                    regexp_split_to_array(
                                        osm."turn:lanes",
                                        '\\|'
                                    ),
                                    1       -- only one dimension
                                )
                    WHEN osm."lanes:forward" IS NOT NULL
                        THEN    substring(osm."lanes:forward" FROM '\\d+')::INT
                    WHEN osm."lanes" IS NOT NULL AND received.sa_ways.one_way_car = 'ft'
                        THEN    substring(osm."lanes" FROM '\\d+')::INT
                    WHEN osm."lanes" IS NOT NULL AND received.sa_ways.one_way_car = NULL
                        THEN    ceil(substring(osm."lanes" FROM '\\d+')::FLOAT / 2)
                    END,
        tf_lanes =
                    CASE    WHEN osm."turn:lanes:backward" IS NOT NULL
                                THEN    array_length(
                                            regexp_split_to_array(
                                                osm."turn:lanes:backward",
                                                '\\|'
                                            ),
                                            1       -- only one dimension
                                        )
                            WHEN osm."turn:lanes" IS NOT NULL AND received.sa_ways.one_way_car = 'tf'
                                THEN    array_length(
                                            regexp_split_to_array(
                                                osm."turn:lanes",
                                                '\\|'
                                            ),
                                            1       -- only one dimension
                                        )
                            WHEN osm."lanes:backward" IS NOT NULL
                                THEN    substring(osm."lanes:backward" FROM '\\d+')::INT
                            WHEN osm."lanes" IS NOT NULL AND received.sa_ways.one_way_car = 'tf'
                                THEN    substring(osm."lanes" FROM '\\d+')::INT
                            WHEN osm."lanes" IS NOT NULL AND received.sa_ways.one_way_car = NULL
                                THEN    ceil(substring(osm."lanes" FROM '\\d+')::FLOAT / 2)
                            END,
        ft_cross_lanes =
            CASE    WHEN osm."turn:lanes:forward" IS NOT NULL
                        THEN    array_length(
                                    array_remove(
                                        regexp_split_to_array(
                                            osm."turn:lanes:forward",
                                            '\\|'
                                        ),
                                        'right'     -- don't consider right-only lanes for crossing stress
                                    ),
                                    1               -- only one dimension
                                )
                    WHEN osm."turn:lanes" IS NOT NULL AND received.sa_ways.one_way_car = 'ft'
                        THEN    array_length(
                                    array_remove(
                                        regexp_split_to_array(
                                            osm."turn:lanes",
                                            '\\|'
                                        ),
                                        'right'     -- don't consider right-only lanes for crossing stress
                                    ),
                                    1               -- only one dimension
                                )
                    WHEN osm."lanes:forward" IS NOT NULL
                        THEN    substring(osm."lanes:forward" FROM '\\d+')::INT
                    WHEN osm."lanes" IS NOT NULL AND received.sa_ways.one_way_car = 'ft'
                        THEN    substring(osm."lanes" FROM '\\d+')::INT
                    WHEN osm."lanes" IS NOT NULL AND received.sa_ways.one_way_car = NULL
                        THEN    ceil(substring(osm."lanes" FROM '\\d+')::FLOAT / 2)
                    END,
        tf_cross_lanes =
            CASE    WHEN osm."turn:lanes:backward" IS NOT NULL
                        THEN    array_length(
                                    array_remove(
                                        regexp_split_to_array(
                                            osm."turn:lanes:backward",
                                            '\\|'
                                        ),
                                        'right'     -- don't consider right-only lanes for crossing stress
                                    ),
                                    1               -- only one dimension
                                )
                    WHEN osm."turn:lanes" IS NOT NULL AND received.sa_ways.one_way_car = 'tf'
                        THEN    array_length(
                                    array_remove(
                                        regexp_split_to_array(
                                            osm."turn:lanes",
                                            '\\|'
                                        ),
                                        'right'     -- don't consider right-only lanes for crossing stress
                                    ),
                                    1               -- only one dimension
                                )
                    WHEN osm."lanes:backward" IS NOT NULL
                        THEN    substring(osm."lanes:backward" FROM '\\d+')::INT
                    WHEN osm."lanes" IS NOT NULL AND received.sa_ways.one_way_car = 'tf'
                        THEN    substring(osm."lanes" FROM '\\d+')::INT
                    WHEN osm."lanes" IS NOT NULL AND received.sa_ways.one_way_car = NULL
                        THEN    ceil(substring(osm."lanes" FROM '\\d+')::FLOAT / 2)
                    END,
        twltl_cross_lanes =
            CASE    WHEN osm."lanes:both_ways" IS NOT NULL THEN 1
                    WHEN osm."turn:lanes:both_ways" IS NOT NULL THEN 1
                    ELSE NULL
                    END
FROM    received.sa_full_line osm
WHERE   received.sa_ways.osm_id = osm.osm_id;

-- Things changed: The original query used one_way column, but that one is not populated yet, so I changed it to one_way_car

----------------------------------------------------------------------
-- park
UPDATE  received.sa_ways SET ft_park = NULL, tf_park = NULL;

-- both
UPDATE  received.sa_ways
SET     ft_park = CASE  WHEN osm."parking:lane:both" = 'parallel' THEN 1
                        WHEN osm."parking:lane:both" = 'paralell' THEN 1
                        WHEN osm."parking:lane:both" = 'diagonal' THEN 1
                        WHEN osm."parking:lane:both" = 'perpendicular' THEN 1
                        WHEN osm."parking:lane:both" = 'no_parking' THEN 0
                        WHEN osm."parking:lane:both" = 'no_stopping' THEN 0
                        END,
        tf_park = CASE  WHEN osm."parking:lane:both" = 'parallel' THEN 1
                        WHEN osm."parking:lane:both" = 'paralell' THEN 1
                        WHEN osm."parking:lane:both" = 'diagonal' THEN 1
                        WHEN osm."parking:lane:both" = 'perpendicular' THEN 1
                        WHEN osm."parking:lane:both" = 'no_parking' THEN 0
                        WHEN osm."parking:lane:both" = 'no_stopping' THEN 0
                        END
FROM    received.sa_full_line osm
WHERE   received.sa_ways.osm_id = osm.osm_id;

-- right
UPDATE  received.sa_ways
SET     ft_park = CASE  WHEN osm."parking:lane:right" = 'parallel' THEN 1
                        WHEN osm."parking:lane:right" = 'paralell' THEN 1
                        WHEN osm."parking:lane:right" = 'diagonal' THEN 1
                        WHEN osm."parking:lane:right" = 'perpendicular' THEN 1
                        WHEN osm."parking:lane:right" = 'no_parking' THEN 0
                        WHEN osm."parking:lane:right" = 'no_stopping' THEN 0
                        END
FROM    received.sa_full_line osm
WHERE   received.sa_ways.osm_id = osm.osm_id;

-- left
UPDATE  received.sa_ways
SET     tf_park = CASE  WHEN osm."parking:lane:left" = 'parallel' THEN 1
                        WHEN osm."parking:lane:left" = 'paralell' THEN 1
                        WHEN osm."parking:lane:left" = 'diagonal' THEN 1
                        WHEN osm."parking:lane:left" = 'perpendicular' THEN 1
                        WHEN osm."parking:lane:left" = 'no_parking' THEN 0
                        WHEN osm."parking:lane:left" = 'no_stopping' THEN 0
                        END
FROM    received.sa_full_line osm
WHERE   received.sa_ways.osm_id = osm.osm_id;

----------------------------------------------------------------------
-- bike_infrastructure
UPDATE  received.sa_ways SET ft_bike_infra = NULL, tf_bike_infra = NULL;

----------------------
-- ft direction
----------------------
UPDATE  received.sa_ways
SET     ft_bike_infra = CASE

            -- :both
            WHEN osm."cycleway:both" = 'shared_lane'
                THEN 'sharrow'
            WHEN osm."cycleway:both" = 'buffered_lane'
                THEN 'buffered_lane'
            WHEN osm."cycleway:both" = 'lane' AND osm."cycleway:buffer" IN ('yes','both','right','left')
                THEN 'buffered_lane'
            WHEN osm."cycleway:both" = 'lane' AND osm."cycleway:both:buffer" IN ('yes','both','right','left')
                THEN 'buffered_lane'
            WHEN osm."cycleway:both" = 'lane'
                THEN 'lane'
            WHEN osm."cycleway:both" = 'track'
                THEN 'track'
            WHEN (osm."cycleway:right" = 'track' AND osm."oneway:bicycle" = 'no')
                THEN 'track'
            WHEN (osm."cycleway:left" = 'track' AND osm."oneway:bicycle" = 'no')
                THEN 'track'
            WHEN (osm.cycleway = 'track' AND osm."oneway:bicycle" = 'no')
                THEN 'track'

            -- one-way=ft
            WHEN one_way_car = 'ft'
                THEN CASE   WHEN osm."cycleway:left" = 'shared_lane'
                                THEN 'sharrow'
                            WHEN osm."cycleway:left" = 'lane' AND osm."cycleway:buffer" IN ('yes','both','right','left')
                                THEN 'buffered_lane'
                            WHEN osm."cycleway:left" = 'lane' AND osm."cycleway:left:buffer" IN ('yes','both','right','left')
                                THEN 'buffered_lane'
                            WHEN osm."cycleway:left" = 'lane'
                                THEN 'lane'
                            WHEN osm."cycleway:left" = 'track'
                                THEN 'track'

                            -- stuff from two-way that also applies to one-way=ft
                            WHEN osm.cycleway = 'shared_lane'
                                THEN 'sharrow'
                            WHEN osm."cycleway:right" = 'shared_lane'
                                THEN 'sharrow'
                            WHEN osm.cycleway = 'buffered_lane'
                                THEN 'buffered_lane'
                            WHEN osm."cycleway:right" = 'buffered_lane'
                                THEN 'buffered_lane'
                            WHEN osm.cycleway = 'lane' AND osm."cycleway:buffer" IN ('yes','both','right','left')
                                THEN 'buffered_lane'
                            WHEN osm."cycleway:right" = 'lane' AND osm."cycleway:buffer" IN ('yes','both','right','left')
                                THEN 'buffered_lane'
                            WHEN osm."cycleway:right" = 'lane' AND osm."cycleway:right:buffer" IN ('yes','both','right','left')
                                THEN 'buffered_lane'
                            WHEN osm.cycleway = 'lane'
                                THEN 'lane'
                            WHEN osm."cycleway:right" = 'lane'
                                THEN 'lane'
                            WHEN osm."cycleway" = 'track'
                                THEN 'track'
                            WHEN osm."cycleway:right" = 'track'
                                THEN 'track'
                            END

            -- one-way=tf
            WHEN one_way_car = 'tf'
                THEN CASE   WHEN osm.cycleway = 'opposite_lane' AND osm."cycleway:buffer" IN ('yes','both','right','left')
                                THEN 'buffered_lane'
                            WHEN osm."cycleway:right" = 'opposite_lane' AND osm."cycleway:buffer" IN ('yes','both','right','left')
                                THEN 'buffered_lane'
                            WHEN osm."cycleway:right" = 'opposite_lane' AND osm."cycleway:right:buffer" IN ('yes','both','right','left')
                                THEN 'buffered_lane'
                            WHEN osm.cycleway = 'opposite_lane'
                                THEN 'lane'
                            WHEN osm."cycleway:right" = 'opposite_lane'
                                THEN 'lane'
                            WHEN osm."cycleway" = 'opposite_track'
                                THEN 'track'
                            WHEN (one_way_car = 'tf' AND osm."cycleway:left" = 'opposite_track')
                                THEN 'track'
                            WHEN (one_way_car = 'tf' AND osm."cycleway:right" = 'opposite_track')
                                THEN 'track'
                            END

            -- two-way
            WHEN one_way_car IS NULL
                THEN CASE   WHEN osm.cycleway = 'shared_lane'
                                THEN 'sharrow'
                            WHEN osm."cycleway:right" = 'shared_lane'
                                THEN 'sharrow'
                            WHEN osm.cycleway = 'buffered_lane'
                                THEN 'buffered_lane'
                            WHEN osm."cycleway:right" = 'buffered_lane'
                                THEN 'buffered_lane'
                            WHEN osm.cycleway = 'lane' AND osm."cycleway:buffer" IN ('yes','both','right','left')
                                THEN 'buffered_lane'
                            WHEN osm."cycleway:right" = 'lane' AND osm."cycleway:buffer" IN ('yes','both','right','left')
                                THEN 'buffered_lane'
                            WHEN osm."cycleway:right" = 'lane' AND osm."cycleway:right:buffer" IN ('yes','both','right','left')
                                THEN 'buffered_lane'
                            WHEN osm.cycleway = 'lane'
                                THEN 'lane'
                            WHEN osm."cycleway:right" = 'lane'
                                THEN 'lane'
                            WHEN osm."cycleway" = 'track'
                                THEN 'track'
                            WHEN osm."cycleway:right" = 'track'
                                THEN 'track'
                            END
            END,

        tf_bike_infra = CASE

            -- :both
            WHEN osm."cycleway:both" = 'shared_lane'
                THEN 'sharrow'
            WHEN osm."cycleway:both" = 'buffered_lane'
                THEN 'buffered_lane'
            WHEN osm."cycleway:both" = 'lane' AND osm."cycleway:buffer" IN ('yes','both','right','left')
                THEN 'buffered_lane'
            WHEN osm."cycleway:both" = 'lane' AND osm."cycleway:both:buffer" IN ('yes','both','right','left')
                THEN 'buffered_lane'
            WHEN osm."cycleway:both" = 'lane'
                THEN 'lane'
            WHEN osm."cycleway:both" = 'track'
                THEN 'track'
            WHEN (osm."cycleway:right" = 'track' AND osm."oneway:bicycle" = 'no')
                THEN 'track'
            WHEN (osm."cycleway:left" = 'track' AND osm."oneway:bicycle" = 'no')
                THEN 'track'
            WHEN (osm.cycleway = 'track' AND osm."oneway:bicycle" = 'no')
                THEN 'track'

            -- one-way=tf
            WHEN one_way_car = 'tf'
                THEN CASE   WHEN osm."cycleway:right" = 'shared_lane'
                                THEN 'sharrow'
                            WHEN osm."cycleway:right" = 'lane' AND osm."cycleway:buffer" IN ('yes','both','right','left')
                                THEN 'buffered_lane'
                            WHEN osm."cycleway:right" = 'lane' AND osm."cycleway:right:buffer" IN ('yes','both','right','left')
                                THEN 'buffered_lane'
                            WHEN osm."cycleway:right" = 'lane'
                                THEN 'lane'
                            WHEN osm."cycleway:right" = 'track'
                                THEN 'track'

                            -- stuff from two-way that also applies to one-way=tf
                            WHEN osm.cycleway = 'shared_lane'
                                THEN 'sharrow'
                            WHEN osm."cycleway:left" = 'shared_lane'
                                THEN 'sharrow'
                            WHEN osm.cycleway = 'buffered_lane'
                                THEN 'buffered_lane'
                            WHEN osm."cycleway:left" = 'buffered_lane'
                                THEN 'buffered_lane'
                            WHEN osm.cycleway = 'lane' AND osm."cycleway:buffer" IN ('yes','both','right','left')
                                THEN 'buffered_lane'
                            WHEN osm."cycleway:left" = 'lane' AND osm."cycleway:buffer" IN ('yes','both','right','left')
                                THEN 'buffered_lane'
                            WHEN osm."cycleway:left" = 'lane' AND osm."cycleway:left:buffer" IN ('yes','both','right','left')
                                THEN 'buffered_lane'
                            WHEN osm.cycleway = 'lane'
                                THEN 'lane'
                            WHEN osm."cycleway:left" = 'lane'
                                THEN 'lane'
                            WHEN osm."cycleway" = 'track'
                                THEN 'track'
                            WHEN osm."cycleway:left" = 'track'
                                THEN 'track'
                            END

            -- one-way=ft
            WHEN one_way_car = 'ft'
                THEN CASE   WHEN osm.cycleway = 'opposite_lane' AND osm."cycleway:buffer" IN ('yes','both','right','left')
                                THEN 'buffered_lane'
                            WHEN osm."cycleway:right" = 'opposite_lane' AND osm."cycleway:buffer" IN ('yes','both','right','left')
                                THEN 'buffered_lane'
                            WHEN osm."cycleway:right" = 'opposite_lane' AND osm."cycleway:right:buffer" IN ('yes','both','right','left')
                                THEN 'buffered_lane'
                            WHEN osm.cycleway = 'opposite_lane'
                                THEN 'lane'
                            WHEN osm."cycleway:right" = 'opposite_lane'
                                THEN 'lane'
                            WHEN osm."cycleway" = 'opposite_track'
                                THEN 'track'
                            WHEN (one_way_car = 'tf' AND osm."cycleway:left" = 'opposite_track')
                                THEN 'track'
                            WHEN (one_way_car = 'tf' AND osm."cycleway:right" = 'opposite_track')
                                THEN 'track'
                            END

            -- two-way
            WHEN one_way_car IS NULL
                THEN CASE   WHEN osm.cycleway = 'shared_lane'
                                THEN 'sharrow'
                            WHEN osm."cycleway:left" = 'shared_lane'
                                THEN 'sharrow'
                            WHEN osm.cycleway = 'buffered_lane'
                                THEN 'buffered_lane'
                            WHEN osm."cycleway:left" = 'buffered_lane'
                                THEN 'buffered_lane'
                            WHEN osm.cycleway = 'lane' AND osm."cycleway:buffer" IN ('yes','both','right','left')
                                THEN 'buffered_lane'
                            WHEN osm."cycleway:left" = 'lane' AND osm."cycleway:buffer" IN ('yes','both','right','left')
                                THEN 'buffered_lane'
                            WHEN osm."cycleway:left" = 'lane' AND osm."cycleway:left:buffer" IN ('yes','both','right','left')
                                THEN 'buffered_lane'
                            WHEN osm.cycleway = 'lane'
                                THEN 'lane'
                            WHEN osm."cycleway:left" = 'lane'
                                THEN 'lane'
                            WHEN osm."cycleway" = 'track'
                                THEN 'track'
                            WHEN osm."cycleway:left" = 'track'
                                THEN 'track'
                            END
            END
FROM    received.sa_full_line osm
WHERE   received.sa_ways.osm_id = osm.osm_id;

-- update one_way based on bike infra
UPDATE  received.sa_ways
SET     one_way = NULL;
UPDATE  received.sa_ways
SET     one_way = one_way_car
FROM    received.sa_full_line osm
WHERE   received.sa_ways.osm_id = osm.osm_id
AND     one_way_car = 'ft'
AND     NOT (tf_bike_infra IS NOT NULL OR COALESCE(osm."oneway:bicycle",'yes') = 'no');
UPDATE  received.sa_ways
SET     one_way = one_way_car
FROM    received.sa_full_line osm
WHERE   received.sa_ways.osm_id = osm.osm_id
AND     one_way_car = 'tf'
AND     NOT (ft_bike_infra IS NOT NULL OR COALESCE(osm."oneway:bicycle",'yes') = 'no');

-- get facility widths
UPDATE  received.sa_ways
SET     ft_bike_infra_width = CASE

            -- feet
            WHEN osm."cycleway:right:width" LIKE '% ft'
                THEN substring("cycleway:right:width" from '\\d+\\.?\\d?\\d?')::FLOAT/3.28084
            WHEN one_way_car = 'ft' AND osm."cycleway:left:width" LIKE '% ft'
                THEN substring("cycleway:left:width" from '\\d+\\.?\\d?\\d?')::FLOAT/3.28084
            WHEN osm."cycleway:both:width" LIKE '% ft'
                THEN substring("cycleway:both:width" from '\\d+\\.?\\d?\\d?')::FLOAT/3.28084
            WHEN osm."cycleway:width" LIKE '% ft'
                THEN substring("cycleway:width" from '\\d+\\.?\\d?\\d?')::FLOAT/3.28084

            -- meters
            WHEN osm."cycleway:right:width" LIKE '% m'
                THEN substring("cycleway:right:width" from '\\d+\\.?\\d?\\d?')::FLOAT
            WHEN one_way_car = 'ft' AND osm."cycleway:left:width" LIKE '% m'
                THEN substring("cycleway:left:width" from '\\d+\\.?\\d?\\d?')::FLOAT
            WHEN osm."cycleway:both:width" LIKE '% m'
                THEN substring("cycleway:both:width" from '\\d+\\.?\\d?\\d?')::FLOAT
            WHEN osm."cycleway:width" LIKE '% m'
                THEN substring("cycleway:width" from '\\d+\\.?\\d?\\d?')::FLOAT

            -- no units (default=meters)
            WHEN osm."cycleway:right:width" IS NOT NULL
                THEN substring("cycleway:right:width" from '\\d+\\.?\\d?\\d?')::FLOAT
            WHEN one_way_car = 'ft' AND osm."cycleway:left:width" IS NOT NULL
                THEN substring("cycleway:left:width" from '\\d+\\.?\\d?\\d?')::FLOAT
            WHEN osm."cycleway:both:width" IS NOT NULL
                THEN substring("cycleway:both:width" from '\\d+\\.?\\d?\\d?')::FLOAT
            WHEN osm."cycleway:width" IS NOT NULL
                THEN substring("cycleway:width" from '\\d+\\.?\\d?\\d?')::FLOAT
            END
FROM    received.sa_full_line osm
WHERE   received.sa_ways.osm_id = osm.osm_id
AND     ft_bike_infra IS NOT NULL;

UPDATE  received.sa_ways
SET     tf_bike_infra_width = CASE

            -- feet
            WHEN osm."cycleway:left:width" LIKE '% ft'
                THEN substring("cycleway:left:width" from '\\d+\\.?\\d?\\d?')::FLOAT/3.28084
            WHEN one_way_car = 'tf' AND osm."cycleway:right:width" LIKE '% ft'
                THEN substring("cycleway:right:width" from '\\d+\\.?\\d?\\d?')::FLOAT/3.28084
            WHEN osm."cycleway:both:width" LIKE '% ft'
                THEN substring("cycleway:both:width" from '\\d+\\.?\\d?\\d?')::FLOAT/3.28084
            WHEN osm."cycleway:width" LIKE '% ft'
                THEN substring("cycleway:width" from '\\d+\\.?\\d?\\d?')::FLOAT/3.28084

            -- meters
            WHEN osm."cycleway:left:width" LIKE '% m'
                THEN substring("cycleway:left:width" from '\\d+\\.?\\d?\\d?')::FLOAT
            WHEN one_way_car = 'tf' AND osm."cycleway:right:width" LIKE '% m'
                THEN substring("cycleway:right:width" from '\\d+\\.?\\d?\\d?')::FLOAT
            WHEN osm."cycleway:both:width" LIKE '% m'
                THEN substring("cycleway:both:width" from '\\d+\\.?\\d?\\d?')::FLOAT
            WHEN osm."cycleway:width" LIKE '% m'
                THEN substring("cycleway:width" from '\\d+\\.?\\d?\\d?')::FLOAT

            -- no units (default=meters)
            WHEN osm."cycleway:left:width" IS NOT NULL
                THEN substring("cycleway:left:width" from '\\d+\\.?\\d?\\d?')::FLOAT
            WHEN one_way_car = 'tf' AND osm."cycleway:right:width" IS NOT NULL
                THEN substring("cycleway:right:width" from '\\d+\\.?\\d?\\d?')::FLOAT
            WHEN osm."cycleway:both:width" IS NOT NULL
                THEN substring("cycleway:both:width" from '\\d+\\.?\\d?\\d?')::FLOAT
            WHEN osm."cycleway:width" IS NOT NULL
                THEN substring("cycleway:width" from '\\d+\\.?\\d?\\d?')::FLOAT
            END
FROM    received.sa_full_line osm
WHERE   received.sa_ways.osm_id = osm.osm_id
AND     tf_bike_infra IS NOT NULL;

----------------------------------------------------------------------
-- class_adjustement
UPDATE  received.sa_ways
SET     functional_class = 'tertiary'
WHERE   functional_class IN ('residential','unclassified')
AND     (
            ft_bike_infra IN ('track','buffered_lane','lane')
        OR  tf_bike_infra IN ('track','buffered_lane','lane')
        OR  ft_lanes > 1
        OR  tf_lanes > 1
        OR  speed_limit >= 50
        );

-- Things changed: speed limit from 30 mph to 50 kmh
