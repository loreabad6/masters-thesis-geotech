## ---- connection --------------
library(DBI)
library(RPostgreSQL)
library(sqldf)
library(readr)
library(utils)
library(sf)
library(dplyr)

# Call useful functions
source("scripts/utils.R")

# Record start time
start <- Sys.time()

# LOAD POSTGRESQL DRIVER
driver <- dbDriver("PostgreSQL")
# CREATE CONNECTION TO THE POSTGRESQL DATABASE
# THE CONNECTION VARIABLE WILL BE USED FOR ALL FURTHER OPERATIONS
connection <-  dbConnect(
  driver, 
  dbname = db_name,
  host = local_host, 
  port = port_num,
  user = user_name, 
  password = db_pass
)

if(!dbExistsTable(connection, "test")) 
  stop("The connection to the database was not possible.")

# Prepare database
dbSendQuery(
  connection,
  "
  CREATE EXTENSION IF NOT EXISTS hstore;
  CREATE EXTENSION IF NOT EXISTS postgis;
  CREATE EXTENSION IF NOT EXISTS pgrouting;
  CREATE SCHEMA IF NOT EXISTS destinations;
  CREATE SCHEMA IF NOT EXISTS generated;
  CREATE SCHEMA IF NOT EXISTS received;
  CREATE SCHEMA IF NOT EXISTS results;
  "
)

## ---- area --------------
library(DBI)
library(RPostgreSQL)
library(sqldf)
library(readr)
library(utils)
library(sf)
library(dplyr)

# Obtain boundary for analysis.
ifelse(
  area_type == "ttwa",
  boundary <- sa_ttwa(
    study_area = sa_name, 
    crs = sa_crs, 
    conn = connection
  ),
  ifelse(
    area_type == "osm",
    boundary <- sa_bb(
      study_area = sa_name,
      dist = NULL,
      crs = sa_crs, 
      conn = connection
    ),
    stop("The area_type provided can only be either 'ttwa' for the UK or 'osm'.")
  )
)

# DOWNLOAD THE DATA FROM OSM WITH OVERPASS API
sa_download(conn = connection)

osm_file <- file.path(getwd(),'temp','overpass.osm')
osm_size <- file.size(osm_file)/1000000

# CREATE A NEW TEMPORAL DIRECTORY TO DOWNLOAD INFO
cd <- getwd()
if(!file.exists(file.path(cd,'temp'))){dir.create(file.path(cd,'temp'))}

# ESTABLISH THE NAME OF THE FILES 
pfbstyle_file <- file.path(cd,'temp','pfb.style')
mapconfig_file <- file.path(cd,"temp","mapconfig.xml")
mapconfigbikes_file <- file.path(cd,"temp","mapconfig_for_bicycles.xml")

# CHECK IF THEY ARE DOWNLOADED
if(
  !file.exists(file.path(pfbstyle_file)) & 
  !file.exists(file.path(mapconfig_file)) &
  !file.exists(file.path(mapconfigbikes_file))
){
  # ESTABLISH THE URLS
  pfbstyle_url <- "https://raw.githubusercontent.com/azavea/pfb-network-connectivity/develop/src/analysis/import/pfb.style"
  
  mapconfig_url <- "https://raw.githubusercontent.com/pgRouting/osm2pgrouting/master/mapconfig.xml"
  
  mapconfigbikes_url <- 
    "https://raw.githubusercontent.com/pgRouting/osm2pgrouting/master/mapconfig_for_bicycles.xml"
  
  # REQUEST THE DATA
  download.file(url = pfbstyle_url, destfile = pfbstyle_file)
  download.file(url = mapconfig_url, destfile = mapconfig_file)
  download.file(url = mapconfigbikes_url, destfile = mapconfigbikes_file) 
}

# Load data to DB
system(
  command = paste(
    "osm2pgsql -c -d bna_europe -U postgres -H localhost -W --create --prefix sa_full -S",
    pfbstyle_file,
    osm_file,
    "--cache 600"
  ),
  show.output.on.console = TRUE
)

system(
  command = paste(
    "osm2pgrouting -f",
    osm_file,
    "-h localhost -d bna_europe --username postgres --schema received --prefix sa_all_ --conf",
    mapconfig_file,
    "--clean"
  ),
  show.output.on.console = TRUE
)

