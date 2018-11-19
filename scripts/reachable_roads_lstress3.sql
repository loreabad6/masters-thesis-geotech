CREATE INDEX IF NOT EXISTS idx_sa_rchblrdslowstrss_b ON generated.sa_reachable_roads_low_stress (base_road);
CREATE INDEX IF NOT EXISTS idx_sa_rchblrdslowstrss_t ON generated.sa_reachable_roads_low_stress (target_road);
