#install.packages("rgdal")
#install.packages("sf")
#install.packages("ggmap")
#install.packages("RgoogleMaps")

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

ottawa <- get_map(c(lon=centerOfMap$lon, lat=centerOfMap$lat),zoom = 12, maptype = "terrain", source = "stamen")
ottawa <- get_map(c(lon=-75.69812, lat=45.41117),zoom = 12, maptype = "terrain", source = "stamen")
ottawaMap <- ggmap(ottawa)
ottawaMap

#need a zoom of 9 to get the formerTownships in
#won't use former townhips for now
#formerTownships <- readOGR(dsn = "C:\\a_orgs\\carleton\\hist3814\\R\\oc-transpo-maps\\former-townships", layer = "former-townships")
#formerTownships <- spTransform(formerTownships, CRS("+proj=longlat +datum=WGS84"))
#formerTownships <- fortify(formerTownships)
#ottawaMap <- ottawaMap + geom_polygon(aes(x=long, y=lat, group=group), fill='grey', size=.2,color='purple', data=formerTownships, alpha=0)

#-------------
# Single route plotted
route <- readOGR(dsn = "C:\\a_orgs\\carleton\\hist3814\\R\\oc-transpo-maps\\route-maps\\2015_Routes", layer = "RTE_001_RegularRoute_2015")
#spTransform allows us to convert and transform between different mapping projections and datums.
#Credit to https://www.r-bloggers.com/shapefile-polygons-plotted-on-google-maps-using-ggmap-in-r-throw-some-throw-some-stats-on-that-mappart-2/


route <- spTransform(route, CRS("+proj=longlat +datum=WGS84"))

route <- fortify(route)
transitMap <- ottawaMap + geom_polygon(aes(x=long, y=lat, group=group), fill='grey', size=.2,color='green', data=route, alpha=0)
transitMap



#--------------

transitMap <- ottawaMap

output_query<-paste("select * from tbl_route_maps where YEAR=1973",sep='')
output_rs = dbSendQuery(routesDb,output_query)
output_dbRows<-dbFetch(output_rs, 999999)
if (nrow(output_dbRows)==0){
  print (paste("Problem: zero rows for ",output_query,sep=''))
} else {
  for (i in 1:nrow(output_dbRows)) {
    print(output_dbRows[i, 1])
    print(output_dbRows[i, 2])
    dsn_temp<-paste("C:\\a_orgs\\carleton\\hist3814\\R\\oc-transpo-maps-data\\route-maps\\",output_dbRows[i, 3],sep='')
    dsn_temp
    layer_temp = gsub(" ","",gsub(".shp","",output_dbRows[i, 2]))
    layer_temp
    route <- readOGR(dsn = dsn_temp, layer = layer_temp)
    
    route <- spTransform(route, CRS("+proj=longlat +datum=WGS84"))
    
    route <- fortify(route)
    
    routeColor<-'green'  
    routeSize<-.4
    if(output_dbRows[i, 8]=="Suburban Car Line" | output_dbRows[i, 8]=="Express Route"){
      routeColor<-'purple'  
      routeSize<-2
    }else {
      if(output_dbRows[i, 8]=="City Car Line" | output_dbRows[i, 8]=="Peak Route"){
        routeColor<-'red'  
        routeSize<-1
      }
    }
    
    #transitMap <- transitMap + geom_polygon(aes(x=long, y=lat, group=group), fill='grey', size=.2,color=routeColor, data=route, alpha=0)
    transitMap <- transitMap + geom_path(data=route, mapping=aes(x=long, y=lat, group=group), size=routeSize, linejoin="round", color=routeColor)
  }
}

#plot(route,col="coral4", lwd=2)
transitMap
summary(route)



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
