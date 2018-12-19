-----------------------------------------------------------------------------------------------------------------------
-- colleges
-----------------------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS destinations.sa_colleges;

CREATE TABLE destinations.sa_colleges (
    id SERIAL PRIMARY KEY,
    cell_id CHARACTER VARYING(18)[],
    osm_id BIGINT,
    dest_name TEXT,
    pop_low_stress INT,
    pop_high_stress INT,
    pop_score FLOAT,
    dest_type TEXT,
    geom_pt geometry(point, ?sa_crs),
    geom_poly geometry(multipolygon, ?sa_crs)
);

-- insert polygons
INSERT INTO destinations.sa_colleges (
    geom_poly
)
SELECT  ST_Multi(ST_Buffer(ST_CollectionExtract(unnest(ST_ClusterWithin(way,?cluster_colleges)),3),0))
FROM    received.sa_full_polygon
WHERE   amenity = 'college';

-- set points on polygons
UPDATE  destinations.sa_colleges
SET     geom_pt = ST_Centroid(geom_poly);

-- index
CREATE INDEX sidx_sa_colleges_geomply ON destinations.sa_colleges USING GIST (geom_poly);
ANALYZE destinations.sa_colleges (geom_poly);

-- insert points
INSERT INTO destinations.sa_colleges (
    osm_id, dest_name, geom_pt
)
SELECT  osm_id,
        name,
        way
FROM    received.sa_full_point
WHERE   amenity = 'college'
AND     NOT EXISTS (
            SELECT  1
            FROM    destinations.sa_colleges s
            WHERE   ST_Intersects(s.geom_poly,received.sa_full_point.way)
        );

-- index
CREATE INDEX sidx_sa_colleges_geompt ON destinations.sa_colleges USING GIST (geom_pt);
ANALYZE destinations.sa_colleges (geom_pt);

-- set cell_id
UPDATE  destinations.sa_colleges
SET     cell_id = array((
            SELECT  cb.cell_id
            FROM    generated.sa_pop_grid cb
            WHERE   ST_Intersects(destinations.sa_colleges.geom_poly,cb.geometry)
            OR      ST_Intersects(destinations.sa_colleges.geom_pt,cb.geometry)
        ));

-- block index
CREATE INDEX IF NOT EXISTS aidx_destinations_sa_colleges_cell_id ON destinations.sa_colleges USING GIN (cell_id);
ANALYZE destinations.sa_colleges (cell_id);

-----------------------------------------------------------------------------------------------------------------------
-- community centers
-----------------------------------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS destinations.sa_community_centers;

CREATE TABLE destinations.sa_community_centers (
    id SERIAL PRIMARY KEY,
    cell_id CHARACTER VARYING(18)[],
    osm_id BIGINT,
    dest_name TEXT,
    pop_low_stress INT,
    pop_high_stress INT,
    pop_score FLOAT,
    dest_type TEXT,
    geom_pt geometry(point, ?sa_crs),
    geom_poly geometry(multipolygon, ?sa_crs)
);

-- insert polygons
INSERT INTO destinations.sa_community_centers (
    geom_poly
)
SELECT  ST_Multi(ST_Buffer(ST_CollectionExtract(unnest(ST_ClusterWithin(way,?cluster_community_centers)),3),0))
FROM    received.sa_full_polygon
WHERE   amenity IN ('community_centre','community_center');

-- set points on polygons
UPDATE  destinations.sa_community_centers
SET     geom_pt = ST_Centroid(geom_poly);

-- index
CREATE INDEX sidx_sa_community_centers_geomply ON destinations.sa_community_centers USING GIST (geom_poly);
ANALYZE destinations.sa_community_centers (geom_poly);

-- insert points
INSERT INTO destinations.sa_community_centers (
    osm_id, dest_name, geom_pt
)
SELECT  osm_id,
        name,
        way
FROM    received.sa_full_point
WHERE   amenity IN ('community_centre','community_center')
AND     NOT EXISTS (
            SELECT  1
            FROM    destinations.sa_community_centers s
            WHERE   ST_Intersects(s.geom_poly,received.sa_full_point.way)
        );

