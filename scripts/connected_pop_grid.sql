DROP TABLE IF EXISTS generated.sa_connected_pop_grid;

CREATE TABLE generated.sa_connected_pop_grid (
    id SERIAL PRIMARY KEY,
    source_cellid VARCHAR(18),
    target_cellid VARCHAR(18),
    low_stress BOOLEAN,
    low_stress_cost INT,
    high_stress BOOLEAN,
    high_stress_cost INT
);

INSERT INTO generated.sa_connected_pop_grid (
    source_cellid, target_cellid,
    low_stress, low_stress_cost, high_stress, high_stress_cost
)
SELECT  source.cell_id,
        target.cell_id,
        FALSE,
        (
            SELECT  MIN(ls.total_cost)
            FROM    generated.sa_reachable_roads_low_stress ls
            WHERE   ls.base_road = ANY(source.road_ids)
            AND     ls.target_road = ANY(target.road_ids)
        ),
        TRUE,
        (
            SELECT  MIN(hs.total_cost)
            FROM    generated.sa_reachable_roads_low_stress hs 
			--They take it from the low stress because these roads can also be accessed by cars. 
			-- Doing it with high stress takes a lot of time because they are like 2 million records, 
			-- while low are 300 thousand. This is why they update afterwards. 
            WHERE   hs.base_road = ANY(source.road_ids)
            AND     hs.target_road = ANY(target.road_ids)
        )
FROM    generated.sa_pop_grid source,
        generated.sa_pop_grid target,
        received.sa_boundary
WHERE   ST_Intersects(source.geometry,received.sa_boundary.geometry)
AND     ST_DWithin(source.geometry,target.geometry,?biking_distance);

-- set low_stress
UPDATE  generated.sa_connected_pop_grid
SET     low_stress = TRUE
WHERE   EXISTS (
            SELECT  1
            FROM    generated.sa_pop_grid source,
                    generated.sa_pop_grid target
            WHERE   generated.sa_connected_pop_grid.source_cellid = source.cell_id
            AND     generated.sa_connected_pop_grid.target_cellid = target.cell_id
            AND     source.road_ids && target.road_ids
        )
OR      (
            low_stress_cost IS NOT NULL
        AND CASE    WHEN COALESCE(high_stress_cost,0) = 0 THEN TRUE
                    ELSE low_stress_cost::FLOAT / high_stress_cost <= 1.25
                    END
        );
		
CREATE UNIQUE INDEX idx_sa_cellpairs ON generated.sa_connected_pop_grid (source_cellid,target_cellid);
CREATE INDEX IF NOT EXISTS idx_sa_cellpairs_lstress ON generated.sa_connected_pop_grid (low_stress) WHERE low_stress IS TRUE;
CREATE INDEX IF NOT EXISTS idx_sa_cellpairs_hstress ON generated.sa_connected_pop_grid (high_stress) WHERE high_stress IS TRUE;
ANALYZE generated.sa_connected_pop_grid;