system(
  command = paste(
    "osm2pgrouting -f",
    osm_file,
    "-h localhost -d bna_europe --username postgres --schema received --prefix sa_all_ --conf",
    mapconfigbikes_file,
    "--clean"
  ),
  show.output.on.console = TRUE
)

# Test if the data loaded
if(
  !dbExistsTable(connection, c("received","sa_all_ways")) &
  !dbExistsTable(connection, "sa_full_line")
) stop("Create or check the password file on %APPDATA%/postgresql/pgpass.conf with the format hostname:port:database:username:password")

rm(pfbstyle_file,mapconfig_file,mapconfigbikes_file)

## ---- network ------------
library(DBI)
library(RPostgreSQL)
library(sqldf)
library(readr)
library(utils)
library(sf)
library(dplyr)

# Call stress functions
source("scripts/stress.R")

# Organize tables
organize <- sqlInterpolate(
  conn = connection,
  sql = read_file('scripts/organize_tables.sql'),
  sa_crs = sa_crs
)

dbSendQuery(connection,statement = organize)
rm(organize)

# Clip data
dbSendQuery(connection,statement = read_file('scripts/clip_data.sql'))

# Populate_ways
populate <-  sqlInterpolate(
  conn = connection,
  sql = read_file('scripts/populate_tables.sql'),
  sa_crs = sa_crs
)

dbSendQuery(connection,statement = populate)
rm(populate)

# Populate_intersections
dbSendQuery(connection,statement = read_file('scripts/populate_intersections.sql'))

# Calculate stress
dbSendQuery(connection,statement = read_file('scripts/stress1.sql'))

stress_higher_order_ways(
  class = "primary", 
  default_speed = 70, 
  default_lanes = 2, 
  default_parking = 1,
  default_parking_width = 2.5,
  default_facility_width = 1.5
)

stress_higher_order_ways(
  class = "secondary", 
  default_speed = 70, 
  default_lanes = 2, 
  default_parking = 1,
  default_parking_width = 2.5,
  default_facility_width = 1.5
)

stress_higher_order_ways(
  class = "tertiary", 
  default_speed = 50, 
  default_lanes = 1, 
  default_parking = 1,
  default_parking_width = 2.5,
  default_facility_width = 1.5
)

stress_lower_order_ways(
  class = "residential", 
  default_speed = 40, 
  default_lanes = 1, 
  default_parking = 1,
  default_roadway_width = 8
)

stress_lower_order_ways(
  class = "unclassified", 
  default_speed = 40, 
  default_lanes = 1, 
  default_parking = 1,
  default_roadway_width = 8
)

dbSendQuery(connection,statement = read_file('scripts/stress2.sql'))

stress_tertiary_int(
  primary_speed = 70,
  secondary_speed = 70,
  primary_lanes = 2,
  secondary_lanes = 2
)

stress_lower_int(
  primary_speed = 70,
  secondary_speed = 70,
  tertiary_speed = 50,
  primary_lanes = 2,
  secondary_lanes = 2,
  tertiary_lanes = 1
)

dbSendQuery(connection,statement = read_file('scripts/stress3.sql'))

# Build network
build <- sqlInterpolate(
  conn = connection,
  sql = read_file('scripts/build.sql'),
  sa_crs = sa_crs
)

dbSendQuery(connection,statement = build)
rm(build)

## ---- min_area -----------

## Call script that sorts out country cases
source("scripts/country.R")
minareadata(min_area,country)

# Load data to plot
min_area_grid <- st_read(
  dsn = connection,
  layer = c("generated","sa_pop_grid")
)

# Prepare sa_pop_grid
preppopgrid <-  sqlInterpolate(
  conn = connection,
  sql = read_file('scripts/prepare_sa_pop_grid.sql'),
  sa_crs = sa_crs
)

dbSendQuery(connection,statement = preppopgrid)
rm(preppopgrid)

## ---- reachable_roads --------------
library(DBI)
library(RPostgreSQL)
library(sqldf)
library(readr)
library(utils)
library(sf)
library(dplyr)

# Reachable high stress

dbSendQuery(connection,statement = read_file('scripts/reachable_roads_hstress1.sql'))