-- index
CREATE INDEX sidx_sa_community_centers_geompt ON destinations.sa_community_centers USING GIST (geom_pt);
ANALYZE destinations.sa_community_centers (geom_pt);

-- set cell_id
UPDATE  destinations.sa_community_centers
SET     cell_id = array((
            SELECT  cb.cell_id
            FROM    generated.sa_pop_grid cb
            WHERE   ST_Intersects(destinations.sa_community_centers.geom_poly,cb.geometry)
            OR      ST_Intersects(destinations.sa_community_centers.geom_pt,cb.geometry)
        ));

-- block index
CREATE INDEX IF NOT EXISTS aidx_sa_community_centers_cell_id ON destinations.sa_community_centers USING GIN (cell_id);
ANALYZE destinations.sa_community_centers (cell_id);

-----------------------------------------------------------------------------------------------------------------------
-- dentists
-----------------------------------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS destinations.sa_dentists;

CREATE TABLE destinations.sa_dentists (
    id SERIAL PRIMARY KEY,
    cell_id CHARACTER VARYING(18)[],
    osm_id BIGINT,
    dest_name TEXT,
    pop_low_stress INT,
    pop_high_stress INT,
    pop_score FLOAT,
    dest_type TEXT,
    geom_pt geometry(point, ?sa_crs),
    geom_poly geometry(multipolygon, ?sa_crs)
);

-- insert polygons
INSERT INTO destinations.sa_dentists (
    geom_poly
)
SELECT  ST_Multi(ST_Buffer(ST_CollectionExtract(unnest(ST_ClusterWithin(way,?cluster_dentists)),3),0))
FROM    received.sa_full_polygon
WHERE   amenity = 'dentist';

-- set points on polygons
UPDATE  destinations.sa_dentists
SET     geom_pt = ST_Centroid(geom_poly);

-- index
CREATE INDEX sidx_sa_dentists_geomply ON destinations.sa_dentists USING GIST (geom_poly);
ANALYZE destinations.sa_dentists (geom_poly);

-- insert points
INSERT INTO destinations.sa_dentists (
    osm_id, dest_name, geom_pt
)
SELECT  osm_id,
        name,
        way
FROM    received.sa_full_point
WHERE   amenity = 'dentist'
AND     NOT EXISTS (
            SELECT  1
            FROM    destinations.sa_dentists s
            WHERE   ST_Intersects(s.geom_poly,received.sa_full_point.way)
        );

-- index
CREATE INDEX sidx_sa_dentists_geompt ON destinations.sa_dentists USING GIST (geom_pt);
ANALYZE destinations.sa_dentists (geom_pt);

-- set cell_id
UPDATE  destinations.sa_dentists
SET     cell_id = array((
            SELECT  cb.cell_id
            FROM    generated.sa_pop_grid cb
            WHERE   ST_Intersects(destinations.sa_dentists.geom_poly,cb.geometry)
            OR      ST_Intersects(destinations.sa_dentists.geom_pt,cb.geometry)
        ));

-- block index
CREATE INDEX IF NOT EXISTS aidx_sa_dentists_cell_id ON destinations.sa_dentists USING GIN (cell_id);
ANALYZE destinations.sa_dentists (cell_id);

-----------------------------------------------------------------------------------------------------------------------
-- doctors
-----------------------------------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS destinations.sa_doctors;

CREATE TABLE destinations.sa_doctors (
    id SERIAL PRIMARY KEY,
    cell_id CHARACTER VARYING(18)[],
    osm_id BIGINT,
    dest_name TEXT,
    pop_low_stress INT,
    pop_high_stress INT,
    pop_score FLOAT,
    dest_type TEXT,
    geom_pt geometry(point, ?sa_crs),
    geom_poly geometry(multipolygon, ?sa_crs)
);

