#install.packages("RMariaDB")
#install.packages("rgdal")
#install.packages("sf")
#install.packages("ggmap")
#install.packages("RgoogleMaps")
#install.packages("svglite")

#
#Before starting this program:
#do
#register_google(key = "???-your api key")

library(ggmap)
#citation("ggmap")

library(RgoogleMaps)
#citation("RgoogleMaps")

library(ggplot2)
#citation("ggplot2")

require(rgdal)
#citation("rgdal")

library(RMariaDB)
#citation("RMariaDB")

library(plyr)
# R needs a full path to find the settings file.
rmariadb.settingsfile<-"C:\\ProgramData\\MySQL\\MySQL Server 8.0\\oc_transpo_maps.cnf"

rmariadb.db<-"oc_transpo_maps"
routesDb<-dbConnect(RMariaDB::MariaDB(),default.file=rmariadb.settingsfile,group=rmariadb.db) 

# list the table. This confirms we connected to the database.
dbListTables(routesDb)

# *** "One time" data load
#sampleRouteData <- read.csv(file="C:\\a_orgs\\carleton\\hist3814\\R\\oc-transpo-maps\\route-maps\\shp.csv", header=TRUE, sep=",")
#sampleRouteData
#dbWriteTable(routesDb, value = sampleRouteData, row.names = FALSE, name = "tbl_route_maps", append = TRUE ) 

# *** "One time" data load from SHP files
# output_query<-paste("select * from tbl_route_maps where true",sep='')
# output_rs = dbSendQuery(routesDb,output_query)
# output_dbRows<-dbFetch(output_rs, 999999)
# if (nrow(output_dbRows)==0){
#   print (paste("Problem: zero rows for ",output_query,sep=''))
# } else {
#   for (i in 1:nrow(output_dbRows)) {
#     print(output_dbRows[i, 1])
#     print(output_dbRows[i, 2])
#     #dsn_temp<-paste("C:\\a_orgs\\carleton\\hist3814\\R\\oc-transpo-maps\\route-maps\\",output_dbRows[i, 2],sep='')
#     #dsn_temp
#     layer_temp = gsub(" ","",gsub(".shp","",output_dbRows[i, 2]))
#     layer_temp
#     route <- readOGR(dsn = paste("C:\\a_orgs\\carleton\\hist3814\\R\\oc-transpo-maps\\route-maps\\",output_dbRows[i, 3],sep=''), layer = gsub(" ","",gsub(".shp","",output_dbRows[i, 2])))
#     
#     output_query<-""
#     
#     output_query_2<-paste(", RTE_TYPE='",paste(route$RTE_TYPE[1],sep=""), "', Mode='",paste(route$Mode[1],sep=""), "'",sep="")
#     
#     if (route$YEAR[1]==1929 | route$YEAR[1]==1939 | route$YEAR[1]==1948) {
#       output_query<-paste("UPDATE tbl_route_maps set YEAR=",paste(route$YEAR[1],sep=""), ", RTE_NAME='",paste(route$RTE_NAME[1],sep=""),"'", output_query_2, " WHERE id=",output_dbRows[i, 1],sep='')
#     }
# 
#     if (route$YEAR[1]==1951) {
#       output_query<-paste("UPDATE tbl_route_maps set YEAR=",paste(route$YEAR[1],sep=""), ", RTE_NUM='",paste(route$RTE_NUM[1],sep=""),"'",  output_query_2, " WHERE id=",output_dbRows[i, 1],sep='')
#       #output_query
#       
#     }    
#     if(nchar(output_query)>1) {
#       output_rs = dbSendQuery(routesDb,output_query)
#     }
#   }
# }


# Read SHAPEFILE.shp from the current working directory (".")

setwd("C:\\a_orgs\\carleton\\hist3814\\R\\oc-transpo-maps\\")

# Prior to running this, perform register_google(key = "-the-key-")
#centerOfMap <- geocode("Ottawa, ON")
#45.41117, -75.69812

