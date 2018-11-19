DROP TABLE IF EXISTS generated.sa_overall_scores;

CREATE TABLE generated.sa_overall_scores (
    id SERIAL PRIMARY KEY,
    score_id TEXT,
    score_original NUMERIC(16,4),
    score_normalized NUMERIC(16,4),
    human_explanation TEXT
);

-- population
INSERT INTO generated.sa_overall_scores (
    score_id, score_original, human_explanation
)
SELECT  'people',
        COALESCE(generated.sa_score_inputs.score,0),
        generated.sa_score_inputs.human_explanation
FROM    generated.sa_score_inputs
WHERE   use_pop;

-- employment
INSERT INTO generated.sa_overall_scores (
    score_id, score_original, human_explanation
)
SELECT  'opportunity_employment',
        COALESCE(generated.sa_score_inputs.score,0),
        generated.sa_score_inputs.human_explanation
FROM    generated.sa_score_inputs
WHERE   use_emp;

-- k12 education
INSERT INTO generated.sa_overall_scores (
    score_id, score_original, human_explanation
)
SELECT  'opportunity_k12_education',
        COALESCE(generated.sa_score_inputs.score,0),
        generated.sa_score_inputs.human_explanation
FROM    generated.sa_score_inputs
WHERE   use_k12;

-- tech school
INSERT INTO generated.sa_overall_scores (
    score_id, score_original, human_explanation
)
SELECT  'opportunity_technical_vocational_college',
        COALESCE(generated.sa_score_inputs.score,0),
        generated.sa_score_inputs.human_explanation
FROM    generated.sa_score_inputs
WHERE   use_tech;

-- higher ed
INSERT INTO generated.sa_overall_scores (
    score_id, score_original, human_explanation
)
SELECT  'opportunity_higher_education',
        COALESCE(generated.sa_score_inputs.score,0),
        generated.sa_score_inputs.human_explanation
FROM    generated.sa_score_inputs
WHERE   use_univ;

-- opportunity
INSERT INTO generated.sa_overall_scores (
    score_id, score_original, human_explanation
)
SELECT  'opportunity',
        (
            0.35 * (SELECT score_original FROM generated.sa_overall_scores WHERE score_id = 'opportunity_employment')
            + 0.35 * (SELECT score_original FROM generated.sa_overall_scores WHERE score_id = 'opportunity_k12_education')
            + 0.1 * (select score_original from generated.sa_overall_scores where score_id = 'opportunity_technical_vocational_college')
            + 0.2 * (SELECT score_original FROM generated.sa_overall_scores WHERE score_id = 'opportunity_higher_education')
        ) /
        (
            0.35
            +   CASE
                WHEN EXISTS (SELECT 1 FROM generated.sa_pop_grid WHERE schools_high_stress > 0)
                    THEN 0.35
                ELSE 0
                END
            +   CASE
                WHEN EXISTS (SELECT 1 FROM generated.sa_pop_grid WHERE colleges_high_stress > 0)
                    THEN 0.1
                ELSE 0
                END
            +   CASE
                WHEN EXISTS (SELECT 1 FROM generated.sa_pop_grid WHERE universities_high_stress > 0)
                    THEN 0.2
                ELSE 0
                END
        ),
        NULL;

-- doctors
INSERT INTO generated.sa_overall_scores (
    score_id, score_original, human_explanation
)
SELECT  'core_services_doctors',
        COALESCE(generated.sa_score_inputs.score,0),
        generated.sa_score_inputs.human_explanation
FROM    generated.sa_score_inputs
WHERE   use_doctor;

-- dentists
INSERT INTO generated.sa_overall_scores (
    score_id, score_original, human_explanation
)
SELECT  'core_services_dentists',
        COALESCE(generated.sa_score_inputs.score,0),
        generated.sa_score_inputs.human_explanation
FROM    generated.sa_score_inputs
WHERE   use_dentist;