-- insert polygons
INSERT INTO destinations.sa_doctors (
    geom_poly
)
SELECT  ST_Multi(ST_Buffer(ST_CollectionExtract(unnest(ST_ClusterWithin(way,?cluster_doctors)),3),0))
FROM    received.sa_full_polygon
WHERE   amenity IN ('clinic','doctors');

-- set points on polygons
UPDATE  destinations.sa_doctors
SET     geom_pt = ST_Centroid(geom_poly);

-- index
CREATE INDEX sidx_sa_doctors_geomply ON destinations.sa_doctors USING GIST (geom_poly);
ANALYZE destinations.sa_doctors (geom_poly);

-- insert points
INSERT INTO destinations.sa_doctors (
    osm_id, dest_name, geom_pt
)
SELECT  osm_id,
        name,
        way
FROM    received.sa_full_point
WHERE   amenity IN ('clinic','doctors')
AND     NOT EXISTS (
            SELECT  1
            FROM    destinations.sa_doctors s
            WHERE   ST_Intersects(s.geom_poly,received.sa_full_point.way)
        );

-- index
CREATE INDEX sidx_sa_doctors_geompt ON destinations.sa_doctors USING GIST (geom_pt);
ANALYZE destinations.sa_doctors (geom_pt);

-- set cell_id
UPDATE  destinations.sa_doctors
SET     cell_id = array((
            SELECT  cb.cell_id
            FROM    generated.sa_pop_grid cb
            WHERE   ST_Intersects(destinations.sa_doctors.geom_poly,cb.geometry)
            OR      ST_Intersects(destinations.sa_doctors.geom_pt,cb.geometry)
        ));

-- block index
CREATE INDEX IF NOT EXISTS aidx_sa_doctors_cell_id ON destinations.sa_doctors USING GIN (cell_id);
ANALYZE destinations.sa_doctors (cell_id);


-----------------------------------------------------------------------------------------------------------------------
-- hospitals
-----------------------------------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS destinations.sa_hospitals;

CREATE TABLE destinations.sa_hospitals (
    id SERIAL PRIMARY KEY,
    cell_id CHARACTER VARYING(18)[],
    osm_id BIGINT,
    dest_name TEXT,
    pop_low_stress INT,
    pop_high_stress INT,
    pop_score FLOAT,
    dest_type TEXT,
    geom_pt geometry(point, ?sa_crs),
    geom_poly geometry(multipolygon, ?sa_crs)
);

-- insert polygons
INSERT INTO destinations.sa_hospitals (
    geom_poly
)
SELECT  ST_Multi(ST_Buffer(ST_CollectionExtract(unnest(ST_ClusterWithin(way,?cluster_hospitals)),3),0))
FROM    received.sa_full_polygon
WHERE   amenity IN ('hospitals','hospital');

-- set points on polygons
UPDATE  destinations.sa_hospitals
SET     geom_pt = ST_Centroid(geom_poly);

-- index
CREATE INDEX sidx_sa_hospitals_geomply ON destinations.sa_hospitals USING GIST (geom_poly);
ANALYZE destinations.sa_hospitals (geom_poly);

-- insert points
INSERT INTO destinations.sa_hospitals (
    osm_id, dest_name, geom_pt
)
SELECT  osm_id,
        name,
        way
FROM    received.sa_full_point
WHERE   amenity IN ('hospitals','hospital')
AND     NOT EXISTS (
            SELECT  1
            FROM    destinations.sa_hospitals s
            WHERE   ST_Intersects(s.geom_poly,received.sa_full_point.way)
        );

-- index
CREATE INDEX sidx_sa_hospitals_geompt ON destinations.sa_hospitals USING GIST (geom_pt);
ANALYZE destinations.sa_hospitals (geom_pt);

-- set cell_id
UPDATE  destinations.sa_hospitals
SET     cell_id = array((
            SELECT  cb.cell_id
            FROM    generated.sa_pop_grid cb
            WHERE   ST_Intersects(destinations.sa_hospitals.geom_poly,cb.geometry)
            OR      ST_Intersects(destinations.sa_hospitals.geom_pt,cb.geometry)
        ));

