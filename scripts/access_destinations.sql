-----------------------------------------------------------------------------------------------------------------------
-- colleges
-----------------------------------------------------------------------------------------------------------------------
-- set block-based raw numbers
UPDATE  generated.sa_pop_grid
SET     colleges_low_stress = (
            SELECT  COUNT(id)
            FROM    destinations.sa_colleges
            WHERE   EXISTS (
                        SELECT  1
                        FROM    generated.sa_connected_pop_grid
                        WHERE   generated.sa_connected_pop_grid.source_cellid = generated.sa_pop_grid.cell_id
                        AND     generated.sa_connected_pop_grid.target_cellid = ANY(destinations.sa_colleges.cell_id)
                        AND     generated.sa_connected_pop_grid.low_stress
                    )
        ),
        colleges_high_stress = (
            SELECT  COUNT(id)
            FROM    destinations.sa_colleges
            WHERE   EXISTS (
                        SELECT  1
                        FROM    generated.sa_connected_pop_grid
                        WHERE   generated.sa_connected_pop_grid.source_cellid = generated.sa_pop_grid.cell_id
                        AND     generated.sa_connected_pop_grid.target_cellid = ANY(destinations.sa_colleges.cell_id)
                    )
        )
WHERE   EXISTS (
            SELECT  1
            FROM    received.sa_boundary AS b
            WHERE   ST_Intersects(generated.sa_pop_grid.geometry,b.geometry)
        );

-- set block-based score
UPDATE  generated.sa_pop_grid
SET     colleges_score =    CASE
                            WHEN colleges_high_stress IS NULL THEN NULL
                            WHEN colleges_high_stress = 0 THEN NULL
                            WHEN colleges_low_stress = 0 THEN 0
                            WHEN colleges_high_stress = colleges_low_stress THEN ?max_score
                            WHEN ?Afirst = 0 THEN colleges_low_stress::FLOAT / colleges_high_stress
                            WHEN ?Asecond = 0
                                THEN    ?Afirst
                                        + ((?max_score - ?Afirst) * (colleges_low_stress::FLOAT - 1))
                                        / (colleges_high_stress - 1)
                            WHEN ?Athird = 0
                                THEN    CASE
                                        WHEN colleges_low_stress = 1 THEN ?Afirst
                                        WHEN colleges_low_stress = 2 THEN ?Afirst + ?Asecond
                                        ELSE ?Afirst + ?Asecond
                                                + ((?max_score - ?Afirst - ?Asecond) * (colleges_low_stress::FLOAT - 2))
                                                / (colleges_high_stress - 2)
                                        END
                            ELSE        CASE
                                        WHEN colleges_low_stress = 1 THEN ?Afirst
                                        WHEN colleges_low_stress = 2 THEN ?Afirst + ?Asecond
                                        WHEN colleges_low_stress = 3 THEN ?Afirst + ?Asecond + ?Athird
                                        ELSE ?Afirst + ?Asecond + ?Athird
                                                + ((?max_score - ?Afirst - ?Asecond - ?Athird) * (colleges_low_stress::FLOAT - 3))
                                                / (colleges_high_stress - 3)
                                        END
                            END;

-- set population shed for each college in the neighborhood
UPDATE  destinations.sa_colleges
SET     dest_type = 'college';

UPDATE  destinations.sa_colleges
SET     pop_high_stress = (
            SELECT  SUM(cb.population)
            FROM    generated.sa_pop_grid cb,
                    generated.sa_connected_pop_grid cbs
            WHERE   cbs.source_cellid = cb.cell_id
            AND     cbs.target_cellid = ANY(destinations.sa_colleges.cell_id)
        ),
        pop_low_stress = (
            SELECT  SUM(cb.population)
            FROM    generated.sa_pop_grid cb,
                    generated.sa_connected_pop_grid cbs
            WHERE   cbs.source_cellid = cb.cell_id
            AND     cbs.target_cellid = ANY(destinations.sa_colleges.cell_id)
            AND     cbs.low_stress
        )
WHERE   EXISTS (
            SELECT  1
            FROM    received.sa_boundary as b
            WHERE   ST_Intersects(destinations.sa_colleges.geom_pt,b.geometry)
        );

UPDATE  destinations.sa_colleges
SET     pop_score = CASE    WHEN pop_high_stress IS NULL THEN NULL
                            WHEN pop_high_stress = 0 THEN 0
                            ELSE pop_low_stress::FLOAT / pop_high_stress
                            END;
							
-----------------------------------------------------------------------------------------------------------------------
-- community centers
-----------------------------------------------------------------------------------------------------------------------
-- set block-based raw numbers
UPDATE  generated.sa_pop_grid
SET     community_centers_low_stress = (
            SELECT  COUNT(id)
            FROM    destinations.sa_community_centers
            WHERE   EXISTS (
                        SELECT  1
                        FROM    generated.sa_connected_pop_grid
                        WHERE   generated.sa_connected_pop_grid.source_cellid = generated.sa_pop_grid.cell_id
                        AND     generated.sa_connected_pop_grid.target_cellid = ANY(destinations.sa_community_centers.cell_id)
                        AND     generated.sa_connected_pop_grid.low_stress
                    )
        ),
        community_centers_high_stress = (
            SELECT  COUNT(id)
            FROM    destinations.sa_community_centers
            WHERE   EXISTS (
                        SELECT  1
                        FROM    generated.sa_connected_pop_grid
                        WHERE   generated.sa_connected_pop_grid.source_cellid = generated.sa_pop_grid.cell_id
                        AND     generated.sa_connected_pop_grid.target_cellid = ANY(destinations.sa_community_centers.cell_id)
                    )
        )
WHERE   EXISTS (
            SELECT  1
            FROM    received.sa_boundary AS b
            WHERE   ST_Intersects(generated.sa_pop_grid.geometry,b.geometry)
        );

-- set block-based score
UPDATE  generated.sa_pop_grid
SET     community_centers_score =   CASE
                                    WHEN community_centers_high_stress IS NULL THEN NULL
                                    WHEN community_centers_high_stress = 0 THEN NULL
                                    WHEN community_centers_low_stress = 0 THEN 0
                                    WHEN community_centers_high_stress = community_centers_low_stress THEN ?max_score
                                    WHEN ?Bfirst = 0 THEN community_centers_low_stress::FLOAT / community_centers_high_stress
                                    WHEN ?Bsecond = 0
                                        THEN    ?Bfirst
                                                + ((?max_score - ?Bfirst) * (community_centers_low_stress::FLOAT - 1))
                                                / (community_centers_high_stress - 1)
                                    WHEN ?Bthird = 0
                                        THEN    CASE
                                                WHEN community_centers_low_stress = 1 THEN ?Bfirst
                                                WHEN community_centers_low_stress = 2 THEN ?Bfirst + ?Bsecond
                                                ELSE ?Bfirst + ?Bsecond
                                                        + ((?max_score - ?Bfirst - ?Bsecond) * (community_centers_low_stress::FLOAT - 2))
                                                        / (community_centers_high_stress - 2)
                                                END
                                    ELSE        CASE
                                                WHEN community_centers_low_stress = 1 THEN ?Bfirst
                                                WHEN community_centers_low_stress = 2 THEN ?Bfirst + ?Bsecond
                                                WHEN community_centers_low_stress = 3 THEN ?Bfirst + ?Bsecond + ?Bthird
                                                ELSE ?Bfirst + ?Bsecond + ?Bthird
                                                        + ((?max_score - ?Bfirst - ?Bsecond - ?Bthird) * (community_centers_low_stress::FLOAT - 3))
                                                        / (community_centers_high_stress - 3)
                                                END
                                    END;