-- hospitals
INSERT INTO generated.sa_overall_scores (
    score_id, score_original, human_explanation
)
SELECT  'core_services_hospitals',
        COALESCE(generated.sa_score_inputs.score,0),
        generated.sa_score_inputs.human_explanation
FROM    generated.sa_score_inputs
WHERE   use_hospital;

-- pharmacies
INSERT INTO generated.sa_overall_scores (
    score_id, score_original, human_explanation
)
SELECT  'core_services_pharmacies',
        COALESCE(generated.sa_score_inputs.score,0),
        generated.sa_score_inputs.human_explanation
FROM    generated.sa_score_inputs
WHERE   use_pharmacy;

-- grocery
INSERT INTO generated.sa_overall_scores (
    score_id, score_original, human_explanation
)
SELECT  'core_services_grocery',
        COALESCE(generated.sa_score_inputs.score,0),
        generated.sa_score_inputs.human_explanation
FROM    generated.sa_score_inputs
WHERE   use_grocery;

-- social services
INSERT INTO generated.sa_overall_scores (
    score_id, score_original, human_explanation
)
SELECT  'core_services_social_services',
        COALESCE(generated.sa_score_inputs.score,0),
        generated.sa_score_inputs.human_explanation
FROM    generated.sa_score_inputs
WHERE   use_social_svcs;

-- core services
INSERT INTO generated.sa_overall_scores (
    score_id, score_original, human_explanation
)
SELECT  'core_services',
        CASE
        WHEN EXISTS (
            SELECT  1
            FROM    generated.sa_pop_grid
            WHERE   doctors_high_stress > 0
            OR      dentists_high_stress > 0
            OR      hospitals_high_stress > 0
            OR      pharmacies_high_stress > 0
            OR      supermarkets_high_stress > 0
            OR      social_services_high_stress > 0
        )
            THEN    (
                        0.2 * (SELECT score_original FROM generated.sa_overall_scores WHERE score_id = 'core_services_doctors')
                        + 0.1 * (SELECT score_original FROM generated.sa_overall_scores WHERE score_id = 'core_services_dentists')
                        + 0.2 * (SELECT score_original FROM generated.sa_overall_scores WHERE score_id = 'core_services_hospitals')
                        + 0.1 * (SELECT score_original FROM generated.sa_overall_scores WHERE score_id = 'core_services_pharmacies')
                        + 0.25 * (SELECT score_original FROM generated.sa_overall_scores WHERE score_id = 'core_services_grocery')
                        + 0.15 * (SELECT score_original FROM generated.sa_overall_scores WHERE score_id = 'core_services_social_services')
                    ) /
                    (
                        CASE
                        WHEN EXISTS (SELECT 1 FROM generated.sa_pop_grid WHERE doctors_high_stress > 0)
                            THEN 0.2
                        ELSE 0
                        END
                        +   CASE
                            WHEN EXISTS (SELECT 1 FROM generated.sa_pop_grid WHERE dentists_high_stress > 0)
                                THEN 0.1
                            ELSE 0
                            END
                        +   CASE
                            WHEN EXISTS (SELECT 1 FROM generated.sa_pop_grid WHERE hospitals_high_stress > 0)
                                THEN 0.2
                            ELSE 0
                            END
                        +   CASE
                            WHEN EXISTS (SELECT 1 FROM generated.sa_pop_grid WHERE pharmacies_high_stress > 0)
                                THEN 0.1
                            ELSE 0
                            END
                        +   CASE
                            WHEN EXISTS (SELECT 1 FROM generated.sa_pop_grid WHERE supermarkets_high_stress > 0)
                                THEN 0.25
                            ELSE 0
                            END
                        +   CASE
                            WHEN EXISTS (SELECT 1 FROM generated.sa_pop_grid WHERE social_services_high_stress > 0)
                                THEN 0.15
                            ELSE 0
                            END
                    )
        ELSE NULL
        END,
        NULL;

-- retail
INSERT INTO generated.sa_overall_scores (
    score_id, score_original, human_explanation
)
SELECT  'retail',
        COALESCE(generated.sa_score_inputs.score,0),
        generated.sa_score_inputs.human_explanation