-- block index
CREATE INDEX IF NOT EXISTS aidx_sa_hospitals_cell_id ON destinations.sa_hospitals USING GIN (cell_id);
ANALYZE destinations.sa_hospitals (cell_id);

-----------------------------------------------------------------------------------------------------------------------
-- parks
-----------------------------------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS destinations.sa_parks;

CREATE TABLE destinations.sa_parks (
    id SERIAL PRIMARY KEY,
    cell_id CHARACTER VARYING(18)[],
    osm_id BIGINT,
    dest_name TEXT,
    pop_low_stress INT,
    pop_high_stress INT,
    pop_score FLOAT,
    dest_type TEXT,
    geom_pt geometry(point, ?sa_crs),
    geom_poly geometry(multipolygon, ?sa_crs)
);

-- insert polygons
INSERT INTO destinations.sa_parks (
    geom_poly
)
SELECT  ST_Multi(ST_Buffer(ST_CollectionExtract(unnest(ST_ClusterWithin(way,?cluster_parks)),3),0))
FROM    received.sa_full_polygon
WHERE   amenity = 'park'
        OR leisure = 'park'
        OR leisure = 'nature_reserve'
        OR leisure = 'playground';

-- set points on polygons
UPDATE  destinations.sa_parks
SET     geom_pt = ST_Centroid(geom_poly);

-- index
CREATE INDEX sidx_sa_parks_geomply ON destinations.sa_parks USING GIST (geom_poly);
ANALYZE destinations.sa_parks (geom_poly);

-- insert points
INSERT INTO destinations.sa_parks (
    osm_id, dest_name, geom_pt
)
SELECT  osm_id,
        name,
        way
FROM    received.sa_full_point
WHERE   (
            amenity = 'park'
        OR  leisure = 'park'
        OR  leisure = 'nature_reserve'
        OR  leisure = 'playground'
        )
AND     NOT EXISTS (
            SELECT  1
            FROM    destinations.sa_parks s
            WHERE   ST_Intersects(s.geom_poly,received.sa_full_point.way)
        );

-- index
CREATE INDEX sidx_sa_parks_geompt ON destinations.sa_parks USING GIST (geom_pt);
ANALYZE destinations.sa_parks (geom_pt);

-- set cell_id
UPDATE  destinations.sa_parks
SET     cell_id = array((
            SELECT  cb.cell_id
            FROM    generated.sa_pop_grid cb
            WHERE   ST_Intersects(destinations.sa_parks.geom_poly,cb.geometry)
            OR      ST_Intersects(destinations.sa_parks.geom_pt,cb.geometry)
        ));

-- block index
CREATE INDEX IF NOT EXISTS aidx_sa_parks_cell_id ON destinations.sa_parks USING GIN (cell_id);
ANALYZE destinations.sa_parks (cell_id);

-----------------------------------------------------------------------------------------------------------------------
-- pharmacies
-----------------------------------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS destinations.sa_pharmacies;

CREATE TABLE destinations.sa_pharmacies (
    id SERIAL PRIMARY KEY,
    cell_id CHARACTER VARYING(18)[],
    osm_id BIGINT,
    dest_name TEXT,
    pop_low_stress INT,
    pop_high_stress INT,
    pop_score FLOAT,
    dest_type TEXT,
    geom_pt geometry(point, ?sa_crs),
    geom_poly geometry(multipolygon, ?sa_crs)
);

-- insert polygons
INSERT INTO destinations.sa_pharmacies (
    geom_poly
)
SELECT  ST_Multi(ST_Buffer(ST_CollectionExtract(unnest(ST_ClusterWithin(way,?cluster_pharmacies)),3),0))
FROM    received.sa_full_polygon
WHERE   amenity = 'pharmacy';

-- set points on polygons
UPDATE  destinations.sa_pharmacies
SET     geom_pt = ST_Centroid(geom_poly);

