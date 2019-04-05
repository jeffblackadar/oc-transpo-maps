require(rgdal)
#citation("rgdal")

# Trying to work with NCC urban growth
dsn_temp<-paste0("C:\\a_orgs\\carleton\\hist3814\\R\\oc-transpo-maps-data\\output")
dsn_temp
layer_temp = gsub(".shp","","ug.shp")
layer_temp
routeUG <- readOGR(dsn = dsn_temp, layer_temp)
routeUG@data
routeUG
plot(routeUG)
#rgdal::writeOGR(obj=routeUG,dsn = paste0("C:\\a_orgs\\carleton\\hist3814\\R\\oc-transpo-maps-data\\output\\urban_growth.geojson"), layer = paste0("urban_growth"), driver="GeoJSON",overwrite_layer=TRUE)

route2 <- subset(routeUG, YEAR=="1925/01/01")
route2@data
rgdal::writeOGR(obj=route2,dsn = paste0("C:\\a_orgs\\carleton\\hist3814\\R\\oc-transpo-maps-data\\output\\urban_growth_1925.geojson"), layer = paste0("urban_growth_1925"), driver="GeoJSON",overwrite_layer=TRUE)

route2 <- subset(routeUG, YEAR=="1945/01/01")
route2@data
rgdal::writeOGR(obj=route2,dsn = paste0("C:\\a_orgs\\carleton\\hist3814\\R\\oc-transpo-maps-data\\output\\urban_growth_1945.geojson"), layer = paste0("urban_growth_1945"), driver="GeoJSON",overwrite_layer=TRUE)

route2 <- subset(routeUG, YEAR=="1956/01/01")
route2@data
rgdal::writeOGR(obj=route2,dsn = paste0("C:\\a_orgs\\carleton\\hist3814\\R\\oc-transpo-maps-data\\output\\urban_growth_1956.geojson"), layer = paste0("urban_growth_1956"), driver="GeoJSON",overwrite_layer=TRUE)

route2 <- subset(routeUG, YEAR=="1976/01/01")
route2@data
rgdal::writeOGR(obj=route2,dsn = paste0("C:\\a_orgs\\carleton\\hist3814\\R\\oc-transpo-maps-data\\output\\urban_growth_1976.geojson"), layer = paste0("urban_growth_1976"), driver="GeoJSON",overwrite_layer=TRUE)

route2 <- subset(routeUG, YEAR=="1996/01/01")
route2@data
rgdal::writeOGR(obj=route2,dsn = paste0("C:\\a_orgs\\carleton\\hist3814\\R\\oc-transpo-maps-data\\output\\urban_growth_1996.geojson"), layer = paste0("urban_growth_1996"), driver="GeoJSON",overwrite_layer=TRUE)

route2 <- subset(routeUG, YEAR=="2008/01/01")
route2@data
rgdal::writeOGR(obj=route2,dsn = paste0("C:\\a_orgs\\carleton\\hist3814\\R\\oc-transpo-maps-data\\output\\urban_growth_2008.geojson"), layer = paste0("urban_growth_2008"), driver="GeoJSON",overwrite_layer=TRUE)

route2 <- subset(routeUG, YEAR=="2012/01/01")
route2@data
rgdal::writeOGR(obj=route2,dsn = paste0("C:\\a_orgs\\carleton\\hist3814\\R\\oc-transpo-maps-data\\output\\urban_growth_2012.geojson"), layer = paste0("urban_growth_2012"), driver="GeoJSON",overwrite_layer=TRUE)

# Not working that well - makes black and white tiffs
#read your TIFF file
#install.packages("raster")

library(raster)
onMap1927 <- raster("C:\\a_orgs\\carleton\\hist3814\\R\\oc-transpo-maps-data\\hist_maps\\HTDP63360K031G05_1927TIFF.tif")

onMap1927
plot(onMap1927)
e <- as(extent(435000, 455000, 5020000, 5040000), 'SpatialPolygons')
crs(e) <- "+proj=longlat +datum=WGS84 +no_defs"
r <- crop(onMap1927, e)
r
plot(r)
#ratify(r,"")
writeRaster(r, "C:\\a_orgs\\carleton\\hist3814\\R\\oc-transpo-maps-data\\hist_maps\\1927_3.tif", "GTiff", overwrite=TRUE)