-- set population shed for each community center in the neighborhood
UPDATE  destinations.sa_community_centers
SET     dest_type = 'community_center';

UPDATE  destinations.sa_community_centers
SET     pop_high_stress = (
            SELECT  SUM(cb.population)
            FROM    generated.sa_pop_grid cb,
                    generated.sa_connected_pop_grid cbs
            WHERE   cbs.source_cellid = cb.cell_id
            AND     cbs.target_cellid = ANY(destinations.sa_community_centers.cell_id)
        ),
        pop_low_stress = (
            SELECT  SUM(cb.population)
            FROM    generated.sa_pop_grid cb,
                    generated.sa_connected_pop_grid cbs
            WHERE   cbs.source_cellid = cb.cell_id
            AND     cbs.target_cellid = ANY(destinations.sa_community_centers.cell_id)
            AND     cbs.low_stress
        )
WHERE   EXISTS (
            SELECT  1
            FROM    received.sa_boundary as b
            WHERE   ST_Intersects(destinations.sa_community_centers.geom_pt,b.geometry)
        );

UPDATE  destinations.sa_community_centers
SET     pop_score = CASE    WHEN pop_high_stress IS NULL THEN NULL
                            WHEN pop_high_stress = 0 THEN 0
                            ELSE pop_low_stress::FLOAT / pop_high_stress
                            END;
							
-----------------------------------------------------------------------------------------------------------------------
-- dentists
-----------------------------------------------------------------------------------------------------------------------
-- set block-based raw numbers
UPDATE  generated.sa_pop_grid
SET     dentists_low_stress = (
            SELECT  COUNT(id)
            FROM    destinations.sa_dentists
            WHERE   EXISTS (
                        SELECT  1
                        FROM    generated.sa_connected_pop_grid
                        WHERE   generated.sa_connected_pop_grid.source_cellid = generated.sa_pop_grid.cell_id
                        AND     generated.sa_connected_pop_grid.target_cellid = ANY(destinations.sa_dentists.cell_id)
                        AND     generated.sa_connected_pop_grid.low_stress
                    )
        ),
        dentists_high_stress = (
            SELECT  COUNT(id)
            FROM    destinations.sa_dentists
            WHERE   EXISTS (
                        SELECT  1
                        FROM    generated.sa_connected_pop_grid
                        WHERE   generated.sa_connected_pop_grid.source_cellid = generated.sa_pop_grid.cell_id
                        AND     generated.sa_connected_pop_grid.target_cellid = ANY(destinations.sa_dentists.cell_id)
                    )
        )
WHERE   EXISTS (
            SELECT  1
            FROM    received.sa_boundary AS b
            WHERE   ST_Intersects(generated.sa_pop_grid.geometry,b.geometry)
        );

-- set block-based score
UPDATE  generated.sa_pop_grid
SET     dentists_score =    CASE
                            WHEN dentists_high_stress IS NULL THEN NULL
                            WHEN dentists_high_stress = 0 THEN NULL
                            WHEN dentists_low_stress = 0 THEN 0
                            WHEN dentists_high_stress = dentists_low_stress THEN ?max_score
                            WHEN ?Bfirst = 0 THEN dentists_low_stress::FLOAT / dentists_high_stress
                            WHEN ?Bsecond = 0
                                THEN    ?Bfirst
                                        + ((?max_score - ?Bfirst) * (dentists_low_stress::FLOAT - 1))
                                        / (dentists_high_stress - 1)
                            WHEN ?Bthird = 0
                                THEN    CASE
                                        WHEN dentists_low_stress = 1 THEN ?Bfirst
                                        WHEN dentists_low_stress = 2 THEN ?Bfirst + ?Bsecond
                                        ELSE ?Bfirst + ?Bsecond
                                                + ((?max_score - ?Bfirst - ?Bsecond) * (dentists_low_stress::FLOAT - 2))
                                                / (dentists_high_stress - 2)
                                        END
                            ELSE        CASE
                                        WHEN dentists_low_stress = 1 THEN ?Bfirst
                                        WHEN dentists_low_stress = 2 THEN ?Bfirst + ?Bsecond
                                        WHEN dentists_low_stress = 3 THEN ?Bfirst + ?Bsecond + ?Bthird
                                        ELSE ?Bfirst + ?Bsecond + ?Bthird
                                                + ((?max_score - ?Bfirst - ?Bsecond - ?Bthird) * (dentists_low_stress::FLOAT - 3))
                                                / (dentists_high_stress - 3)
                                        END
                            END;

-- set population shed for each dentists destination in the neighborhood
UPDATE  destinations.sa_dentists
SET     dest_type = 'dentist';

UPDATE  destinations.sa_dentists
SET     pop_high_stress = (
            SELECT  SUM(cb.population)
            FROM    generated.sa_pop_grid cb,
                    generated.sa_connected_pop_grid cbs
            WHERE   cbs.source_cellid = cb.cell_id
            AND     cbs.target_cellid = ANY(destinations.sa_dentists.cell_id)
        ),
        pop_low_stress = (
            SELECT  SUM(cb.population)
            FROM    generated.sa_pop_grid cb,
                    generated.sa_connected_pop_grid cbs
            WHERE   cbs.source_cellid = cb.cell_id
            AND     cbs.target_cellid = ANY(destinations.sa_dentists.cell_id)
            AND     cbs.low_stress
        )
WHERE   EXISTS (
            SELECT  1
            FROM    received.sa_boundary as b
            WHERE   ST_Intersects(destinations.sa_dentists.geom_pt,b.geometry)
        );

UPDATE  destinations.sa_dentists
SET     pop_score = CASE    WHEN pop_high_stress IS NULL THEN NULL
                            WHEN pop_high_stress = 0 THEN 0
                            ELSE pop_low_stress::FLOAT / pop_high_stress
                            END;

-----------------------------------------------------------------------------------------------------------------------
-- doctors
-----------------------------------------------------------------------------------------------------------------------
-- set block-based raw numbers
UPDATE  generated.sa_pop_grid
SET     doctors_low_stress = (
            SELECT  COUNT(id)
            FROM    destinations.sa_doctors
            WHERE   EXISTS (
                        SELECT  1
                        FROM    generated.sa_connected_pop_grid
                        WHERE   generated.sa_connected_pop_grid.source_cellid = generated.sa_pop_grid.cell_id
                        AND     generated.sa_connected_pop_grid.target_cellid = ANY(destinations.sa_doctors.cell_id)
                        AND     generated.sa_connected_pop_grid.low_stress
                    )
        ),
        doctors_high_stress = (
            SELECT  COUNT(id)
            FROM    destinations.sa_doctors
            WHERE   EXISTS (
                        SELECT  1
                        FROM    generated.sa_connected_pop_grid
                        WHERE   generated.sa_connected_pop_grid.source_cellid = generated.sa_pop_grid.cell_id
                        AND     generated.sa_connected_pop_grid.target_cellid = ANY(destinations.sa_doctors.cell_id)
                    )
        )
WHERE   EXISTS (
            SELECT  1
            FROM    received.sa_boundary AS b
            WHERE   ST_Intersects(generated.sa_pop_grid.geometry,b.geometry)
        );

