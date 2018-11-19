CREATE UNIQUE INDEX IF NOT EXISTS idx_sa_rchblrdshistrss_b ON generated.sa_reachable_roads_high_stress (base_road, target_road);
CREATE INDEX IF NOT EXISTS idx_sa_rchblrdshistrss_t ON generated.sa_reachable_roads_high_stress (target_road);
