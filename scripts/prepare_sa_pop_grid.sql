ALTER TABLE generated.sa_pop_grid DROP COLUMN IF EXISTS road_ids;
ALTER TABLE generated.sa_pop_grid DROP COLUMN IF EXISTS pop_low_stress;
ALTER TABLE generated.sa_pop_grid DROP COLUMN IF EXISTS pop_high_stress;
ALTER TABLE generated.sa_pop_grid DROP COLUMN IF EXISTS pop_score;
ALTER TABLE generated.sa_pop_grid DROP COLUMN IF EXISTS emp_low_stress;
ALTER TABLE generated.sa_pop_grid DROP COLUMN IF EXISTS emp_high_stress;
ALTER TABLE generated.sa_pop_grid DROP COLUMN IF EXISTS emp_score;
ALTER TABLE generated.sa_pop_grid DROP COLUMN IF EXISTS schools_low_stress;
ALTER TABLE generated.sa_pop_grid DROP COLUMN IF EXISTS schools_high_stress;
ALTER TABLE generated.sa_pop_grid DROP COLUMN IF EXISTS schools_score;
ALTER TABLE generated.sa_pop_grid DROP COLUMN IF EXISTS universities_low_stress;
ALTER TABLE generated.sa_pop_grid DROP COLUMN IF EXISTS universities_high_stress;
ALTER TABLE generated.sa_pop_grid DROP COLUMN IF EXISTS universities_score;
ALTER TABLE generated.sa_pop_grid DROP COLUMN IF EXISTS colleges_low_stress;
ALTER TABLE generated.sa_pop_grid DROP COLUMN IF EXISTS colleges_high_stress;
ALTER TABLE generated.sa_pop_grid DROP COLUMN IF EXISTS colleges_score;
ALTER TABLE generated.sa_pop_grid DROP COLUMN IF EXISTS doctors_low_stress;
ALTER TABLE generated.sa_pop_grid DROP COLUMN IF EXISTS doctors_high_stress;
ALTER TABLE generated.sa_pop_grid DROP COLUMN IF EXISTS doctors_score;
ALTER TABLE generated.sa_pop_grid DROP COLUMN IF EXISTS dentists_low_stress;
ALTER TABLE generated.sa_pop_grid DROP COLUMN IF EXISTS dentists_high_stress;
ALTER TABLE generated.sa_pop_grid DROP COLUMN IF EXISTS dentists_score;
ALTER TABLE generated.sa_pop_grid DROP COLUMN IF EXISTS hospitals_low_stress;
ALTER TABLE generated.sa_pop_grid DROP COLUMN IF EXISTS hospitals_high_stress;
ALTER TABLE generated.sa_pop_grid DROP COLUMN IF EXISTS hospitals_score;
ALTER TABLE generated.sa_pop_grid DROP COLUMN IF EXISTS pharmacies_low_stress;
ALTER TABLE generated.sa_pop_grid DROP COLUMN IF EXISTS pharmacies_high_stress;
ALTER TABLE generated.sa_pop_grid DROP COLUMN IF EXISTS pharmacies_score;
ALTER TABLE generated.sa_pop_grid DROP COLUMN IF EXISTS retail_low_stress;
ALTER TABLE generated.sa_pop_grid DROP COLUMN IF EXISTS retail_high_stress;
ALTER TABLE generated.sa_pop_grid DROP COLUMN IF EXISTS retail_score;
ALTER TABLE generated.sa_pop_grid DROP COLUMN IF EXISTS supermarkets_low_stress;
ALTER TABLE generated.sa_pop_grid DROP COLUMN IF EXISTS supermarkets_high_stress;
ALTER TABLE generated.sa_pop_grid DROP COLUMN IF EXISTS supermarkets_score;
ALTER TABLE generated.sa_pop_grid DROP COLUMN IF EXISTS social_services_low_stress;
ALTER TABLE generated.sa_pop_grid DROP COLUMN IF EXISTS social_services_high_stress;
ALTER TABLE generated.sa_pop_grid DROP COLUMN IF EXISTS social_services_score;
ALTER TABLE generated.sa_pop_grid DROP COLUMN IF EXISTS parks_low_stress;
ALTER TABLE generated.sa_pop_grid DROP COLUMN IF EXISTS parks_high_stress;
ALTER TABLE generated.sa_pop_grid DROP COLUMN IF EXISTS parks_score;
ALTER TABLE generated.sa_pop_grid DROP COLUMN IF EXISTS trails_low_stress;
ALTER TABLE generated.sa_pop_grid DROP COLUMN IF EXISTS trails_high_stress;
ALTER TABLE generated.sa_pop_grid DROP COLUMN IF EXISTS trails_score;
ALTER TABLE generated.sa_pop_grid DROP COLUMN IF EXISTS community_centers_low_stress;
ALTER TABLE generated.sa_pop_grid DROP COLUMN IF EXISTS community_centers_high_stress;
ALTER TABLE generated.sa_pop_grid DROP COLUMN IF EXISTS community_centers_score;
ALTER TABLE generated.sa_pop_grid DROP COLUMN IF EXISTS transit_low_stress;
ALTER TABLE generated.sa_pop_grid DROP COLUMN IF EXISTS transit_high_stress;
ALTER TABLE generated.sa_pop_grid DROP COLUMN IF EXISTS transit_score;
ALTER TABLE generated.sa_pop_grid DROP COLUMN IF EXISTS overall_score;

