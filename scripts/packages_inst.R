#' Only run this script if you are missing any of the packages below. 
#' If you already have them, it is recomended for you to look at what version you wish to keep. 
#' This script is mainly meant for documenting all the packages used, and to declare whether 
#' they were installed from GitHub or CRAN.
#' 
#' To make sure, all the lines will be kept as comments. 
#' 
#' FROM CRAN:
#' install.packages(
#'   sf,
#'   tmap,
#'   DBI,
#'   RPostgreSQL,
#'   sqldf,
#'   readr,
#'   
#' )
#' 
#' FROM GITHUB:
#' devtools::install_git("https://gitlab.datatailor.be/open-source/BelgiumMaps.StatBel")
#' devtools::install_github("jwijffels/StatisticsBelgium")
#' devtools::install_github("jwijffels/BelgiumMaps.Admin")