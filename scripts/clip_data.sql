ALTER TABLE IF EXISTS received.sa_ways DROP CONSTRAINT IF EXISTS sa_all_ways_source_fkey CASCADE;
ALTER TABLE IF EXISTS received.sa_ways DROP CONSTRAINT IF EXISTS sa_all_ways_target_fkey CASCADE;

DELETE FROM received.sa_ways_int AS intersections
    USING received.sa_boundary AS boundary
    WHERE NOT ST_DWithin(intersections.geom, boundary.geometry, 1000);

DELETE FROM received.sa_ways AS ways
    USING received.sa_boundary AS boundary
    WHERE NOT ST_DWithin(ways.geom, boundary.geometry, 1000);

DELETE FROM received.sa_full_line AS lines
    USING received.sa_boundary AS boundary
    WHERE NOT ST_DWithin(lines.way, boundary.geometry, 1000);

DELETE FROM received.sa_full_point AS points
    USING received.sa_boundary AS boundary
    WHERE NOT ST_DWithin(points.way, boundary.geometry, 1000);

DELETE FROM received.sa_full_polygon AS polygons
    USING received.sa_boundary AS boundary
    WHERE NOT ST_DWithin(polygons.way, boundary.geometry, 1000);

DELETE FROM received.sa_full_roads AS roads
    USING received.sa_boundary AS boundary
    WHERE NOT ST_DWithin(roads.way, boundary.geometry, 1000);