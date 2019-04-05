require(rgdal)
#citation("rgdal")

censusPath <-"C:\\a_orgs\\carleton\\hist3814\\R\\oc-transpo-maps-data\\census\\census_tracts\\"

censusYears<-c(1961,1971)
for(cYr in 1:length(censusYears)){
  print(censusYears[cYr])
  
  censusDataYear <- censusYears[cYr]
  censusMapYear <-censusDataYear
  #no map for 1961
  if(censusDataYear==1961){
    censusMapYear <-1951
  }
  
  #Each year has a different file name for maps
  if(censusMapYear==1951){
    censusMapShapeFile <-"1951_Ottawa_CT.shp"
  }
  if(censusMapYear==1971){
    censusMapShapeFile <-"1971_ct.shp"
  }
  if(censusMapYear==1981){
    censusMapShapeFile <-"1981_OttawaHullCT_polygon.shp"
  }
  if(censusMapYear==1991){
    censusMapShapeFile <-"ct.shp"
  }  
  if(censusMapYear==2001){
    censusMapShapeFile <-"2001_Ottawa_CTs.shp"
  }  
  if(censusMapYear==2006){
    censusMapShapeFile <-"gct_505b06a_e.shp"
  }  
  if(censusMapYear==2011){
    censusMapShapeFile <-"gct_505b11a_e.shp"
  }  
  
  #1961 Autombile data with 1951 map
  
  # Ottawa-Gatineau Census Geography Files
  # https://library.carleton.ca/find/gis/geospatial-data/ottawa-gatineau-census-geography-files
  # Get Census map
  dsn_temp<-paste0(censusPath,"\\",censusMapYear,"\\ct")
  dsn_temp
  layer_temp = gsub(".shp","",censusMapShapeFile)
  layer_temp
  censusMap <- readOGR(dsn = dsn_temp, layer_temp)
  censusMap@data
  
  if(censusMapYear==1951){
  #Make match column for merge with auto data the same
  if("X51_CT_No" %in% colnames(censusMap@data)){
    censusMap@data<-plyr::rename(censusMap@data, c("X51_CT_No"="CT"))
  } 
  }
  plot(censusMap)
  censusMap@data
  
  #http://dc1.chass.utoronto.ca.proxy.library.carleton.ca/census/
  
  censusDf <- read.csv(paste0(censusPath,censusDataYear,"\\",censusDataYear,"_census_auto.csv"), header=TRUE)
  censusDf
  
  if(censusDataYear==1961){
  #Remove unneeded columns to keep geojson size small.
  
  if("prov_name" %in% colnames(censusDf)){
    censusDf$prov_name<-NULL
  } 
  if("prov_no" %in% colnames(censusDf)){
    censusDf$prov_no<-NULL
  } 
  if("county_census_div" %in% colnames(censusDf)){
    censusDf$county_census_div<-NULL
  } 
  if("mun_subdiv" %in% colnames(censusDf)){
    censusDf$mun_subdiv<-NULL
  } 
  if("mun_subdiv" %in% colnames(censusDf)){
    censusDf$mun_subdiv<-NULL
  } 
  if("mun" %in% colnames(censusDf)){
    censusDf$mun<-NULL
  } 
  if("mun_size" %in% colnames(censusDf)){
    censusDf$mun_size<-NULL
  }
  if("rural_urban_size" %in% colnames(censusDf)){
    censusDf$rural_urban_size<-NULL
  } 
  if("met_area" %in% colnames(censusDf)){
    censusDf$met_area<-NULL
  } 
  }
  censusDf
  
  
  mergeGeo<-censusMap
  mergeGeo@data<-merge(censusMap@data, censusDf, all.x=TRUE)
  rbind(mergeGeo@data)
  plot(mergeGeo@data$auto_one)
  plot(mergeGeo)
  mergeGeo
  
  mergeGeo@data
  
  mergeGeo2<-spTransform(mergeGeo,CRS("+init=epsg:4326"))
  
  #calculate % of automobile ownership
  if(censusDataYear==1961){
    mergeGeo2@data<-transform(mergeGeo2@data, auto_total=auto_none+auto_one+auto_two)  
  }
  
  if(censusDataYear==1971){
    mergeGeo2@data<-transform(mergeGeo2@data, dwelling_total=D19001945+D19461960+D19611970+D1971)
    #total dwellings = total automobile population (none, one, two+)
    mergeGeo2@data<-transform(mergeGeo2@data, auto_total=dwelling_total)
    #remove columns we no longer need to calculate % of automobile ownership
    if("D19001945" %in% colnames(mergeGeo2@data)){
      mergeGeo2@data$D19001945<-NULL
    }
    if("D19461960" %in% colnames(mergeGeo2@data)){
      mergeGeo2@data$D19461960<-NULL
    } 
    if("D19611970" %in% colnames(mergeGeo2@data)){
      mergeGeo2@data$D19611970<-NULL
    } 
    if("D1971" %in% colnames(mergeGeo2@data)){
      mergeGeo2@data$D1971<-NULL
    } 
    if("dwelling_total" %in% colnames(mergeGeo2@data)){
      mergeGeo2@data$dwelling_total<-NULL
    } 
    mergeGeo2@data<-transform(mergeGeo2@data, auto_none=auto_total-auto_one-auto_two)
  }
  
  #mergeGeo2@data$auto_total = sum(mergeGeo2@data$auto_none,mergeGeo2@data$auto_one,mergeGeo2@data$auto_two)
  mergeGeo2@data
  
  mergeGeo2@data<-transform(mergeGeo2@data, auto_none_100=round((auto_none/auto_total*100),digits=0))
  mergeGeo2@data<-transform(mergeGeo2@data, auto_one_100=round((auto_one/auto_total*100),digits=0))
  mergeGeo2@data<-transform(mergeGeo2@data, auto_two_100=round((auto_two/auto_total*100),digits=0))
  
  #Check the data.  due to rounding some % total 99 and 101 - ok for map coloring
  #mergeGeo2@data<-transform(mergeGeo2@data, auto_100_check=auto_none_100+auto_one_100+auto_two_100)
  mergeGeo2
  plot(mergeGeo2)
  mergeGeo2@data
  rgdal::writeOGR(obj=mergeGeo2,dsn = paste0(censusPath,censusDataYear,"\\",censusDataYear,"_census_auto.geojson"), layer = paste0("census"), driver="GeoJSON",overwrite_layer=TRUE)
  
}