-- index
CREATE INDEX sidx_sa_pharmacies_geomply ON destinations.sa_pharmacies USING GIST (geom_poly);
ANALYZE destinations.sa_pharmacies (geom_poly);

-- insert points
INSERT INTO destinations.sa_pharmacies (
    osm_id, dest_name, geom_pt
)
SELECT  osm_id,
        name,
        way
FROM    received.sa_full_point
WHERE   amenity = 'pharmacy'
AND     NOT EXISTS (
            SELECT  1
            FROM    destinations.sa_pharmacies s
            WHERE   ST_Intersects(s.geom_poly,received.sa_full_point.way)
        );

-- index
CREATE INDEX sidx_sa_pharmacies_geompt ON destinations.sa_pharmacies USING GIST (geom_pt);
ANALYZE destinations.sa_pharmacies (geom_pt);

-- set cell_id
UPDATE  destinations.sa_pharmacies
SET     cell_id = array((
            SELECT  cb.cell_id
            FROM    generated.sa_pop_grid cb
            WHERE   ST_Intersects(destinations.sa_pharmacies.geom_poly,cb.geometry)
            OR      ST_Intersects(destinations.sa_pharmacies.geom_pt,cb.geometry)
        ));

-- block index
CREATE INDEX IF NOT EXISTS aidx_sa_pharmacies_cell_id ON destinations.sa_pharmacies USING GIN (cell_id);
ANALYZE destinations.sa_pharmacies (cell_id);

-----------------------------------------------------------------------------------------------------------------------
-- retail
-----------------------------------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS destinations.sa_retail;

CREATE TABLE destinations.sa_retail (
    id SERIAL PRIMARY KEY,
    cell_id CHARACTER VARYING(18)[],
    osm_id BIGINT,
    dest_name TEXT,
    pop_low_stress INT,
    pop_high_stress INT,
    pop_score FLOAT,
    dest_type TEXT,
    geom_pt geometry(point, ?sa_crs),
    geom_poly geometry(multipolygon, ?sa_crs)
);

-- insert
INSERT INTO destinations.sa_retail (
    geom_poly
)
SELECT  ST_Multi(ST_Buffer(ST_CollectionExtract(unnest(ST_ClusterWithin(way,?cluster_retail)),3),0))
FROM    received.sa_full_polygon
WHERE   landuse = 'retail';

-- set points on polygons
UPDATE  destinations.sa_retail
SET     geom_pt = ST_Centroid(geom_poly);

-- index
CREATE INDEX sidx_sa_retail_geomply ON destinations.sa_retail USING GIST (geom_poly);
ANALYZE destinations.sa_retail (geom_poly);

-- set cell_id
UPDATE  destinations.sa_retail
SET     cell_id = array((
            SELECT  cb.cell_id
            FROM    generated.sa_pop_grid cb
            WHERE   ST_Intersects(destinations.sa_retail.geom_poly,cb.geometry)
        ));

-- block index
CREATE INDEX IF NOT EXISTS aidx_sa_retail_cell_id ON destinations.sa_retail USING GIN (cell_id);
ANALYZE destinations.sa_retail (cell_id);

-----------------------------------------------------------------------------------------------------------------------
-- schools
-----------------------------------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS destinations.sa_schools;

CREATE TABLE destinations.sa_schools (
    id SERIAL PRIMARY KEY,
    cell_id CHARACTER VARYING(18)[],
    osm_id BIGINT,
    dest_name TEXT,
    pop_low_stress INT,
    pop_high_stress INT,
    pop_score FLOAT,
    dest_type TEXT,
    geom_pt geometry(point, ?sa_crs),
    geom_poly geometry(polygon, ?sa_crs)
);

-- insert points from polygons
INSERT INTO destinations.sa_schools (
    osm_id, dest_name, geom_pt, geom_poly
)
SELECT  osm_id,
        name,
        ST_Centroid(way),
        way
FROM    received.sa_full_polygon
WHERE   amenity = 'school';

