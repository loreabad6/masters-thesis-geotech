-- stress2

---------------------------------------------------
-- living_street
UPDATE  received.sa_ways SET ft_seg_stress = NULL, tf_seg_stress = NULL
WHERE   functional_class = 'living_street';

UPDATE  received.sa_ways
SET     ft_seg_stress = 3,
        tf_seg_stress = 3
FROM    received.sa_full_line osm
WHERE   functional_class = 'living_street'
AND     received.sa_ways.osm_id = osm.osm_id
AND     osm.bicycle = 'no';

UPDATE  received.sa_ways
SET     ft_seg_stress = COALESCE(ft_seg_stress,1),
        tf_seg_stress = COALESCE(tf_seg_stress,1)
WHERE   functional_class = 'living_street';

---------------------------------------------------
-- track
UPDATE  received.sa_ways SET ft_seg_stress = NULL, tf_seg_stress = NULL
WHERE   functional_class = 'track';

UPDATE  received.sa_ways
SET     ft_seg_stress = 1,
        tf_seg_stress = 1
WHERE   functional_class = 'track';

---------------------------------------------------
-- path
UPDATE  received.sa_ways SET ft_seg_stress = NULL, tf_seg_stress = NULL
WHERE   functional_class = 'path';

UPDATE  received.sa_ways
SET     ft_seg_stress = 1,
        tf_seg_stress = 1
WHERE   functional_class = 'path';

---------------------------------------------------
-- oneway_reset
UPDATE  received.sa_ways
SET     ft_seg_stress = NULL
WHERE   one_way = 'tf';

UPDATE  received.sa_ways
SET     tf_seg_stress = NULL
WHERE   one_way = 'ft';
-- reset opposite stress for one-way

---------------------------------------------------
-- motorway_trunk_int
UPDATE  received.sa_ways SET ft_int_stress = 1, tf_int_stress = 1
WHERE   functional_class IN ('motorway','trunk');
-- assume low stress, since these juncions would always be controlled or free flowing

---------------------------------------------------
-- primary_int
UPDATE  received.sa_ways SET ft_int_stress = 1, tf_int_stress = 1
WHERE   functional_class = 'primary';
-- assume low stress, since these juncions would always be controlled or free flowing

---------------------------------------------------
-- secondary_int
UPDATE  received.sa_ways SET ft_int_stress = 1, tf_int_stress = 1
WHERE   functional_class = 'secondary';
-- assume low stress, since these juncions would always be controlled or free flowing

---------------------------------------------------
-- tertiary_int
-- Find it as 'stress_tertiary_int' function in stress.R 

---------------------------------------------------
-- lower_int
--Find it as 'stress_lower_int' function in stress.R 