ALTER TABLE generated.sa_pop_grid ADD COLUMN road_ids INTEGER[];
ALTER TABLE generated.sa_pop_grid ADD COLUMN pop_low_stress INT;
ALTER TABLE generated.sa_pop_grid ADD COLUMN pop_high_stress INT;
ALTER TABLE generated.sa_pop_grid ADD COLUMN pop_score FLOAT;
ALTER TABLE generated.sa_pop_grid ADD COLUMN emp_low_stress INT;
ALTER TABLE generated.sa_pop_grid ADD COLUMN emp_high_stress INT;
ALTER TABLE generated.sa_pop_grid ADD COLUMN emp_score FLOAT;
ALTER TABLE generated.sa_pop_grid ADD COLUMN schools_low_stress INT;
ALTER TABLE generated.sa_pop_grid ADD COLUMN schools_high_stress INT;
ALTER TABLE generated.sa_pop_grid ADD COLUMN schools_score FLOAT;
ALTER TABLE generated.sa_pop_grid ADD COLUMN universities_low_stress INT;
ALTER TABLE generated.sa_pop_grid ADD COLUMN universities_high_stress INT;
ALTER TABLE generated.sa_pop_grid ADD COLUMN universities_score FLOAT;
ALTER TABLE generated.sa_pop_grid ADD COLUMN colleges_low_stress INT;
ALTER TABLE generated.sa_pop_grid ADD COLUMN colleges_high_stress INT;
ALTER TABLE generated.sa_pop_grid ADD COLUMN colleges_score FLOAT;
ALTER TABLE generated.sa_pop_grid ADD COLUMN doctors_low_stress INT;
ALTER TABLE generated.sa_pop_grid ADD COLUMN doctors_high_stress INT;
ALTER TABLE generated.sa_pop_grid ADD COLUMN doctors_score FLOAT;
ALTER TABLE generated.sa_pop_grid ADD COLUMN dentists_low_stress INT;
ALTER TABLE generated.sa_pop_grid ADD COLUMN dentists_high_stress INT;
ALTER TABLE generated.sa_pop_grid ADD COLUMN dentists_score FLOAT;
ALTER TABLE generated.sa_pop_grid ADD COLUMN hospitals_low_stress INT;
ALTER TABLE generated.sa_pop_grid ADD COLUMN hospitals_high_stress INT;
ALTER TABLE generated.sa_pop_grid ADD COLUMN hospitals_score FLOAT;
ALTER TABLE generated.sa_pop_grid ADD COLUMN pharmacies_low_stress INT;
ALTER TABLE generated.sa_pop_grid ADD COLUMN pharmacies_high_stress INT;
ALTER TABLE generated.sa_pop_grid ADD COLUMN pharmacies_score FLOAT;
ALTER TABLE generated.sa_pop_grid ADD COLUMN retail_low_stress INT;
ALTER TABLE generated.sa_pop_grid ADD COLUMN retail_high_stress INT;
ALTER TABLE generated.sa_pop_grid ADD COLUMN retail_score FLOAT;
ALTER TABLE generated.sa_pop_grid ADD COLUMN supermarkets_low_stress INT;
ALTER TABLE generated.sa_pop_grid ADD COLUMN supermarkets_high_stress INT;
ALTER TABLE generated.sa_pop_grid ADD COLUMN supermarkets_score FLOAT;
ALTER TABLE generated.sa_pop_grid ADD COLUMN social_services_low_stress INT;
ALTER TABLE generated.sa_pop_grid ADD COLUMN social_services_high_stress INT;
ALTER TABLE generated.sa_pop_grid ADD COLUMN social_services_score FLOAT;
ALTER TABLE generated.sa_pop_grid ADD COLUMN parks_low_stress INT;
ALTER TABLE generated.sa_pop_grid ADD COLUMN parks_high_stress INT;
ALTER TABLE generated.sa_pop_grid ADD COLUMN parks_score FLOAT;
ALTER TABLE generated.sa_pop_grid ADD COLUMN trails_low_stress INT;
ALTER TABLE generated.sa_pop_grid ADD COLUMN trails_high_stress INT;
ALTER TABLE generated.sa_pop_grid ADD COLUMN trails_score FLOAT;
ALTER TABLE generated.sa_pop_grid ADD COLUMN community_centers_low_stress INT;
ALTER TABLE generated.sa_pop_grid ADD COLUMN community_centers_high_stress INT;
ALTER TABLE generated.sa_pop_grid ADD COLUMN community_centers_score FLOAT;
ALTER TABLE generated.sa_pop_grid ADD COLUMN transit_low_stress INT;
ALTER TABLE generated.sa_pop_grid ADD COLUMN transit_high_stress INT;
ALTER TABLE generated.sa_pop_grid ADD COLUMN transit_score FLOAT;
ALTER TABLE generated.sa_pop_grid ADD COLUMN overall_score FLOAT;