-- remove subareas that are mistakenly designated as amenity=school
DELETE FROM destinations.sa_schools
WHERE   EXISTS (
            SELECT  1
            FROM    destinations.sa_schools s
            WHERE   ST_Contains(s.geom_poly,destinations.sa_schools.geom_poly)
            AND     s.id != destinations.sa_schools.id
);

-- index
CREATE INDEX sidx_sa_schools_geomply ON destinations.sa_schools USING GIST (geom_poly);
ANALYZE destinations.sa_schools (geom_poly);

-- insert points
INSERT INTO destinations.sa_schools (
    osm_id, dest_name, geom_pt
)
SELECT  osm_id,
        name,
        way
FROM    received.sa_full_point
WHERE   amenity = 'school'
AND     NOT EXISTS (
            SELECT  1
            FROM    destinations.sa_schools s
            WHERE   ST_Intersects(s.geom_poly,received.sa_full_point.way)
        );

-- index
CREATE INDEX sidx_sa_schools_geompt ON destinations.sa_schools USING GIST (geom_pt);
ANALYZE destinations.sa_schools (geom_pt);

-- set cell_id
UPDATE  destinations.sa_schools
SET     cell_id = array((
            SELECT  cb.cell_id
            FROM    generated.sa_pop_grid cb
            WHERE   ST_Intersects(destinations.sa_schools.geom_poly,cb.geometry)
            OR      ST_Intersects(destinations.sa_schools.geom_pt,cb.geometry)
        ));

-- block index
CREATE INDEX IF NOT EXISTS aidx_sa_schools_cell_id ON destinations.sa_schools USING GIN (cell_id);
ANALYZE destinations.sa_schools (cell_id);

-----------------------------------------------------------------------------------------------------------------------
-- social services
-----------------------------------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS destinations.sa_social_services;

CREATE TABLE destinations.sa_social_services (
    id SERIAL PRIMARY KEY,
    cell_id CHARACTER VARYING(18)[],
    osm_id BIGINT,
    dest_name TEXT,
    pop_low_stress INT,
    pop_high_stress INT,
    pop_score FLOAT,
    dest_type TEXT,
    geom_pt geometry(point, ?sa_crs),
    geom_poly geometry(polygon, ?sa_crs)
);

-- insert points from polygons
INSERT INTO destinations.sa_social_services (
    osm_id, dest_name, geom_pt, geom_poly
)
SELECT  osm_id,
        name,
        ST_Centroid(way),
        way
FROM    received.sa_full_polygon
WHERE   amenity = 'social_facility';

-- remove subareas that are already covered
DELETE FROM destinations.sa_social_services
WHERE   EXISTS (
            SELECT  1
            FROM    destinations.sa_social_services s
            WHERE   ST_Contains(s.geom_poly,destinations.sa_social_services.geom_poly)
            AND     s.id != destinations.sa_social_services.id
);

-- index
CREATE INDEX sidx_sa_social_services_geomply ON destinations.sa_social_services USING GIST (geom_poly);
ANALYZE destinations.sa_social_services (geom_poly);

-- insert points
INSERT INTO destinations.sa_social_services (
    osm_id, dest_name, geom_pt
)
SELECT  osm_id,
        name,
        way
FROM    received.sa_full_point
WHERE   amenity = 'social_facility'
AND     NOT EXISTS (
            SELECT  1
            FROM    destinations.sa_social_services s
            WHERE   ST_Intersects(s.geom_poly,received.sa_full_point.way)
        );

-- index
CREATE INDEX sidx_sa_social_services_geompt ON destinations.sa_social_services USING GIST (geom_pt);
ANALYZE destinations.sa_social_services (geom_pt);

-- set cell_id
UPDATE  destinations.sa_social_services
SET     cell_id = array((
            SELECT  cb.cell_id
            FROM    generated.sa_pop_grid cb
            WHERE   ST_Intersects(destinations.sa_social_services.geom_poly,cb.geometry)
            OR      ST_Intersects(destinations.sa_social_services.geom_pt,cb.geometry)
        ));

