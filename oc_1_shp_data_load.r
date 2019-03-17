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
#sampleRouteData <- read.csv(file="C:\\a_orgs\\carleton\\hist3814\\R\\oc-transpo-maps-data\\route-maps\\oc-shps.csv", header=TRUE, strip.white=TRUE, sep=",")
#sampleRouteData
#dbWriteTable(routesDb, value = sampleRouteData, row.names = FALSE, name = "tbl_route_maps", append = TRUE ) 

#routeTypes <- read.csv(file="C:\\a_orgs\\carleton\\hist3814\\R\\oc-transpo-maps-data\\RTE_TYPE_raw.csv", header=TRUE, strip.white=TRUE, sep=",")
#routeTypes
#dbWriteTable(routesDb, value = routeTypes, row.names = FALSE, name = "tbl_route_types", append = TRUE ) 

#Look at empty modes
#63	RTE_023_TrolleyBusRoute_1951.shp	1951_Routes	1951		023		Trolley Bus Route
#98	RTE_023_MotorCoachRoute_1954.shp	1954_December	1954		023		Motor Coach Route
#99	RTE_023_TrolleyBusRoute_1954.shp	1954_December	1954		023		Trolley Bus Route
#132	RTE_026_TrolleyBusRoute_1954.shp	1954_June	1954		026		Trolley Bus Route

#Look at empty RTE_TYPES
#11	BusRoute_Crerar_1939.shp	1939_Routes	1939	Crerar		Bus	
#22	BusRoute_Crerar_1948.shp	1948_Routes	1948	Crerar		Bus	
#5381	RTE_094_RegularRoute_2014.shp	2014_Routes	2014		094	Bus	
#5390	RTE_099_RegularRoute_2014.shp	2014_Routes	2014		099	Bus	

dsn_temp<-paste0("C:\\a_orgs\\carleton\\hist3814\\R\\oc-transpo-maps-data\\route-maps\\","1954_June")
dsn_temp
layer_temp = gsub(".shp","","RTE_026_TrolleyBusRoute_1954.shp")
layer_temp
route <- readOGR(dsn = dsn_temp, layer_temp)
route@data

dsn_temp<-paste0("C:\\a_orgs\\carleton\\hist3814\\R\\oc-transpo-maps-data\\route-maps\\","1948_Routes")
dsn_temp
layer_temp = gsub(".shp","","BusRoute_Crerar_1948.shp")
layer_temp
route <- readOGR(dsn = dsn_temp, layer_temp)
route@data
colnames(route@data)



# *** "One time" data load from SHP files
output_query<-paste("select * from tbl_route_maps where true",sep='')
#Use statement below to update a specific year
#output_query<-paste("select * from tbl_route_maps where YEAR=1954",sep='')
output_rs = dbSendQuery(routesDb,output_query)
output_dbRows<-dbFetch(output_rs, 999999)
if (nrow(output_dbRows)==0){
  print (paste("Problem: zero rows for ",output_query,sep=''))
} else {
  for (i in 1:nrow(output_dbRows)) {

    print(output_dbRows[i, 1])
    print(output_dbRows[i, 2])
    dsn_temp<-paste0("C:\\a_orgs\\carleton\\hist3814\\R\\oc-transpo-maps-data\\route-maps\\",output_dbRows[i, 3])
    dsn_temp
    layer_temp = gsub(".shp","",output_dbRows[i, 2])
    layer_temp
    route <- readOGR(dsn = dsn_temp, layer_temp)
    
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
    #summary(route)
    route@data<-routeDataDf
    
    output_query<-""
    
    output_query_2<-paste0(", RTE_TYPE='",paste0(route$RTE_TYPE[1]), "', RTE_TYPE_GROOMED='",paste0(route$RTE_TYPE[1]), "', MODE='",paste0(route$MODE[1]), "'")
    
    if (route$YEAR[1]==1929 | route$YEAR[1]==1939 | route$YEAR[1]==1948) {
      output_query<-paste0("UPDATE tbl_route_maps set YEAR=",paste0(route$YEAR[1]), ", RTE_NAME='",paste0(route$RTE_NAME[1]),"'", output_query_2, " WHERE id=",output_dbRows[i, 1])
    }
    else{
      output_query<-paste0("UPDATE tbl_route_maps set YEAR=",paste0(route$YEAR[1]), ", RTE_NUM='",paste0(route$RTE_NUM[1]),"'",  output_query_2, " WHERE id=",output_dbRows[i, 1])
      
    }    
    if(nchar(output_query)>1) {
      output_query
      output_rs = dbSendQuery(routesDb,output_query)
    }
  }
}
dbDisconnect(routesDb)



