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
  `RTE_SHP_FILE_NAME` varchar(99) DEFAULT NULL COMMENT 'The file name of the shapefile to be loaded.',
  `RTE_SHP_FILE_FOLDER` varchar(50) DEFAULT NULL COMMENT 'The folder name of the shapefile to be loaded.',
  `YEAR` int(11) DEFAULT NULL COMMENT 'The year of the shapefile''s data',
  `RTE_NAME` varchar(99) DEFAULT NULL COMMENT 'The route name.',
  `RTE_NUM` varchar(99) DEFAULT NULL COMMENT 'The route number.',
  `Mode` varchar(50) DEFAULT NULL COMMENT 'The Mode of the route. (Street Car)',
  `RTE_TYPE` varchar(50) DEFAULT NULL COMMENT 'The route type. This is the original data from the shapefiles.',
  `RTE_TYPE_GROOMED` varchar(50) DEFAULT NULL COMMENT 'The route type. This is modified or groomed data from the shapefiles for more consistency during differnet years.',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5793 DEFAULT CHARSET=utf8 COMMENT='Contains the list of shapefiles and their attributes so that they can be queried to generate maps from data that matches the query.';



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

## Side effect for Git
Downloading all the Shapefiles resulted in anout 40k of files being added to the Git index.
This slowed things down badly, and we did not need these, so I removed them from the index

```
 git rm route-maps -r -f
```

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
Row 3800  RTE_184_Limited Service_2002  - does not load
-- This was an initial problem.  It was solved. (see below.)

### RTE_TYPEs

Here are the RTE_TYPES - they are not fully consistent

"4am to 6am only"
"Bus Line"
"Bus Route"
"City Car Line"
"Demand Responsive Route"
DemandResponsiveService
"Early Morning Only"
"Express Route"
ExpressRoute
GreenRoute
"Limited Service"
"Limited Stops Route"
LimitedService
"Main Route - Regular"
"Main Route - Rush Hour"
"Motor Coach Route"
OffPeak
OffPeakService
"Other Through Route - Regular"
"Other Through Route - Rush Hour"
OTRAIN
Peak
"Peak Hour Extension"
"Peak Route"
PeakHourExtension
PeakPeriod
PeakPeriodExtension
PeakPeriodRoute
PeakPeriodService
PeakRoute
RedRoute
"Regular Route"
RegularRoute
"Rural Express Route"
"Rural Shopping Route"
RuralExpressRoute
"Rush Hour Bus Route"
"Street Car Route"
"Suburban Car Line"
"Sunday Only Route"
"Sunday Service Route"
SundayOnly
"Transfer Route - Regular"
"Transfer Route - Rush Hour"
"Trolley Bus Route"

I will add to the data import program to groom these

```
CREATE TABLE `tbl_route_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `RTE_TYPE` varchar(50) DEFAULT "",
  `RTE_TYPE_MODE` varchar(50) DEFAULT "",
  `RTE_TYPE_MODE_CODE` int(11) DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
```
This query provides a useful view of the years when the route types were in use.
select RTE_TYPE, min(YEAR), max(YEAR) from oc_transpo_maps.tbl_route_maps GROUP BY RTE_TYPE order by RTE_TYPE;

#Thank you
#http://www.sthda.com/english/wiki/colors-in-r

# Generate a plot of color names which R knows about.
#++++++++++++++++++++++++++++++++++++++++++++
# cl : a vector of colors to plots
# bg: background of the plot
# rot: text rotation angle
#usage=showCols(bg="gray33")
showCols <- function(cl=colors(), bg = "grey",
                     cex = 0.75, rot = 30) {
  m <- ceiling(sqrt(n <-length(cl)))
  length(cl) <- m*m; cm <- matrix(cl, m)
  require("grid")
  grid.newpage(); vp <- viewport(w = .92, h = .92)
  grid.rect(gp=gpar(fill=bg))
  grid.text(cm, x = col(cm)/m, y = rev(row(cm))/m, rot = rot,
            vp=vp, gp=gpar(cex = cex, col = cm))
}
showCols(bg="gray33")

These don't work for me

```
# Write image to file
ggsave(filename="test.svg",plot=image,width=10,height=8,units="cm")

writeOGR(obj=transitMap,dsn = "C:\\a_orgs\\carleton\\hist3814\\R\\oc-transpo-maps-data\\route-maps\\", layer = "2015_map", driver="ESRI Shapefile")
```
### Problem loading RTE_184_Limited Service_2002
I had a problem loading RTE_184_Limited Service_2002
It has a space in it and the space was being removed when I did
layer_temp = gsub(" ","",gsub(".shp","",output_dbRows[i, 2]))
in the data load on line 49.  I was replacing spacec because I loaded the data with trailing spaces.  I should have removed the whitespace on load (and will)

"RTE_184_LimitedService_2002"

### Geojson
I may want to write out geojson for my project
I see some good information here
https://github.com/Robinlovelace/Creating-maps-in-R/blob/master/vignettes/geoJSON.Rmd


### Empty modes
SELECT * FROM oc_transpo_maps.tbl_route_maps WHERE MODE = "";
63	RTE_023_TrolleyBusRoute_1951.shp	1951_Routes	1951		023		Trolley Bus Route
98	RTE_023_MotorCoachRoute_1954.shp	1954_December	1954		023		Motor Coach Route
99	RTE_023_TrolleyBusRoute_1954.shp	1954_December	1954		023		Trolley Bus Route
132	RTE_026_TrolleyBusRoute_1954.shp	1954_June	1954		026		Trolley Bus Route

SELECT * FROM oc_transpo_maps.tbl_route_maps WHERE RTE_TYPE = "";

### Leaflet
https://github.com/DataVizForAll/leaflet-storymap

Kim Pham, "Web Mapping with Python and Leaflet," The Programming Historian 6 (2017), https://programminghistorian.org/en/lessons/mapping-with-python-leaflet.

# Data grooming RTE_RUM
```
RTE_RUM   RTE_TYPE MODE YEAR
0      152 Peak Route  Bus 2000
C:\a_orgs\carleton\hist3814\R\oc-transpo-maps-data\route-maps\2000_Routes\RTE_152_PeakRoute_2000.shp
```