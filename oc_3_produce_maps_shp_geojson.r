#install.packages("RMariaDB")
#install.packages("rgdal")
#install.packages("sf")
#install.packages("ggmap")
#install.packages("RgoogleMaps")
#install.packages("svglite")

#
#Before starting this:
#do
#register_google(key = "hhh")

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

#library(svglite)
#citation("svglite")

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





for (generateYear in 1953:1954){
  
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
      layer_temp = gsub(" ","",gsub(".shp","",output_dbRows[i, 2]))
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
      #To fix
      #RTE_RUM   RTE_TYPE MODE YEAR
      #0      152 Peak Route  Bus 2000
      if("RTE_RUM" %in% colnames(route@data)){
        routeDataDf<-plyr::rename(routeDataDf, c("RTE_RUM"="RTE_NUM"))
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
      
      
      #transitMap <- transitMap + geom_polygon(aes(x=long, y=lat, group=group), fill='grey', size=.2,color=routeColor, data=route, alpha=0)
      transitMap <- transitMap + geom_path(data=routeDf, mapping=aes(x=long, y=lat, group=group), size=routeSize, linejoin="round", color=routeColor)
    }
    
    
    
    
    
    #plot(route,col="coral4", lwd=2)
    
    #http://environmentalcomputing.net/plotting-with-ggplot-adding-titles-and-axis-names/
    mapTheme <- theme(plot.title = element_text(family = "Helvetica", face = "bold", size = (12)), 
                      legend.title = element_text(colour = "steelblue",  face = "bold.italic", family = "Helvetica"), 
                      legend.text = element_text(face = "italic", colour="steelblue4",family = "Helvetica"), 
                      axis.title = element_text(family = "Helvetica", size = (10), colour = "steelblue4"),
                      axis.text = element_text(family = "Courier", colour = "cornflowerblue", size = (10)))
    
    transitMap<-transitMap+mapTheme+ggtitle(paste0("Ottawa Transit Map for ",mapYear))
    transitMap$labels$subtitle=""
    #transitMap<-transitMap+scale_color(c("green","red","blue"), breaks=c(1,2,3), labels=c("Regular","Peak","Train"))
    #transitMap$plot_env$legend.title="k"
    #transitMap$plot_env$legend.text="hh"
    #transitMap$plot_env$
    transitMap
    
    #Messing around here
    #transitMap <- transitMap + geom_polygon(data=routeUG, mapping=aes(x=long, y=lat, group=group), size=routeSize, fill='grey',  alpha=0, color="red")
    
    #                                       geom_polygon(aes(x=long, y=lat, group=group), fill='grey', size=.2,color=routeColor, data=route, alpha=0)
    #ggsave(filename="test.svg",plot=image,width=10,height=8,units="cm")
    #landUse <- readOGR(dsn = "C:\\a_orgs\\carleton\\hist3814\\R\\oc-transpo-maps-data\\Urban_Growth", layer = "UrbanGrowth_AllYears")
    #landUse <- spTransform(landUse, CRS("+proj=longlat +datum=WGS84"))
    #landUse <- fortify(landUse)
    #transitMap <- transitMap + geom_polygon(aes(x=long, y=lat, group=group), fill='grey', size=.2,color='green', data=landUse, alpha=0)
    #transitMap
    
    rgdal::writeOGR(obj=routesDf,dsn = "C:\\a_orgs\\carleton\\hist3814\\R\\oc-transpo-maps-data\\output", layer = paste0(mapYear,"_map"), driver="ESRI Shapefile",overwrite_layer=TRUE)
    
    rgdal::writeOGR(obj=routesDf,dsn = paste0("C:\\a_orgs\\carleton\\hist3814\\R\\oc-transpo-maps-data\\output\\",mapYear,".geojson"), layer = paste0(mapYear,"_map"), driver="GeoJSON",overwrite_layer=TRUE)
    dbClearResult(output_rs)
  }
} 
# close for loop
#route@lines
?#summary(routesDf)
  
  #writeOGR(inputJSON, "outTest.geojson", layer="inputJSON", driver="GeoJSON",check_exists = FALSE)
  
  #transitMap$plot_env$legend
  #transitMap <- ottawaMap
  #transitMap <- transitMap + geom_path(aes(x=long, y=lat, fill = "red", colour = "red"), size=1, shape = 1, data=route )
  #transitMap <- transitMap + geom_polygon(aes(x=long, y=lat, group=group), fill='grey', size=.2,color=routeColor, data=route, alpha=0)
  #transitMap
  #plot(shape)
  
  

#require(sf)
#shape <- read_sf(dsn = "C:\\a_orgs\\carleton\\hist3814\\R\\oc-transpo-maps\\route-maps\\1929_Routes", layer = "BusRoute_Crosstown_1929")

# disconnect to clean up the connection to the database.
dbDisconnect(routesDb)