#ottawa <- get_map(c(lon=centerOfMap$lon, lat=centerOfMap$lat),zoom = 12, maptype = "terrain", source = "stamen")
ottawa <- get_map(c(lon=-75.69812, lat=45.37000),zoom = 11, maptype = "terrain", source = "stamen")
ottawaMap <- ggmap(ottawa,legend = "right")
ottawaMap

#need a zoom of 9 to get the formerTownships in
#won't use former townhips for now
#formerTownships <- readOGR(dsn = "C:\\a_orgs\\carleton\\hist3814\\R\\oc-transpo-maps\\former-townships", layer = "former-townships")
#formerTownships <- spTransform(formerTownships, CRS("+proj=longlat +datum=WGS84"))
#formerTownships <- fortify(formerTownships)
#ottawaMap <- ottawaMap + geom_polygon(aes(x=long, y=lat, group=group), fill='grey', size=.2,color='purple', data=formerTownships, alpha=0)

#-------------
# Single route plotted
#route <- readOGR(dsn = "C:\\a_orgs\\carleton\\hist3814\\R\\oc-transpo-maps-data\\route-maps\\2015_Routes", layer = "RTE_001_RegularRoute_2015")
#spTransform allows us to convert and transform between different mapping projections and datums.
#Credit to https://www.r-bloggers.com/shapefile-polygons-plotted-on-google-maps-using-ggmap-in-r-throw-some-throw-some-stats-on-that-mappart-2/


#route <- spTransform(route, CRS("+proj=longlat +datum=WGS84"))

#route <- fortify(route)
#transitMap <- ottawaMap + geom_polygon(aes(x=long, y=lat, group=group), fill='grey', size=.2,color='green', data=route, alpha=0)
#transitMap



#--------------

transitMap <- ottawaMap