# Moved to oc_2_census_geojson.r
# 
# 
# # Trying to work with 1971 census
# # Ottawa-Gatineau Census Geography Files
# #https://library.carleton.ca/find/gis/geospatial-data/ottawa-gatineau-census-geography-files
# #Get Census map
# dsn_temp<-paste0("C:\\a_orgs\\carleton\\hist3814\\R\\oc-transpo-maps-data\\census\\census_tracts\\1971\\ct_laundered")
# dsn_temp
# layer_temp = gsub(".shp","","1971_census_map.shp")
# layer_temp
# censusMap <- readOGR(dsn = dsn_temp, layer_temp)
# censusMap@data
# plot(censusMap)
# 
# #Population data
# #http://dc1.chass.utoronto.ca.proxy.library.carleton.ca/census/
# censusDf <- read.csv("C:\\a_orgs\\carleton\\hist3814\\R\\oc-transpo-maps-data\\census\\census_tracts\\1971\\1971_census_010_pop.csv", header=TRUE)
# censusDf
# 
# mergeGeo<-censusMap
# mergeGeo@data<-merge(censusMap@data, censusDf, all.x=TRUE)
# rbind(mergeGeo@data)
# plot(mergeGeo@data$totalPopulation)
# plot(mergeGeo)
# mergeGeo
# rgdal::writeOGR(obj=mergeGeo,dsn = paste0("C:\\a_orgs\\carleton\\hist3814\\R\\oc-transpo-maps-data\\census\\census_tracts\\1971\\1971_census_pop.geojson"), layer = paste0("census"), driver="GeoJSON",overwrite_layer=TRUE)
# 
# mergeGeo@data
# 
# mergeGeo2<-spTransform(mergeGeo,CRS("+init=epsg:4326"))
# mergeGeo2
# plot(mergeGeo2)
# rgdal::writeOGR(obj=mergeGeo2,dsn = paste0("C:\\a_orgs\\carleton\\hist3814\\R\\oc-transpo-maps-data\\census\\census_tracts\\1971\\1971_census_pop.geojson"), layer = paste0("census"), driver="GeoJSON",overwrite_layer=TRUE)
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# # Trying to work with 1971 census
# # Ottawa-Gatineau Census Geography Files
# #https://library.carleton.ca/find/gis/geospatial-data/ottawa-gatineau-census-geography-files
# #Get Census map
# dsn_temp<-paste0("C:\\a_orgs\\carleton\\hist3814\\R\\oc-transpo-maps-data\\census\\census_tracts\\1971\\ct_laundered")
# dsn_temp
# layer_temp = gsub(".shp","","1971_census_map.shp")
# layer_temp
# censusMap <- readOGR(dsn = dsn_temp, layer_temp)
# censusMap@data
# plot(censusMap)
# 
# #Population data
# #http://dc1.chass.utoronto.ca.proxy.library.carleton.ca/census/
# censusDf <- read.csv("C:\\a_orgs\\carleton\\hist3814\\R\\oc-transpo-maps-data\\census\\census_tracts\\1971\\1971_census_010_pop.csv", header=TRUE)
# censusDf
# 
# mergeGeo<-censusMap
# mergeGeo@data<-merge(censusMap@data, censusDf, all.x=TRUE)
# rbind(mergeGeo@data)
# plot(mergeGeo@data$totalPopulation)
# plot(mergeGeo)
# mergeGeo
# rgdal::writeOGR(obj=mergeGeo,dsn = paste0("C:\\a_orgs\\carleton\\hist3814\\R\\oc-transpo-maps-data\\census\\census_tracts\\1971\\1971_census_pop.geojson"), layer = paste0("census"), driver="GeoJSON",overwrite_layer=TRUE)
# 
# mergeGeo@data
# 
# mergeGeo2<-spTransform(mergeGeo,CRS("+init=epsg:4326"))
# mergeGeo2
# plot(mergeGeo2)
# rgdal::writeOGR(obj=mergeGeo2,dsn = paste0("C:\\a_orgs\\carleton\\hist3814\\R\\oc-transpo-maps-data\\census\\census_tracts\\1971\\1971_census_pop.geojson"), layer = paste0("census"), driver="GeoJSON",overwrite_layer=TRUE)
