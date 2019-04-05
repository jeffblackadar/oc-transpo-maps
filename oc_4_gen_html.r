library(RMariaDB)

# R needs a full path to find the settings file.
rmariadb.settingsfile<-"C:\\ProgramData\\MySQL\\MySQL Server 8.0\\oc_transpo_maps.cnf"

rmariadb.db<-"oc_transpo_maps"
routesDb<-dbConnect(RMariaDB::MariaDB(),default.file=rmariadb.settingsfile,group=rmariadb.db) 

# list the table. This confirms we connected to the database.
dbListTables(routesDb)


#Generate links
pageLinks="";
for (generateYear in 1929:2015){
  
  print(paste0("Making links for year ", generateYear))
  
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
    dbClearResult(output_rs)
  } else {
    pageLinks<-paste0(pageLinks,"<a href='",mapYear,".html'>",mapYear,"</a> | ")
    dbClearResult(output_rs)
  }
}



for (generateYear in 1929:2015){
  
  
  
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
    print (paste0("Zero rows for ",mapYear))
    dbClearResult(output_rs)
    
  } else {
    print(paste0("Generating maps and geojson for year ", mapYear))  
    #which urban growth year to use?
    urbanGrowthYear=1925
    if(generateYear>=1929 & generateYear<1945){
      urbanGrowthYear=1925  
    } else {
      if(generateYear>=1945 & generateYear<1956){
        urbanGrowthYear=1945  
      } else {
        if(generateYear>=1956 & generateYear<1976){
          urbanGrowthYear=1956  
        } else {
          if(generateYear>=1976 & generateYear<1996){
            urbanGrowthYear=1976  
          } else {
            if(generateYear>=1996 & generateYear<2008){
              urbanGrowthYear=1996  
            } else {
              if(generateYear>=2008 & generateYear<2012){
                urbanGrowthYear=2008  
              } else {
                if(generateYear>=2012 & generateYear<2016){
                  urbanGrowthYear=2012  
                } else {
                  #This would be a problem.
                  urbanGrowthYear=1925              
                }
              }
            }
          }
        }
      }  
    }
    
    censusYear=0
    censusCMA_no=10
    if(generateYear>=1961 & generateYear<1971){
      censusYear=1961
      censusCMA_no=6
    } else {
      if(generateYear>=1971 & generateYear<1976){
        censusYear=1971  
        censusCMA_no=10
      } 
    }
    
    
    dbClearResult(output_rs)
    outputFileHtml <- paste0("C:\\a_orgs\\carleton\\hist3814\\R\\oc-transpo-maps-data\\output\\",mapYear,".html")
    outputFileHtmlCon<-file(outputFileHtml, open = "w")

    writeLines('<!DOCTYPE html>', outputFileHtmlCon)
    writeLines('  <html>', outputFileHtmlCon)
    writeLines('  <head><meta http-equiv="Content-Type" content="text/html; charset=utf-8">', outputFileHtmlCon)
    writeLines(paste0("<!-- Global site tag (gtag.js) - Google Analytics -->"), outputFileHtmlCon)
    writeLines(paste0('  <script async src="https://www.googletagmanager.com/gtag/js?id=UA-137783752-1"></script>'), outputFileHtmlCon)
    writeLines(paste0("  <script>"), outputFileHtmlCon)
    writeLines(paste0("  window.dataLayer = window.dataLayer || [];"), outputFileHtmlCon)
    writeLines(paste0("function gtag(){dataLayer.push(arguments);}"), outputFileHtmlCon)
    writeLines(paste0("gtag('js', new Date());"), outputFileHtmlCon)
    writeLines(paste0("gtag('config', 'UA-137783752-1');"), outputFileHtmlCon)
    writeLines(paste0("</script>"), outputFileHtmlCon)
      
    
    writeLines(paste0('  <title>Ottawa Mass Transit Maps ',mapYear,'</title>'), outputFileHtmlCon)
    writeLines('  <link href="http://cdn.leafletjs.com/leaflet-0.6.4/leaflet.css" rel="stylesheet" /><script src="http://cdn.leafletjs.com/leaflet-0.6.4/leaflet.js"></script><script src="https://code.jquery.com/jquery-2.1.4.min.js"></script>', outputFileHtmlCon)
    writeLines('  <style type="text/css">#my-map {', outputFileHtmlCon)
    writeLines('  width:960px;', outputFileHtmlCon)
    writeLines('  height:700px;', outputFileHtmlCon)
    writeLines('}', outputFileHtmlCon)
    writeLines('h1 {', outputFileHtmlCon)
    writeLines('  color: #AA0000;', outputFileHtmlCon)
    writeLines('  font-size: 24px;', outputFileHtmlCon)
    writeLines('  font-family: verdana;', outputFileHtmlCon)
    writeLines('}', outputFileHtmlCon)
    writeLines('h2 {', outputFileHtmlCon)
    writeLines('  color: #000000;', outputFileHtmlCon)
    writeLines('  font-size: 20px;', outputFileHtmlCon)
    writeLines('  font-family: verdana;', outputFileHtmlCon)
    writeLines('}', outputFileHtmlCon)
    writeLines('h3 {', outputFileHtmlCon)
    writeLines('  color: #000000;', outputFileHtmlCon)
    writeLines('  font-size: 16px;', outputFileHtmlCon)
    writeLines('  font-family: verdana;', outputFileHtmlCon)
    writeLines('}', outputFileHtmlCon)    
    writeLines('p {', outputFileHtmlCon)
    writeLines('  color: #996600;', outputFileHtmlCon)
    writeLines('  font-family: verdana;', outputFileHtmlCon)
    writeLines('}', outputFileHtmlCon)
    writeLines('th {', outputFileHtmlCon)
    writeLines('  text-align: right;', outputFileHtmlCon)
    writeLines('  font-family: verdana;', outputFileHtmlCon)
    writeLines('  color: #663300;', outputFileHtmlCon)
    writeLines('}', outputFileHtmlCon)
    writeLines('td {', outputFileHtmlCon)
    writeLines('  text-align: right;', outputFileHtmlCon)
    writeLines('  font-family: verdana;', outputFileHtmlCon)
    writeLines('  color: #663300;', outputFileHtmlCon)
    writeLines('}', outputFileHtmlCon)
    writeLines('</style>', outputFileHtmlCon)
    writeLines('  </head>', outputFileHtmlCon)
    writeLines('  <body>', outputFileHtmlCon)
    writeLines('  <p><a href="https://github.com/jeffblackadar/oc-transpo-maps/blob/master/oc_tips.md">Instructions</a>: Click on map features. Scroll down. | <a href="https://github.com/jeffblackadar/oc-transpo-maps/blob/master/oc_about.md">About the project</a> | * Draft work in progress *</p>', outputFileHtmlCon)
    writeLines('  <div id="my-map"></div>', outputFileHtmlCon)
    writeLines('    <script>', outputFileHtmlCon)
    writeLines('    // This file was generated by this R program:  https://github.com/jeffblackadar/oc-transpo-maps/blob/master/oc_4_gen_html.r')
    writeLines('    var geojsonLayer;', outputFileHtmlCon)
    writeLines('  var geojson;', outputFileHtmlCon)
    writeLines('  var geojson2;', outputFileHtmlCon)
    writeLines('  var map;', outputFileHtmlCon)
    
    writeLines(paste0("function colorValue(percent) {"), outputFileHtmlCon)
    writeLines(paste0("   if(percent>100) {percent=100;}"), outputFileHtmlCon)
    writeLines(paste0("   if(percent<0) {percent=0;}"), outputFileHtmlCon)
    writeLines(paste0("   hex = ((percent/100*255) >> 0).toString(16);"), outputFileHtmlCon)
    writeLines(paste0("   if(hex.length==1){"), outputFileHtmlCon)
    writeLines(paste0("      hex='0'+hex;"), outputFileHtmlCon)
    writeLines(paste0("   }"), outputFileHtmlCon)
    writeLines(paste0("   return hex;"), outputFileHtmlCon) 
    writeLines(paste0("}"), outputFileHtmlCon)
    writeLines(paste0(''), outputFileHtmlCon)
    writeLines(paste0('  window.onload = function() {'), outputFileHtmlCon)
    # Some early years have historical maps available. Load these as the basemap instead of OpenStreetMap
    if(generateYear>=1929 & generateYear<1939){
      writeLines(paste0("var basemap = L.tileLayer('http://www.jeffblackadar.ca/oc-transpo/1927/{z}/{x}/{y}.png', {"), outputFileHtmlCon)
      writeLines(paste0("      attribution: '",'<a href="http://geo1.scholarsportal.info">Scholars Geoportal</a>',' | <a href="https://library.carleton.ca/find/gis/geospatial-data/oc-transpo-transit-routes">MacOdrum Library</a>',"'"), outputFileHtmlCon)
      writeLines("    });", outputFileHtmlCon)
      basemapTitle="Topo. Map 1927"
    }else{
      if(generateYear>=1939 & generateYear<1948){
        writeLines(paste0("var basemap = L.tileLayer('http://www.jeffblackadar.ca/oc-transpo/1939/{z}/{x}/{y}.png', {"), outputFileHtmlCon)
        writeLines(paste0("      attribution: '",'<a href="http://geo1.scholarsportal.info">Scholars Geoportal</a>',' | <a href="https://library.carleton.ca/find/gis/geospatial-data/oc-transpo-transit-routes">MacOdrum Library</a>',"'"), outputFileHtmlCon)
        writeLines("    });", outputFileHtmlCon)
        basemapTitle="Topo. Map 1939"
      }else{
        if(generateYear>=1948 & generateYear<1953){
          writeLines(paste0("var basemap = L.tileLayer('http://www.jeffblackadar.ca/oc-transpo/1948/{z}/{x}/{y}.png', {"), outputFileHtmlCon)
          writeLines(paste0("      attribution: '",'<a href="http://geo1.scholarsportal.info">Scholars Geoportal</a>',' | <a href="https://library.carleton.ca/find/gis/geospatial-data/oc-transpo-transit-routes">MacOdrum Library</a>',"'"), outputFileHtmlCon)
          writeLines("    });", outputFileHtmlCon)
          basemapTitle="Topo. Map 1948"
        }else{
          writeLines("    var basemap = L.tileLayer('http://{s}.tile.osm.org/{z}/{x}/{y}.png', {", outputFileHtmlCon)
          writeLines(paste0("      attribution: '&copy; ",'<a href="http://osm.org/copyright">OpenStreetMap</a>',' contributors | <a href="https://library.carleton.ca/find/gis/geospatial-data/oc-transpo-transit-routes">MacOdrum Library</a>',"'"), outputFileHtmlCon)
          writeLines("    });", outputFileHtmlCon)
          basemapTitle="Open Street Map Today"
          
        }
      }
    }
  
    writeLines(paste0(""), outputFileHtmlCon)
    writeLines(paste0('    $.getJSON("urban_growth_',urbanGrowthYear,'.geojson", function(data) {'), outputFileHtmlCon)
    writeLines(paste0('      geojson = L.geoJson(data, {'), outputFileHtmlCon)
    writeLines(paste0("      });"), outputFileHtmlCon)
    
    writeLines("", outputFileHtmlCon)      
    writeLines("", outputFileHtmlCon)
    writeLines("      map = L.map('my-map')", outputFileHtmlCon)
    writeLines("      .fitBounds(geojson.getBounds());", outputFileHtmlCon)
    writeLines("      //    .setView([0.0,-10.0], 2);", outputFileHtmlCon)
    writeLines("      basemap.addTo(map);", outputFileHtmlCon)
    #writeLines("      geojson.addTo(map);", outputFileHtmlCon)
    writeLines("", outputFileHtmlCon)      
    writeLines("      // add legend control layers - global variable with (null, null) allows indiv basemaps and overlays to be added inside functions below", outputFileHtmlCon)
    writeLines("      var controlLayers = L.control.layers(null, null, {", outputFileHtmlCon)
    writeLines('        position: "topright",', outputFileHtmlCon)
    writeLines("        collapsed: false // false = open by default", outputFileHtmlCon)
    writeLines("      }).addTo(map);", outputFileHtmlCon)
    writeLines("", outputFileHtmlCon)   

    #routeTypes is used for the documentation below the map.
    routeTypes=""
    
    if(censusYear==1961 | censusYear==1971){
      
      
      writeLines(paste0("// Census"), outputFileHtmlCon)
      writeLines(paste0("   $.ajax({"), outputFileHtmlCon)
      writeLines(paste0("      type: 'POST',"), outputFileHtmlCon)
      writeLines(paste0("      url: '",censusYear,"_census_auto.geojson',"), outputFileHtmlCon)
      writeLines(paste0("      dataType: 'json',"), outputFileHtmlCon)
      writeLines(paste0("      success: function(response) {"), outputFileHtmlCon)
      writeLines(paste0("         censusAutoLayer = L.geoJson(response, {"), outputFileHtmlCon)
      writeLines(paste0("         "), outputFileHtmlCon)
      writeLines(paste0("         onEachFeature: function (feature, layer) {"), outputFileHtmlCon)
      writeLines(paste0("            "), outputFileHtmlCon)
      writeLines(paste0("            if(feature.properties.CMA_no==",censusCMA_no,"){"), outputFileHtmlCon)
      #writeLines(paste0("               layer.bindPopup('<h3>Census 1961 '+feature.properties.CMA_name+'</h3><p>CMA number: '+feature.properties.CMA_no+'<br>No Automobile: '+feature.properties.auto_none+' '+feature.properties.auto_none_100+'%<br>One Automobile: '+feature.properties.auto_one+' '+feature.properties.auto_one_100+'%<br>Two Automobiles: '+feature.properties.auto_two+' '+feature.properties.auto_two_100+'%</p>');"), outputFileHtmlCon)
      writeLines(paste0("               layer.bindPopup('<h3>Census ",censusYear," '+feature.properties.CMA_name+'</h3><table><tr><td>No Automobile:</td><td>'+feature.properties.auto_none+'</td><td>'+feature.properties.auto_none_100+'%</td></tr><tr><td>One Automobile:</td><td>'+feature.properties.auto_one+'</td><td>'+feature.properties.auto_one_100+'%</td></tr><tr><td>Two Automobiles:</td><td>'+feature.properties.auto_two+'</td><td>'+feature.properties.auto_two_100+'%</td></tr><tr><td>CMA number:</td><td>'+feature.properties.CMA_no+'</td><td></td></tr><td>Census Tract:</td><td>'+feature.properties.CT+'</td><td></td></tr><table>');"), outputFileHtmlCon)
      writeLines(paste0("               layer.setStyle({"), outputFileHtmlCon)
      writeLines(paste0("                  color: 'white',"), outputFileHtmlCon)
      writeLines(paste0("                  fillColor: '#'+colorValue(feature.properties.auto_two_100)+colorValue(feature.properties.auto_two_100)+colorValue(feature.properties.auto_two_100),"), outputFileHtmlCon)
      writeLines(paste0("                  weight: 0,"), outputFileHtmlCon)
      writeLines(paste0("                  opacity: 0,"), outputFileHtmlCon)
      writeLines(paste0("                  fillOpacity: .7"), outputFileHtmlCon)
      writeLines(paste0("                });"), outputFileHtmlCon)
      writeLines(paste0("             }"), outputFileHtmlCon)
      writeLines(paste0("             else{"), outputFileHtmlCon)
      writeLines(paste0("                layer.setStyle({"), outputFileHtmlCon)
      writeLines(paste0("                   color: 'white',"), outputFileHtmlCon)
      writeLines(paste0("                   weight: 0,"), outputFileHtmlCon)
      writeLines(paste0("                   opacity: 0"), outputFileHtmlCon)
      writeLines(paste0("                });"), outputFileHtmlCon)
      writeLines(paste0("             }"), outputFileHtmlCon)
      writeLines(paste0("          }"), outputFileHtmlCon)
      writeLines(paste0("       });"), outputFileHtmlCon)
      writeLines(paste0("          censusAutoLayer.addTo(map);"), outputFileHtmlCon)
      writeLines(paste0("          controlLayers.addOverlay(censusAutoLayer, '% no Automobile owned, ",censusYear," census');"), outputFileHtmlCon)
      writeLines(paste0("        }"), outputFileHtmlCon)
      writeLines(paste0("      });"), outputFileHtmlCon)
      writeLines(paste0(""), outputFileHtmlCon)
    }
    
    # rework this, like above
    if(generateYear==2929){
    writeLines(paste0("// Census"), outputFileHtmlCon)
    writeLines(paste0("   $.ajax({"), outputFileHtmlCon)
    writeLines(paste0("      type: 'POST',"), outputFileHtmlCon)
    writeLines(paste0("      url: 'http://jeffblackadar.ca/oc-transpo/1971_census_pop.geojson',"), outputFileHtmlCon)
    writeLines(paste0("      dataType: 'json',"), outputFileHtmlCon)
    writeLines(paste0("      success: function(response) {"), outputFileHtmlCon)
    writeLines(paste0("         censusPopLayer = L.geoJson(response, {"), outputFileHtmlCon)
    writeLines(paste0("         "), outputFileHtmlCon)
    writeLines(paste0("         onEachFeature: function (feature, layer) {"), outputFileHtmlCon)
    writeLines(paste0("            "), outputFileHtmlCon)
    writeLines(paste0("            if(feature.properties.CMAno==10){"), outputFileHtmlCon)
    writeLines(paste0("               layer.bindPopup('<h3>Census 1971 '+feature.properties.CMAname+'</h3><p>CMA number: '+feature.properties.CMAno+'</p><p>Population: '+feature.properties.totalPopulation+'</p>');"), outputFileHtmlCon)
    writeLines(paste0("                  layer.setStyle({"), outputFileHtmlCon)
    writeLines(paste0("                  color: 'yellow',"), outputFileHtmlCon)
    writeLines(paste0("                  weight: 1"), outputFileHtmlCon)
    writeLines(paste0("                });"), outputFileHtmlCon)
    writeLines(paste0("             }"), outputFileHtmlCon)
    writeLines(paste0("             else{"), outputFileHtmlCon)
    writeLines(paste0("                layer.setStyle({"), outputFileHtmlCon)
    writeLines(paste0("                   color: 'white',"), outputFileHtmlCon)
    writeLines(paste0("                   weight: 0,"), outputFileHtmlCon)
    writeLines(paste0("                   opacity: 0"), outputFileHtmlCon)
    writeLines(paste0("                });"), outputFileHtmlCon)
    writeLines(paste0("             }"), outputFileHtmlCon)
    writeLines(paste0("          }"), outputFileHtmlCon)
    writeLines(paste0("       });"), outputFileHtmlCon)
    writeLines(paste0("          censusPopLayer.addTo(map);"), outputFileHtmlCon)
    writeLines(paste0("          controlLayers.addOverlay(censusPopLayer, 'Population ",urbanGrowthYear,"');"), outputFileHtmlCon)
    writeLines(paste0("//          map.fitBounds(censusPopLayer.getBounds());"), outputFileHtmlCon)
    writeLines(paste0("        }"), outputFileHtmlCon)
    writeLines(paste0("      });"), outputFileHtmlCon)
    writeLines(paste0(""), outputFileHtmlCon)
    }
    
        
    writeLines("// Urban extent", outputFileHtmlCon)
    writeLines("      $.ajax({", outputFileHtmlCon)
    writeLines("        type: 'POST',", outputFileHtmlCon)
    writeLines(paste0("        url: 'urban_growth_",urbanGrowthYear,".geojson',"), outputFileHtmlCon)
    writeLines("        dataType: 'json',", outputFileHtmlCon)
    writeLines("        success: function(response) {", outputFileHtmlCon)
    writeLines("          geojsonLayer = L.geoJson(response);", outputFileHtmlCon)
    writeLines("          geojsonLayer.setStyle({", outputFileHtmlCon)
    writeLines("            color: 'brown',", outputFileHtmlCon)
    writeLines("            weight: 1", outputFileHtmlCon)
    writeLines("          });", outputFileHtmlCon)
    #This popup seems to displace the popup for the routes.
    writeLines(paste0("          geojsonLayer.bindPopup('Urban extent ",urbanGrowthYear,".')"), outputFileHtmlCon)
    writeLines("          geojsonLayer.addTo(map);", outputFileHtmlCon)
    writeLines(paste0("          controlLayers.addOverlay(geojsonLayer, '", '<span style=','"color:brown">',"Urban Extent ",urbanGrowthYear,"</span>');"), outputFileHtmlCon)
    writeLines("          map.fitBounds(geojsonLayer.getBounds());", outputFileHtmlCon)
    writeLines("        }", outputFileHtmlCon)
    writeLines("      });", outputFileHtmlCon)
    writeLines("", outputFileHtmlCon)

    #Write a layer for each route type
    output_query_route_style<-paste0("SELECT tbl_route_maps.RTE_TYPE, tbl_route_maps.RTE_TYPE_GROOMED, tbl_route_types.RTE_TYPE_MODE, tbl_route_types.RTE_TYPE_MODE_CODE, tbl_route_types.RTE_TYPE_MODE_CODE2, tbl_route_types.RTE_TYPE_MAP_COLOR FROM tbl_route_maps LEFT JOIN tbl_route_types ON tbl_route_maps.RTE_TYPE_GROOMED = tbl_route_types.RTE_TYPE WHERE YEAR=",mapYear," GROUP BY RTE_TYPE ORDER BY RTE_TYPE DESC;")
    #A kluge to use 1953, but worth it to avoid complexity
    if(generateYear==1953){
      mapYear="1954_June"    
      #output_query<-paste0("SELECT tbl_route_maps.ID, tbl_route_maps.RTE_SHP_FILE_NAME, tbl_route_maps.RTE_SHP_FILE_FOLDER, tbl_route_maps.RTE_TYPE_GROOMED, tbl_route_maps.RTE_NUM, tbl_route_types.RTE_TYPE_MODE, tbl_route_types.RTE_TYPE_MODE_CODE FROM tbl_route_maps LEFT JOIN tbl_route_types ON tbl_route_maps.RTE_TYPE_GROOMED = tbl_route_types.RTE_TYPE WHERE RTE_SHP_FILE_FOLDER='1954_June' ORDER BY RTE_TYPE_MODE_CODE DESC, RTE_NUM;")
      output_query_route_style<-paste0("SELECT tbl_route_maps.RTE_TYPE, tbl_route_maps.RTE_TYPE_GROOMED, tbl_route_types.RTE_TYPE_MODE, tbl_route_types.RTE_TYPE_MODE_CODE, tbl_route_types.RTE_TYPE_MODE_CODE2, tbl_route_types.RTE_TYPE_MAP_COLOR FROM tbl_route_maps LEFT JOIN tbl_route_types ON tbl_route_maps.RTE_TYPE_GROOMED = tbl_route_types.RTE_TYPE WHERE RTE_SHP_FILE_FOLDER='1954_June' GROUP BY RTE_TYPE ORDER BY RTE_TYPE DESC;")
    }
    if(generateYear==1954){
      mapYear="1954_December"
      #output_query<-paste0("SELECT tbl_route_maps.ID, tbl_route_maps.RTE_SHP_FILE_NAME, tbl_route_maps.RTE_SHP_FILE_FOLDER, tbl_route_maps.RTE_TYPE_GROOMED, tbl_route_maps.RTE_NUM, tbl_route_types.RTE_TYPE_MODE, tbl_route_types.RTE_TYPE_MODE_CODE FROM tbl_route_maps LEFT JOIN tbl_route_types ON tbl_route_maps.RTE_TYPE_GROOMED = tbl_route_types.RTE_TYPE WHERE RTE_SHP_FILE_FOLDER='1954_December' ORDER BY RTE_TYPE_MODE_CODE DESC, RTE_NUM;")
      output_query_route_style<-paste0("SELECT tbl_route_maps.RTE_TYPE, tbl_route_maps.RTE_TYPE_GROOMED, tbl_route_types.RTE_TYPE_MODE, tbl_route_types.RTE_TYPE_MODE_CODE, tbl_route_types.RTE_TYPE_MODE_CODE2, tbl_route_types.RTE_TYPE_MAP_COLOR FROM tbl_route_maps LEFT JOIN tbl_route_types ON tbl_route_maps.RTE_TYPE_GROOMED = tbl_route_types.RTE_TYPE WHERE RTE_SHP_FILE_FOLDER='1954_December' GROUP BY RTE_TYPE ORDER BY RTE_TYPE DESC;")
    }
    
    output_rs_route_style = dbSendQuery(routesDb,output_query_route_style)
    output_dbRows_route_style<-dbFetch(output_rs_route_style, 999999)
    if (nrow(output_dbRows_route_style)==0){
      print (paste0("Zero rows for ",mapYear))
      dbClearResult(output_rs_route_style)
      
    } else {
      
      for (i_route_style in 1:nrow(output_dbRows_route_style)) {
        print(paste0("To map ", mapYear, ", adding: "))
        print(output_dbRows_route_style[i_route_style, 1])
        routeLayerName <- paste0(gsub("-","",gsub(" ","",output_dbRows_route_style[i_route_style, 1])),"Layer")
        writeLines("")
        writeLines(paste0("// layer for ",output_dbRows_route_style[i_route_style, 1]), outputFileHtmlCon)
        writeLines("      $.ajax({", outputFileHtmlCon)
        writeLines("        type: 'POST',", outputFileHtmlCon)
        writeLines(paste0("        url: '",mapYear,"-",gsub(" ","-",output_dbRows_route_style[i_route_style, 1]),".geojson',"), outputFileHtmlCon)
        writeLines("        dataType: 'json',", outputFileHtmlCon)
        writeLines("        success: function(response) {", outputFileHtmlCon)
        writeLines(paste0("          ",routeLayerName," = L.geoJson(response, {"), outputFileHtmlCon)
        # Only need attribution once.
        #if(i_route_style ==1){
        #writeLines(paste0("      attribution: '",'<a href="https://library.carleton.ca/find/gis/geospatial-data/oc-transpo-transit-routes">Carleton University</a>'," ';"), outputFileHtmlCon)
        #}
        writeLines("             onEachFeature: function (feature, layer) {", outputFileHtmlCon)
        if(generateYear<=1948){
          writeLines("                 layer.bindPopup('<h3>Route Name: '+feature.properties.RTE_NAME+'</h3><p>'+feature.properties.RTE_TYPE+'</p><p>'+feature.properties.MODE+'</p>');", outputFileHtmlCon)  
        }else{
          writeLines("                 layer.bindPopup('<h3>Route Number: '+feature.properties.RTE_NUM+'</h3><p>'+feature.properties.RTE_TYPE+'</p><p>'+feature.properties.MODE+'</p>');", outputFileHtmlCon)  
        }
        
        writeLines("               }", outputFileHtmlCon)
        writeLines("             });", outputFileHtmlCon)
        writeLines(paste0("          ",routeLayerName,".setStyle({"), outputFileHtmlCon)
        writeLines(paste0("            color: '",output_dbRows_route_style[i_route_style, 6],"',"), outputFileHtmlCon)
        routeTypes <- paste0(routeTypes,"<span style=",'"color:',output_dbRows_route_style[i_route_style, 6],'"',">",output_dbRows_route_style[i_route_style, 1]," ___________</span><br>")
        writeLines("            weight: 2,", outputFileHtmlCon)
        writeLines('            opacity: 1', outputFileHtmlCon)
        writeLines("          });", outputFileHtmlCon)
        writeLines(paste0("          ",routeLayerName,".addTo(map);"), outputFileHtmlCon)
        writeLines(paste0("          controlLayers.addOverlay(",routeLayerName,", '<span style=",'"color:',output_dbRows_route_style[i_route_style, 6],'"',">",output_dbRows_route_style[i_route_style, 1],"</span>');"), outputFileHtmlCon)
        #writeLines("          map.fitBounds(geojsonLayer.getBounds());", outputFileHtmlCon)
        writeLines("        }", outputFileHtmlCon)
        writeLines("      });", outputFileHtmlCon)
        writeLines("", outputFileHtmlCon)
      }
      dbClearResult(output_rs_route_style)
    }

    writeLines(paste0("      controlLayers.addOverlay(basemap, '",basemapTitle,"');"), outputFileHtmlCon)
    writeLines("      ", outputFileHtmlCon)
    writeLines("    });", outputFileHtmlCon)
    writeLines("  };", outputFileHtmlCon)
    writeLines("  </script>", outputFileHtmlCon)
    
    writeLines(paste0("    <h1>Ottawa mass transit routes ",mapYear,"</h1>"), outputFileHtmlCon)
    writeLines(paste0("<h2>Legend</h2>"), outputFileHtmlCon)
    writeLines(paste0("<h3>Route types</h3>"), outputFileHtmlCon)
    writeLines(paste0("<p>",routeTypes,"</p>"), outputFileHtmlCon)
    writeLines(paste0("<p>Each route can be clicked to view its route number and mode. Due to overlapping routes and layers, the route may be below other information on the map and not clickable. To bring it to the top of the map layers, click the layer twice in the control box at the top right portion of the map.</p>"), outputFileHtmlCon)
    writeLines(paste0("<h3>Base map</h3>"), outputFileHtmlCon)
    writeLines(paste0("<p>",basemapTitle," is the base map used to provide context for the mass transit routes.</p>"), outputFileHtmlCon)
    
    writeLines(paste0("<h3>Urban Extent</h3>"), outputFileHtmlCon)
    writeLines(paste0("<p>This layer shows the urban extent of the Ottawa-Gatineau region for the year ",urbanGrowthYear,". It is based on data compiled by the NCC and available at Carleton University's MacOdrum Library.</p>"), outputFileHtmlCon)
    writeLines(paste0("<h2>Links to maps of other years</h2>"), outputFileHtmlCon)
    writeLines(paste0("<p>",pageLinks,"</p>"), outputFileHtmlCon)
    writeLines(paste0("<hr><p>Observations may be sent to <a href='https://twitter.com/jeffblackadar'>@jeffblackadar</a> on Twitter.</p>"), outputFileHtmlCon)
    
    writeLines(paste0("<h2>List of routes</h2>"), outputFileHtmlCon)
    writeLines(paste0("<table>"), outputFileHtmlCon)
    
    if(generateYear<=1948){
      writeLines(paste0("<tr><th>Map<br>line<br>colour</th><th>Route<br>name</th><th>Route type</th><th>Route mode</th></tr>"), outputFileHtmlCon)
    }else{
      writeLines(paste0("<tr><th>Map<br>line<br>colour</th><th>Route<br>number</th><th>Route type</th><th>Route mode</th></tr>"), outputFileHtmlCon)
    }
    output_query_route_style<-paste0("SELECT tbl_route_maps.RTE_TYPE, tbl_route_maps.RTE_NUM, tbl_route_maps.RTE_TYPE_GROOMED, tbl_route_types.RTE_TYPE_MODE, tbl_route_types.RTE_TYPE_MODE_CODE, tbl_route_types.RTE_TYPE_MODE_CODE2, tbl_route_types.RTE_TYPE_MAP_COLOR FROM tbl_route_maps LEFT JOIN tbl_route_types ON tbl_route_maps.RTE_TYPE_GROOMED = tbl_route_types.RTE_TYPE WHERE YEAR=",mapYear," ORDER BY RTE_NUM,RTE_TYPE;")
    #A kluge to use 1953, but worth it to avoid complexity
    if(generateYear==1953){
      mapYear="1954_June"    
      output_query_route_style<-paste0("SELECT tbl_route_maps.RTE_TYPE, tbl_route_maps.RTE_NUM, tbl_route_maps.RTE_TYPE_GROOMED, tbl_route_types.RTE_TYPE_MODE, tbl_route_types.RTE_TYPE_MODE_CODE, tbl_route_types.RTE_TYPE_MODE_CODE2, tbl_route_types.RTE_TYPE_MAP_COLOR FROM tbl_route_maps LEFT JOIN tbl_route_types ON tbl_route_maps.RTE_TYPE_GROOMED = tbl_route_types.RTE_TYPE WHERE RTE_SHP_FILE_FOLDER='1954_June' ORDER BY RTE_NUM,RTE_TYPE;")
    }
    if(generateYear==1954){
      mapYear="1954_December"
      output_query_route_style<-paste0("SELECT tbl_route_maps.RTE_TYPE, tbl_route_maps.RTE_NUM, tbl_route_maps.RTE_TYPE_GROOMED, tbl_route_types.RTE_TYPE_MODE, tbl_route_types.RTE_TYPE_MODE_CODE, tbl_route_types.RTE_TYPE_MODE_CODE2, tbl_route_types.RTE_TYPE_MAP_COLOR FROM tbl_route_maps LEFT JOIN tbl_route_types ON tbl_route_maps.RTE_TYPE_GROOMED = tbl_route_types.RTE_TYPE WHERE RTE_SHP_FILE_FOLDER='1954_December' ORDER BY RTE_NUM,RTE_TYPE;")
    }
    if(generateYear<=1948){
      output_query_route_style<-paste0("SELECT tbl_route_maps.RTE_TYPE, tbl_route_maps.RTE_NAME, tbl_route_maps.RTE_TYPE_GROOMED, tbl_route_types.RTE_TYPE_MODE, tbl_route_types.RTE_TYPE_MODE_CODE, tbl_route_types.RTE_TYPE_MODE_CODE2, tbl_route_types.RTE_TYPE_MAP_COLOR FROM tbl_route_maps LEFT JOIN tbl_route_types ON tbl_route_maps.RTE_TYPE_GROOMED = tbl_route_types.RTE_TYPE WHERE YEAR=",mapYear," ORDER BY RTE_NUM,RTE_TYPE;")
    }
    print(output_query_route_style)
    output_rs_route_style = dbSendQuery(routesDb,output_query_route_style)
    output_dbRows_route_style<-dbFetch(output_rs_route_style, 999999)
    if (nrow(output_dbRows_route_style)==0){
      print (paste0("Zero rows for ",mapYear))
      dbClearResult(output_rs_route_style)
    } else {
      for (i_route_style in 1:nrow(output_dbRows_route_style)) {
        #print(paste0("To map ", mapYear, " adding "))
        #print(output_dbRows_route_style[i_route_style, 1])
        routeLayerName <- paste0(gsub("-","",gsub(" ","",output_dbRows_route_style[i_route_style, 1])),"Layer")
        #writeLines("")
        writeLines(paste0("<tr>"), outputFileHtmlCon)
        writeLines(paste0("<td bgcolor='",output_dbRows_route_style[i_route_style, 7],"'>&nbsp;&nbsp;&nbsp;</td>","<td>",output_dbRows_route_style[i_route_style, 2],"</td>","<td>",output_dbRows_route_style[i_route_style, 1],"</td>","<td>",output_dbRows_route_style[i_route_style, 4],"</td>"), outputFileHtmlCon)
        writeLines(paste0("</tr>"), outputFileHtmlCon)
      }
      dbClearResult(output_rs_route_style)
    }
    writeLines(paste0("</table>"), outputFileHtmlCon)
    writeLines("    </body>", outputFileHtmlCon)
    writeLines("    </html>", outputFileHtmlCon)
    close(outputFileHtmlCon)
  }
}
dbDisconnect(routesDb)