-- set block-based score
UPDATE  generated.sa_pop_grid
SET     doctors_score = CASE
                        WHEN doctors_high_stress IS NULL THEN NULL
                        WHEN doctors_high_stress = 0 THEN NULL
                        WHEN doctors_low_stress = 0 THEN 0
                        WHEN doctors_high_stress = doctors_low_stress THEN ?max_score
                        WHEN ?Bfirst = 0 THEN doctors_low_stress::FLOAT / doctors_high_stress
                        WHEN ?Bsecond = 0
                            THEN    ?Bfirst
                                    + ((?max_score - ?Bfirst) * (doctors_low_stress::FLOAT - 1))
                                    / (doctors_high_stress - 1)
                        WHEN ?Bthird = 0
                            THEN    CASE
                                    WHEN doctors_low_stress = 1 THEN ?Bfirst
                                    WHEN doctors_low_stress = 2 THEN ?Bfirst + ?Bsecond
                                    ELSE ?Bfirst + ?Bsecond
                                            + ((?max_score - ?Bfirst - ?Bsecond) * (doctors_low_stress::FLOAT - 2))
                                            / (doctors_high_stress - 2)
                                    END
                        ELSE        CASE
                                    WHEN doctors_low_stress = 1 THEN ?Bfirst
                                    WHEN doctors_low_stress = 2 THEN ?Bfirst + ?Bsecond
                                    WHEN doctors_low_stress = 3 THEN ?Bfirst + ?Bsecond + ?Bthird
                                    ELSE ?Bfirst + ?Bsecond + ?Bthird
                                            + ((?max_score - ?Bfirst - ?Bsecond - ?Bthird) * (doctors_low_stress::FLOAT - 3))
                                            / (doctors_high_stress - 3)
                                    END
                        END;

-- set population shed for each doctors destination in the neighborhood
UPDATE  destinations.sa_doctors
SET     dest_type = 'doctor';

UPDATE  destinations.sa_doctors
SET     pop_high_stress = (
            SELECT  SUM(cb.population)
            FROM    generated.sa_pop_grid cb,
                    generated.sa_connected_pop_grid cbs
            WHERE   cbs.source_cellid = cb.cell_id
            AND     cbs.target_cellid = ANY(destinations.sa_doctors.cell_id)
        ),
        pop_low_stress = (
            SELECT  SUM(cb.population)
            FROM    generated.sa_pop_grid cb,
                    generated.sa_connected_pop_grid cbs
            WHERE   cbs.source_cellid = cb.cell_id
            AND     cbs.target_cellid = ANY(destinations.sa_doctors.cell_id)
            AND     cbs.low_stress
        )
WHERE   EXISTS (
            SELECT  1
            FROM    received.sa_boundary as b
            WHERE   ST_Intersects(destinations.sa_doctors.geom_pt,b.geometry)
        );

UPDATE  destinations.sa_doctors
SET     pop_score = CASE    WHEN pop_high_stress IS NULL THEN NULL
                            WHEN pop_high_stress = 0 THEN 0
                            ELSE pop_low_stress::FLOAT / pop_high_stress
                            END;

-----------------------------------------------------------------------------------------------------------------------
-- hospitals
-----------------------------------------------------------------------------------------------------------------------
-- set block-based raw numbers
UPDATE  generated.sa_pop_grid
SET     hospitals_low_stress = (
            SELECT  COUNT(id)
            FROM    destinations.sa_hospitals
            WHERE   EXISTS (
                        SELECT  1
                        FROM    generated.sa_connected_pop_grid
                        WHERE   generated.sa_connected_pop_grid.source_cellid = generated.sa_pop_grid.cell_id
                        AND     generated.sa_connected_pop_grid.target_cellid = ANY(destinations.sa_hospitals.cell_id)
                        AND     generated.sa_connected_pop_grid.low_stress
                    )
        ),
        hospitals_high_stress = (
            SELECT  COUNT(id)
            FROM    destinations.sa_hospitals
            WHERE   EXISTS (
                        SELECT  1
                        FROM    generated.sa_connected_pop_grid
                        WHERE   generated.sa_connected_pop_grid.source_cellid = generated.sa_pop_grid.cell_id
                        AND     generated.sa_connected_pop_grid.target_cellid = ANY(destinations.sa_hospitals.cell_id)
                    )
        )
WHERE   EXISTS (
            SELECT  1
            FROM    received.sa_boundary AS b
            WHERE   ST_Intersects(generated.sa_pop_grid.geometry,b.geometry)
        );

-- set block-based score
UPDATE  generated.sa_pop_grid
SET     hospitals_score =   CASE
                            WHEN hospitals_high_stress IS NULL THEN NULL
                            WHEN hospitals_high_stress = 0 THEN NULL
                            WHEN hospitals_low_stress = 0 THEN 0
                            WHEN hospitals_high_stress = hospitals_low_stress THEN ?max_score
                            WHEN ?Afirst = 0 THEN hospitals_low_stress::FLOAT / hospitals_high_stress
                            WHEN ?Asecond = 0
                                THEN    ?Afirst
                                        + ((?max_score - ?Afirst) * (hospitals_low_stress::FLOAT - 1))
                                        / (hospitals_high_stress - 1)
                            WHEN ?Athird = 0
                                THEN    CASE
                                        WHEN hospitals_low_stress = 1 THEN ?Afirst
                                        WHEN hospitals_low_stress = 2 THEN ?Afirst + ?Asecond
                                        ELSE ?Afirst + ?Asecond
                                                + ((?max_score - ?Afirst - ?Asecond) * (hospitals_low_stress::FLOAT - 2))
                                                / (hospitals_high_stress - 2)
                                        END
                            ELSE        CASE
                                        WHEN hospitals_low_stress = 1 THEN ?Afirst
                                        WHEN hospitals_low_stress = 2 THEN ?Afirst + ?Asecond
                                        WHEN hospitals_low_stress = 3 THEN ?Afirst + ?Asecond + ?Athird
                                        ELSE ?Afirst + ?Asecond + ?Athird
                                                + ((?max_score - ?Afirst - ?Asecond - ?Athird) * (hospitals_low_stress::FLOAT - 3))
                                                / (hospitals_high_stress - 3)
                                        END
                            END;

-- set population shed for each hospitals destination in the neighborhood
UPDATE  destinations.sa_hospitals
SET     dest_type = 'hospital';

UPDATE  destinations.sa_hospitals
SET     pop_high_stress = (
            SELECT  SUM(cb.population)
            FROM    generated.sa_pop_grid cb,
                    generated.sa_connected_pop_grid cbs
            WHERE   cbs.source_cellid = cb.cell_id
            AND     cbs.target_cellid = ANY(destinations.sa_hospitals.cell_id)
        ),
        pop_low_stress = (
            SELECT  SUM(cb.population)
            FROM    generated.sa_pop_grid cb,
                    generated.sa_connected_pop_grid cbs
            WHERE   cbs.source_cellid = cb.cell_id
            AND     cbs.target_cellid = ANY(destinations.sa_hospitals.cell_id)
            AND     cbs.low_stress
        )
WHERE   EXISTS (
            SELECT  1
            FROM    received.sa_boundary as b
            WHERE   ST_Intersects(destinations.sa_hospitals.geom_pt,b.geometry)
        );

UPDATE  destinations.sa_hospitals
SET     pop_score = CASE    WHEN pop_high_stress IS NULL THEN NULL
                            WHEN pop_high_stress = 0 THEN 0
                            ELSE pop_low_stress::FLOAT / pop_high_stress
                            END;
							
