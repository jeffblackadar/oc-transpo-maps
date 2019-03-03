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
#sampleRouteData <- read.csv(file="C:\\a_orgs\\carleton\\hist3814\\R\\oc-transpo-maps\\shp.csv", header=TRUE, sep=",")
#sampleRouteData
#dbWriteTable(routesDb, value = sampleRouteData, row.names = FALSE, name = "tbl_route_maps", append = TRUE ) 

#routeTypes <- read.csv(file="C:\\a_orgs\\carleton\\hist3814\\R\\oc-transpo-maps-data\\RTE_TYPE_raw.csv", header=TRUE, sep=",")
#routeTypes
#dbWriteTable(routesDb, value = routeTypes, row.names = FALSE, name = "tbl_route_types", append = TRUE ) 



# *** "One time" data load from SHP files
output_query<-paste("select * from tbl_route_maps where true",sep='')
output_rs = dbSendQuery(routesDb,output_query)
output_dbRows<-dbFetch(output_rs, 999999)
if (nrow(output_dbRows)==0){
  print (paste("Problem: zero rows for ",output_query,sep=''))
} else {
  for (i in 3801:nrow(output_dbRows)) {
    print(output_dbRows[i, 1])
    print(output_dbRows[i, 2])
    dsn_temp<-paste0("C:\\a_orgs\\carleton\\hist3814\\R\\oc-transpo-maps-data\\route-maps\\",output_dbRows[i, 3])
    dsn_temp
    layer_temp = gsub(" ","",gsub(".shp","",output_dbRows[i, 2]))
    layer_temp
    route <- readOGR(dsn = dsn_temp, layer_temp)
    
    output_query<-""
    
    output_query_2<-paste(", RTE_TYPE='",paste(route$RTE_TYPE[1],sep=""), "', Mode='",paste(route$Mode[1],sep=""), "'",sep="")
    
    if (route$YEAR[1]==1929 | route$YEAR[1]==1939 | route$YEAR[1]==1948) {
      output_query<-paste("UPDATE tbl_route_maps set YEAR=",paste(route$YEAR[1],sep=""), ", RTE_NAME='",paste(route$RTE_NAME[1],sep=""),"'", output_query_2, " WHERE id=",output_dbRows[i, 1],sep='')
    }
    else{
      output_query<-paste("UPDATE tbl_route_maps set YEAR=",paste(route$YEAR[1],sep=""), ", RTE_NUM='",paste(route$RTE_NUM[1],sep=""),"'",  output_query_2, " WHERE id=",output_dbRows[i, 1],sep='')
      #output_query
    }    
    if(nchar(output_query)>1) {
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
    
  groom_query<-paste0("select id, RTE_SHP_FILE_NAME, RTE_TYPE from tbl_route_maps where RTE_TYPE='",bad_RTE_TYPE,"'")
  groom_query_rs = dbSendQuery(db_RTE_TYPE,groom_query)
  groom_dbRows<-dbFetch(groom_query_rs, 999999)
  
  if (nrow(groom_dbRows)==0){
    print (paste0("Problem: zero rows for ",groom_query))
  } else {
    print(paste0("Updating: ",bad_RTE_TYPE," to ",good_RTE_TYPE, " for:"))
    for (i in 1:nrow(groom_dbRows)) {
      print(paste0(groom_dbRows[i, 1]," ",groom_dbRows[i, 2]," ",groom_dbRows[i, 3]))
      
    }
    
    groom_update_query<-paste0("UPDATE tbl_route_maps set RTE_TYPE='",good_RTE_TYPE,"' WHERE RTE_TYPE='",bad_RTE_TYPE,"'")
    print(groom_update_query)
    groom_rs = dbSendQuery(db_RTE_TYPE,groom_update_query)
    dbHasCompleted(groom_rs)
    dbClearResult(groom_rs)
  }
  dbClearResult(groom_query_rs)
  dbDisconnect(db_RTE_TYPE)
  return()
  
}


#groom_RTE_TYPE("4am to 6am only","Early Morning Only",routesDb)
#groom_RTE_TYPE("DemandResponsiveService","Demand Responsive Route",routesDb)
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





