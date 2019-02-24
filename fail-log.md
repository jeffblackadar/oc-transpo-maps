# OC Transpo Maps Fail Log

## Sources of data
OC Transpo Maps
https://library.carleton.ca/find/gis/geospatial-data/oc-transpo-transit-routes

A source of neighbourhood boundaries is here:
http://data.ottawa.ca/group/geography-and-maps?q=&page=3

## Documentation and how to do things
https://mgimond.github.io/Spatial/data-manipulation-in-r.html

https://gis.stackexchange.com/questions/19064/how-to-open-a-shapefile-in-r

https://www.r-bloggers.com/shapefile-polygons-plotted-on-google-maps-using-ggmap-in-r-throw-some-throw-some-stats-on-that-mappart-2/

I did:
install.packages("rgdal")
install.packages("sf")
install.packages("ggmap")
install.packages("RgoogleMaps")


setwd("C:\\a_orgs\\carleton\\hist3814\\R\\oc-transpo-maps\\")

This was handy for readogr
https://www.r-bloggers.com/things-i-forget-reading-a-shapefile-in-r-with-readogr/

https://www.r-bloggers.com/throw-some-throw-some-stats-on-that-mappart-1/

### map keys
I saw I left a map key in code I wrote last year and then posted to GitHub.  Not a good idea. This is removed.


## database
I plan to create a database to store the route map information so that I can use it for R.
I used instructions from here: (these are mine, but they are a helpful reminder.)
https://programminghistorian.org/en/lessons/getting-started-with-mysql-using-r

In MySQL
```
CREATE DATABASE oc_transpo_maps;
USE oc_transpo_maps;

CREATE TABLE `tbl_route_maps` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `RTE_SHP_FILE_NAME` varchar(50) DEFAULT NULL,
  `RTE_SHP_FILE_FOLDER` varchar(50) DEFAULT NULL,
  `RTE_NAME` varchar(99) DEFAULT NULL,
  `RTE_YEAR` int(11) DEFAULT NULL,
  `RTE_MODE` varchar(50) DEFAULT NULL,
  `RTE_TYPE` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE USER 'oc_maps_user'@'localhost' IDENTIFIED BY '---a-password---';
GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE, SHOW VIEW ON oc_transpo_maps.* TO 'oc_maps_user'@'localhost';


ALTER USER 'oc_maps_user'@'localhost' IDENTIFIED WITH mysql_native_password BY '---a-password---';
```

Made a file
```
[oc_transpo_maps]
user=oc_maps_user
password=---a-password---
host=127.0.0.1
port=3306
database=oc_transpo_maps
```
# Loading the database with information from the ShapeFiles

## Get all of the shp files
```
C:\\a_orgs\\carleton\\hist3814\\R\\oc-transpo-maps\\route-maps>for /r %i in (*.shp) do @echo %~pnxi
```

Made a file like this (replace the paths, replace the / with , add a header)
Replace:
\a_orgs\carleton\hist3814\R\oc-transpo-maps\route-maps\
with " "

replace \ with ,

Add header
RTE_SHP_FILE_FOLDER,RTE_SHP_FILE_NAME

```
RTE_SHP_FILE_FOLDER,RTE_SHP_FILE_NAME
1929_Routes,BusRoute_Crosstown_1929.shp 
1929_Routes,BusRoute_Templeton_1929.shp 
1929_Routes,CarRoute_BankRideauCharlotte_1929.shp 
1929_Routes,CarRoute_BritanniaGeorgeLoop_1929.shp 
```

### Loaded the data

TRUNCATE tbl_route_maps;

```
sampleRouteData <- read.csv(file="C:\\a_orgs\\carleton\\hist3814\\R\\oc-transpo-maps\\route-maps\\shp.csv", header=TRUE, sep=",")
sampleRouteData
dbWriteTable(routesDb, value = sampleRouteData, row.names = FALSE, name = "tbl_route_maps", append = TRUE ) 
```

