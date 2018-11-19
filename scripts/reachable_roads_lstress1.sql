DROP TABLE IF EXISTS generated.sa_reachable_roads_low_stress;

CREATE TABLE generated.sa_reachable_roads_low_stress (
    id SERIAL PRIMARY KEY,
    base_road INT,
    target_road INT,
    total_cost FLOAT
);