-- block index
CREATE INDEX IF NOT EXISTS aidx_sa_social_services_cell_id ON destinations.sa_social_services USING GIN (cell_id);
ANALYZE destinations.sa_social_services (cell_id);

-----------------------------------------------------------------------------------------------------------------------
-- supermarkets
-----------------------------------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS destinations.sa_supermarkets;

CREATE TABLE destinations.sa_supermarkets (
    id SERIAL PRIMARY KEY,
    cell_id CHARACTER VARYING(18)[],
    osm_id BIGINT,
    dest_name TEXT,
    pop_low_stress INT,
    pop_high_stress INT,
    pop_score FLOAT,
    dest_type TEXT,
    geom_pt geometry(point, ?sa_crs),
    geom_poly geometry(polygon, ?sa_crs)
);

-- insert points from polygons
INSERT INTO destinations.sa_supermarkets (
    osm_id, dest_name, geom_pt, geom_poly
)
SELECT  osm_id,
        name,
        ST_Centroid(way),
        way
FROM    received.sa_full_polygon
WHERE   shop = 'supermarket';

-- remove subareas that are already covered
DELETE FROM destinations.sa_supermarkets
WHERE   EXISTS (
            SELECT  1
            FROM    destinations.sa_supermarkets s
            WHERE   ST_Contains(s.geom_poly,destinations.sa_supermarkets.geom_poly)
            AND     s.id != destinations.sa_supermarkets.id
);

-- index
CREATE INDEX sidx_sa_supermarkets_geomply ON destinations.sa_supermarkets USING GIST (geom_poly);
ANALYZE destinations.sa_supermarkets (geom_poly);

-- insert points
INSERT INTO destinations.sa_supermarkets (
    osm_id, dest_name, geom_pt
)
SELECT  osm_id,
        name,
        way
FROM    received.sa_full_point
WHERE   shop = 'supermarket'
AND     NOT EXISTS (
            SELECT  1
            FROM    destinations.sa_supermarkets s
            WHERE   ST_Intersects(s.geom_poly,received.sa_full_point.way)
        );

-- index
CREATE INDEX sidx_sa_supermarkets_geompt ON destinations.sa_supermarkets USING GIST (geom_pt);
ANALYZE destinations.sa_supermarkets (geom_pt);

-- set cell_id
UPDATE  destinations.sa_supermarkets
SET     cell_id = array((
            SELECT  cb.cell_id
            FROM    generated.sa_pop_grid cb
            WHERE   ST_Intersects(destinations.sa_supermarkets.geom_poly,cb.geometry)
            OR      ST_Intersects(destinations.sa_supermarkets.geom_pt,cb.geometry)
        ));

-- block index
CREATE INDEX IF NOT EXISTS aidx_sa_supermarkets_cell_id ON destinations.sa_supermarkets USING GIN (cell_id);
ANALYZE destinations.sa_supermarkets (cell_id);

-----------------------------------------------------------------------------------------------------------------------
-- transit
-----------------------------------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS destinations.sa_transit;

CREATE TABLE destinations.sa_transit (
    id SERIAL PRIMARY KEY,
    cell_id CHARACTER VARYING(18)[],
    osm_id BIGINT,
    dest_name TEXT,
    pop_low_stress INT,
    pop_high_stress INT,
    pop_score FLOAT,
    dest_type TEXT,
    geom_pt geometry(point, ?sa_crs),
    geom_poly geometry(polygon, ?sa_crs)
);

-- insert points from polygons
INSERT INTO destinations.sa_transit (
    osm_id, dest_name, geom_pt, geom_poly
)
SELECT  osm_id,
        name,
        ST_Centroid(way),
        way
FROM    received.sa_full_polygon
WHERE   amenity = 'bus_station'
OR      railway = 'station'
OR      public_transport = 'station';

-- remove subareas
DELETE FROM destinations.sa_transit
WHERE   EXISTS (
            SELECT  1
            FROM    destinations.sa_transit s
            WHERE   ST_Contains(s.geom_poly,destinations.sa_transit.geom_poly)
            AND     s.id != destinations.sa_transit.id
);

