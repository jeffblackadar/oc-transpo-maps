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