-----------------------------------------------------------------------------------------------------------------------
-- parks
-----------------------------------------------------------------------------------------------------------------------
-- set block-based raw numbers
UPDATE  generated.sa_pop_grid
SET     parks_low_stress = (
            SELECT  COUNT(id)
            FROM    destinations.sa_parks
            WHERE   EXISTS (
                        SELECT  1
                        FROM    generated.sa_connected_pop_grid
                        WHERE   generated.sa_connected_pop_grid.source_cellid = generated.sa_pop_grid.cell_id
                        AND     generated.sa_connected_pop_grid.target_cellid = ANY(destinations.sa_parks.cell_id)
                        AND     generated.sa_connected_pop_grid.low_stress
                    )
        ),
        parks_high_stress = (
            SELECT  COUNT(id)
            FROM    destinations.sa_parks
            WHERE   EXISTS (
                        SELECT  1
                        FROM    generated.sa_connected_pop_grid
                        WHERE   generated.sa_connected_pop_grid.source_cellid = generated.sa_pop_grid.cell_id
                        AND     generated.sa_connected_pop_grid.target_cellid = ANY(destinations.sa_parks.cell_id)
                    )
        )
WHERE   EXISTS (
            SELECT  1
            FROM    received.sa_boundary AS b
            WHERE   ST_Intersects(generated.sa_pop_grid.geometry,b.geometry)
        );

-- set block-based score
UPDATE  generated.sa_pop_grid
SET     parks_score =   CASE
                        WHEN parks_high_stress IS NULL THEN NULL
                        WHEN parks_high_stress = 0 THEN NULL
                        WHEN parks_low_stress = 0 THEN 0
                        WHEN parks_high_stress = parks_low_stress THEN ?max_score
                        WHEN ?Cfirst = 0 THEN parks_low_stress::FLOAT / parks_high_stress
                        WHEN ?Csecond = 0
                            THEN    ?Cfirst
                                    + ((?max_score - ?Cfirst) * (parks_low_stress::FLOAT - 1))
                                    / (parks_high_stress - 1)
                        WHEN ?Cthird = 0
                            THEN    CASE
                                    WHEN parks_low_stress = 1 THEN ?Cfirst
                                    WHEN parks_low_stress = 2 THEN ?Cfirst + ?Csecond
                                    ELSE ?Cfirst + ?Csecond
                                            + ((?max_score - ?Cfirst - ?Csecond) * (parks_low_stress::FLOAT - 2))
                                            / (parks_high_stress - 2)
                                    END
                        ELSE        CASE
                                    WHEN parks_low_stress = 1 THEN ?Cfirst
                                    WHEN parks_low_stress = 2 THEN ?Cfirst + ?Csecond
                                    WHEN parks_low_stress = 3 THEN ?Cfirst + ?Csecond + ?Cthird
                                    ELSE ?Cfirst + ?Csecond + ?Cthird
                                            + ((?max_score - ?Cfirst - ?Csecond - ?Cthird) * (parks_low_stress::FLOAT - 3))
                                            / (parks_high_stress - 3)
                                    END
                        END;

-- set population shed for each park in the neighborhood
UPDATE  destinations.sa_parks
SET     dest_type = 'park';

UPDATE  destinations.sa_parks
SET     pop_high_stress = (
            SELECT  SUM(cb.population)
            FROM    generated.sa_pop_grid cb,
                    generated.sa_connected_pop_grid cbs
            WHERE   cbs.source_cellid = cb.cell_id
            AND     cbs.target_cellid = ANY(destinations.sa_parks.cell_id)
        ),
        pop_low_stress = (
            SELECT  SUM(cb.population)
            FROM    generated.sa_pop_grid cb,
                    generated.sa_connected_pop_grid cbs
            WHERE   cbs.source_cellid = cb.cell_id
            AND     cbs.target_cellid = ANY(destinations.sa_parks.cell_id)
            AND     cbs.low_stress
        )
WHERE   EXISTS (
            SELECT  1
            FROM    received.sa_boundary as b
            WHERE   ST_Intersects(destinations.sa_parks.geom_pt,b.geometry)
        );

UPDATE  destinations.sa_parks
SET     pop_score = CASE    WHEN pop_high_stress IS NULL THEN NULL
                            WHEN pop_high_stress = 0 THEN 0
                            ELSE pop_low_stress::FLOAT / pop_high_stress
                            END;
							
-----------------------------------------------------------------------------------------------------------------------
-- pharmacies
-----------------------------------------------------------------------------------------------------------------------
-- set block-based raw numbers
UPDATE  generated.sa_pop_grid
SET     pharmacies_low_stress = (
            SELECT  COUNT(id)
            FROM    destinations.sa_pharmacies
            WHERE   EXISTS (
                        SELECT  1
                        FROM    generated.sa_connected_pop_grid
                        WHERE   generated.sa_connected_pop_grid.source_cellid = generated.sa_pop_grid.cell_id
                        AND     generated.sa_connected_pop_grid.target_cellid = ANY(destinations.sa_pharmacies.cell_id)
                        AND     generated.sa_connected_pop_grid.low_stress
                    )
        ),
        pharmacies_high_stress = (
            SELECT  COUNT(id)
            FROM    destinations.sa_pharmacies
            WHERE   EXISTS (
                        SELECT  1
                        FROM    generated.sa_connected_pop_grid
                        WHERE   generated.sa_connected_pop_grid.source_cellid = generated.sa_pop_grid.cell_id
                        AND     generated.sa_connected_pop_grid.target_cellid = ANY(destinations.sa_pharmacies.cell_id)
                    )
        )
WHERE   EXISTS (
            SELECT  1
            FROM    received.sa_boundary AS b
            WHERE   ST_Intersects(generated.sa_pop_grid.geometry,b.geometry)
        );

-- set block-based score
UPDATE  generated.sa_pop_grid
SET     pharmacies_score =  CASE
                            WHEN pharmacies_high_stress IS NULL THEN NULL
                            WHEN pharmacies_high_stress = 0 THEN NULL
                            WHEN pharmacies_low_stress = 0 THEN 0
                            WHEN pharmacies_high_stress = pharmacies_low_stress THEN ?max_score
                            WHEN ?Bfirst = 0 THEN pharmacies_low_stress::FLOAT / pharmacies_high_stress
                            WHEN ?Bsecond = 0
                                THEN    ?Bfirst
                                        + ((?max_score - ?Bfirst) * (pharmacies_low_stress::FLOAT - 1))
                                        / (pharmacies_high_stress - 1)
                            WHEN ?Bthird = 0
                                THEN    CASE
                                        WHEN pharmacies_low_stress = 1 THEN ?Bfirst
                                        WHEN pharmacies_low_stress = 2 THEN ?Bfirst + ?Bsecond
                                        ELSE ?Bfirst + ?Bsecond
                                                + ((?max_score - ?Bfirst - ?Bsecond) * (pharmacies_low_stress::FLOAT - 2))
                                                / (pharmacies_high_stress - 2)
                                        END
                            ELSE        CASE
                                        WHEN pharmacies_low_stress = 1 THEN ?Bfirst
                                        WHEN pharmacies_low_stress = 2 THEN ?Bfirst + ?Bsecond
                                        WHEN pharmacies_low_stress = 3 THEN ?Bfirst + ?Bsecond + ?Bthird
                                        ELSE ?Bfirst + ?Bsecond + ?Bthird
                                                + ((?max_score - ?Bfirst - ?Bsecond - ?Bthird) * (pharmacies_low_stress::FLOAT - 3))
                                                / (pharmacies_high_stress - 3)
                                        END
                            END;

-- set population shed for each pharmacies destination in the neighborhood
UPDATE  destinations.sa_pharmacies
SET     dest_type = 'pharmacy';

