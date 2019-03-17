# This program downloads the SHP files to a directory an unzips them.  It just saves some manual work.  
# Side effect for Git
# Downloading all the Shapefiles into the R project directory resulted in anout 40k of files being added to the Git index.
# This slowed things down badly, and these files don't need to be in the project repository, so I removed them from the index
# git rm route-maps -r -f


library(RCurl)

#Download ShapeFiles to a directory outside of the R project.
destDir <- "C:\\a_orgs\\carleton\\hist3814\\R\\oc-transpo-maps-data\\route-maps"

#Specify the years to download in the for loop
for (downloadYear in 1971:2015){
  print(paste("The year is", downloadYear))

  #There are 2 files for 1954, so do this twice for June and Dec.
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
