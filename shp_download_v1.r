#This program downloads the SHP files to a directory an unzips them.  It just saves some manual work.  
#Does not work for 1954 since there are 2 for that year.
library(RCurl)

#Download ShapeFiles
destDir <- "C:\\a_orgs\\carleton\\hist3814\\R\\oc-transpo-maps\\route-maps"

for (downloadYear in 1970:2015){
  print(paste("The year is", downloadYear))

  url <- paste0('http://madgic.library.carleton.ca/deposit/maps/OCTranspo/SHP/TransitRoutes_',downloadYear,'.zip')
  if(url.exists(url)){
    file <- basename(url)
    download.file(url, file)
    unzip(file, exdir = destDir)
    #don't stress server, pause for a moment
    Sys.sleep(20)
  }
}