UPDATE  destinations.sa_pharmacies
SET     pop_high_stress = (
            SELECT  SUM(cb.population)
            FROM    generated.sa_pop_grid cb,
                    generated.sa_connected_pop_grid cbs
            WHERE   cbs.source_cellid = cb.cell_id
            AND     cbs.target_cellid = ANY(destinations.sa_pharmacies.cell_id)
        ),
        pop_low_stress = (
            SELECT  SUM(cb.population)
            FROM    generated.sa_pop_grid cb,
                    generated.sa_connected_pop_grid cbs
            WHERE   cbs.source_cellid = cb.cell_id
            AND     cbs.target_cellid = ANY(destinations.sa_pharmacies.cell_id)
            AND     cbs.low_stress
        )
WHERE   EXISTS (
            SELECT  1
            FROM    received.sa_boundary as b
            WHERE   ST_Intersects(destinations.sa_pharmacies.geom_pt,b.geometry)
        );

UPDATE  destinations.sa_pharmacies
SET     pop_score = CASE    WHEN pop_high_stress IS NULL THEN NULL
                            WHEN pop_high_stress = 0 THEN 0
                            ELSE pop_low_stress::FLOAT / pop_high_stress
                            END;
							

-----------------------------------------------------------------------------------------------------------------------
-- retail
-----------------------------------------------------------------------------------------------------------------------
-- set block-based raw numbers
UPDATE  generated.sa_pop_grid
SET     retail_low_stress = (
            SELECT  COUNT(id)
            FROM    destinations.sa_retail
            WHERE   EXISTS (
                        SELECT  1
                        FROM    generated.sa_connected_pop_grid
                        WHERE   generated.sa_connected_pop_grid.source_cellid = generated.sa_pop_grid.cell_id
                        AND     generated.sa_connected_pop_grid.target_cellid = ANY(destinations.sa_retail.cell_id)
                        AND     generated.sa_connected_pop_grid.low_stress
                    )
        ),
        retail_high_stress = (
            SELECT  COUNT(id)
            FROM    destinations.sa_retail
            WHERE   EXISTS (
                        SELECT  1
                        FROM    generated.sa_connected_pop_grid
                        WHERE   generated.sa_connected_pop_grid.source_cellid = generated.sa_pop_grid.cell_id
                        AND     generated.sa_connected_pop_grid.target_cellid = ANY(destinations.sa_retail.cell_id)
                    )
        )
WHERE   EXISTS (
            SELECT  1
            FROM    received.sa_boundary AS b
            WHERE   ST_Intersects(generated.sa_pop_grid.geometry,b.geometry)
        );

-- set block-based score
UPDATE  generated.sa_pop_grid
SET     retail_score =  CASE
                        WHEN retail_high_stress IS NULL THEN NULL
                        WHEN retail_high_stress = 0 THEN NULL
                        WHEN retail_low_stress = 0 THEN 0
                        WHEN retail_high_stress = retail_low_stress THEN ?max_score
                        WHEN ?Bfirst = 0 THEN retail_low_stress::FLOAT / retail_high_stress
                        WHEN ?Bsecond = 0
                            THEN    ?Bfirst
                                    + ((?max_score - ?Bfirst) * (retail_low_stress::FLOAT - 1))
                                    / (retail_high_stress - 1)
                        WHEN ?Bthird = 0
                            THEN    CASE
                                    WHEN retail_low_stress = 1 THEN ?Bfirst
                                    WHEN retail_low_stress = 2 THEN ?Bfirst + ?Bsecond
                                    ELSE ?Bfirst + ?Bsecond
                                            + ((?max_score - ?Bfirst - ?Bsecond) * (retail_low_stress::FLOAT - 2))
                                            / (retail_high_stress - 2)
                                    END
                        ELSE        CASE
                                    WHEN retail_low_stress = 1 THEN ?Bfirst
                                    WHEN retail_low_stress = 2 THEN ?Bfirst + ?Bsecond
                                    WHEN retail_low_stress = 3 THEN ?Bfirst + ?Bsecond + ?Bthird
                                    ELSE ?Bfirst + ?Bsecond + ?Bthird
                                            + ((?max_score - ?Bfirst - ?Bsecond - ?Bthird) * (retail_low_stress::FLOAT - 3))
                                            / (retail_high_stress - 3)
                                    END
                        END;

-- set population shed for each retail destination in the neighborhood
UPDATE  destinations.sa_retail
SET     dest_type = 'retail';

UPDATE  destinations.sa_retail
SET     pop_high_stress = (
            SELECT  SUM(cb.population)
            FROM    generated.sa_pop_grid cb,
                    generated.sa_connected_pop_grid cbs
            WHERE   cbs.source_cellid = cb.cell_id
            AND     cbs.target_cellid = ANY(destinations.sa_retail.cell_id)
        ),
        pop_low_stress = (
            SELECT  SUM(cb.population)
            FROM    generated.sa_pop_grid cb,
                    generated.sa_connected_pop_grid cbs
            WHERE   cbs.source_cellid = cb.cell_id
            AND     cbs.target_cellid = ANY(destinations.sa_retail.cell_id)
            AND     cbs.low_stress
        )
WHERE   EXISTS (
            SELECT  1
            FROM    received.sa_boundary as b
            WHERE   ST_Intersects(destinations.sa_retail.geom_poly,b.geometry)
        );

UPDATE  destinations.sa_retail
SET     pop_score = CASE    WHEN pop_high_stress IS NULL THEN NULL
                            WHEN pop_high_stress = 0 THEN 0
                            ELSE pop_low_stress::FLOAT / pop_high_stress
                            END;
SELECT * FROM generated.sa_pop_grid;

-----------------------------------------------------------------------------------------------------------------------
-- schools
-----------------------------------------------------------------------------------------------------------------------	
-- set block-based raw numbers
UPDATE  generated.sa_pop_grid
SET     schools_low_stress = (
            SELECT  COUNT(id)
            FROM    destinations.sa_schools
            WHERE   EXISTS (
                        SELECT  1
                        FROM    generated.sa_connected_pop_grid
                        WHERE   generated.sa_connected_pop_grid.source_cellid = generated.sa_pop_grid.cell_id
                        AND     generated.sa_connected_pop_grid.target_cellid = ANY(destinations.sa_schools.cell_id)
                        AND     generated.sa_connected_pop_grid.low_stress
                    )
        ),
        schools_high_stress = (
            SELECT  COUNT(id)
            FROM    destinations.sa_schools
            WHERE   EXISTS (
                        SELECT  1
                        FROM    generated.sa_connected_pop_grid
                        WHERE   generated.sa_connected_pop_grid.source_cellid = generated.sa_pop_grid.cell_id
                        AND     generated.sa_connected_pop_grid.target_cellid = ANY(destinations.sa_schools.cell_id)
                    )
        )
WHERE   EXISTS (
            SELECT  1
            FROM    received.sa_boundary AS b
            WHERE   ST_Intersects(generated.sa_pop_grid.geometry,b.geometry)
        );

-- set block-based score
UPDATE  generated.sa_pop_grid
SET     schools_score = CASE
                        WHEN schools_high_stress IS NULL THEN NULL
                        WHEN schools_high_stress = 0 THEN NULL
                        WHEN schools_low_stress = 0 THEN 0
                        WHEN schools_high_stress = schools_low_stress THEN ?max_score
                        WHEN ?Cfirst = 0 THEN schools_low_stress::FLOAT / schools_high_stress
                        WHEN ?Csecond = 0
                            THEN    ?Cfirst
                                    + ((?max_score - ?Cfirst) * (schools_low_stress::FLOAT - 1))
                                    / (schools_high_stress - 1)
                        WHEN ?Cthird = 0
                            THEN    CASE
                                    WHEN schools_low_stress = 1 THEN ?Cfirst
                                    WHEN schools_low_stress = 2 THEN ?Cfirst + ?Csecond
                                    ELSE ?Cfirst + ?Csecond
                                            + ((?max_score - ?Cfirst - ?Csecond) * (schools_low_stress::FLOAT - 2))
                                            / (schools_high_stress - 2)
                                    END
                        ELSE        CASE
                                    WHEN schools_low_stress = 1 THEN ?Cfirst
                                    WHEN schools_low_stress = 2 THEN ?Cfirst + ?Csecond
                                    WHEN schools_low_stress = 3 THEN ?Cfirst + ?Csecond + ?Cthird
                                    ELSE ?Cfirst + ?Csecond + ?Cthird
                                            + ((?max_score - ?Cfirst - ?Csecond - ?Cthird) * (schools_low_stress::FLOAT - 3))
                                            / (schools_high_stress - 3)
                                    END
                        END;

