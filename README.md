# Geospatial Technologies Master's Thesis
Advances of my master thesis for the [Erasmus Mundus Masters in Geospatial Technologies](http://mastergeotech.info/).

## Topic

Validating a bike network analysis score based on open data as a connectivity measure of urban cycling infrastructure adapted for European cities.

### Basic idea

Reproduce the [BNA score developed by People for Bikes](https://bna.peopleforbikes.org/#/), validate it and adapt it to compute bike network connectivity in European cities.
 
My thesis proposal can be accessed [here](https://loreabad6.github.io/masters-thesis-geotech/Thesis_Proposal.html). Keep in mind, it will be constantly updated.	

### Products

1. [BNA score translated into R and SQL, to be applied in European cities](https://loreabad6.github.io/masters-thesis-geotech/BNA-Europe.nb.html).
 
2. A [series of scripts](scripts/) that come together into an [R-Markdown report](report/BNA-Report-Template.Rmd) to calculate the BNA score for cities in England, Wales and the Netherlands. The analysis has been run for some example cities:
   - [Cambridge, UK](https://loreabad6.github.io/masters-thesis-geotech/BNA-Report-Cambridge.nb.html)
   - [York, UK](https://loreabad6.github.io/masters-thesis-geotech/BNA-Report-York.nb.html) _(with a surprisingly high score)_
   - [Oxford, UK](https://loreabad6.github.io/masters-thesis-geotech/BNA-Report-Oxford.nb.html)
   - [Venlo, NL](https://loreabad6.github.io/masters-thesis-geotech/BNA-Report-Venlo.nb.html)
   - [Delft, NL](https://loreabad6.github.io/masters-thesis-geotech/BNA-Report-Delft.nb.html)

### Tasks

- [X] Translate [BNA score developed by People for Bikes](https://bna.peopleforbikes.org/#/) scripts into R and SQL architecture.
- [X] Include data for population and jobs for European cities _(Population data available for Europe, UK and NL, job data available for UK)_
- [ ] Include data sources to compute the score in the US
- [ ] Validate the level of traffic stress classification
- [ ] Validate the destination's weights
- [ ] Find an alternative set of destinations that cover people's needs when they commute by bike to use in European cities