# Trying to work with 1971 census
# Ottawa-Gatineau Census Geography Files
#https://library.carleton.ca/find/gis/geospatial-data/ottawa-gatineau-census-geography-files
#Get Census map
dsn_temp<-paste0("C:\\a_orgs\\carleton\\hist3814\\R\\oc-transpo-maps-data\\census\\census_tracts\\1971\\ct_laundered")
dsn_temp
layer_temp = gsub(".shp","","1971_census_map.shp")
layer_temp
censusMap <- readOGR(dsn = dsn_temp, layer_temp)
censusMap@data
plot(censusMap)

#Population data
#http://dc1.chass.utoronto.ca.proxy.library.carleton.ca/census/
censusDf <- read.csv("C:\\a_orgs\\carleton\\hist3814\\R\\oc-transpo-maps-data\\census\\census_tracts\\1971\\1971_census_010_pop.csv", header=TRUE)
censusDf

mergeGeo<-censusMap
mergeGeo@data<-merge(censusMap@data, censusDf, all.x=TRUE)
rbind(mergeGeo@data)
plot(mergeGeo@data$totalPopulation)
plot(mergeGeo)
mergeGeo
rgdal::writeOGR(obj=mergeGeo,dsn = paste0("C:\\a_orgs\\carleton\\hist3814\\R\\oc-transpo-maps-data\\census\\census_tracts\\1971\\1971_census_pop.geojson"), layer = paste0("census"), driver="GeoJSON",overwrite_layer=TRUE)

mergeGeo@data

mergeGeo2<-spTransform(mergeGeo,CRS("+init=epsg:4326"))
mergeGeo2
plot(mergeGeo2)
rgdal::writeOGR(obj=mergeGeo2,dsn = paste0("C:\\a_orgs\\carleton\\hist3814\\R\\oc-transpo-maps-data\\census\\census_tracts\\1971\\1971_census_pop.geojson"), layer = paste0("census"), driver="GeoJSON",overwrite_layer=TRUE)
