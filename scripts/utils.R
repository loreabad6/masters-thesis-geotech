# FUNCTION TO EXTRACT STUDY AREA BOUNDARY WITH OSM AND WRITE IT TO THE DATABASE
sa_bb <- function (study_area, dist = NULL, crs, conn){
  # GET DATA FROM OSM
  study_area_bb <- study_area %>% 
    osmdata::getbb(format_out = "sf_polygon") %>%
    sf::st_transform(crs = crs)
  
  if(!is.null(dist)){
    ## ADD A BUFFER TO THE BOUNDARY
    study_area_bb <-study_area_bb %>% 
      sf::st_buffer(dist = 0.5*dist) 
  }
  
  # DELETE EXISTING BOUNDARY
  sqldf::sqldf(
    "DROP TABLE IF EXISTS received.sa_boundary",
    connection = conn
  )
  
  # UPLOAD BOUNDARY TO POSTGRESQL DATABASE
  DBI::dbWriteTable(conn, c("received","sa_boundary"), study_area_bb)
  
  study_area_bb
}

# FUNCTION TO EXTRACT THE TTWA BOUNDARY FROM THE ONS GEOPORTAL
sa_ttwa <- function(study_area, crs, conn){
  # GET DATA FROM OSM
  study_area_bb <- study_area %>% 
    osmdata::getbb(format_out = "sf_polygon") %>%
    sf::st_transform(crs = crs)
  
  # DELETE EXISTING BOUNDARY
  sqldf::sqldf(
    "DROP TABLE IF EXISTS received.boundary",
    connection = conn
  )
  
  # UPLOAD BOUNDARY TO POSTGRESQL DATABASE
  RPostgreSQL::dbWriteTable(conn, c("received","boundary"), study_area_bb)
  
  if(!dbExistsTable(conn = conn, c("received","ttwa"))){
    # GET DATA FROM ONS
    ttwa <- sf::st_read(
      "http://geoportal1-ons.opendata.arcgis.com/datasets/d3062ec5f03b49a7be631d71586cac8c_1.geojson"
    ) %>% 
      sf::st_transform(crs = crs)
    
    # LOAD TO DATABASE 
    DBI::dbWriteTable(conn, c("received","ttwa"), ttwa)
  }
  
  # EXTRACT ONLY REQUIRED TTWA
  DBI::dbSendQuery(
    conn = conn,
    statement = "
DROP TABLE IF EXISTS received.sa_boundary;
CREATE TABLE received.sa_boundary AS
    SELECT ttwa.ttwa11cd, ttwa.ttwa11nm, ttwa.geometry
    FROM received.ttwa ttwa, received.boundary
    WHERE ST_Intersects(ttwa.geometry, received.boundary.geometry)
    ORDER BY ST_Area(ST_Intersection(ttwa.geometry, received.boundary.geometry)) DESC
    LIMIT 1;
DROP TABLE IF EXISTS received.boundary;
    "
  )

    # CALL TABLE INTO R
  study_area_ttwa <- sf::st_read(
    dsn = conn,
    layer = c("received","sa_boundary")
  )

  study_area_ttwa
}

# FUNCTION TO DOWNLOAD OSM DATA WITH THE OVERPASS API 
sa_download <- function(conn){
  # OBTAIN THE EXTENT OF THE STUDY AREA AS A BOUNDING BOX
  sa_extent <- dbGetQuery(conn,
                          "SELECT
                          ST_Extent((ST_Transform(geometry,4326)))
                          FROM received.sa_boundary") 
  
  library(stringr)
  sa_coord <- toString(sa_extent) %>% 
    str_extract_all("\\-*\\d+\\.*\\d*") %>% 
    unlist() %>% 
    toString()
  
  # CONSTRUCT THE API LINE TO REQUEST THE DATA
  api <- paste(
    'https://overpass-api.de/api/map?bbox=',
    sa_coord,
    sep = ''
  )
  
  # CREATE A NEW TEMPORAL DIRECTORY TO DOWNLOAD THE INFO
  cd <- getwd()
  ifelse(
    !file.exists(file.path(cd,'temp')),
    dir.create(file.path(cd,'temp')), 
    "Directory already exists"
  )
  
  # ESTABLISH THE NAME OF THE FILE WHERE THE OVERPASS API WILL DOWNLOAD ITS DATA
  osm_file <- file.path(cd,'temp','overpass.osm')
  
  # REQUEST THE DATA FROM THE API
  library(utils)
  download.file(url = api, destfile = osm_file, extra = '-nv -O') 
  
  ifelse(
    file.exists(file.path(cd,'temp','overpass.osm')),
    "OMS data successfully downloaded!",
    stop("OSM data was not downloaded, please try again or download manually.")
  )
  
}

## Establish a function to create grid with different number of subdivisions, defaults to 9

grid <- function(s = 9){
  ## Call it as an sf object and then transform it to CRS:3035 to create grid
  library(sf)
  library(dplyr, quietly = TRUE)
  
  sa_pop_1km2 <- st_read(
    dsn = connection,
    layer = c("received", "sa_geostat")
  ) %>% 
    st_transform(crs = 3035)
  
  ## Determine number of horizontal and vertical cells
  h <- as.integer(as.numeric(diff(st_bbox(sa_pop_1km2)[c(1, 3)]))/1000)
  v <- as.integer(as.numeric(diff(st_bbox(sa_pop_1km2)[c(2, 4)]))/1000)
  
  ## Make grid
  grid <- sa_pop_1km2 %>% 
    st_make_grid(n=c(h*sqrt(s),v*sqrt(s)), what = "polygons") %>%
    st_sf() %>% 
    mutate(id = 1:n()) %>% 
    st_intersection(sa_pop_1km2)
  
  ## Filter grid by area of intersection because there are small polygons created.
  
  grid <- grid %>% mutate(
    area = grid %>% st_geometry() %>% st_area() %>% as.numeric()
  )

  grid <- grid %>% filter(area > 1)
  
  grid <- within(grid, cell_id <- paste(grd_id,"C",id, sep = ""))
  
  grid <- grid %>% mutate(
    area = NULL,
    id = NULL,
    population = grid$tot_p/s
  )
  
  grid %>% st_transform(crs = sa_crs)
}