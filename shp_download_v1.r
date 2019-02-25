#This program downloads the SHP files to a directory an unzips them.  It just saves some manual work.  

library(RCurl)

#Download ShapeFiles
destDir <- "C:\\a_orgs\\carleton\\hist3814\\R\\oc-transpo-maps-data\\route-maps"

for (downloadYear in 1971:2015){
  print(paste("The year is", downloadYear))

  #There are 2 files for 1954  
  if(downloadYear==1954){
    url <- paste0('http://madgic.library.carleton.ca/deposit/maps/OCTranspo/SHP/TransitRoutes_',downloadYear,'_June.zip')
    if(url.exists(url)){
      file <- basename(url)
      download.file(url, file)
      unzip(file, exdir = destDir)
      #don't stress server, pause for a moment
      Sys.sleep(20)
    }
    url <- paste0('http://madgic.library.carleton.ca/deposit/maps/OCTranspo/SHP/TransitRoutes_',downloadYear,'_Dec.zip')
    if(url.exists(url)){
      file <- basename(url)
      download.file(url, file)
      unzip(file, exdir = destDir)
      #don't stress server, pause for a moment
      Sys.sleep(20)
    }
    
    
  }
  else{
    url <- paste0('http://madgic.library.carleton.ca/deposit/maps/OCTranspo/SHP/TransitRoutes_',downloadYear,'.zip')
    if(url.exists(url)){
      file <- basename(url)
      download.file(url, file)
      unzip(file, exdir = destDir)
      #don't stress server, pause for a moment
      Sys.sleep(20)
    }
  }
}