-- indexes
CREATE INDEX IF NOT EXISTS idx_sa_pop_grid_cell_id ON generated.sa_pop_grid (cell_id);
CREATE INDEX IF NOT EXISTS idx_sa_pop_grid_geom ON generated.sa_pop_grid USING GIST (geometry);
ANALYZE generated.sa_pop_grid;

ALTER TABLE generated.sa_pop_grid DROP COLUMN IF EXISTS tmp_geom_buffer;
ALTER TABLE generated.sa_pop_grid ADD COLUMN tmp_geom_buffer geometry(multipolygon, ?sa_crs);

UPDATE  generated.sa_pop_grid
SET     tmp_geom_buffer = ST_Multi(ST_Buffer(geometry,5));
CREATE INDEX tsidx_sa_pop_grid_cellidbuffgeoms ON generated.sa_pop_grid USING GIST (tmp_geom_buffer);
ANALYZE generated.sa_pop_grid (tmp_geom_buffer);

UPDATE  generated.sa_pop_grid
SET     road_ids = array((
            SELECT  ways.road_id
            FROM    received.sa_ways ways
            WHERE   ST_Intersects(generated.sa_pop_grid.tmp_geom_buffer,ways.geom)
            AND     (
                        ST_Contains(generated.sa_pop_grid.tmp_geom_buffer,ways.geom)
                    OR  ST_Length(
                            ST_Intersection(generated.sa_pop_grid.tmp_geom_buffer,ways.geom)
                        ) > 10
                    )
        ));

ALTER TABLE generated.sa_pop_grid DROP COLUMN IF EXISTS tmp_geom_buffer;

CREATE INDEX aidx_sa_pop_grid_road_ids ON generated.sa_pop_grid USING GIN (road_ids);
ANALYZE generated.sa_pop_grid (road_ids);