#Loop through each year to create the geojson files needed for leaflet maps
for (generateYear in 2006:2015){
  
  print(paste0("Generating maps and geojson for year ", generateYear))
  
  #There are 2 files for 1954, so do this twice for June and Dec.
  mapYear=generateYear
  output_query<-paste0("SELECT tbl_route_maps.ID, tbl_route_maps.RTE_SHP_FILE_NAME, tbl_route_maps.RTE_SHP_FILE_FOLDER, tbl_route_maps.RTE_TYPE_GROOMED, tbl_route_maps.RTE_NUM, tbl_route_types.RTE_TYPE_MODE, tbl_route_types.RTE_TYPE_MODE_CODE FROM tbl_route_maps LEFT JOIN tbl_route_types ON tbl_route_maps.RTE_TYPE_GROOMED = tbl_route_types.RTE_TYPE WHERE YEAR=",mapYear," ORDER BY RTE_TYPE_MODE_CODE DESC, RTE_NUM;")
  #A kluge to use 1953, but worth it to avoid complexity
  if(generateYear==1953){
    mapYear="1954_June"    
    output_query<-paste0("SELECT tbl_route_maps.ID, tbl_route_maps.RTE_SHP_FILE_NAME, tbl_route_maps.RTE_SHP_FILE_FOLDER, tbl_route_maps.RTE_TYPE_GROOMED, tbl_route_maps.RTE_NUM, tbl_route_types.RTE_TYPE_MODE, tbl_route_types.RTE_TYPE_MODE_CODE FROM tbl_route_maps LEFT JOIN tbl_route_types ON tbl_route_maps.RTE_TYPE_GROOMED = tbl_route_types.RTE_TYPE WHERE RTE_SHP_FILE_FOLDER='1954_June' ORDER BY RTE_TYPE_MODE_CODE DESC, RTE_NUM;")
  }
  if(generateYear==1954){
    mapYear="1954_December"
    output_query<-paste0("SELECT tbl_route_maps.ID, tbl_route_maps.RTE_SHP_FILE_NAME, tbl_route_maps.RTE_SHP_FILE_FOLDER, tbl_route_maps.RTE_TYPE_GROOMED, tbl_route_maps.RTE_NUM, tbl_route_types.RTE_TYPE_MODE, tbl_route_types.RTE_TYPE_MODE_CODE FROM tbl_route_maps LEFT JOIN tbl_route_types ON tbl_route_maps.RTE_TYPE_GROOMED = tbl_route_types.RTE_TYPE WHERE RTE_SHP_FILE_FOLDER='1954_December' ORDER BY RTE_TYPE_MODE_CODE DESC, RTE_NUM;")
  }
  
  
  
  output_rs = dbSendQuery(routesDb,output_query)
  output_dbRows<-dbFetch(output_rs, 999999)
  if (nrow(output_dbRows)==0){
    print (paste("Problem: zero rows for ",output_query,sep=''))
    dbClearResult(output_rs)
  } else {
    for (i in 1:nrow(output_dbRows)) {
      print(output_dbRows[i, 1])
      print(output_dbRows[i, 2])
      dsn_temp<-paste0("C:\\a_orgs\\carleton\\hist3814\\R\\oc-transpo-maps-data\\route-maps\\",output_dbRows[i, 3])
      dsn_temp
      #"RTE_184_Limited Service_2002.shp"
      layer_temp = gsub(".shp","",output_dbRows[i, 2])
      layer_temp
      route <- readOGR(dsn = dsn_temp, layer = layer_temp)
      
      route <- spTransform(route, CRS("+proj=longlat +datum=WGS84"))
      #slotNames(route)
      #route@data
      
      #Correct for any non-standard names in the dataframe.
      #Do this when the data is loaded.
      routeDataDf<-route@data
      if("Mode" %in% colnames(route@data)){
        routeDataDf<-plyr::rename(routeDataDf, c("Mode"="MODE"))
      } else {
        if("mode" %in% colnames(route@data)){
          routeDataDf<-plyr::rename(routeDataDf, c("mode"="MODE"))
        }
      }
      if("RTE_Type" %in% colnames(route@data)){
        routeDataDf<-plyr::rename(routeDataDf, c("RTE_Type"="RTE_TYPE"))
      } 
      #The if statement below is to fix
      #RTE_RUM   RTE_TYPE MODE YEAR
      #0      152 Peak Route  Bus 2000
      if("RTE_RUM" %in% colnames(route@data)){
        routeDataDf<-plyr::rename(routeDataDf, c("RTE_RUM"="RTE_NUM"))
      }     
      
      #The if statement below is to fix
      #"RTE_094_RegularRoute_2014.shp"
      #It has 6 fields
      #Error in rbind(deparse.level, ...) :
      if("OBJECTID_1" %in% colnames(route@data)){
        routeDataDf$OBJECTID_1<-NULL
      }     
      if("Shape_Leng" %in% colnames(route@data)){
        routeDataDf$Shape_Leng<-NULL
      }
      # To Fix
      # [1] "RTE_099_RegularRoute_2014.shp"
      # It has 5 fields
      # Error in rbind(deparse.level, ...) : 
      #   numbers of columns of arguments do not match
      if("OBJECTID" %in% colnames(route@data)){
        routeDataDf$OBJECTID<-NULL
      }

      #summary(route)
      route@data<-routeDataDf
      
      if(i==1) {
        routesDf <- route
      }else{
        routesDf <- rbind(routesDf,route)
      }
      routeDf <- fortify(route)
      
      route_mode_code = output_dbRows[i, 7]
      routeColor<-'green'  
      routeSize<-.5    
      
      if(route_mode_code==0){
        routeColor<-'green4'
        routeSize<-.5
      } else {
        if(route_mode_code==1){
          routeColor<-'blue4'
          routeSize<-1
        } else {
          if(route_mode_code==2){
            routeColor<-'purple'
            routeSize<-1.5
          } else {
            if(route_mode_code==3){
              routeColor<-'turquoise'
              routeSize<-2
            } else {
              if(route_mode_code==4){
                routeColor<-'red'
                routeSize<-2.5
              } else {
                routeColor<-'yellow'
                routeSize<-1
              }    
            } 
          }
        }  
      }
      transitMap <- transitMap + geom_path(data=routeDf, mapping=aes(x=long, y=lat, group=group), size=routeSize, linejoin="round", color=routeColor)
    }

    #http://environmentalcomputing.net/plotting-with-ggplot-adding-titles-and-axis-names/
    mapTheme <- theme(plot.title = element_text(family = "Helvetica", face = "bold", size = (12)), 
                      legend.title = element_text(colour = "steelblue",  face = "bold.italic", family = "Helvetica"), 
                      legend.text = element_text(face = "italic", colour="steelblue4",family = "Helvetica"), 
                      axis.title = element_text(family = "Helvetica", size = (10), colour = "steelblue4"),
                      axis.text = element_text(family = "Courier", colour = "cornflowerblue", size = (10)))
    
    transitMap<-transitMap+mapTheme+ggtitle(paste0("Ottawa Transit Map for ",mapYear))
    transitMap$labels$subtitle=""
    transitMap
    
    #Write a shape file containing all of the routes for 1 year
    #I am no using these anymore for this project, but I am leaving this here to make sure that the shape files are updated when this is run.
    print(paste0("writing big SHP for ",mapYear))
    rgdal::writeOGR(obj=routesDf,dsn = "C:\\a_orgs\\carleton\\hist3814\\R\\oc-transpo-maps-data\\output", layer = paste0(mapYear,"_map"), driver="ESRI Shapefile",overwrite_layer=TRUE)
    
    #Write a geojson file containing all of the routes for 1 year
    #I am no longer loading one large geojson file into leaflet for this project (it does not perform well), but I am leaving this here to make sure that it gets updated when this is run.
    rgdal::writeOGR(obj=routesDf,dsn = paste0("C:\\a_orgs\\carleton\\hist3814\\R\\oc-transpo-maps-data\\output\\",mapYear,".geojson"), layer = paste0(mapYear,"_map"), driver="GeoJSON",overwrite_layer=TRUE)
    
    #Write a geojson for each RTE_TYPE so they can be added to the map individually
    output_query_route_style<-paste0("SELECT tbl_route_maps.RTE_TYPE, tbl_route_maps.RTE_TYPE_GROOMED, tbl_route_types.RTE_TYPE_MODE, tbl_route_types.RTE_TYPE_MODE_CODE, tbl_route_types.RTE_TYPE_MODE_CODE2, tbl_route_types.RTE_TYPE_MAP_COLOR FROM tbl_route_maps LEFT JOIN tbl_route_types ON tbl_route_maps.RTE_TYPE_GROOMED = tbl_route_types.RTE_TYPE WHERE YEAR=",mapYear," GROUP BY RTE_TYPE ORDER BY RTE_TYPE DESC;")
    #A kluge to use 1953, but worth it to avoid complexity
    if(generateYear==1953){
      mapYear="1954_June"    
      #output_query<-paste0("SELECT tbl_route_maps.ID, tbl_route_maps.RTE_SHP_FILE_NAME, tbl_route_maps.RTE_SHP_FILE_FOLDER, tbl_route_maps.RTE_TYPE_GROOMED, tbl_route_maps.RTE_NUM, tbl_route_types.RTE_TYPE_MODE, tbl_route_types.RTE_TYPE_MODE_CODE FROM tbl_route_maps LEFT JOIN tbl_route_types ON tbl_route_maps.RTE_TYPE_GROOMED = tbl_route_types.RTE_TYPE WHERE RTE_SHP_FILE_FOLDER='1954_June' ORDER BY RTE_TYPE_MODE_CODE DESC, RTE_NUM;")
      output_query_route_style<-paste0("SELECT tbl_route_maps.RTE_TYPE, tbl_route_maps.RTE_TYPE_GROOMED, tbl_route_types.RTE_TYPE_MODE, tbl_route_types.RTE_TYPE_MODE_CODE, tbl_route_types.RTE_TYPE_MODE_CODE2, tbl_route_types.RTE_TYPE_MAP_COLOR FROM tbl_route_maps LEFT JOIN tbl_route_types ON tbl_route_maps.RTE_TYPE_GROOMED = tbl_route_types.RTE_TYPE WHERE RTE_SHP_FILE_FOLDER='1954_June' GROUP BY RTE_TYPE ORDER BY RTE_TYPE DESC;")
    }
    if(generateYear==1954){
      mapYear="1954_December"
      #output_query<-paste0("SELECT tbl_route_maps.ID, tbl_route_maps.RTE_SHP_FILE_NAME, tbl_route_maps.RTE_SHP_FILE_FOLDER, tbl_route_maps.RTE_TYPE_GROOMED, tbl_route_maps.RTE_NUM, tbl_route_types.RTE_TYPE_MODE, tbl_route_types.RTE_TYPE_MODE_CODE FROM tbl_route_maps LEFT JOIN tbl_route_types ON tbl_route_maps.RTE_TYPE_GROOMED = tbl_route_types.RTE_TYPE WHERE RTE_SHP_FILE_FOLDER='1954_December' ORDER BY RTE_TYPE_MODE_CODE DESC, RTE_NUM;")
      output_query_route_style<-paste0("SELECT tbl_route_maps.RTE_TYPE, tbl_route_maps.RTE_TYPE_GROOMED, tbl_route_types.RTE_TYPE_MODE, tbl_route_types.RTE_TYPE_MODE_CODE, tbl_route_types.RTE_TYPE_MODE_CODE2, tbl_route_types.RTE_TYPE_MAP_COLOR FROM tbl_route_maps LEFT JOIN tbl_route_types ON tbl_route_maps.RTE_TYPE_GROOMED = tbl_route_types.RTE_TYPE WHERE RTE_SHP_FILE_FOLDER='1954_December' GROUP BY RTE_TYPE ORDER BY RTE_TYPE DESC;")
    }
    
    output_rs_route_style = dbSendQuery(routesDb,output_query_route_style)
    output_dbRows_route_style<-dbFetch(output_rs_route_style, 999999)
    if (nrow(output_dbRows_route_style)==0){
      print (paste0("Zero rows for ",mapYear))
      dbClearResult(output_rs_route_style)
    } else {
      for (i_route_style in 1:nrow(output_dbRows_route_style)) {
        print(paste0("Separate geojson file in year ", mapYear, " for "))
        print(output_dbRows_route_style[i_route_style, 1])
        #We have a nice dataframe of geographic data, we can write subsets of it for different uses, like individual geojson files for each route type
        just_RTE_TYPE <- subset(routesDf, RTE_TYPE==output_dbRows_route_style[i_route_style, 1])
        rgdal::writeOGR(obj=just_RTE_TYPE,dsn = paste0("C:\\a_orgs\\carleton\\hist3814\\R\\oc-transpo-maps-data\\output\\",mapYear,"-",gsub(" ", "-",output_dbRows_route_style[i_route_style, 1]),".geojson"), layer = paste0(mapYear,"-",output_dbRows_route_style[i_route_style, 1],"_map"), driver="GeoJSON",overwrite_layer=TRUE)
      }
      dbClearResult(output_rs_route_style)
    }
    dbClearResult(output_rs)
    
    #Write a geojson for each year MODE = Street Car or Train to a rail only map may be seen
    if(generateYear<2001){
      just_MODE <- subset(routesDf, MODE=="Street Car")
      rgdal::writeOGR(obj=just_MODE,dsn = paste0("C:\\a_orgs\\carleton\\hist3814\\R\\oc-transpo-maps-data\\output\\",mapYear,"_rail_only_map.geojson"), layer = paste0(mapYear,"_rail_only_map"), driver="GeoJSON",overwrite_layer=TRUE)
    }else{
      just_MODE <- subset(routesDf, MODE=="Train")
      rgdal::writeOGR(obj=just_MODE,dsn = paste0("C:\\a_orgs\\carleton\\hist3814\\R\\oc-transpo-maps-data\\output\\",mapYear,"_rail_only_map.geojson"), layer = paste0(mapYear,"_rail_only_map"), driver="GeoJSON",overwrite_layer=TRUE)
    }
  }
} 
# close for loop

# disconnect to clean up the connection to the database.
dbDisconnect(routesDb)
