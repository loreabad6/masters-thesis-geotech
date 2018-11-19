--- job access

UPDATE  generated.sa_pop_grid
SET     emp_low_stress = (
            SELECT  SUM(blocks2.jobs)
            FROM    generated.sa_pop_grid blocks2
            WHERE   EXISTS (
                        SELECT  1
                        FROM    generated.sa_connected_pop_grid cb
                        WHERE   cb.source_cellid = generated.sa_pop_grid.cell_id
                        AND     cb.target_cellid = blocks2.cell_id
                        AND     cb.low_stress
            )
        ),
        emp_high_stress = (
            SELECT  SUM(blocks2.jobs)
            FROM    generated.sa_pop_grid blocks2
            WHERE   EXISTS (
                        SELECT  1
                        FROM    generated.sa_connected_pop_grid cb
                        WHERE   cb.source_cellid = generated.sa_pop_grid.cell_id
                        AND     cb.target_cellid = blocks2.cell_id
            )
        )
WHERE   EXISTS (
            SELECT  1
            FROM    received.sa_boundary AS b
            WHERE   ST_Intersects(generated.sa_pop_grid.geometry,b.geometry)
        );

-- set score
UPDATE  generated.sa_pop_grid
SET     emp_score = CASE
                    WHEN emp_high_stress IS NULL THEN NULL
                    WHEN emp_high_stress = 0 THEN NULL
                    WHEN emp_low_stress = 0 THEN 0
                    WHEN emp_high_stress = emp_low_stress THEN ?max_score
                    WHEN ?step1 = 0 THEN ?max_score * emp_low_stress::FLOAT / emp_high_stress
                    WHEN emp_low_stress::FLOAT / emp_high_stress = ?step3 THEN ?score3
                    WHEN emp_low_stress::FLOAT / emp_high_stress = ?step2 THEN ?score2
                    WHEN emp_low_stress::FLOAT / emp_high_stress = ?step1 THEN ?score1
                    WHEN emp_low_stress::FLOAT / emp_high_stress > ?step3
                        THEN    ?score3
                                + (?max_score - ?score3)
                                * (
                                    (emp_low_stress::FLOAT / emp_high_stress - ?step3)
                                    / (1 - ?step3)
                                )
                    WHEN emp_low_stress::FLOAT / emp_high_stress > ?step2
                        THEN    ?score2
                                + (?score3 - ?score2)
                                * (
                                    (emp_low_stress::FLOAT / emp_high_stress - ?step2)
                                    / (?step3 - ?step2)
                                )
                    WHEN emp_low_stress::FLOAT / emp_high_stress > ?step1
                        THEN    ?score1
                                + (?score2 - ?score1)
                                * (
                                    (emp_low_stress::FLOAT / emp_high_stress - ?step1)
                                    / (?step2 - ?step1)
                                )
                    ELSE        ?score1
                                * (
                                    (emp_low_stress::FLOAT / emp_high_stress)
                                    / ?step1
                                )
                    END;