FROM    generated.sa_score_inputs
WHERE   use_retail;

-- parks
INSERT INTO generated.sa_overall_scores (
    score_id, score_original, human_explanation
)
SELECT  'recreation_parks',
        COALESCE(generated.sa_score_inputs.score,0),
        generated.sa_score_inputs.human_explanation
FROM    generated.sa_score_inputs
WHERE   use_parks;

-- trails
INSERT INTO generated.sa_overall_scores (
    score_id, score_original, human_explanation
)
SELECT  'recreation_trails',
        COALESCE(generated.sa_score_inputs.score,0),
        generated.sa_score_inputs.human_explanation
FROM    generated.sa_score_inputs
WHERE   use_trails;

-- community_centers
INSERT INTO generated.sa_overall_scores (
    score_id, score_original, human_explanation
)
SELECT  'recreation_community_centers',
        COALESCE(generated.sa_score_inputs.score,0),
        generated.sa_score_inputs.human_explanation
FROM    generated.sa_score_inputs
WHERE   use_comm_ctrs;

-- recreation
INSERT INTO generated.sa_overall_scores (
    score_id, score_original, human_explanation
)
SELECT  'recreation',
        CASE
        WHEN EXISTS (
            SELECT  1
            FROM    generated.sa_pop_grid
            WHERE   parks_high_stress > 0
            OR      trails_high_stress > 0
            OR      community_centers_high_stress > 0
        )
            THEN    (
                        0.4 * (SELECT score_original FROM generated.sa_overall_scores WHERE score_id = 'recreation_parks')
                        + 0.35 * (SELECT score_original FROM generated.sa_overall_scores WHERE score_id = 'recreation_trails')
                        + 0.25 * (SELECT score_original FROM generated.sa_overall_scores WHERE score_id = 'recreation_community_centers')
                    ) /
                    (
                        CASE
                        WHEN EXISTS (SELECT 1 FROM generated.sa_pop_grid WHERE parks_high_stress > 0)
                            THEN 0.4
                        ELSE 0
                        END
                        +   CASE
                            WHEN EXISTS (SELECT 1 FROM generated.sa_pop_grid WHERE trails_high_stress > 0)
                                THEN 0.35
                            ELSE 0
                            END
                        +   CASE
                            WHEN EXISTS (SELECT 1 FROM generated.sa_pop_grid WHERE community_centers_high_stress > 0)
                                THEN 0.25
                            ELSE 0
                            END
                    )
        ELSE NULL
        END,
        NULL;

-- transit
INSERT INTO generated.sa_overall_scores (
    score_id, score_original, human_explanation
)
SELECT  'transit',
        COALESCE(generated.sa_score_inputs.score,0),
        generated.sa_score_inputs.human_explanation
FROM    generated.sa_score_inputs
WHERE   use_transit;