-- index
CREATE INDEX sidx_sa_transit_geomply ON destinations.sa_transit USING GIST (geom_poly);
ANALYZE destinations.sa_transit (geom_poly);

-- insert points
INSERT INTO destinations.sa_transit (
    geom_pt
)
SELECT  ST_Centroid(ST_CollectionExtract(unnest(ST_ClusterWithin(way,?cluster_transit)),1))
FROM    received.sa_full_point
WHERE   (
            amenity = 'bus_station'
        OR  railway = 'station'
        OR  public_transport = 'station'
        )
AND     NOT EXISTS (
            SELECT  1
            FROM    destinations.sa_transit s
            WHERE   ST_DWithin(s.geom_poly,received.sa_full_point.way,50)
        );

-- index
CREATE INDEX sidx_sa_transit_geompt ON destinations.sa_transit USING GIST (geom_pt);
ANALYZE destinations.sa_transit (geom_pt);

-- set cell_id
UPDATE  destinations.sa_transit
SET     cell_id = array((
            SELECT  cb.cell_id
            FROM    generated.sa_pop_grid cb
            WHERE   ST_Intersects(destinations.sa_transit.geom_poly,cb.geometry)
            OR      ST_Intersects(destinations.sa_transit.geom_pt,cb.geometry)
        ));

-- block index
CREATE INDEX IF NOT EXISTS aidx_sa_transit_cell_id ON destinations.sa_transit USING GIN (cell_id);
ANALYZE destinations.sa_transit (cell_id);

-----------------------------------------------------------------------------------------------------------------------
-- universities
-----------------------------------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS destinations.sa_universities;

CREATE TABLE destinations.sa_universities (
    id SERIAL PRIMARY KEY,
    cell_id CHARACTER VARYING(18)[],
    osm_id BIGINT,
    dest_name TEXT,
    pop_low_stress INT,
    pop_high_stress INT,
    pop_score FLOAT,
    dest_type TEXT,
    geom_pt geometry(point, ?sa_crs),
    geom_poly geometry(multipolygon, ?sa_crs)
);

-- insert polygons
INSERT INTO destinations.sa_universities (
    geom_poly
)
SELECT  ST_Multi(ST_Buffer(ST_CollectionExtract(unnest(ST_ClusterWithin(way,?cluster_universities)),3),0))
FROM    received.sa_full_polygon
WHERE   amenity = 'university';

-- set points on polygons
UPDATE  destinations.sa_universities
SET     geom_pt = ST_Centroid(geom_poly);

-- index
CREATE INDEX sidx_sa_universities_geomply ON destinations.sa_universities USING GIST (geom_poly);
ANALYZE destinations.sa_universities (geom_poly);

-- insert points
INSERT INTO destinations.sa_universities (
    osm_id, dest_name, geom_pt
)
SELECT  osm_id,
        name,
        way
FROM    received.sa_full_point
WHERE   amenity = 'university'
AND     NOT EXISTS (
            SELECT  1
            FROM    destinations.sa_universities s
            WHERE   ST_Intersects(s.geom_poly,received.sa_full_point.way)
        );

-- index
CREATE INDEX sidx_sa_universities_geompt ON destinations.sa_universities USING GIST (geom_pt);
ANALYZE destinations.sa_universities (geom_pt);

-- set cell_id
UPDATE  destinations.sa_universities
SET     cell_id = array((
            SELECT  cb.cell_id
            FROM    generated.sa_pop_grid cb
            WHERE   ST_Intersects(destinations.sa_universities.geom_poly,cb.geometry)
            OR      ST_Intersects(destinations.sa_universities.geom_pt,cb.geometry)
        ));

-- block index
CREATE INDEX IF NOT EXISTS aidx_sa_universities_cell_id ON destinations.sa_universities USING GIN (cell_id);
ANALYZE destinations.sa_universities (cell_id);