#Groom Route Types
groom_RTE_TYPE <- function(bad_RTE_TYPE, good_RTE_TYPE) {

  library(RMariaDB)
  #citation("RMariaDB")
  
  # R needs a full path to find the settings file.
  rmariadb.settingsfile<-"C:\\ProgramData\\MySQL\\MySQL Server 8.0\\oc_transpo_maps.cnf"
  
  rmariadb.db<-"oc_transpo_maps"
  db_RTE_TYPE<-dbConnect(RMariaDB::MariaDB(),default.file=rmariadb.settingsfile,group=rmariadb.db) 
  
  # list the table. This confirms we connected to the database.
  dbListTables(db_RTE_TYPE)
    
  groom_query<-paste0("select id, RTE_SHP_FILE_NAME, RTE_TYPE_GROOMED from tbl_route_maps where RTE_TYPE_GROOMED='",bad_RTE_TYPE,"'")
  groom_query_rs = dbSendQuery(db_RTE_TYPE,groom_query)
  groom_dbRows<-dbFetch(groom_query_rs, 999999)
  
  if (nrow(groom_dbRows)==0){
    print (paste0("Problem: zero rows for ",groom_query))
  } else {
    print(paste0("Updating: ",bad_RTE_TYPE," to ",good_RTE_TYPE, " for:"))
    for (i in 1:nrow(groom_dbRows)) {
      print(paste0(groom_dbRows[i, 1]," ",groom_dbRows[i, 2]," ",groom_dbRows[i, 3]))
      
    }
    
    groom_update_query<-paste0("UPDATE tbl_route_maps set RTE_TYPE_GROOMED='",good_RTE_TYPE,"' WHERE RTE_TYPE_GROOMED='",bad_RTE_TYPE,"'")
    print(groom_update_query)
    groom_rs = dbSendQuery(db_RTE_TYPE,groom_update_query)
    dbHasCompleted(groom_rs)
    dbClearResult(groom_rs)
  }
  dbClearResult(groom_query_rs)
  dbDisconnect(db_RTE_TYPE)
  return()
  
}


#groom_RTE_TYPE("4am to 6am only","Early Morning Only")
#groom_RTE_TYPE("DemandResponsiveService","Demand Responsive Route")
# groom_RTE_TYPE("ExpressRoute","Express Route")
# groom_RTE_TYPE("Limited Stops Route","Limited Service")
# groom_RTE_TYPE("LimitedService","Limited Service")
# groom_RTE_TYPE("OffPeakService","Off Peak Service")
# groom_RTE_TYPE("OffPeak","Off Peak Service")
# groom_RTE_TYPE("Peak","Peak Period Route")
# groom_RTE_TYPE("PeakHourExtension","Peak Period Extension")
# groom_RTE_TYPE("PeakPeriod","Peak Period Route")
# groom_RTE_TYPE("PeakPeriodExtension","Peak Period Extension")
# groom_RTE_TYPE("PeakPeriodRoute","Peak Period Route")
# groom_RTE_TYPE("PeakPeriodService","Peak Period Route")
# groom_RTE_TYPE("PeakRoute","Peak Period Route")
# groom_RTE_TYPE("GreenRoute","Green Route")
# groom_RTE_TYPE("RedRoute","Red Route")
# 
# groom_RTE_TYPE("RegularRoute","Regular Route")
# 
# 
# groom_RTE_TYPE("RuralExpressRoute","Rural Express Route")
# groom_RTE_TYPE("Rush Hour Bus Route","Peak Period Route")
# groom_RTE_TYPE("Peak Route","Peak Period Route")
# 
# groom_RTE_TYPE("SundayOnly","Sunday Only Route")
groom_RTE_TYPE("","Blank")
groom_RTE_TYPE(NULL,"Blank")





