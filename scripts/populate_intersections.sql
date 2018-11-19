-- populate_intersections

----------------------------------------------------------------------
-- legs
UPDATE  received.sa_ways_int
SET     legs = (
            SELECT  COUNT(road_id)
            FROM    received.sa_ways
            WHERE   received.sa_ways_int.int_id IN (intersection_from,intersection_to)
);

----------------------------------------------------------------------
-- signalized
UPDATE received.sa_ways_int SET signalized = 'f';

-----------------------------------
-- traffic signals
-----------------------------------
UPDATE  received.sa_ways_int
SET     signalized = 't'
FROM    received.sa_full_point osm
WHERE   received.sa_ways_int.osm_id = osm.osm_id
AND     osm.highway = 'traffic_signals';

UPDATE  received.sa_ways_int
SET     signalized = 't'
FROM    received.sa_ways,
        received.sa_full_line osm
WHERE   received.sa_ways.osm_id = osm.osm_id
AND     int_id = received.sa_ways.intersection_to
AND     osm."traffic_signals:direction" = 'forward';

UPDATE  received.sa_ways_int
SET     signalized = 't'
FROM    received.sa_ways,
        received.sa_full_line osm
WHERE   received.sa_ways.osm_id = osm.osm_id
AND     int_id = received.sa_ways.intersection_from
AND     osm."traffic_signals:direction" = 'backward';


-----------------------------------
-- HAWKs and other variants
-----------------------------------
UPDATE  received.sa_ways_int
SET     signalized = 't'
WHERE   legs > 2
AND     EXISTS (
            SELECT  1
            FROM    received.sa_full_point osm
            WHERE   osm.highway = 'crossing'
            AND     osm.crossing IN ('traffic_signals','pelican','toucan')
            AND     ST_DWithin(received.sa_ways_int.geom, osm.way, 25)
        );


-----------------------------------
-- Capture signals from other points
-- on the intersection
-----------------------------------
UPDATE  received.sa_ways_int
SET     signalized = 't'
WHERE   legs > 2
AND     EXISTS (
            SELECT  1
            FROM    received.sa_ways_int i
            WHERE   i.signalized
            AND     ST_DWithin(received.sa_ways_int.geom, i.geom, 25)
        );

----------------------------------------------------------------------
-- stops
UPDATE received.sa_ways_int SET stops = 'f';

UPDATE  received.sa_ways_int
SET     stops = 't'
FROM    received.sa_full_point osm
WHERE   received.sa_ways_int.osm_id = osm.osm_id
AND     osm.highway = 'stop'
AND     osm.stop = 'all';

UPDATE  received.sa_ways_int
SET     stops = 't'
WHERE   legs > 2
AND     EXISTS (
            SELECT  1
            FROM    received.sa_ways_int i
            WHERE   i.stops
            AND     ST_DWithin(received.sa_ways_int.geom, i.geom, 25)
        );
		
----------------------------------------------------------------------
-- rrfb
UPDATE received.sa_ways_int SET rrfb = FALSE;

UPDATE  received.sa_ways_int
SET     rrfb = TRUE
WHERE   legs > 2
AND     EXISTS (
            SELECT  1
            FROM    received.sa_full_point osm
            WHERE   osm.highway = 'crossing'
            AND     osm.flashing_lights = 'yes'
            AND     ST_DWithin(received.sa_ways_int.geom, osm.way, 25)
        );
		
----------------------------------------------------------------------
-- island
UPDATE received.sa_ways_int SET island = FALSE;

UPDATE  received.sa_ways_int
SET     island = TRUE
WHERE   legs > 2
AND     EXISTS (
            SELECT  1
            FROM    received.sa_full_point osm
            WHERE   osm.highway = 'crossing'
            AND     osm.crossing = 'island'
            AND     ST_DWithin(received.sa_ways_int.geom, osm.way, 25)
        );
		
		