hstress2 <-  sqlInterpolate(
  conn = connection,
  sql = read_file('scripts/reachable_roads_hstress2.sql'),
  biking_distance = biking_distance
)

dbSendQuery(connection,statement = hstress2)
rm(hstress2)

dbSendQuery(connection,statement = read_file('scripts/reachable_roads_hstress3.sql'))

dbSendQuery(
  connection,
  statement ='VACUUM ANALYZE generated.sa_reachable_roads_high_stress'
)

# Reachable low stress

dbSendQuery(connection,statement = read_file('scripts/reachable_roads_lstress1.sql'))

lstress2 <-  sqlInterpolate(
  conn = connection,
  sql = read_file('scripts/reachable_roads_lstress2.sql'),
  biking_distance = biking_distance
)

dbSendQuery(connection,statement = lstress2)
rm(lstress2)

dbSendQuery(connection,statement = read_file('scripts/reachable_roads_lstress3.sql'))

dbSendQuery(
  connection,
  statement = 'VACUUM ANALYZE generated.sa_reachable_roads_low_stress (base_road,target_road)'
)


## ---- accessibility ----------------

## Compute connected grids
connected <-  sqlInterpolate(
  conn = connection,
  sql = read_file('scripts/connected_pop_grid.sql'),
  biking_distance = biking_distance
)

dbSendQuery(connection,statement = connected)
rm(connected)

## Establish variables to give scores to population access 
laccess <- sqlInterpolate(
  conn = connection,
  sql = read_file('scripts/low_stress_access.sql'),
  max_score = 1,
  step1 = 0.03,
  score1 = 0.1,
  step2 = 0.2,
  score2 = 0.4,
  step3 = 0.5,
  score3 = 0.8
)

dbSendQuery(connection,statement = laccess)
rm(laccess)

## Establish variables to give scores to job access 
jobaccess <- sqlInterpolate(
  conn = connection,
  sql = read_file('scripts/job_access.sql'),
  max_score = 1,
  step1 = 0.03,
  score1 = 0.1,
  step2 = 0.2,
  score2 = 0.4,
  step3 = 0.5,
  score3 = 0.8
)

dbSendQuery(connection,statement = jobaccess)
rm(jobaccess)

## Extract common destinations
dest <- sqlInterpolate(
  conn = connection,
  sql = read_file('scripts/fetch_destinations.sql'),
  sa_crs = sa_crs,
  cluster_colleges = 100,
  cluster_community_centers = 50,
  cluster_doctors = 50,
  cluster_dentists = 50,
  cluster_hospitals = 50,
  cluster_pharmacies = 50,
  cluster_parks = 50,
  cluster_retail = 50,
  cluster_transit = 75,
  cluster_universities = 150
)

dbSendQuery(connection,statement = dest)
rm(dest)

## compute access to destinations
accdest <- sqlInterpolate(
  conn = connection,
  sql = read_file('scripts/access_destinations.sql'),
  max_score = 1,
  ## Scores first group: colleges, hospitals, social services, universities
  Afirst = 0.7,
  Asecond = 0,
  Athird = 0,
  ## Scores second group: community centers, dentists, pharmacies, retail
  Bfirst = 0.4, 
  Bsecond = 0.2, 
  Bthird = 0.1,
  ## Scores third group: parks, schools
  Cfirst = 0.3,
  Csecond = 0.2, 
  Cthird = 0.2,
  ## Scores fourth group: supermarkets
  Dfirst = 0.6,
  Dsecond = 0.2, 
  Dthird = 0,
  ## Scores fifth group: trails
  Efirst = 0.7, 
  Esecond = 0.2, 
  Ethird = 0,
  min_path_length=4800, 
  min_bbox_length=3300,
  ## Scores sixth group: transit
  Ffirst = 0.6,
  Fsecond = 0,
  Fthird = 0
)

dbSendQuery(connection,statement = accdest)
rm(accdest)

## ----overall_score------------

## Compute overall access
overall <- sqlInterpolate(
  conn = connection,
  sql = read_file('scripts/overall_access.sql'),
  total = 100,
  people = 15,
  opportunity = 20,
  core_services = 20,
  retail = 15,
  recreation = 15,
  transit = 15
)

