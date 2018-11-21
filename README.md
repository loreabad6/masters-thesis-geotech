# Geospatial Technologies Master's Thesis
Advances of my master thesis for the [Erasmus Mundus Masters in Geospatial Technologies](http://mastergeotech.info/).

## Topic

Validating a bike network analysis score based on open data as a connectivity measure of urban cycling infrastructure adapted for European cities.

- [ Basic Idea ](#idea)
- [ Products ](#products)
- [ BNA score for UK and NL ](#product2)
  - [ How to use it? ](#use)
  - [ Data ](#data)
  - [ Example cities ](#example)
- [ Tasks ](#tasks)
  
<a name="idea"></a>
### Basic idea

Reproduce the [BNA score developed by People for Bikes](https://bna.peopleforbikes.org/#/), validate it and adapt it to compute bike network connectivity in European cities.
 
My thesis proposal can be accessed [here](https://loreabad6.github.io/masters-thesis-geotech/Thesis_Proposal.html). Keep in mind, it will be constantly updated.	

<a name="products"></a>
### Products

1. [BNA score translated into R and SQL, to be applied in European cities](https://loreabad6.github.io/masters-thesis-geotech/BNA-Europe.nb.html).
 
2. A [series of scripts](scripts/) that come together into an [R-Markdown report](report/BNA-Report-Template.Rmd) to calculate the BNA score for cities in the UK (England and Wales) and the Netherlands. 

<a name="product2"></a>
### Calculate BNA for cities in the UK (England and Wales) and the Netherlands. 

<a name="use"></a>
##### How to use it?

1. Create a database on its PostgreSQL. To test connection an empty table on the database called `test` should be created on the public schema
    + Tip: Run `FULL VACUUM/ANALYZE` frequently on the database to improve performance
    + Follow the tips on [this presentation](https://thebuild.com/presentations/not-your-job.pdf) to increase performance of the database
2. Set path variables for `osm2pgsql` and `osm2pgrouting`
3. Create a password file on `%APPDATA%/postgresql/pgpass.conf` with the format *hostname:port:database:username:password*
4. Clone this repository 
5. Edit the [R-Markdown report](report/BNA-Report-Template.Rmd) with your study area, and run the R-Notebook locally
6. Wait for a while, keep in mind larger and more crowded areas take longer
7. Check out your results as an HTML file 

<a name="data"></a>
##### Data

The BNA score bases its methodology on [OSM](https://www.openstreetmap.org/) data, however job and population data is accessed from other open data sources. Particularly for this project, this datasets were used:

- Europe:
  - Population grid per squared kilometer for 2011 from [GEOSTAT - EUROSTAT](https://ec.europa.eu/eurostat/web/gisco/geodata/reference-data/population-distribution-demography/geostat)
  - No data available for the whole continent with high spatial resolution
  
- UK (England and Wales)
  - Population estimates for mid-2017 at LSOA and MSOA level from the [Office of National Statistics - ONS](https://www.ons.gov.uk/peoplepopulationandcommunity/populationandmigration/populationestimates) 
  - Flow commute data (travel to work) for the 2011 Census at LSOA and MSOA level from the [Office of National Statistics - ONS](https://wicid.ukdataservice.ac.uk/cider/wicid/downloads.php?guest=1), where the total number of trips per destination super-output area where aggregated, and assumed as the total number of jobs in the area.

- The Netherlands
  - District and neighborhood map with associated key figures like population for 2017 from the [Centraal Bureau voor de Statistiek - CBS ](https://www.cbs.nl/nl-nl/dossier/nederland-regionaal/geografische%20data/wijk-en-buurtkaart-2017) 
  - Jobs per municipality from [	LISA (National Information System for Workplaces) dataset](https://www.lisa.nl/data/gratis-data/overzicht-lisa-data-per-gemeente). To estimate jobs at neighborhood level a spatial interpolation was made with the number of jobs in the whole municipality hafly weighted by the fraction of the neighborhood area, and hafly weighted by the fraction of companies in the neighborhood, taken from the CBS data. This approach needs to be validated, however it is one way to approximate it, given that LISA data at this aggregation level has to be bought and is not open data

<a name="example"></a>
##### Example cities

| England       | The Netherlands | Wales         |
| ------------- | --------------- | ------------- |
| [Cambridge](https://loreabad6.github.io/masters-thesis-geotech/BNA-Report-Cambridge.nb.html)                                                           | [Venlo](https://loreabad6.github.io/masters-thesis-geotech/BNA-Report-Venlo.nb.html)                                                                     | [Bridgend](https://loreabad6.github.io/masters-thesis-geotech/BNA-Report-Brdigend.nb.html) |
| [York](https://loreabad6.github.io/masters-thesis-geotech/BNA-Report-York.nb.html)                                                                     | [Delft](https://loreabad6.github.io/masters-thesis-geotech/BNA-Report-Delft.nb.html)                                                                     | [Newport](https://loreabad6.github.io/masters-thesis-geotech/BNA-Report-Newport.nb.html) |
| [Oxford](https://loreabad6.github.io/masters-thesis-geotech/BNA-Report-Oxford.nb.html)                                                                 | [Groningen](https://loreabad6.github.io/masters-thesis-geotech/BNA-Report-Groningen.nb.html)                                                             | |
| [Cheltenham](https://loreabad6.github.io/masters-thesis-geotech/BNA-Report-Cheltenham.nb.html)                                                         | [Breda](https://loreabad6.github.io/masters-thesis-geotech/BNA-Report-Breda.nb.html)                                                                     | |
| [Chesterfield](https://loreabad6.github.io/masters-thesis-geotech/BNA-Report-Chesterfield.nb.html)                                                     | [Zwolle](https://loreabad6.github.io/masters-thesis-geotech/BNA-Report-Zwolle.nb.html)                                                                   | |
| [Worcester](https://loreabad6.github.io/masters-thesis-geotech/BNA-Report-Worcester.nb.html)                                                           |                                                                                                                                                         | |
| [Maidstone](https://loreabad6.github.io/masters-thesis-geotech/BNA-Report-Maidstone.nb.html)                                                           |                                                                                                                                                         | |
| [Lincoln](https://loreabad6.github.io/masters-thesis-geotech/BNA-Report-Lincoln.nb.html)                                                               |                                                                                                                                                         | |
| [Chelmsford](https://loreabad6.github.io/masters-thesis-geotech/BNA-Report-Chelmsford.nb.html)                                                         |                                                                                                                                                         | |
| [Bedford](https://loreabad6.github.io/masters-thesis-geotech/BNA-Report-Bedford.nb.html)                                                               |                                                                                                                                                         | |

<a name="tasks"></a>
### Tasks

- [X] Translate [BNA score developed by People for Bikes](https://bna.peopleforbikes.org/#/) scripts into R and SQL architecture.
- [X] Include data for population and jobs for European cities _(Population data available for Europe, UK and NL, job data available for UK)_
- [ ] \(Optional) Include data sources to compute the score in the US
- [ ] \(Optional) Create a shiny app to show the computed results so far
- [ ] Validate the level of traffic stress classification
- [ ] Validate the destination's weights
- [ ] Find an alternative set of destinations that cover people's needs when they commute by bike to use in European cities