-- calculate overall neighborhood score
INSERT INTO generated.sa_overall_scores (
    score_id, score_original, human_explanation
)
SELECT  'overall_score',
        (
            ?people * COALESCE((SELECT score_original FROM generated.sa_overall_scores WHERE score_id = 'people'),0)
            + ?opportunity * COALESCE((SELECT score_original FROM generated.sa_overall_scores WHERE score_id = 'opportunity'),0)
            + ?core_services * COALESCE((SELECT score_original FROM generated.sa_overall_scores WHERE score_id = 'core_services'),0)
            + ?retail * COALESCE((SELECT score_original FROM generated.sa_overall_scores WHERE score_id = 'retail'),0)
            + ?recreation * COALESCE((SELECT score_original FROM generated.sa_overall_scores WHERE score_id = 'recreation'),0)
            + ?transit * COALESCE((SELECT score_original FROM generated.sa_overall_scores WHERE score_id = 'transit'),0)
        ) /
        (
            ?people + ?opportunity
            +   CASE
                WHEN EXISTS (SELECT 1 FROM generated.sa_pop_grid WHERE doctors_high_stress > 0)
                    THEN ?core_services
                WHEN EXISTS (SELECT 1 FROM generated.sa_pop_grid WHERE dentists_high_stress > 0)
                    THEN ?core_services
                WHEN EXISTS (SELECT 1 FROM generated.sa_pop_grid WHERE hospitals_high_stress > 0)
                    THEN ?core_services
                WHEN EXISTS (SELECT 1 FROM generated.sa_pop_grid WHERE pharmacies_high_stress > 0)
                    THEN ?core_services
                WHEN EXISTS (SELECT 1 FROM generated.sa_pop_grid WHERE supermarkets_high_stress > 0)
                    THEN ?core_services
                WHEN EXISTS (SELECT 1 FROM generated.sa_pop_grid WHERE social_services_high_stress > 0)
                    THEN ?core_services
                ELSE 0
                END
            +   CASE
                WHEN EXISTS (SELECT 1 FROM generated.sa_pop_grid WHERE retail_high_stress > 0)
                    THEN ?retail
                ELSE 0
                END
            +   CASE
                WHEN EXISTS (SELECT 1 FROM generated.sa_pop_grid WHERE parks_high_stress > 0)
                    THEN ?recreation
                WHEN EXISTS (SELECT 1 FROM generated.sa_pop_grid WHERE trails_high_stress > 0)
                    THEN ?recreation
                WHEN EXISTS (SELECT 1 FROM generated.sa_pop_grid WHERE community_centers_high_stress > 0)
                    THEN ?recreation
                ELSE 0
                END
            +   CASE
                WHEN EXISTS (SELECT 1 FROM generated.sa_pop_grid WHERE transit_high_stress > 0)
                    THEN ?transit
                ELSE 0
                END
        ),
        NULL;

-- normalize
UPDATE  generated.sa_overall_scores
SET     score_normalized = score_original * ?total;

-- population
INSERT INTO generated.sa_overall_scores (
    score_id, score_original, human_explanation
)
SELECT  'population_total',
        (
            SELECT SUM(population) FROM generated.sa_pop_grid
            WHERE   EXISTS (
                        SELECT  1
                        FROM    received.sa_boundary AS b
                        WHERE   ST_Intersects(b.geometry,generated.sa_pop_grid.geometry)
                    )
        ),
        'Total population of boundary';


-- high and low stress total mileage
INSERT INTO generated.sa_overall_scores (
    score_id, score_original, human_explanation
)
SELECT 'total_km_low_stress',
    (
        SELECT
            (
                SUM(ST_Length(ST_Intersection(w.geom, b.geometry)) *
                    CASE ft_seg_stress WHEN 1 THEN 1 ELSE 0 END) +
                SUM(ST_Length(ST_Intersection(w.geom, b.geometry)) *
                    CASE tf_seg_stress WHEN 1 THEN 1 ELSE 0 END)
            ) / 1000 as dist
        FROM received.sa_ways as w, received.sa_boundary as b
        WHERE ST_Intersects(w.geom, b.geometry)
    ),
    'Total low-stress km';

INSERT INTO generated.sa_overall_scores (
    score_id, score_original, human_explanation
)
SELECT 'total_km_high_stress',
    (
        SELECT
            (
                SUM(ST_Length(ST_Intersection(w.geom, b.geometry)) *
                    CASE ft_seg_stress WHEN 3 THEN 1 ELSE 0 END) +
                SUM(ST_Length(ST_Intersection(w.geom, b.geometry)) *
                    CASE tf_seg_stress WHEN 3 THEN 1 ELSE 0 END)
            ) / 1000 as dist
        FROM received.sa_ways as w, received.sa_boundary as b
        WHERE ST_Intersects(w.geom, b.geometry)
    ),
    'Total high-stress km';

UPDATE generated.sa_overall_scores
SET    score_normalized = ROUND(score_original, 1)
WHERE  score_id in ('total_km_low_stress', 'total_km_high_stress');