dbSendQuery(connection,statement = overall)
rm(overall)

## Compute inputs
dbSendQuery(connection,statement = read_file("scripts/score_inputs.sql"))

## Compute overall score
overallsc <- sqlInterpolate(
  conn = connection,
  sql = read_file('scripts/overall_score.sql'),
  total = 100,
  people = 15,
  opportunity = 20,
  core_services = 20,
  retail = 15,
  recreation = 15,
  transit = 15
)

dbSendQuery(connection,statement = overallsc)
rm(overallsc)

## Call data for results
bna_score_table <- dbGetQuery(connection,statement = "SELECT * FROM generated.sa_overall_scores")

### Create bna_score tables for study area on results schema

## Ways with stress network 
sqldf(
  paste0(
    "DROP TABLE IF EXISTS results.",sa_name,"_stress_network;
    CREATE TABLE results.",sa_name,"_stress_network AS
    SELECT ft_seg_stress, ft_int_stress, tf_seg_stress, tf_int_stress, geom 
    FROM received.sa_ways;"
  ),
  connection = connection
  )

## Connected population grid 
sqldf(
  paste0(
    "DROP TABLE IF EXISTS results.",sa_name,"_connected_pop_grid;
    CREATE TABLE results.",sa_name,"_connected_pop_grid AS
    SELECT * 
    FROM generated.sa_connected_pop_grid;"
  ),
  connection = connection
)

## Population grid with BNA score
sqldf(
  paste0(
    "DROP TABLE IF EXISTS results.",sa_name,"_pop_grid;
    CREATE TABLE results.",sa_name,"_pop_grid AS
      SELECT * 
      FROM generated.sa_pop_grid;"
  ),
  connection = connection
)

## Overall scores
sqldf(
  paste0(
    "DROP TABLE IF EXISTS results.",sa_name,"_overall_scores;
    CREATE TABLE results.",sa_name,"_overall_scores AS
      SELECT * 
      FROM generated.sa_overall_scores;"
  ),
  connection = connection
)

## ----display_table -------------
library(kableExtra)
bna_display <- bna_score_table %>% mutate(
  category = c(
    "Total People",
    "Employment",
    "K-12 Education",
    "Technical/vocational school",
    "Higher Education",
    "Total Opportunity",
    "Doctor offices/clinics",
    "Dentist offices",
    "Hospitals",
    "Pharmacies",
    "Supermarkets",
    "Social services",
    "Total Core Services",
    "Total Retail shopping",
    "Parks",
    "Recreational trails",
    "Community centers",
    "Total Recreation",
    "Total Transit",
    "Overall Score",
    "Population",
    "Length of Low Stress Network (km)",
    "Length of High Stress Network (km)"
  ),
  id = NULL,
  score_id = NULL,
  score = score_normalized
)

bna_display[21,5] <- round(bna_display[21,1],0)

bna_display$score_original <- NULL
bna_display$score_normalized <- NULL

bna_display <- bna_display[c(20:23,1:19),]
row.names(bna_display) <- NULL

bna_display <- bna_display %>% mutate(
  category = cell_spec(
    category,
    bold = ifelse(
      grepl("Total",category),
      T, 
      F
    )
  ),
  score = cell_spec(
    score,
    "html", 
    color = ifelse(
      score >= 54 & score <= 100,
      "#009acd",
      ifelse(
        score < 54,
        "#ff3030",
        "#666666"
      )
    ),
    popover = human_explanation
  )
)

colnames(bna_display) <- c("popover","","Score/Value")

kable(
  bna_display[2:3], 
  align = c("l","r"), 
  format = "html", 
  escape = F
) %>% 
  kable_styling(
    "hover",
    full_width = FALSE,
    position = "center"
  ) %>% 
  group_rows("People", 5, 5) %>% 
  group_rows("Opportunity", 6, 10) %>% 
  group_rows("Core Services", 11, 17) %>% 
  group_rows("Retail", 18, 18) %>%
  group_rows("Recreation", 19, 22) %>% 
  group_rows("Transit", 23, 23)

## ----duration----------------
## Log end of procedure
end <- Sys.time()
duration <- end - start

## Disconnect from DB
dbDisconnect(connection)