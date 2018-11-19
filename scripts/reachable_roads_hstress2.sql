INSERT INTO generated.sa_reachable_roads_high_stress (
    base_road,
    target_road,
    total_cost
)
SELECT  r1.road_id,
        v2.road_id,
        sheds.agg_cost
FROM    received.sa_ways r1,
        received.sa_ways_net_vert v1,
        received.sa_ways_net_vert v2,
        pgr_drivingDistance('
            SELECT  link_id AS id,
                    source_vert AS source,
                    target_vert AS target,
                    link_cost AS cost
            FROM    received.sa_ways_net_link',
            v1.vert_id,
            ?biking_distance, --value used in PfB approach, might change later, it is in meters and assumes a max 10 minute trip at 10mph
            directed := true
        ) sheds
--WHERE r1.road_id % :thread_num = :thread_no
--AND
WHERE
EXISTS (
            SELECT  1
            FROM    received.sa_boundary AS b
            WHERE   ST_Intersects(b.geometry,r1.geom)
)
AND     r1.road_id = v1.road_id
AND     v2.vert_id = sheds.node;