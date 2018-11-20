## Get minimum area data depending on country of analysis.

minareadata <- function(min_area,country){
  if(min_area == "geostat"){
    ## Download data and load to PostgreSQL
    if (!dbExistsTable(connection, c("received","geostat"))){
      
      # CREATE A NEW TEMPORAL DIRECTORY TO DOWNLOAD THE INFO
      cd <- getwd()
      ifelse(
        !file.exists(file.path(cd,'temp')),
        dir.create(file.path(cd,'temp')), 
        "Directory already exists"
      )
      
      # ESTABLISH THE NAME OF THE FILE WHERE THE GEOSTAT DATA WILL BE DOWNLOADED AND UNZIPPED
      geostat_file <- file.path(cd,'temp','geostat.zip')
      geostat_exdir <- file.path(cd,"temp","geostat")
      
      if (!file.exists(geostat_exdir)){
        # DEFINE THE URL FROM WHERE THE DATA COMES
        
        geostat_url <- 
          "https://ec.europa.eu/eurostat/cache/GISCO/geodatafiles/GEOSTAT-grid-POP-1K-2011-V2-0-1.zip"
        
        # DOWNLOAD THE FILE, UNZIP IT AND DELETE .ZIP
        
        download.file(url = geostat_url, destfile = geostat_file)
        unzip(geostat_file, exdir = geostat_exdir)
        file.remove(geostat_file)
      }
      
      # CALL DATA INTO R AND REPROJECT
      table_path <- file.path(
        geostat_exdir,
        "Version 2_0_1/GEOSTAT_grid_POP_1K_2011_V2_0_1.csv"
      )
      
      grid_path <- file.path(
        geostat_exdir,
        "Version 2_0_1/GEOSTATReferenceGrid/Grid_ETRS89_LAEA_1K-ref_GEOSTAT_POP_2011_V2_0_1.shp"
      )
      
      pop_table <- st_read(table_path)
      names(pop_table) <- pop_table %>% names() %>% tolower()
      
      pop_grid <- st_read(grid_path)
      pop_grid_t <- pop_grid %>% st_transform(crs = sa_crs)
      names(pop_grid_t) <- pop_grid_t %>% names() %>% tolower()
      
      # LOAD TO POSTGRESQL
      sqldf(
        "
        DROP TABLE IF EXISTS received.pop_grid;
        DROP TABLE IF EXISTS received.pop_table;
        ",
        connection = connection
      )
      
      dbWriteTable(
        conn = connection,
        name = c("received","pop_grid"),
        value = pop_grid_t
      )
      
      dbWriteTable(
        conn = connection,
        name = c("received","pop_table"),
        value = pop_table
      )
      
      #### Join tables on data base and extract study area
      
      sqldf(
        "
        -- Create join between .csv and .shp
        
        DROP TABLE IF EXISTS received.geostat;
        DROP INDEX IF EXISTS received.geostat_geom_idx;
        
        CREATE TABLE received.geostat AS
        SELECT grid.grd_id, grid.geometry, tab.tot_p, tab.cntr_code, tab.year, tab.tot_p_con_dt
        FROM received.pop_grid grid, received.pop_table tab
        WHERE grid.grd_id = tab.grd_id;
        
        CREATE INDEX geostat_geom_idx
        ON received.geostat
        USING gist
        (geometry);
        
        DROP TABLE IF EXISTS received.pop_grid;
        DROP TABLE IF EXISTS received.pop_table;
        ",
        connection = connection
      )
    }
    
    sqldf(
      "
      DROP TABLE IF EXISTS received.sa_geostat;
      DROP INDEX IF EXISTS received.sa_geostat_geom_idx;
      
      -- Extract the grids concerning only the study area
      
      CREATE TABLE received.sa_geostat AS
      SELECT 	DISTINCT geo.grd_id, 
      CAST(geo.tot_p AS INTEGER), 
      geo.cntr_code, 
      geo.geometry
      FROM received.geostat geo, received.sa_ways w
      WHERE ST_Intersects(geo.geometry, w.geom);
      
      CREATE INDEX sa_geostat_geom_idx
      ON received.sa_geostat
      USING gist
      (geometry);  
      ",
      connection = connection 
    )
    
    source("scripts/utils.R")
    sa_grid <- grid(s = subdivisions) # Always consider a squared number to make an even division
    
    sqldf(
      "DROP TABLE IF EXISTS generated.sa_pop_grid",
      connection = connection
    )
    
    ## Load data into data base
    dbWriteTable(
      conn = connection,
      name = c("generated","sa_pop_grid"),
      value = sa_grid
    )
  } else if(min_area == "msoa" & country == "UK"){
    if (!dbExistsTable(connection, "msoa")){
      
      # CREATE A NEW TEMPORAL DIRECTORY TO DOWNLOAD THE INFO
      cd <- getwd()
      ifelse(
        !file.exists(file.path(cd,'temp')),
        dir.create(file.path(cd,'temp')), 
        "Directory already exists"
      )
      
      url <- "https://opendata.arcgis.com/datasets/826dc85fb600440889480f4d9dbb1a24_2.geojson"
      
      file <- "temp/MSOA_boundary.geojson"
      
      if(!file.exists(file)){
        download.file(url, destfile = file)
      }
      
      # Call data into R
      msoa <- st_read(file) %>% 
        st_transform(crs = sa_crs)
      
      # Fetch population data 
      url_pop <- "https://www.ons.gov.uk/file?uri=/peoplepopulationandcommunity/populationandmigration/populationestimates/datasets/middlesuperoutputareamidyearpopulationestimates/mid2017/sape20dt4mid2017msoasyoaestimatesunformatted.zip"   
      file_pop <- "temp/MSOA_pop.zip"
      exdir_pop <- "temp/MSOA_pop"
      
      if(!file.exists(file.path(exdir_pop))){
        download.file(url = url_pop, destfile = file_pop,mode = 'wb')
        unzip(file_pop, exdir = exdir_pop)
        file.remove(file_pop)
        file.rename(
          from = file.path(
            exdir_pop,
            "SAPE20DT4-mid-2017-msoa-syoa-estimates-unformatted.xls"
          ), 
          to = file.path(exdir_pop,"msoa-population.xls")
        )
      }
      
      # Call it into R
      library(xlsx)
      pop <- read.xlsx2(
        file = file.path(
          getwd(),
          exdir_pop,
          "msoa-population.xls"
        ),
        sheetIndex = 4,
        colIndex = 1:3,
        startRow = 5
      )
      
      # Fetch jobs data
      url_job <- 'https://media.githubusercontent.com/media/npct/pct-outputs-national/master/commute/msoa/od_all_attributes.csv'
      file_job <- "temp/MSOA_jobs.csv"
      
      if(!file.exists(file.path(file_job))){
        download.file(url = url_job, destfile = file_job, mode = 'wb')
      }
      
      # Call data into R
      job <- read.csv(file_job)

      # Summarize per workplace LSOA code 
      job <- job %>% group_by(geo_code2) %>% 
        summarize_if(is.numeric, sum) %>% 
        select(geo_code2, jobs = all)
      
      # Join datasets 
      msoa <- inner_join(msoa, pop, by = c("msoa11cd" = "Area.Codes"))
      
      msoa <- left_join(msoa, job, by = c("msoa11cd" = "geo_code2")) %>% 
        select(cell_id = lsoa11cd, lsoa11nm, population = All.Ages, jobs) %>% 
        mutate(
          population = as.numeric(as.character(population)),
          jobs = as.numeric(as.character(jobs))
        )

      # Load data into database
      dbWriteTable(
        conn = connection,
        name = c("received","msoa"),
        value = msoa
      )
    }  
    
    # Extract MSOAs for study area
    extract <-  sqlInterpolate(
      conn = connection,
      sql = "
      DROP TABLE IF EXISTS generated.sa_pop_grid;
      CREATE TABLE generated.sa_pop_grid AS
      SELECT m.msoa11cd, m.msoa11nm, m.population, m.jobs, m.geometry
      FROM received.msoa m, received.sa_boundary b
      WHERE ST_Intersects(m.geometry,b.geometry)
      AND ST_Area(ST_Intersection(m.geometry, b.geometry))>1000;
      ",
      sa_crs = sa_crs
    )
    
    dbSendQuery(connection,statement = extract)
    
  } else if (min_area == "lsoa" & country == "UK"){
    if (!dbExistsTable(connection, c("received","lsoa"))){
      
      # CREATE A NEW TEMPORAL DIRECTORY TO DOWNLOAD THE INFO
      cd <- getwd()
      ifelse(
        !file.exists(file.path(cd,'temp')),
        dir.create(file.path(cd,'temp')), 
        "Directory already exists"
      )
      
      url <- "https://opendata.arcgis.com/datasets/da831f80764346889837c72508f046fa_2.geojson"
      
      file <- "temp/LSOA_boundary.geojson"
      
      if(!file.exists(file)){
        download.file(url, destfile = file)
      }
      
      # Call data into R
      lsoa <- st_read(file) %>% 
        st_transform(crs = sa_crs)
      
      # Fetch population data 
      url_pop <- "https://www.ons.gov.uk/file?uri=/peoplepopulationandcommunity/populationandmigration/populationestimates/datasets/lowersuperoutputareamidyearpopulationestimatesnationalstatistics/mid2017/sape20dt13mid2017lsoabroadagesestimatesunformatted.zip"
      file_pop <- "temp/LSOA_pop.zip"
      exdir_pop <- "temp/LSOA_pop"
      
      if(!file.exists(file.path(exdir_pop))){
        download.file(url = url_pop, destfile = file_pop, mode = 'wb')
        unzip(file_pop, exdir = exdir_pop)
        file.remove(file_pop)
        file.rename(
          from = file.path(
            exdir_pop,
            "SAPE20DT13-mid-2017-lsoa-Broad_ages-estimates-unformatted.XLS"
          ), 
          to = file.path(exdir_pop,"lsoa-population.xls")
        )
      }
      
      # Call it into R
      library(xlsx)
      pop <- read.xlsx2(
        file = file.path(
          getwd(),
          exdir_pop,
          "lsoa-population.xls"
        ),
        sheetIndex = 4,
        colIndex = 1:3,
        startRow = 5
      )
      
      # Fetch jobs data
      url_job <- 'https://media.githubusercontent.com/media/npct/pct-outputs-national/master/commute/lsoa/od_all_attributes.csv'
      file_job <- "temp/LSOA_jobs.csv"
      
      if(!file.exists(file.path(file_job))){
        download.file(url = url_job, destfile = file_job, mode = 'wb')
      }
      
      # Call data into R
      job <- read.csv(file_job)
      
      # Summarize per workplace LSOA code 
      job <- job %>% group_by(geo_code2) %>% 
        summarize_if(is.numeric, sum) %>% 
        select(geo_code2, jobs = all)
      
      # Join datasets 
      lsoa <- inner_join(lsoa, pop, by = c("lsoa11cd" = "Area.Codes"))

      lsoa <- left_join(lsoa, job, by = c("lsoa11cd" = "geo_code2")) %>% 
        select(cell_id = lsoa11cd, lsoa11nm, population = All.Ages, jobs) %>% 
        mutate(
          population = as.numeric(as.character(population)),
          jobs = as.numeric(as.character(jobs))
        )
      
      # Load data into database
      dbWriteTable(
        conn = connection,
        name = c("received","lsoa"),
        value = lsoa
      )
    }  
    
    # Extract LSOAs for study area
    extract <-  sqlInterpolate(
      conn = connection,
      sql = "
      DROP TABLE IF EXISTS generated.sa_pop_grid;
      CREATE TABLE generated.sa_pop_grid AS
      SELECT l.cell_id, l.lsoa11nm, l.population, l.jobs, l.geometry
      FROM received.lsoa l, received.sa_boundary b
      WHERE ST_Intersects(l.geometry,b.geometry)
      AND (ST_Area(ST_Intersection(l.geometry, b.geometry)) > 100000
            OR ST_Contains(b.geometry, l.geometry));
      ",
      sa_crs = sa_crs
    )
    
    dbSendQuery(connection,statement = extract)
    
  } else if(min_area == "buurt" & country == "Netherlands") {
    if (!dbExistsTable(connection, c("received","nl_buurt"))){
      
      # CREATE A NEW TEMPORAL DIRECTORY TO DOWNLOAD THE INFO
      cd <- getwd()
      ifelse(
        !file.exists(file.path(cd,'temp')),
        dir.create(file.path(cd,'temp')), 
        "Directory already exists"
      )
      
      # Fetch buurt and population data 
      url_nl <- "https://www.cbs.nl/-/media/cbs/dossiers/nederland%20regionaal/wijk-en-buurtstatistieken/2018/shape%202017%20versie%2020.zip"
      file_nl <- "temp/nl_buurt_pop.zip"
      exdir_nl <- "temp/nl_buurt_pop"
      
      if(!file.exists(file.path(exdir_nl))){
        download.file(url = url_nl, destfile = file_nl,mode = 'wb')
        unzip(file_nl, exdir = exdir_nl)
        file.remove(file_nl)
      }
      
      # Fetch LISA data for jobs per Gemeente
      url_job <- 'https://raw.githubusercontent.com/loreabad6/masters-thesis-geotech/master/data/gemeente.csv'
      job_gem <- read.csv(url_job, sep = '\t')
      
      # Call data into R
      file_buurt <- file.path(exdir_nl,'Uitvoer_shape','buurt_2017.shp')
      
      library(sf)
      library(dplyr)
      library(tidyr)
      nl_buurt <- st_read(file_buurt) %>% 
        filter(WATER == "NEE") %>% 
        left_join(job_gem, by = c("GM_NAAM" = "Gemeente")) %>% 
        select(
          cell_id = BU_CODE, 
          bu_naam = BU_NAAM, 
          population = AANT_INW, 
          GM_NAAM, 
          companies = A_BED_A,
          jobs_gem = Banen.totaal
        ) %>% 
        mutate(
          companies = na_if(companies, -99999999),
          area = st_area(geometry) %>% as.numeric()
        ) %>% 
        group_by(GM_NAAM) %>% 
        mutate(
          companies_total = sum(companies, na.rm = T),
          area_total = sum(area, na.rm = T)
        ) %>% ungroup() %>% 
        mutate(
          jobs = round(
            jobs_gem
            *(
              (0.5*companies/companies_total) + (0.5*area/area_total) 
              ### Just an approx. of the number of jobs per neighborhood as 
              ### LISA data is not available at this level of aggregation. 
              ### For the time being I'll leave it like this until I find a better solution.
              ),
            0
          )
        )%>% 
        select(cell_id, bu_naam, population, jobs)
      
      ## Transform data to match OSM geometry
      proj_nl <- "+proj=sterea +lat_0=52.15616055555555 +lon_0=5.38763888888889 +k=0.999908 +x_0=155000 +y_0=463000 +ellps=bessel +units=m +towgs84=565.2369,50.0087,465.658,-0.406857330322398,0.350732676542563,-1.8703473836068,4.0812 +no_defs no_defs"
      nl_buurt <- nl_buurt %>% 
        st_transform(crs = proj_nl)  %>% 
        st_transform(crs = sa_crs)
      
      #### Correction taken from this blog: 
      #### http://www.qgis.nl/2011/12/05/epsg28992-of-rijksdriehoekstelsel-verschuiving/
      
      # Load data into database
      dbWriteTable(
        conn = connection,
        name = c("received","nl_buurt"),
        value = nl_buurt
      )
    }
    
    # Extract LSOAs for study area
    extract <-  sqlInterpolate(
      conn = connection,
      sql = "
      DROP TABLE IF EXISTS generated.sa_pop_grid;
      CREATE TABLE generated.sa_pop_grid AS
      SELECT l.cell_id, l.bu_naam, l.population, l.jobs, l.geometry
      FROM received.nl_buurt l, received.sa_boundary b
      WHERE ST_Intersects(l.geometry, b.geometry)
      AND (ST_Area(ST_Intersection(l.geometry, b.geometry)) > 500000 
            OR ST_Contains(b.geometry, l.geometry));
      "
    )
    
    dbSendQuery(connection,statement = extract)
    
  #}else if(min_area == "cb" & country == "US") {
    
  }else stop("Check that the minimum area corresponds to your country of analysis or that it is set to 'geostat' for a gridded outcome for any country in Europe.")
  
}