-- set population shed for each school in the neighborhood
UPDATE  destinations.sa_schools
SET     dest_type = 'school';

UPDATE  destinations.sa_schools
SET     pop_high_stress = (
            SELECT  SUM(cb.population)
            FROM    generated.sa_pop_grid cb,
                    generated.sa_connected_pop_grid cbs
            WHERE   cbs.source_cellid = cb.cell_id
            AND     cbs.target_cellid = ANY(destinations.sa_schools.cell_id)
        ),
        pop_low_stress = (
            SELECT  SUM(cb.population)
            FROM    generated.sa_pop_grid cb,
                    generated.sa_connected_pop_grid cbs
            WHERE   cbs.source_cellid = cb.cell_id
            AND     cbs.target_cellid = ANY(destinations.sa_schools.cell_id)
            AND     cbs.low_stress
        )
WHERE   EXISTS (
            SELECT  1
            FROM    received.sa_boundary as b
            WHERE   ST_Intersects(destinations.sa_schools.geom_pt,b.geometry)
        );

UPDATE  destinations.sa_schools
SET     pop_score = CASE    WHEN pop_high_stress IS NULL THEN NULL
                            WHEN pop_high_stress = 0 THEN 0
                            ELSE pop_low_stress::FLOAT / pop_high_stress
                            END;
							
							
-----------------------------------------------------------------------------------------------------------------------
-- social services
-----------------------------------------------------------------------------------------------------------------------
-- set block-based raw numbers
UPDATE  generated.sa_pop_grid
SET     social_services_low_stress = (
            SELECT  COUNT(id)
            FROM    destinations.sa_social_services
            WHERE   EXISTS (
                        SELECT  1
                        FROM    generated.sa_connected_pop_grid
                        WHERE   generated.sa_connected_pop_grid.source_cellid = generated.sa_pop_grid.cell_id
                        AND     generated.sa_connected_pop_grid.target_cellid = ANY(destinations.sa_social_services.cell_id)
                        AND     generated.sa_connected_pop_grid.low_stress
                    )
        ),
        social_services_high_stress = (
            SELECT  COUNT(id)
            FROM    destinations.sa_social_services
            WHERE   EXISTS (
                        SELECT  1
                        FROM    generated.sa_connected_pop_grid
                        WHERE   generated.sa_connected_pop_grid.source_cellid = generated.sa_pop_grid.cell_id
                        AND     generated.sa_connected_pop_grid.target_cellid = ANY(destinations.sa_social_services.cell_id)
                    )
        )
WHERE   EXISTS (
            SELECT  1
            FROM    received.sa_boundary AS b
            WHERE   ST_Intersects(generated.sa_pop_grid.geometry,b.geometry)
        );

-- set block-based score
UPDATE  generated.sa_pop_grid
SET     social_services_score = CASE
                                WHEN social_services_high_stress IS NULL THEN NULL
                                WHEN social_services_high_stress = 0 THEN NULL
                                WHEN social_services_low_stress = 0 THEN 0
                                WHEN social_services_high_stress = social_services_low_stress THEN ?max_score
                                WHEN ?Afirst = 0 THEN social_services_low_stress::FLOAT / social_services_high_stress
                                WHEN ?Asecond = 0
                                    THEN    ?Afirst
                                            + ((?max_score - ?Afirst) * (social_services_low_stress::FLOAT - 1))
                                            / (social_services_high_stress - 1)
                                WHEN ?Athird = 0
                                    THEN    CASE
                                            WHEN social_services_low_stress = 1 THEN ?Afirst
                                            WHEN social_services_low_stress = 2 THEN ?Afirst + ?Asecond
                                            ELSE ?Afirst + ?Asecond
                                                    + ((?max_score - ?Afirst - ?Asecond) * (social_services_low_stress::FLOAT - 2))
                                                    / (social_services_high_stress - 2)
                                            END
                                ELSE        CASE
                                            WHEN social_services_low_stress = 1 THEN ?Afirst
                                            WHEN social_services_low_stress = 2 THEN ?Afirst + ?Asecond
                                            WHEN social_services_low_stress = 3 THEN ?Afirst + ?Asecond + ?Athird
                                            ELSE ?Afirst + ?Asecond + ?Athird
                                                    + ((?max_score - ?Afirst - ?Asecond - ?Athird) * (social_services_low_stress::FLOAT - 3))
                                                    / (social_services_high_stress - 3)
                                            END
                                END;

-- set population shed for each social service destination in the neighborhood
UPDATE  destinations.sa_social_services
SET     dest_type = 'social_services';

UPDATE  destinations.sa_social_services
SET     pop_high_stress = (
            SELECT  SUM(cb.population)
            FROM    generated.sa_pop_grid cb,
                    generated.sa_connected_pop_grid cbs
            WHERE   cbs.source_cellid = cb.cell_id
            AND     cbs.target_cellid = ANY(destinations.sa_social_services.cell_id)
        ),
        pop_low_stress = (
            SELECT  SUM(cb.population)
            FROM    generated.sa_pop_grid cb,
                    generated.sa_connected_pop_grid cbs
            WHERE   cbs.source_cellid = cb.cell_id
            AND     cbs.target_cellid = ANY(destinations.sa_social_services.cell_id)
            AND     cbs.low_stress
        )
WHERE   EXISTS (
            SELECT  1
            FROM    received.sa_boundary as b
            WHERE   ST_Intersects(destinations.sa_social_services.geom_pt,b.geometry)
        );

UPDATE  destinations.sa_social_services
SET     pop_score = CASE    WHEN pop_high_stress IS NULL THEN NULL
                            WHEN pop_high_stress = 0 THEN 0
                            ELSE pop_low_stress::FLOAT / pop_high_stress
                            END;
							
-----------------------------------------------------------------------------------------------------------------------
-- supermarkets
-----------------------------------------------------------------------------------------------------------------------
-- set block-based raw numbers
UPDATE  generated.sa_pop_grid
SET     supermarkets_low_stress = (
            SELECT  COUNT(id)
            FROM    destinations.sa_supermarkets
            WHERE   EXISTS (
                        SELECT  1
                        FROM    generated.sa_connected_pop_grid
                        WHERE   generated.sa_connected_pop_grid.source_cellid = generated.sa_pop_grid.cell_id
                        AND     generated.sa_connected_pop_grid.target_cellid = ANY(destinations.sa_supermarkets.cell_id)
                        AND     generated.sa_connected_pop_grid.low_stress
                    )
        ),
        supermarkets_high_stress = (
            SELECT  COUNT(id)
            FROM    destinations.sa_supermarkets
            WHERE   EXISTS (
                        SELECT  1
                        FROM    generated.sa_connected_pop_grid
                        WHERE   generated.sa_connected_pop_grid.source_cellid = generated.sa_pop_grid.cell_id
                        AND     generated.sa_connected_pop_grid.target_cellid = ANY(destinations.sa_supermarkets.cell_id)
                    )
        )
