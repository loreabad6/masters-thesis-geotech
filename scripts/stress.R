# Function to calculate stress for higher order ways

stress_higher_order_ways <- function(
  class, 
  default_speed, 
  default_lanes, 
  default_parking,
  default_parking_width,
  default_facility_width
)
{
  sqldf(
    paste0(
      "
      UPDATE  received.sa_ways SET ft_seg_stress = NULL, tf_seg_stress = NULL
      WHERE   functional_class IN ('",
      class,
      "','",
      class,
      "'||'_link');
      
      -- ft direction
      UPDATE  received.sa_ways
      SET     ft_seg_stress =
      CASE
      WHEN ft_bike_infra = 'track' THEN 1
      WHEN ft_bike_infra = 'buffered_lane'
      THEN    CASE
      WHEN COALESCE(speed_limit,",
      default_speed,
      ") > 60 THEN 3
      WHEN COALESCE(speed_limit,",
      default_speed,
      ") = 60
      THEN    CASE
      WHEN COALESCE(ft_lanes,",
      default_lanes,
      ") > 1 THEN 3
      ELSE    CASE
      WHEN COALESCE(ft_park,",
      default_parking,
      ") = 1 THEN 2
      ELSE 1
      END
      END
      WHEN COALESCE(speed_limit,",
      default_speed,
      ") = 50
      THEN    CASE
      WHEN COALESCE(ft_lanes,",
      default_lanes,
      ") > 1
      THEN    CASE
      WHEN COALESCE(ft_park,",
      default_parking,
      ") = 1 THEN 2
      ELSE 1
      END
      ELSE 1
      END
      WHEN COALESCE(speed_limit,",
      default_speed,
      ") < 50 THEN 1
      ELSE 3
      END
      WHEN ft_bike_infra = 'lane' AND COALESCE(ft_park,",
      default_parking,
      ") = 0  -- bike lane with no parking
      THEN    CASE
      WHEN COALESCE(speed_limit,",
      default_speed,
      ") > 50 THEN 3
      WHEN COALESCE(speed_limit,",
      default_speed,
      ") = 50
      THEN    CASE
      WHEN COALESCE(ft_lanes,",
      default_lanes,
      ") > 1 THEN 3
      ELSE 1
      END
      WHEN COALESCE(speed_limit,",
      default_speed,
      ") = 40
      THEN    CASE
      WHEN COALESCE(ft_lanes,",
      default_lanes,
      ") > 1 THEN 3
      ELSE 1
      END
      WHEN COALESCE(speed_limit,",
      default_speed,
      ") <= 30
      THEN    CASE
      WHEN COALESCE(ft_lanes,",
      default_lanes,
      ") > 2 THEN 3
      ELSE 1
      END
      ELSE 3
      END
      WHEN ft_bike_infra = 'lane' AND COALESCE(ft_park,",
      default_parking,
      ") = 1
      THEN    CASE
      WHEN COALESCE(ft_bike_infra_width,",
      default_facility_width,
      ") + ",
      default_parking_width,
      " >= 5   -- treat as buffered lane
      THEN    CASE
      WHEN COALESCE(speed_limit,",
      default_speed,
      ") > 60 THEN 3
      WHEN COALESCE(speed_limit,",
      default_speed,
      ") = 60 THEN 3
      WHEN COALESCE(speed_limit,",
      default_speed,
      ") = 50
      THEN    CASE
      WHEN COALESCE(ft_lanes,",
      default_lanes,
      ") > 1 THEN 2
      ELSE 1
      END
      WHEN COALESCE(speed_limit,",
      default_speed,
      ") < 50 THEN 1
      ELSE 3
      END
      WHEN COALESCE(ft_bike_infra_width,",
      default_facility_width,
      ") + ",
      default_parking_width,
      " >= 4   -- treat as bike lane with no parking
      THEN    CASE
      WHEN COALESCE(speed_limit,",
      default_speed,
      ") > 50 THEN 3
      WHEN COALESCE(speed_limit,",
      default_speed,
      ") = 50
      THEN    CASE
      WHEN COALESCE(ft_lanes,",
      default_lanes,
      ") > 1 THEN 3
      ELSE 1
      END
      WHEN COALESCE(speed_limit,",
      default_speed,
      ") = 40
      THEN    CASE
      WHEN COALESCE(ft_lanes,",
      default_lanes,
      ") > 1 THEN 3
      ELSE 1
      END
      WHEN COALESCE(speed_limit,",
      default_speed,
      ") <= 30
      THEN    CASE
      WHEN COALESCE(ft_lanes,",
      default_lanes,
      ") > 2 THEN 3
      ELSE 1
      END
      ELSE 3
      END
      ELSE 3
      END
      ELSE                -- shared lane
      CASE
      WHEN COALESCE(speed_limit,",
      default_speed,
      ") <= 30
      THEN    CASE
      WHEN COALESCE(ft_lanes,",
      default_lanes,
      ") = 1 THEN 1
      ELSE 3
      END
      ELSE 3
      END
      END,
      tf_seg_stress =
      CASE
      WHEN tf_bike_infra = 'track' THEN 1
      WHEN tf_bike_infra = 'buffered_lane'
      THEN    CASE
      WHEN COALESCE(speed_limit,",
      default_speed,
      ") > 60 THEN 3
      WHEN COALESCE(speed_limit,",
      default_speed,
      ") = 60
      THEN    CASE
      WHEN COALESCE(tf_lanes,",
      default_lanes,
      ") > 1 THEN 3
      ELSE    CASE
      WHEN COALESCE(tf_park,",
      default_parking,
      ") = 1 THEN 2
      ELSE 1
      END
      END
      WHEN COALESCE(speed_limit,",
      default_speed,
      ") = 50
      THEN    CASE
      WHEN COALESCE(tf_lanes,",
      default_lanes,
      ") > 1
      THEN    CASE
      WHEN COALESCE(tf_park,",
      default_parking,
      ") = 1 THEN 2
      ELSE 1
      END
      ELSE 1
      END
      WHEN COALESCE(speed_limit,",
      default_speed,
      ") < 50 THEN 1
      ELSE 3
      END
      WHEN tf_bike_infra = 'lane' AND COALESCE(tf_park,",
      default_parking,
      ") = 0  -- bike lane with no parking
      THEN    CASE
      WHEN COALESCE(speed_limit,",
      default_speed,
      ") > 50 THEN 3
      WHEN COALESCE(speed_limit,",
      default_speed,
      ") = 50
      THEN    CASE
      WHEN COALESCE(tf_lanes,",
      default_lanes,
      ") > 1 THEN 3
      ELSE 1
      END
      WHEN COALESCE(speed_limit,",
      default_speed,
      ") = 40
      THEN    CASE
      WHEN COALESCE(tf_lanes,",
      default_lanes,
      ") > 1 THEN 3
      ELSE 1
      END
      WHEN COALESCE(speed_limit,",
      default_speed,
      ") <= 30
      THEN    CASE
      WHEN COALESCE(tf_lanes,",
      default_lanes,
      ") > 2 THEN 3
      ELSE 1
      END
      ELSE 3
      END
      WHEN tf_bike_infra = 'lane' AND COALESCE(tf_park,",
      default_parking,
      ") = 1
      THEN    CASE
      WHEN COALESCE(tf_bike_infra_width,",
      default_facility_width,
      ") + ",
      default_parking_width,
      " >= 5   -- treat as buffered lane
      THEN    CASE
      WHEN COALESCE(speed_limit,",
      default_speed,
      ") > 60 THEN 3
      WHEN COALESCE(speed_limit,",
      default_speed,
      ") = 60 THEN 3
      WHEN COALESCE(speed_limit,",
      default_speed,
      ") = 50
      THEN    CASE
      WHEN COALESCE(tf_lanes,",
      default_lanes,
      ") > 1 THEN 2
      ELSE 1
      END
      WHEN COALESCE(speed_limit,",
      default_speed,
      ") < 50 THEN 1
      ELSE 3
      END
      WHEN COALESCE(tf_bike_infra_width,",
      default_facility_width,
      ") + ",
      default_parking_width,
      " >= 4   -- treat as bike lane with no parking
      THEN    CASE
      WHEN COALESCE(speed_limit,",
      default_speed,
      ") > 50 THEN 3
      WHEN COALESCE(speed_limit,",
      default_speed,
      ") = 50
      THEN    CASE
      WHEN COALESCE(tf_lanes,",
      default_lanes,
      ") > 1 THEN 3
      ELSE 1
      END
      WHEN COALESCE(speed_limit,",
      default_speed,
      ") = 40
      THEN    CASE
      WHEN COALESCE(tf_lanes,",
      default_lanes,
      ") > 1 THEN 3
      ELSE 1
      END
      WHEN COALESCE(speed_limit,",
      default_speed,
      ") <= 30
      THEN    CASE
      WHEN COALESCE(tf_lanes,",
      default_lanes,
      ") > 2 THEN 3
      ELSE 1
      END
      ELSE 3
      END
      ELSE 3
      END
      ELSE                -- shared lane
      CASE
      WHEN COALESCE(speed_limit,",
      default_speed,
      ") <= 30
      THEN    CASE
      WHEN COALESCE(tf_lanes,",
      default_lanes,
      ") = 1 THEN 1
      ELSE 3
      END
      ELSE 3
      END
      END
      WHERE   functional_class IN ('",
      class,
      "','",
      class,
      "'||'_link');
      "
      ),
    connection = connection
      )
}

stress_lower_order_ways <- function(class,
                                    default_speed,
                                    default_lanes,
                                    default_parking,
                                    default_roadway_width)
{
  sqldf(
    paste0(
      "
      UPDATE  received.sa_ways SET ft_seg_stress=NULL, tf_seg_stress=NULL
      WHERE   functional_class = '",
      class,
      "';
      
      UPDATE  received.sa_ways
      SET     ft_seg_stress =
      CASE
      WHEN COALESCE(speed_limit,",
      default_speed,
      ") = 40
      THEN    CASE
      WHEN COALESCE(ft_park,",
      default_parking,
      ") + COALESCE(tf_park,",
      default_parking,
      ") = 2    -- parking on both sides
      THEN    CASE
      WHEN COALESCE(width,",
      default_roadway_width,
      ") >= 8
      THEN 1
      ELSE 2
      END
      ELSE    CASE                                                                        -- parking on one side
      WHEN COALESCE(width,",
      default_roadway_width,
      ") >= 6
      THEN 1
      ELSE 2
      END
      END
      WHEN COALESCE(speed_limit,",
      default_speed,
      ") <= 30 THEN 1
      ELSE 3
      END,
      tf_seg_stress =
      CASE
      WHEN COALESCE(speed_limit,",
      default_speed,
      ") = 40
      THEN    CASE
      WHEN COALESCE(ft_park,",
      default_parking,
      ") + COALESCE(tf_park,",
      default_parking,
      ") = 2    -- parking on both sides
      THEN    CASE
      WHEN COALESCE(width,",
      default_roadway_width,
      ") >= 8
      THEN 1
      ELSE 2
      END
      ELSE    CASE                                                                        -- parking on one side
      WHEN COALESCE(width,",
      default_roadway_width,
      ") >= 6
      THEN 1
      ELSE 2
      END
      END
      WHEN COALESCE(speed_limit,",
      default_speed,
      ") <= 30 THEN 1
      ELSE 3
      END
      WHERE   functional_class = '",
      class,
      "';
      
      "
      ),
    connection = connection
      )
}

stress_tertiary_int <- function(primary_speed,
                                secondary_speed,
                                primary_lanes,
                                secondary_lanes)
{
  sqldf(
    paste0(
      "
      UPDATE  received.sa_ways SET ft_int_stress = 1, tf_int_stress = 1
      WHERE   functional_class = 'tertiary';
      
      -- ft
      UPDATE  received.sa_ways
      SET     ft_int_stress = 3
      FROM    received.sa_ways_int i
      WHERE   functional_class = 'tertiary'
      AND     received.sa_ways.intersection_to = i.int_id
      AND     NOT i.signalized
      AND     NOT i.stops
      AND     EXISTS (
      SELECT  1
      FROM    received.sa_ways w
      WHERE   i.int_id IN (w.intersection_to,w.intersection_from)
      AND     COALESCE(received.sa_ways.name,'a') != COALESCE(w.name,'b')
      AND     CASE
      WHEN w.functional_class IN ('motorway','trunk') THEN TRUE
      
      -- two way primary
      WHEN w.functional_class = 'primary' AND w.one_way IS NULL
      THEN    CASE
      WHEN COALESCE(w.ft_lanes,",
      primary_lanes,
      ") + COALESCE(w.tf_lanes,",
      primary_lanes,
      ") > 4 THEN TRUE
      
      -- with rrfb
      WHEN i.rrfb
      THEN    CASE
      WHEN COALESCE(w.ft_lanes,",
      primary_lanes,
      ") + COALESCE(w.tf_lanes,",
      primary_lanes,
      ") = 4
      THEN    CASE
      WHEN COALESCE(w.speed_limit,",
      primary_speed,
      ") > 70 THEN TRUE
      WHEN COALESCE(w.speed_limit,",
      primary_speed,
      ") > 50
      THEN    CASE
      WHEN i.island THEN FALSE
      ELSE TRUE
      END
      ELSE FALSE
      END
      WHEN COALESCE(w.ft_lanes,",
      primary_lanes,
      ") + COALESCE(w.tf_lanes,",
      primary_lanes,
      ") < 4
      THEN    CASE
      WHEN COALESCE(w.speed_limit,",
      primary_speed,
      ") > 60
      THEN    CASE
      WHEN i.island THEN FALSE
      ELSE TRUE
      END
      ELSE FALSE
      END
      END
      
      -- without rrfb
      ELSE        CASE
      WHEN COALESCE(w.ft_lanes,",
      primary_lanes,
      ") + COALESCE(w.tf_lanes,",
      primary_lanes,
      ") = 4
      THEN    CASE
      WHEN COALESCE(w.speed_limit,",
      primary_speed,
      ") > 50 THEN TRUE
      WHEN COALESCE(w.speed_limit,",
      primary_speed,
      ") = 50
      THEN    CASE
      WHEN i.island THEN FALSE
      ELSE TRUE
      END
      ELSE FALSE
      END
      WHEN COALESCE(w.ft_lanes,",
      primary_lanes,
      ") + COALESCE(w.tf_lanes,",
      primary_lanes,
      ") < 4
      THEN    CASE
      WHEN COALESCE(w.speed_limit,",
      primary_speed,
      ") > 50
      THEN    CASE
      WHEN i.island THEN FALSE
      ELSE TRUE
      END
      ELSE FALSE
      END
      END
      END
      
      -- one way primary
      WHEN w.functional_class = 'primary' AND w.one_way IS NOT NULL
      THEN    CASE
      WHEN COALESCE(w.ft_lanes,w.tf_lanes,",
      primary_lanes,
      ") > 2 THEN TRUE
      
      -- with rrfb
      WHEN i.rrfb
      THEN    CASE
      WHEN COALESCE(w.ft_lanes,w.tf_lanes,",
      primary_lanes,
      ") = 2
      THEN    CASE
      WHEN COALESCE(w.speed_limit,",
      primary_speed,
      ") > 70 THEN TRUE
      ELSE FALSE
      END
      WHEN COALESCE(w.ft_lanes,w.tf_lanes,",
      primary_lanes,
      ") < 2
      THEN    CASE
      WHEN COALESCE(w.speed_limit,",
      primary_speed,
      ") > 60 THEN TRUE
      ELSE FALSE
      END
      END
      
      -- without rrfb
      ELSE        CASE
      WHEN COALESCE(w.ft_lanes,w.tf_lanes,",
      primary_lanes,
      ") = 2
      THEN    CASE
      WHEN COALESCE(w.speed_limit,",
      primary_speed,
      ") > 50 THEN TRUE
      ELSE FALSE
      END
      WHEN COALESCE(w.ft_lanes,w.tf_lanes,",
      primary_lanes,
      ") < 2
      THEN    CASE
      WHEN COALESCE(w.speed_limit,",
      primary_speed,
      ") > 50 THEN TRUE
      ELSE FALSE
      END
      END
      END
      
      -- two way secondary
      WHEN w.functional_class = 'secondary' AND w.one_way IS NULL
      THEN    CASE
      WHEN COALESCE(w.ft_lanes,",
      secondary_lanes,
      ") + COALESCE(w.tf_lanes,",
      secondary_lanes,
      ") > 4 THEN TRUE
      
      -- with rrfb
      WHEN i.rrfb
      THEN    CASE
      WHEN COALESCE(w.ft_lanes,",
      secondary_lanes,
      ") + COALESCE(w.tf_lanes,",
      secondary_lanes,
      ") = 4
      THEN    CASE
      WHEN COALESCE(w.speed_limit,",
      secondary_speed,
      ") > 70 THEN TRUE
      WHEN COALESCE(w.speed_limit,",
      secondary_speed,
      ") > 50
      THEN    CASE
      WHEN i.island THEN FALSE
      ELSE TRUE
      END
      ELSE FALSE
      END
      WHEN COALESCE(w.ft_lanes,",
      secondary_lanes,
      ") + COALESCE(w.tf_lanes,",
      secondary_lanes,
      ") < 4
      THEN    CASE
      WHEN COALESCE(w.speed_limit,",
      secondary_speed,
      ") > 60
      THEN    CASE
      WHEN i.island THEN FALSE
      ELSE TRUE
      END
      ELSE FALSE
      END
      END
      
      -- without rrfb
      ELSE        CASE
      WHEN COALESCE(w.ft_lanes,",
      secondary_lanes,
      ") + COALESCE(w.tf_lanes,",
      secondary_lanes,
      ") = 4
      THEN    CASE
      WHEN COALESCE(w.speed_limit,",
      secondary_speed,
      ") > 50 THEN TRUE
      WHEN COALESCE(w.speed_limit,",
      secondary_speed,
      ") = 50
      THEN    CASE
      WHEN i.island THEN FALSE
      ELSE TRUE
      END
      ELSE FALSE
      END
      WHEN COALESCE(w.ft_lanes,",
      secondary_lanes,
      ") + COALESCE(w.tf_lanes,",
      secondary_lanes,
      ") < 4
      THEN    CASE
      WHEN COALESCE(w.speed_limit,",
      secondary_speed,
      ") > 50
      THEN    CASE
      WHEN i.island THEN FALSE
      ELSE TRUE
      END
      ELSE FALSE
      END
      END
      END
      
      -- one way secondary
      WHEN w.functional_class = 'secondary' AND w.one_way IS NOT NULL
      THEN    CASE
      WHEN COALESCE(w.ft_lanes,w.tf_lanes,",
      secondary_lanes,
      ") > 2 THEN TRUE
      
      -- with rrfb
      WHEN i.rrfb
      THEN    CASE
      WHEN COALESCE(w.ft_lanes,w.tf_lanes,",
      secondary_lanes,
      ") = 2
      THEN    CASE
      WHEN COALESCE(w.speed_limit,",
      secondary_speed,
      ") > 70 THEN TRUE
      ELSE FALSE
      END
      WHEN COALESCE(w.ft_lanes,w.tf_lanes,",
      secondary_lanes,
      ") < 2
      THEN    CASE
      WHEN COALESCE(w.speed_limit,",
      secondary_speed,
      ") > 60
      THEN TRUE
      ELSE FALSE
      END
      END
      
      -- without rrfb
      ELSE        CASE
      WHEN COALESCE(w.ft_lanes,w.tf_lanes,",
      secondary_lanes,
      ") = 2
      THEN    CASE
      WHEN COALESCE(w.speed_limit,",
      secondary_speed,
      ") > 50 THEN TRUE
      ELSE FALSE
      END
      WHEN COALESCE(w.ft_lanes,w.tf_lanes,",
      secondary_lanes,
      ") < 2
      THEN    CASE
      WHEN COALESCE(w.speed_limit,",
      secondary_speed,
      ") > 50
      THEN TRUE
      ELSE FALSE
      END
      END
      END
      END
      );
      
      
      -- tf
      UPDATE  received.sa_ways
      SET     tf_int_stress = 3
      FROM    received.sa_ways_int i
      WHERE   functional_class = 'tertiary'
      AND     received.sa_ways.intersection_from = i.int_id
      AND     NOT i.signalized
      AND     NOT i.stops
      AND     EXISTS (
      SELECT  1
      FROM    received.sa_ways w
      WHERE   i.int_id IN (w.intersection_to,w.intersection_from)
      AND     COALESCE(received.sa_ways.name,'a') != COALESCE(w.name,'b')
      AND     CASE
      WHEN w.functional_class IN ('motorway','trunk') THEN TRUE
      
      -- two way primary
      WHEN w.functional_class = 'primary' AND w.one_way IS NULL
      THEN    CASE
      WHEN COALESCE(w.ft_lanes,",
      primary_lanes,
      ") + COALESCE(w.tf_lanes,",
      primary_lanes,
      ") > 4 THEN TRUE
      
      -- with rrfb
      WHEN i.rrfb
      THEN    CASE
      WHEN COALESCE(w.ft_lanes,",
      primary_lanes,
      ") + COALESCE(w.tf_lanes,",
      primary_lanes,
      ") = 4
      THEN    CASE
      WHEN COALESCE(w.speed_limit,",
      primary_speed,
      ") > 70 THEN TRUE
      WHEN COALESCE(w.speed_limit,",
      primary_speed,
      ") > 50
      THEN    CASE
      WHEN i.island THEN FALSE
      ELSE TRUE
      END
      ELSE FALSE
      END
      WHEN COALESCE(w.ft_lanes,",
      primary_lanes,
      ") + COALESCE(w.tf_lanes,",
      primary_lanes,
      ") < 4
      THEN    CASE
      WHEN COALESCE(w.speed_limit,",
      primary_speed,
      ") > 60
      THEN    CASE
      WHEN i.island THEN FALSE
      ELSE TRUE
      END
      ELSE FALSE
      END
      END
      
      -- without rrfb
      ELSE        CASE
      WHEN COALESCE(w.ft_lanes,",
      primary_lanes,
      ") + COALESCE(w.tf_lanes,",
      primary_lanes,
      ") = 4
      THEN    CASE
      WHEN COALESCE(w.speed_limit,",
      primary_speed,
      ") > 50 THEN TRUE
      WHEN COALESCE(w.speed_limit,",
      primary_speed,
      ") = 50
      THEN    CASE
      WHEN i.island THEN FALSE
      ELSE TRUE
      END
      ELSE FALSE
      END
      WHEN COALESCE(w.ft_lanes,",
      primary_lanes,
      ") + COALESCE(w.tf_lanes,",
      primary_lanes,
      ") < 4
      THEN    CASE
      WHEN COALESCE(w.speed_limit,",
      primary_speed,
      ") > 50
      THEN    CASE
      WHEN i.island THEN FALSE
      ELSE TRUE
      END
      ELSE FALSE
      END
      END
      END
      
      -- one way primary
      WHEN w.functional_class = 'primary' AND w.one_way IS NOT NULL
      THEN    CASE
      WHEN COALESCE(w.ft_lanes,w.tf_lanes,",
      primary_lanes,
      ") > 2 THEN TRUE
      
      -- with rrfb
      WHEN i.rrfb
      THEN    CASE
      WHEN COALESCE(w.ft_lanes,w.tf_lanes,",
      primary_lanes,
      ") = 2
      THEN    CASE
      WHEN COALESCE(w.speed_limit,",
      primary_speed,
      ") > 70 THEN TRUE
      ELSE FALSE
      END
      WHEN COALESCE(w.ft_lanes,w.tf_lanes,",
      primary_lanes,
      ") < 2
      THEN    CASE
      WHEN COALESCE(w.speed_limit,",
      primary_speed,
      ") > 60 THEN TRUE
      ELSE FALSE
      END
      END
      
      -- without rrfb
      ELSE        CASE
      WHEN COALESCE(w.ft_lanes,w.tf_lanes,",
      primary_lanes,
      ") = 2
      THEN    CASE
      WHEN COALESCE(w.speed_limit,",
      primary_speed,
      ") > 50 THEN TRUE
      ELSE FALSE
      END
      WHEN COALESCE(w.ft_lanes,w.tf_lanes,",
      primary_lanes,
      ") < 2
      THEN    CASE
      WHEN COALESCE(w.speed_limit,",
      primary_speed,
      ") > 50 THEN TRUE
      ELSE FALSE
      END
      END
      END
      
      -- two way secondary
      WHEN w.functional_class = 'secondary' AND w.one_way IS NULL
      THEN    CASE
      WHEN COALESCE(w.ft_lanes,",
      secondary_lanes,
      ") + COALESCE(w.tf_lanes,",
      secondary_lanes,
      ") > 4 THEN TRUE
      
      -- with rrfb
      WHEN i.rrfb
      THEN    CASE
      WHEN COALESCE(w.ft_lanes,",
      secondary_lanes,
      ") + COALESCE(w.tf_lanes,",
      secondary_lanes,
      ") = 4
      THEN    CASE
      WHEN COALESCE(w.speed_limit,",
      secondary_speed,
      ") > 70 THEN TRUE
      WHEN COALESCE(w.speed_limit,",
      secondary_speed,
      ") > 50
      THEN    CASE
      WHEN i.island THEN FALSE
      ELSE TRUE
      END
      ELSE FALSE
      END
      WHEN COALESCE(w.ft_lanes,",
      secondary_lanes,
      ") + COALESCE(w.tf_lanes,",
      secondary_lanes,
      ") < 4
      THEN    CASE
      WHEN COALESCE(w.speed_limit,",
      secondary_speed,
      ") > 60
      THEN    CASE
      WHEN i.island THEN FALSE
      ELSE TRUE
      END
      ELSE FALSE
      END
      END
      
      -- without rrfb
      ELSE        CASE
      WHEN COALESCE(w.ft_lanes,",
      secondary_lanes,
      ") + COALESCE(w.tf_lanes,",
      secondary_lanes,
      ") = 4
      THEN    CASE
      WHEN COALESCE(w.speed_limit,",
      secondary_speed,
      ") > 50 THEN TRUE
      WHEN COALESCE(w.speed_limit,",
      secondary_speed,
      ") = 50
      THEN    CASE
      WHEN i.island THEN FALSE
      ELSE TRUE
      END
      ELSE FALSE
      END
      WHEN COALESCE(w.ft_lanes,",
      secondary_lanes,
      ") + COALESCE(w.tf_lanes,",
      secondary_lanes,
      ") < 4
      THEN    CASE
      WHEN COALESCE(w.speed_limit,",
      secondary_speed,
      ") > 50
      THEN    CASE
      WHEN i.island THEN FALSE
      ELSE TRUE
      END
      ELSE FALSE
      END
      END
      END
      
      -- one way secondary
      WHEN w.functional_class = 'secondary' AND w.one_way IS NOT NULL
      THEN    CASE
      WHEN COALESCE(w.ft_lanes,w.tf_lanes,",
      secondary_lanes,
      ") > 2 THEN TRUE
      
      -- with rrfb
      WHEN i.rrfb
      THEN    CASE
      WHEN COALESCE(w.ft_lanes,w.tf_lanes,",
      secondary_lanes,
      ") = 2
      THEN    CASE
      WHEN COALESCE(w.speed_limit,",
      secondary_speed,
      ") > 70 THEN TRUE
      ELSE FALSE
      END
      WHEN COALESCE(w.ft_lanes,w.tf_lanes,",
      secondary_lanes,
      ") < 2
      THEN    CASE
      WHEN COALESCE(w.speed_limit,",
      secondary_speed,
      ") > 60
      THEN TRUE
      ELSE FALSE
      END
      END
      
      -- without rrfb
      ELSE        CASE
      WHEN COALESCE(w.ft_lanes,w.tf_lanes,",
      secondary_lanes,
      ") = 2
      THEN    CASE
      WHEN COALESCE(w.speed_limit,",
      secondary_speed,
      ") > 50 THEN TRUE
      ELSE FALSE
      END
      WHEN COALESCE(w.ft_lanes,w.tf_lanes,",
      secondary_lanes,
      ") < 2
      THEN    CASE
      WHEN COALESCE(w.speed_limit,",
      secondary_speed,
      ") > 50
      THEN TRUE
      ELSE FALSE
      END
      END
      END
      END
      );
      
      "
      ),
    connection = connection
      )
}

stress_lower_int <- function(primary_speed,
                             secondary_speed,
                             tertiary_speed,
                             primary_lanes,
                             secondary_lanes,
                             tertiary_lanes)
{
  sqldf(
    paste0(
      "
      UPDATE  received.sa_ways SET ft_int_stress = 1, tf_int_stress = 1
      WHERE   functional_class IN ('residential','unclassified','living_street','track','path');
      
      -- ft
      UPDATE  received.sa_ways
      SET     ft_int_stress = 3
      FROM    received.sa_ways_int i
      WHERE   functional_class IN ('residential','unclassified','living_street','track','path')
      AND     received.sa_ways.intersection_to = i.int_id
      AND     NOT i.signalized
      AND     NOT i.stops
      AND     EXISTS (
      SELECT  1
      FROM    received.sa_ways w
      WHERE   i.int_id IN (w.intersection_to,w.intersection_from)
      AND     COALESCE(received.sa_ways.name,'a') != COALESCE(w.name,'b')
      AND     CASE
      WHEN w.functional_class IN ('motorway','trunk') THEN TRUE
      
      -- two way primary
      WHEN w.functional_class = 'primary' AND w.one_way IS NULL
      THEN    CASE
      WHEN COALESCE(w.ft_lanes,",
      primary_lanes,
      ") + COALESCE(w.tf_lanes,",
      primary_lanes,
      ") > 4 THEN TRUE
      
      -- with rrfb
      WHEN i.rrfb
      THEN    CASE
      WHEN COALESCE(w.ft_lanes,",
      primary_lanes,
      ") + COALESCE(w.tf_lanes,",
      primary_lanes,
      ") = 4
      THEN    CASE
      WHEN COALESCE(w.speed_limit,",
      primary_speed,
      ") > 70 THEN TRUE
      WHEN COALESCE(w.speed_limit,",
      primary_speed,
      ") > 50
      THEN    CASE
      WHEN i.island THEN FALSE
      ELSE TRUE
      END
      ELSE FALSE
      END
      WHEN COALESCE(w.ft_lanes,",
      primary_lanes,
      ") + COALESCE(w.tf_lanes,",
      primary_lanes,
      ") < 4
      THEN    CASE
      WHEN COALESCE(w.speed_limit,",
      primary_speed,
      ") > 60
      THEN    CASE
      WHEN i.island THEN FALSE
      ELSE TRUE
      END
      ELSE FALSE
      END
      END
      
      -- without rrfb
      ELSE        CASE
      WHEN COALESCE(w.ft_lanes,",
      primary_lanes,
      ") + COALESCE(w.tf_lanes,",
      primary_lanes,
      ") = 4
      THEN    CASE
      WHEN COALESCE(w.speed_limit,",
      primary_speed,
      ") > 50 THEN TRUE
      WHEN COALESCE(w.speed_limit,",
      primary_speed,
      ") = 50
      THEN    CASE
      WHEN i.island THEN FALSE
      ELSE TRUE
      END
      ELSE FALSE
      END
      WHEN COALESCE(w.ft_lanes,",
      primary_lanes,
      ") + COALESCE(w.tf_lanes,",
      primary_lanes,
      ") < 4
      THEN    CASE
      WHEN COALESCE(w.speed_limit,",
      primary_speed,
      ") > 50
      THEN    CASE
      WHEN i.island THEN FALSE
      ELSE TRUE
      END
      ELSE FALSE
      END
      END
      END
      
      -- one way primary
      WHEN w.functional_class = 'primary' AND w.one_way IS NOT NULL
      THEN    CASE
      WHEN COALESCE(w.ft_lanes,w.tf_lanes,",
      primary_lanes,
      ") > 2 THEN TRUE
      
      -- with rrfb
      WHEN i.rrfb
      THEN    CASE
      WHEN COALESCE(w.ft_lanes,w.tf_lanes,",
      primary_lanes,
      ") = 2
      THEN    CASE
      WHEN COALESCE(w.speed_limit,",
      primary_speed,
      ") > 70 THEN TRUE
      ELSE FALSE
      END
      WHEN COALESCE(w.ft_lanes,w.tf_lanes,",
      primary_lanes,
      ") < 2
      THEN    CASE
      WHEN COALESCE(w.speed_limit,",
      primary_speed,
      ") > 60 THEN TRUE
      ELSE FALSE
      END
      END
      
      -- without rrfb
      ELSE        CASE
      WHEN COALESCE(w.ft_lanes,w.tf_lanes,",
      primary_lanes,
      ") = 2
      THEN    CASE
      WHEN COALESCE(w.speed_limit,",
      primary_speed,
      ") > 50 THEN TRUE
      ELSE FALSE
      END
      WHEN COALESCE(w.ft_lanes,w.tf_lanes,",
      primary_lanes,
      ") < 2
      THEN    CASE
      WHEN COALESCE(w.speed_limit,",
      primary_speed,
      ") > 50 THEN TRUE
      ELSE FALSE
      END
      END
      END
      
      -- two way secondary
      WHEN w.functional_class = 'secondary' AND w.one_way IS NULL
      THEN    CASE
      WHEN COALESCE(w.ft_lanes,",
      secondary_lanes,
      ") + COALESCE(w.tf_lanes,",
      secondary_lanes,
      ") > 4 THEN TRUE
      
      -- with rrfb
      WHEN i.rrfb
      THEN    CASE
      WHEN COALESCE(w.ft_lanes,",
      secondary_lanes,
      ") + COALESCE(w.tf_lanes,",
      secondary_lanes,
      ") = 4
      THEN    CASE
      WHEN COALESCE(w.speed_limit,",
      secondary_speed,
      ") > 70 THEN TRUE
      WHEN COALESCE(w.speed_limit,",
      secondary_speed,
      ") > 50
      THEN    CASE
      WHEN i.island THEN FALSE
      ELSE TRUE
      END
      ELSE FALSE
      END
      WHEN COALESCE(w.ft_lanes,",
      secondary_lanes,
      ") + COALESCE(w.tf_lanes,",
      secondary_lanes,
      ") < 4
      THEN    CASE
      WHEN COALESCE(w.speed_limit,",
      secondary_speed,
      ") > 60
      THEN    CASE
      WHEN i.island THEN FALSE
      ELSE TRUE
      END
      ELSE FALSE
      END
      END
      
      -- without rrfb
      ELSE        CASE
      WHEN COALESCE(w.ft_lanes,",
      secondary_lanes,
      ") + COALESCE(w.tf_lanes,",
      secondary_lanes,
      ") = 4
      THEN    CASE
      WHEN COALESCE(w.speed_limit,",
      secondary_speed,
      ") > 50 THEN TRUE
      WHEN COALESCE(w.speed_limit,",
      secondary_speed,
      ") = 50
      THEN    CASE
      WHEN i.island THEN FALSE
      ELSE TRUE
      END
      ELSE FALSE
      END
      WHEN COALESCE(w.ft_lanes,",
      secondary_lanes,
      ") + COALESCE(w.tf_lanes,",
      secondary_lanes,
      ") < 4
      THEN    CASE
      WHEN COALESCE(w.speed_limit,",
      secondary_speed,
      ") > 50
      THEN    CASE
      WHEN i.island THEN FALSE
      ELSE TRUE
      END
      ELSE FALSE
      END
      END
      END
      
      -- one way secondary
      WHEN w.functional_class = 'secondary' AND w.one_way IS NOT NULL
      THEN    CASE
      WHEN COALESCE(w.ft_lanes,w.tf_lanes,",
      secondary_lanes,
      ") > 2 THEN TRUE
      
      -- with rrfb
      WHEN i.rrfb
      THEN    CASE
      WHEN COALESCE(w.ft_lanes,w.tf_lanes,",
      secondary_lanes,
      ") = 2
      THEN    CASE
      WHEN COALESCE(w.speed_limit,",
      secondary_speed,
      ") > 70 THEN TRUE
      ELSE FALSE
      END
      WHEN COALESCE(w.ft_lanes,w.tf_lanes,",
      secondary_lanes,
      ") < 2
      THEN    CASE
      WHEN COALESCE(w.speed_limit,",
      secondary_speed,
      ") > 60
      THEN TRUE
      ELSE FALSE
      END
      END
      
      -- without rrfb
      ELSE        CASE
      WHEN COALESCE(w.ft_lanes,w.tf_lanes,",
      secondary_lanes,
      ") = 2
      THEN    CASE
      WHEN COALESCE(w.speed_limit,",
      secondary_speed,
      ") > 50 THEN TRUE
      ELSE FALSE
      END
      WHEN COALESCE(w.ft_lanes,w.tf_lanes,",
      secondary_lanes,
      ") < 2
      THEN    CASE
      WHEN COALESCE(w.speed_limit,",
      secondary_speed,
      ") > 50
      THEN TRUE
      ELSE FALSE
      END
      END
      END
      
      -- two way tertiary
      WHEN w.functional_class = 'tertiary' AND w.one_way IS NULL
      THEN    CASE
      WHEN COALESCE(w.ft_lanes,",
      tertiary_lanes,
      ") + COALESCE(w.tf_lanes,",
      tertiary_lanes,
      ") > 4 THEN TRUE
      
      -- with rrfb
      WHEN i.rrfb
      THEN    CASE
      WHEN COALESCE(w.ft_lanes,",
      tertiary_lanes,
      ") + COALESCE(w.tf_lanes,",
      tertiary_lanes,
      ") = 4
      THEN    CASE
      WHEN COALESCE(w.speed_limit,",
      tertiary_speed,
      ") > 70 THEN TRUE
      WHEN COALESCE(w.speed_limit,",
      tertiary_speed,
      ") > 50
      THEN    CASE
      WHEN i.island THEN FALSE
      ELSE TRUE
      END
      ELSE FALSE
      END
      WHEN COALESCE(w.ft_lanes,",
      tertiary_lanes,
      ") + COALESCE(w.tf_lanes,",
      tertiary_lanes,
      ") < 4
      THEN    CASE
      WHEN COALESCE(w.speed_limit,",
      tertiary_speed,
      ") > 60
      THEN    CASE
      WHEN i.island THEN FALSE
      ELSE TRUE
      END
      ELSE FALSE
      END
      END
      
      -- without rrfb
      ELSE        CASE
      WHEN COALESCE(w.ft_lanes,",
      tertiary_lanes,
      ") + COALESCE(w.tf_lanes,",
      tertiary_lanes,
      ") = 4
      THEN    CASE
      WHEN COALESCE(w.speed_limit,",
      tertiary_speed,
      ") > 50 THEN TRUE
      WHEN COALESCE(w.speed_limit,",
      tertiary_speed,
      ") = 50
      THEN    CASE
      WHEN i.island THEN FALSE
      ELSE TRUE
      END
      ELSE FALSE
      END
      WHEN COALESCE(w.ft_lanes,",
      tertiary_lanes,
      ") + COALESCE(w.tf_lanes,",
      tertiary_lanes,
      ") < 4
      THEN    CASE
      WHEN COALESCE(w.speed_limit,",
      tertiary_speed,
      ") > 50
      THEN    CASE
      WHEN i.island THEN FALSE
      ELSE TRUE
      END
      ELSE FALSE
      END
      END
      END
      
      -- one way tertiary
      WHEN w.functional_class = 'tertiary' AND w.one_way IS NOT NULL
      THEN    CASE
      WHEN COALESCE(w.ft_lanes,w.tf_lanes,",
      tertiary_lanes,
      ") > 2 THEN TRUE
      
      -- with rrfb
      WHEN i.rrfb
      THEN    CASE
      WHEN COALESCE(w.ft_lanes,w.tf_lanes,",
      tertiary_lanes,
      ") = 2
      THEN    CASE
      WHEN COALESCE(w.speed_limit,",
      tertiary_speed,
      ") > 70 THEN TRUE
      ELSE FALSE
      END
      WHEN COALESCE(w.ft_lanes,w.tf_lanes,",
      tertiary_lanes,
      ") < 2
      THEN    CASE
      WHEN COALESCE(w.speed_limit,",
      tertiary_speed,
      ") > 60
      THEN TRUE
      ELSE FALSE
      END
      END
      
      -- without rrfb
      ELSE        CASE
      WHEN COALESCE(w.ft_lanes,w.tf_lanes,",
      tertiary_lanes,
      ") = 2
      THEN    CASE
      WHEN COALESCE(w.speed_limit,",
      tertiary_speed,
      ") > 50 THEN TRUE
      ELSE FALSE
      END
      WHEN COALESCE(w.ft_lanes,w.tf_lanes,",
      tertiary_lanes,
      ") < 2
      THEN    CASE
      WHEN COALESCE(w.speed_limit,",
      tertiary_speed,
      ") > 50
      THEN TRUE
      ELSE FALSE
      END
      END
      END
      END
      );
      
      
      -- tf
      UPDATE  received.sa_ways
      SET     tf_int_stress = 3
      FROM    received.sa_ways_int i
      WHERE   functional_class IN ('residential','unclassified','living_street','track','path')
      AND     received.sa_ways.intersection_from = i.int_id
      AND     NOT i.signalized
      AND     NOT i.stops
      AND     EXISTS (
      SELECT  1
      FROM    received.sa_ways w
      WHERE   i.int_id IN (w.intersection_to,w.intersection_from)
      AND     COALESCE(received.sa_ways.name,'a') != COALESCE(w.name,'b')
      AND     CASE
      WHEN w.functional_class IN ('motorway','trunk') THEN TRUE
      
      -- two way primary
      WHEN w.functional_class = 'primary' AND w.one_way IS NULL
      THEN    CASE
      WHEN COALESCE(w.ft_lanes,",
      primary_lanes,
      ") + COALESCE(w.tf_lanes,",
      primary_lanes,
      ") > 4 THEN TRUE
      
      -- with rrfb
      WHEN i.rrfb
      THEN    CASE
      WHEN COALESCE(w.ft_lanes,",
      primary_lanes,
      ") + COALESCE(w.tf_lanes,",
      primary_lanes,
      ") = 4
      THEN    CASE
      WHEN COALESCE(w.speed_limit,",
      primary_speed,
      ") > 70 THEN TRUE
      WHEN COALESCE(w.speed_limit,",
      primary_speed,
      ") > 50
      THEN    CASE
      WHEN i.island THEN FALSE
      ELSE TRUE
      END
      ELSE FALSE
      END
      WHEN COALESCE(w.ft_lanes,",
      primary_lanes,
      ") + COALESCE(w.tf_lanes,",
      primary_lanes,
      ") < 4
      THEN    CASE
      WHEN COALESCE(w.speed_limit,",
      primary_speed,
      ") > 60
      THEN    CASE
      WHEN i.island THEN FALSE
      ELSE TRUE
      END
      ELSE FALSE
      END
      END
      
      -- without rrfb
      ELSE        CASE
      WHEN COALESCE(w.ft_lanes,",
      primary_lanes,
      ") + COALESCE(w.tf_lanes,",
      primary_lanes,
      ") = 4
      THEN    CASE
      WHEN COALESCE(w.speed_limit,",
      primary_speed,
      ") > 50 THEN TRUE
      WHEN COALESCE(w.speed_limit,",
      primary_speed,
      ") = 50
      THEN    CASE
      WHEN i.island THEN FALSE
      ELSE TRUE
      END
      ELSE FALSE
      END
      WHEN COALESCE(w.ft_lanes,",
      primary_lanes,
      ") + COALESCE(w.tf_lanes,",
      primary_lanes,
      ") < 4
      THEN    CASE
      WHEN COALESCE(w.speed_limit,",
      primary_speed,
      ") > 50
      THEN    CASE
      WHEN i.island THEN FALSE
      ELSE TRUE
      END
      ELSE FALSE
      END
      END
      END
      
      -- one way primary
      WHEN w.functional_class = 'primary' AND w.one_way IS NOT NULL
      THEN    CASE
      WHEN COALESCE(w.ft_lanes,w.tf_lanes,",
      primary_lanes,
      ") > 2 THEN TRUE
      
      -- with rrfb
      WHEN i.rrfb
      THEN    CASE
      WHEN COALESCE(w.ft_lanes,w.tf_lanes,",
      primary_lanes,
      ") = 2
      THEN    CASE
      WHEN COALESCE(w.speed_limit,",
      primary_speed,
      ") > 70 THEN TRUE
      ELSE FALSE
      END
      WHEN COALESCE(w.ft_lanes,w.tf_lanes,",
      primary_lanes,
      ") < 2
      THEN    CASE
      WHEN COALESCE(w.speed_limit,",
      primary_speed,
      ") > 60 THEN TRUE
      ELSE FALSE
      END
      END
      
      -- without rrfb
      ELSE        CASE
      WHEN COALESCE(w.ft_lanes,w.tf_lanes,",
      primary_lanes,
      ") = 2
      THEN    CASE
      WHEN COALESCE(w.speed_limit,",
      primary_speed,
      ") > 50 THEN TRUE
      ELSE FALSE
      END
      WHEN COALESCE(w.ft_lanes,w.tf_lanes,",
      primary_lanes,
      ") < 2
      THEN    CASE
      WHEN COALESCE(w.speed_limit,",
      primary_speed,
      ") > 50 THEN TRUE
      ELSE FALSE
      END
      END
      END
      
      -- two way secondary
      WHEN w.functional_class = 'secondary' AND w.one_way IS NULL
      THEN    CASE
      WHEN COALESCE(w.ft_lanes,",
      secondary_lanes,
      ") + COALESCE(w.tf_lanes,",
      secondary_lanes,
      ") > 4 THEN TRUE
      
      -- with rrfb
      WHEN i.rrfb
      THEN    CASE
      WHEN COALESCE(w.ft_lanes,",
      secondary_lanes,
      ") + COALESCE(w.tf_lanes,",
      secondary_lanes,
      ") = 4
      THEN    CASE
      WHEN COALESCE(w.speed_limit,",
      secondary_speed,
      ") > 70 THEN TRUE
      WHEN COALESCE(w.speed_limit,",
      secondary_speed,
      ") > 50
      THEN    CASE
      WHEN i.island THEN FALSE
      ELSE TRUE
      END
      ELSE FALSE
      END
      WHEN COALESCE(w.ft_lanes,",
      secondary_lanes,
      ") + COALESCE(w.tf_lanes,",
      secondary_lanes,
      ") < 4
      THEN    CASE
      WHEN COALESCE(w.speed_limit,",
      secondary_speed,
      ") > 60
      THEN    CASE
      WHEN i.island THEN FALSE
      ELSE TRUE
      END
      ELSE FALSE
      END
      END
      
      -- without rrfb
      ELSE        CASE
      WHEN COALESCE(w.ft_lanes,",
      secondary_lanes,
      ") + COALESCE(w.tf_lanes,",
      secondary_lanes,
      ") = 4
      THEN    CASE
      WHEN COALESCE(w.speed_limit,",
      secondary_speed,
      ") > 50 THEN TRUE
      WHEN COALESCE(w.speed_limit,",
      secondary_speed,
      ") = 50
      THEN    CASE
      WHEN i.island THEN FALSE
      ELSE TRUE
      END
      ELSE FALSE
      END
      WHEN COALESCE(w.ft_lanes,",
      secondary_lanes,
      ") + COALESCE(w.tf_lanes,",
      secondary_lanes,
      ") < 4
      THEN    CASE
      WHEN COALESCE(w.speed_limit,",
      secondary_speed,
      ") > 50
      THEN    CASE
      WHEN i.island THEN FALSE
      ELSE TRUE
      END
      ELSE FALSE
      END
      END
      END
      
      -- one way secondary
      WHEN w.functional_class = 'secondary' AND w.one_way IS NOT NULL
      THEN    CASE
      WHEN COALESCE(w.ft_lanes,w.tf_lanes,",
      secondary_lanes,
      ") > 2 THEN TRUE
      
      -- with rrfb
      WHEN i.rrfb
      THEN    CASE
      WHEN COALESCE(w.ft_lanes,w.tf_lanes,",
      secondary_lanes,
      ") = 2
      THEN    CASE
      WHEN COALESCE(w.speed_limit,",
      secondary_speed,
      ") > 70 THEN TRUE
      ELSE FALSE
      END
      WHEN COALESCE(w.ft_lanes,w.tf_lanes,",
      secondary_lanes,
      ") < 2
      THEN    CASE
      WHEN COALESCE(w.speed_limit,",
      secondary_speed,
      ") > 60
      THEN TRUE
      ELSE FALSE
      END
      END
      
      -- without rrfb
      ELSE        CASE
      WHEN COALESCE(w.ft_lanes,w.tf_lanes,",
      secondary_lanes,
      ") = 2
      THEN    CASE
      WHEN COALESCE(w.speed_limit,",
      secondary_speed,
      ") > 50 THEN TRUE
      ELSE FALSE
      END
      WHEN COALESCE(w.ft_lanes,w.tf_lanes,",
      secondary_lanes,
      ") < 2
      THEN    CASE
      WHEN COALESCE(w.speed_limit,",
      secondary_speed,
      ") > 50
      THEN TRUE
      ELSE FALSE
      END
      END
      END
      
      -- two way tertiary
      WHEN w.functional_class = 'tertiary' AND w.one_way IS NULL
      THEN    CASE
      WHEN COALESCE(w.ft_lanes,",
      tertiary_lanes,
      ") + COALESCE(w.tf_lanes,",
      tertiary_lanes,
      ") > 4 THEN TRUE
      
      -- with rrfb
      WHEN i.rrfb
      THEN    CASE
      WHEN COALESCE(w.ft_lanes,",
      tertiary_lanes,
      ") + COALESCE(w.tf_lanes,",
      tertiary_lanes,
      ") = 4
      THEN    CASE
      WHEN COALESCE(w.speed_limit,",
      tertiary_speed,
      ") > 70 THEN TRUE
      WHEN COALESCE(w.speed_limit,",
      tertiary_speed,
      ") > 50
      THEN    CASE
      WHEN i.island THEN FALSE
      ELSE TRUE
      END
      ELSE FALSE
      END
      WHEN COALESCE(w.ft_lanes,",
      tertiary_lanes,
      ") + COALESCE(w.tf_lanes,",
      tertiary_lanes,
      ") < 4
      THEN    CASE
      WHEN COALESCE(w.speed_limit,",
      tertiary_speed,
      ") > 60
      THEN    CASE
      WHEN i.island THEN FALSE
      ELSE TRUE
      END
      ELSE FALSE
      END
      END
      
      -- without rrfb
      ELSE        CASE
      WHEN COALESCE(w.ft_lanes,",
      tertiary_lanes,
      ") + COALESCE(w.tf_lanes,",
      tertiary_lanes,
      ") = 4
      THEN    CASE
      WHEN COALESCE(w.speed_limit,",
      tertiary_speed,
      ") > 50 THEN TRUE
      WHEN COALESCE(w.speed_limit,",
      tertiary_speed,
      ") = 50
      THEN    CASE
      WHEN i.island THEN FALSE
      ELSE TRUE
      END
      ELSE FALSE
      END
      WHEN COALESCE(w.ft_lanes,",
      tertiary_lanes,
      ") + COALESCE(w.tf_lanes,",
      tertiary_lanes,
      ") < 4
      THEN    CASE
      WHEN COALESCE(w.speed_limit,",
      tertiary_speed,
      ") > 50
      THEN    CASE
      WHEN i.island THEN FALSE
      ELSE TRUE
      END
      ELSE FALSE
      END
      END
      END
      
      -- one way tertiary
      WHEN w.functional_class = 'tertiary' AND w.one_way IS NOT NULL
      THEN    CASE
      WHEN COALESCE(w.ft_lanes,w.tf_lanes,",
      tertiary_lanes,
      ") > 2 THEN TRUE
      
      -- with rrfb
      WHEN i.rrfb
      THEN    CASE
      WHEN COALESCE(w.ft_lanes,w.tf_lanes,",
      tertiary_lanes,
      ") = 2
      THEN    CASE
      WHEN COALESCE(w.speed_limit,",
      tertiary_speed,
      ") > 70 THEN TRUE
      ELSE FALSE
      END
      WHEN COALESCE(w.ft_lanes,w.tf_lanes,",
      tertiary_lanes,
      ") < 2
      THEN    CASE
      WHEN COALESCE(w.speed_limit,",
      tertiary_speed,
      ") > 60
      THEN TRUE
      ELSE FALSE
      END
      END
      
      -- without rrfb
      ELSE        CASE
      WHEN COALESCE(w.ft_lanes,w.tf_lanes,",
      tertiary_lanes,
      ") = 2
      THEN    CASE
      WHEN COALESCE(w.speed_limit,",
      tertiary_speed,
      ") > 50 THEN TRUE
      ELSE FALSE
      END
      WHEN COALESCE(w.ft_lanes,w.tf_lanes,",
      tertiary_lanes,
      ") < 2
      THEN    CASE
      WHEN COALESCE(w.speed_limit,",
      tertiary_speed,
      ") > 50
      THEN TRUE
      ELSE FALSE
      END
      END
      END
      END
      );
      
      "
      ),
    connection = connection
      )
}