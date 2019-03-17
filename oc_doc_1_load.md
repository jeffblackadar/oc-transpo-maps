# OC Transpo Maps
## Data load process
### Download source data
Create a destination directory. I used:
C:\\a_orgs\\carleton\\hist3814\\R\\oc-transpo-maps-data\\route-maps
Run R program oc_0_shp_download.r to download the .zip files and unzip them.

### Load database with Shapefile information
#### Load all of the shp files
In the directory where the shapefiles are:
```
C:\\a_orgs\\carleton\\hist3814\\R\\oc-transpo-maps-data\\route-maps>
```
Run
```
for /r %i in (*.shp) do @echo %~pnxi >>oc-shps.txt
```
This command lists all of the file names in subdirectories and stores them into oc-shps.txt.

Open oc-shps.txt in a text file editor. 
This next step will change this list of file names into a comma separated value file (.csv) to be loaded into a database.


Made a file like this (replace the paths, replace the / with , add a header)

In the text editory, replace all:
\\a_orgs\\carleton\\hist3814\\R\\oc-transpo-maps-data\\route-maps\\
with "" (no space)

replace \ with ,

Add a header to the first line of the file
RTE_SHP_FILE_FOLDER,RTE_SHP_FILE_NAME

The first few lines of the file should look like this.
```
RTE_SHP_FILE_FOLDER,RTE_SHP_FILE_NAME
1929_Routes,BusRoute_Crosstown_1929.shp 
1929_Routes,BusRoute_Templeton_1929.shp 
1929_Routes,CarRoute_BankRideauCharlotte_1929.shp 
1929_Routes,CarRoute_BritanniaGeorgeLoop_1929.shp 
```

### Loaded the data

#### Create database
The route information from the shapefiles is stored in a database so that it can be queried in R to generate maps and combined with other data.
I used instructions from here: (these are mine, but they are a helpful reminder.)
https://programminghistorian.org/en/lessons/getting-started-with-mysql-using-r

In MySQL create the database and use it.
```
CREATE DATABASE oc_transpo_maps;
USE oc_transpo_maps;
```
Create the table to store route information
```

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

```
Create a user to access the table
```

CREATE USER 'oc_maps_user'@'localhost' IDENTIFIED BY '---a-password---';
GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE, SHOW VIEW ON oc_transpo_maps.* TO 'oc_maps_user'@'localhost';


ALTER USER 'oc_maps_user'@'localhost' IDENTIFIED WITH mysql_native_password BY '---a-password---';
```

Create a file for R to use to access the database
```
[oc_transpo_maps]
user=oc_maps_user
password=---a-password---
host=127.0.0.1
port=3306
database=oc_transpo_maps
```
If reloading data, truncate the table to empty it.
```
TRUNCATE tbl_route_maps;
```
Load the shapefile names into the database

```
sampleRouteData <- read.csv(file="C:\\a_orgs\\carleton\\hist3814\\R\\oc-transpo-maps-data\\route-maps\\oc-shps.csv", header=TRUE, strip.white=TRUE, sep=",")
sampleRouteData
dbWriteTable(routesDb, value = sampleRouteData, row.names = FALSE, name = "tbl_route_maps", append = TRUE ) 

```
In MySQL check that data looks correct:
```
SELECT * FROM oc_transpo_maps.tbl_route_maps;
```
If all shapefiles were downloaded, extracted and loaded this count equals 5661 rows.

```
SELECT COUNT(*) FROM oc_transpo_maps.tbl_route_maps;
```
### Load the data from the shapefiles into the database
The data load program reads each shapefile and stores the data into fields in the database. Loading the data makes it more easy to query. It can also be groomed for analytical purposes to allow comparison of transit routes from different years.

run the program oc_1_shp_data_load.r.  It takes approximately 2 hours to read and process all 5661 files.


#### Check for data quality
```
SELECT * FROM oc_transpo_maps.tbl_route_maps WHERE MODE = "";
result should be 0.
SELECT * FROM oc_transpo_maps.tbl_route_maps WHERE RTE_TYPE = "";

SELECT * FROM oc_transpo_maps.tbl_route_maps WHERE YEAR <1929;
SELECT YEAR FROM oc_transpo_maps.tbl_route_maps WHERE TRUE GROUP BY YEAR ORDER BY YEAR;

SELECT * FROM oc_transpo_maps.tbl_route_maps WHERE MODE = "";
SELECT MODE FROM oc_transpo_maps.tbl_route_maps WHERE TRUE GROUP BY MODE ORDER BY MODE;

SELECT * FROM oc_transpo_maps.tbl_route_maps WHERE RTE_TYPE = "";
SELECT RTE_TYPE FROM oc_transpo_maps.tbl_route_maps WHERE TRUE GROUP BY RTE_TYPE ORDER BY RTE_TYPE;

SELECT * FROM oc_transpo_maps.tbl_route_maps WHERE RTE_TYPE = "";

update oc_transpo_maps.tbl_route_maps set RTE_TYPE_GROOMED=RTE_TYPE where ID>130 and ID<200 and RTE_TYPE_GROOMED=null
```