WHERE   EXISTS (
            SELECT  1
            FROM    received.sa_boundary AS b
            WHERE   ST_Intersects(generated.sa_pop_grid.geometry,b.geometry)
        );

-- set block-based score
UPDATE  generated.sa_pop_grid
SET     supermarkets_score =    CASE
                                WHEN supermarkets_high_stress IS NULL THEN NULL
                                WHEN supermarkets_high_stress = 0 THEN NULL
                                WHEN supermarkets_low_stress = 0 THEN 0
                                WHEN supermarkets_high_stress = supermarkets_low_stress THEN ?max_score
                                WHEN ?Dfirst = 0 THEN supermarkets_low_stress::FLOAT / supermarkets_high_stress
                                WHEN ?Dsecond = 0
                                    THEN    ?Dfirst
                                            + ((?max_score - ?Dfirst) * (supermarkets_low_stress::FLOAT - 1))
                                            / (supermarkets_high_stress - 1)
                                WHEN ?Dthird = 0
                                    THEN    CASE
                                            WHEN supermarkets_low_stress = 1 THEN ?Dfirst
                                            WHEN supermarkets_low_stress = 2 THEN ?Dfirst + ?Dsecond
                                            ELSE ?Dfirst + ?Dsecond
                                                    + ((?max_score - ?Dfirst - ?Dsecond) * (supermarkets_low_stress::FLOAT - 2))
                                                    / (supermarkets_high_stress - 2)
                                            END
                                ELSE        CASE
                                            WHEN supermarkets_low_stress = 1 THEN ?Dfirst
                                            WHEN supermarkets_low_stress = 2 THEN ?Dfirst + ?Dsecond
                                            WHEN supermarkets_low_stress = 3 THEN ?Dfirst + ?Dsecond + ?Dthird
                                            ELSE ?Dfirst + ?Dsecond + ?Dthird
                                                    + ((?max_score - ?Dfirst - ?Dsecond - ?Dthird) * (supermarkets_low_stress::FLOAT - 3))
                                                    / (supermarkets_high_stress - 3)
                                            END
                                END;

-- set population shed for each supermarket in the neighborhood
UPDATE  destinations.sa_supermarkets
SET     dest_type = 'supermarket';

UPDATE  destinations.sa_supermarkets
SET     pop_high_stress = (
            SELECT  SUM(cb.population)
            FROM    generated.sa_pop_grid cb,
                    generated.sa_connected_pop_grid cbs
            WHERE   cbs.source_cellid = cb.cell_id
            AND     cbs.target_cellid = ANY(destinations.sa_supermarkets.cell_id)
        ),
        pop_low_stress = (
            SELECT  SUM(cb.population)
            FROM    generated.sa_pop_grid cb,
                    generated.sa_connected_pop_grid cbs
            WHERE   cbs.source_cellid = cb.cell_id
            AND     cbs.target_cellid = ANY(destinations.sa_supermarkets.cell_id)
            AND     cbs.low_stress
        )
WHERE   EXISTS (
            SELECT  1
            FROM    received.sa_boundary as b
            WHERE   ST_Intersects(destinations.sa_supermarkets.geom_pt,b.geometry)
        );

UPDATE  destinations.sa_supermarkets
SET     pop_score = CASE    WHEN pop_high_stress IS NULL THEN NULL
                            WHEN pop_high_stress = 0 THEN 0
                            ELSE pop_low_stress::FLOAT / pop_high_stress
                            END;
SELECT * FROM generated.sa_pop_grid;


-----------------------------------------------------------------------------------------------------------------------
-- trails
-----------------------------------------------------------------------------------------------------------------------
-- low stress access
UPDATE  generated.sa_pop_grid
SET     trails_low_stress = (
            SELECT  COUNT(path_id)
            FROM    generated.sa_paths
            WHERE   path_length > ?min_path_length
            AND     bbox_length > ?min_bbox_length
            AND     EXISTS (
                        SELECT  1
                        FROM    generated.sa_reachable_roads_low_stress ls
                        WHERE   ls.target_road = ANY(generated.sa_paths.road_ids)
                        AND     ls.base_road = ANY(generated.sa_pop_grid.road_ids)
            )
        ),
        trails_high_stress = (
            SELECT  COUNT(path_id)
            FROM    generated.sa_paths
            WHERE   path_length > ?min_path_length
            AND     bbox_length > ?min_bbox_length
            AND     EXISTS (
                        SELECT  1
                        FROM    generated.sa_reachable_roads_high_stress hs
                        WHERE   hs.target_road = ANY(generated.sa_paths.road_ids)
                        AND     hs.base_road = ANY(generated.sa_pop_grid.road_ids)
            )
        )
WHERE   EXISTS (
            SELECT  1
            FROM    received.sa_boundary AS b
            WHERE   ST_Intersects(generated.sa_pop_grid.geometry,b.geometry)
        );

-- set block-based score
UPDATE  generated.sa_pop_grid
SET     trails_score =  CASE
                        WHEN trails_high_stress IS NULL THEN NULL
                        WHEN trails_high_stress = 0 THEN NULL
                        WHEN trails_low_stress = 0 THEN 0
                        WHEN trails_high_stress = trails_low_stress THEN ?max_score
                        WHEN ?Efirst = 0 THEN trails_low_stress::FLOAT / trails_high_stress
                        WHEN ?Esecond = 0
                            THEN    ?Efirst
                                    + ((?max_score - ?Efirst) * (trails_low_stress::FLOAT - 1))
                                    / (trails_high_stress - 1)
                        WHEN ?Ethird = 0
                            THEN    CASE
                                    WHEN trails_low_stress = 1 THEN ?Efirst
                                    WHEN trails_low_stress = 2 THEN ?Efirst + ?Esecond
                                    ELSE ?Efirst + ?Esecond
                                            + ((?max_score - ?Efirst - ?Esecond) * (trails_low_stress::FLOAT - 2))
                                            / (trails_high_stress - 2)
                                    END
                        ELSE        CASE
                                    WHEN trails_low_stress = 1 THEN ?Efirst
                                    WHEN trails_low_stress = 2 THEN ?Efirst + ?Esecond
                                    WHEN trails_low_stress = 3 THEN ?Efirst + ?Esecond + ?Ethird
                                    ELSE ?Efirst + ?Esecond + ?Ethird
                                            + ((?max_score - ?Efirst - ?Esecond - ?Ethird) * (trails_low_stress::FLOAT - 3))
                                            / (trails_high_stress - 3)
                                    END
                        END;
						
						
-----------------------------------------------------------------------------------------------------------------------
-- transit
-----------------------------------------------------------------------------------------------------------------------
-- set block-based raw numbers
UPDATE  generated.sa_pop_grid
SET     transit_low_stress = (
            SELECT  COUNT(id)
            FROM    destinations.sa_transit
            WHERE   EXISTS (
                        SELECT  1
                        FROM    generated.sa_connected_pop_grid
                        WHERE   generated.sa_connected_pop_grid.source_cellid = generated.sa_pop_grid.cell_id
                        AND     generated.sa_connected_pop_grid.target_cellid = ANY(destinations.sa_transit.cell_id)
                        AND     generated.sa_connected_pop_grid.low_stress
                    )
        ),
        transit_high_stress = (
            SELECT  COUNT(id)
            FROM    destinations.sa_transit
            WHERE   EXISTS (
                        SELECT  1
                        FROM    generated.sa_connected_pop_grid
                        WHERE   generated.sa_connected_pop_grid.source_cellid = generated.sa_pop_grid.cell_id
                        AND     generated.sa_connected_pop_grid.target_cellid = ANY(destinations.sa_transit.cell_id)
                    )
        )
WHERE   EXISTS (
            SELECT  1
            FROM    received.sa_boundary AS b
            WHERE   ST_Intersects(generated.sa_pop_grid.geometry,b.geometry)
        );

-- set block-based score
UPDATE  generated.sa_pop_grid
SET     transit_score =   CASE
                        WHEN transit_high_stress IS NULL THEN NULL
                        WHEN transit_high_stress = 0 THEN NULL
                        WHEN transit_low_stress = 0 THEN 0
                        WHEN transit_high_stress = transit_low_stress THEN ?max_score
                        WHEN ?Ffirst = 0 THEN transit_low_stress::FLOAT / transit_high_stress
                        WHEN ?Fsecond = 0
                            THEN    ?Ffirst
                                    + ((?max_score - ?Ffirst) * (transit_low_stress::FLOAT - 1))
                                    / (transit_high_stress - 1)
                        WHEN ?Fthird = 0
                            THEN    CASE
                                    WHEN transit_low_stress = 1 THEN ?Ffirst
                                    WHEN transit_low_stress = 2 THEN ?Ffirst + ?Fsecond
                                    ELSE ?Ffirst + ?Fsecond
                                            + ((?max_score - ?Ffirst - ?Fsecond) * (transit_low_stress::FLOAT - 2))
                                            / (transit_high_stress - 2)
                                    END
                        ELSE        CASE
                                    WHEN transit_low_stress = 1 THEN ?Ffirst
                                    WHEN transit_low_stress = 2 THEN ?Ffirst + ?Fsecond
                                    WHEN transit_low_stress = 3 THEN ?Ffirst + ?Fsecond + ?Fthird
                                    ELSE ?Ffirst + ?Fsecond + ?Fthird
                                            + ((?max_score - ?Ffirst - ?Fsecond - ?Fthird) * (transit_low_stress::FLOAT - 3))
                                            / (transit_high_stress - 3)
                                    END
                        END;

-- set population shed for each park in the neighborhood
UPDATE  destinations.sa_transit
SET     dest_type = 'transit';

UPDATE  destinations.sa_transit
SET     pop_high_stress = (
            SELECT  SUM(cb.population)
            FROM    generated.sa_pop_grid cb,
                    generated.sa_connected_pop_grid cbs
            WHERE   cbs.source_cellid = cb.cell_id
            AND     cbs.target_cellid = ANY(destinations.sa_transit.cell_id)
        ),
        pop_low_stress = (
            SELECT  SUM(cb.population)
            FROM    generated.sa_pop_grid cb,
                    generated.sa_connected_pop_grid cbs
            WHERE   cbs.source_cellid = cb.cell_id
            AND     cbs.target_cellid = ANY(destinations.sa_transit.cell_id)
            AND     cbs.low_stress
        )
WHERE   EXISTS (
            SELECT  1
            FROM    received.sa_boundary as b
            WHERE   ST_Intersects(destinations.sa_transit.geom_pt,b.geometry)
        );

UPDATE  destinations.sa_transit
SET     pop_score = CASE    WHEN pop_high_stress IS NULL THEN NULL
                            WHEN pop_high_stress = 0 THEN 0
                            ELSE pop_low_stress::FLOAT / pop_high_stress
                            END;

-----------------------------------------------------------------------------------------------------------------------
-- universities
-----------------------------------------------------------------------------------------------------------------------	
-- set block-based raw numbers
UPDATE  generated.sa_pop_grid
SET     universities_low_stress = (
            SELECT  COUNT(id)
            FROM    destinations.sa_universities
            WHERE   EXISTS (
                        SELECT  1
                        FROM    generated.sa_connected_pop_grid
                        WHERE   generated.sa_connected_pop_grid.source_cellid = generated.sa_pop_grid.cell_id
                        AND     generated.sa_connected_pop_grid.target_cellid = ANY(destinations.sa_universities.cell_id)
                        AND     generated.sa_connected_pop_grid.low_stress
                    )
        ),
        universities_high_stress = (
            SELECT  COUNT(id)
            FROM    destinations.sa_universities
            WHERE   EXISTS (
                        SELECT  1
                        FROM    generated.sa_connected_pop_grid
                        WHERE   generated.sa_connected_pop_grid.source_cellid = generated.sa_pop_grid.cell_id
                        AND     generated.sa_connected_pop_grid.target_cellid = ANY(destinations.sa_universities.cell_id)
                    )
        )
WHERE   EXISTS (
            SELECT  1
            FROM    received.sa_boundary AS b
            WHERE   ST_Intersects(generated.sa_pop_grid.geometry,b.geometry)
        );

-- set block-based score
UPDATE  generated.sa_pop_grid
SET     universities_score =    CASE
                                WHEN universities_high_stress IS NULL THEN NULL
                                WHEN universities_high_stress = 0 THEN NULL
                                WHEN universities_low_stress = 0 THEN 0
                                WHEN universities_high_stress = universities_low_stress THEN ?max_score
                                WHEN ?Afirst = 0 THEN universities_low_stress::FLOAT / universities_high_stress
                                WHEN ?Asecond = 0
                                    THEN    ?Afirst
                                            + ((?max_score - ?Afirst) * (universities_low_stress::FLOAT - 1))
                                            / (universities_high_stress - 1)
                                WHEN ?Athird = 0
                                    THEN    CASE
                                            WHEN universities_low_stress = 1 THEN ?Afirst
                                            WHEN universities_low_stress = 2 THEN ?Afirst + ?Asecond
                                            ELSE ?Afirst + ?Asecond
                                                    + ((?max_score - ?Afirst - ?Asecond) * (universities_low_stress::FLOAT - 2))
                                                    / (universities_high_stress - 2)
                                            END
                                ELSE        CASE
                                            WHEN universities_low_stress = 1 THEN ?Afirst
                                            WHEN universities_low_stress = 2 THEN ?Afirst + ?Asecond
                                            WHEN universities_low_stress = 3 THEN ?Afirst + ?Asecond + ?Athird
                                            ELSE ?Afirst + ?Asecond + ?Athird
                                                    + ((?max_score - ?Afirst - ?Asecond - ?Athird) * (universities_low_stress::FLOAT - 3))
                                                    / (universities_high_stress - 3)
                                            END
                                END;

-- set population shed for each university in the neighborhood
UPDATE  destinations.sa_universities
SET     dest_type = 'university';

UPDATE  destinations.sa_universities
SET     pop_high_stress = (
            SELECT  SUM(cb.population)
            FROM    generated.sa_pop_grid cb,
                    generated.sa_connected_pop_grid cbs
            WHERE   cbs.source_cellid = cb.cell_id
            AND     cbs.target_cellid = ANY(destinations.sa_universities.cell_id)
        ),
        pop_low_stress = (
            SELECT  SUM(cb.population)
            FROM    generated.sa_pop_grid cb,
                    generated.sa_connected_pop_grid cbs
            WHERE   cbs.source_cellid = cb.cell_id
            AND     cbs.target_cellid = ANY(destinations.sa_universities.cell_id)
            AND     cbs.low_stress
        )
WHERE   EXISTS (
            SELECT  1
            FROM    received.sa_boundary as b
            WHERE   ST_Intersects(destinations.sa_universities.geom_pt,b.geometry)
        );

UPDATE  destinations.sa_universities
SET     pop_score = CASE    WHEN pop_high_stress IS NULL THEN NULL
                            WHEN pop_high_stress = 0 THEN 0
                            ELSE pop_low_stress::FLOAT / pop_high_stress
                            END;