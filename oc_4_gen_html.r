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
    pageLinks<-paste0(pageLinks," | <a href='",mapYear,".html'>",mapYear,"</a>")
    dbClearResult(output_rs)
  }
}



for (generateYear in 1929:2002){
  
  
  
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
    
    dbClearResult(output_rs)
    outputFileHtml <- paste0("C:\\a_orgs\\carleton\\hist3814\\R\\oc-transpo-maps-data\\output\\",mapYear,".html")
    outputFileHtmlCon<-file(outputFileHtml, open = "w")

    writeLines('<!DOCTYPE html>', outputFileHtmlCon)
    writeLines('  <html>', outputFileHtmlCon)
    writeLines('  <head><meta http-equiv="Content-Type" content="text/html; charset=utf-8">', outputFileHtmlCon)
    writeLines('  <title>Ottawa Mass Transit Maps</title>', outputFileHtmlCon)
    writeLines('  <link href="http://cdn.leafletjs.com/leaflet-0.6.4/leaflet.css" rel="stylesheet" /><script src="http://cdn.leafletjs.com/leaflet-0.6.4/leaflet.js"></script><script src="https://code.jquery.com/jquery-2.1.4.min.js"></script>', outputFileHtmlCon)
    writeLines('  <style type="text/css">#my-map {', outputFileHtmlCon)
    writeLines('  width:960px;', outputFileHtmlCon)
    writeLines('  height:700px;', outputFileHtmlCon)
    writeLines('}', outputFileHtmlCon)
    writeLines('</style>', outputFileHtmlCon)
    writeLines('  </head>', outputFileHtmlCon)
    writeLines('  <body>', outputFileHtmlCon)
    writeLines('  <span id="loading"></span>Instructions: Click on map features. Scroll down.<br>', outputFileHtmlCon)
    writeLines('  <div id="my-map"></div>', outputFileHtmlCon)
    writeLines('    <script>', outputFileHtmlCon)
    writeLines("    var spanLoading = document.getElementById('loading');", outputFileHtmlCon)
    writeLines('    while( spanLoading.firstChild ) {', outputFileHtmlCon)
    writeLines('        spanLoading.removeChild( spanLoading.firstChild );', outputFileHtmlCon)
    writeLines('    }', outputFileHtmlCon)
    writeLines('    spanLoading.appendChild( document.createTextNode("Loading map. ") );', outputFileHtmlCon)
    writeLines('', outputFileHtmlCon)
    writeLines('    // This file was generated by this R program:  https://github.com/jeffblackadar/oc-transpo-maps/blob/master/oc_4_gen_html.r')
    writeLines('    var geojsonLayer;', outputFileHtmlCon)
    writeLines('  var geojson;', outputFileHtmlCon)
    writeLines('  var geojson2;', outputFileHtmlCon)
    writeLines('  var map;', outputFileHtmlCon)
    writeLines('', outputFileHtmlCon)
    writeLines('  window.onload = function() {', outputFileHtmlCon)
    writeLines("    var basemap = L.tileLayer('http://{s}.tile.osm.org/{z}/{x}/{y}.png', {", outputFileHtmlCon)
    writeLines(paste0("      attribution: '&copy; ",'<a href="http://osm.org/copyright">OpenStreetMap</a>',"contributors'"), outputFileHtmlCon)
    writeLines("    });", outputFileHtmlCon)
    writeLines("", outputFileHtmlCon)
    
    
    # We may no longer need to load this big geojson 
    writeLines(paste0('    $.getJSON("urban_growth_',urbanGrowthYear,'.geojson", function(data) {'), outputFileHtmlCon)
    writeLines('      geojson = L.geoJson(data, {', outputFileHtmlCon)
    
    
    # writeLines('        onEachFeature: function(feature, layer) {', outputFileHtmlCon)
    # writeLines('          layer.bindPopup(feature.properties.RTE_NUM + " " + feature.properties.RTE_TYPE);', outputFileHtmlCon)
    # writeLines("          layer.setStyle({", outputFileHtmlCon)
    # writeLines('            weight: 2,', outputFileHtmlCon)
    # writeLines('            opacity: 1', outputFileHtmlCon)
    # writeLines('          });', outputFileHtmlCon)


    # output_query_route_style<-paste0("SELECT tbl_route_maps.RTE_TYPE, tbl_route_maps.RTE_TYPE_GROOMED, tbl_route_types.RTE_TYPE_MODE, tbl_route_types.RTE_TYPE_MODE_CODE, tbl_route_types.RTE_TYPE_MODE_CODE2, tbl_route_types.RTE_TYPE_MAP_COLOR FROM tbl_route_maps LEFT JOIN tbl_route_types ON tbl_route_maps.RTE_TYPE_GROOMED = tbl_route_types.RTE_TYPE WHERE YEAR=",mapYear," GROUP BY RTE_TYPE ORDER BY RTE_TYPE DESC;")
    # #A kluge to use 1953, but worth it to avoid complexity
    # if(generateYear==1953){
    #   mapYear="1954_June"
    #   #output_query<-paste0("SELECT tbl_route_maps.ID, tbl_route_maps.RTE_SHP_FILE_NAME, tbl_route_maps.RTE_SHP_FILE_FOLDER, tbl_route_maps.RTE_TYPE_GROOMED, tbl_route_maps.RTE_NUM, tbl_route_types.RTE_TYPE_MODE, tbl_route_types.RTE_TYPE_MODE_CODE FROM tbl_route_maps LEFT JOIN tbl_route_types ON tbl_route_maps.RTE_TYPE_GROOMED = tbl_route_types.RTE_TYPE WHERE RTE_SHP_FILE_FOLDER='1954_June' ORDER BY RTE_TYPE_MODE_CODE DESC, RTE_NUM;")
    #   output_query_route_style<-paste0("SELECT tbl_route_maps.RTE_TYPE, tbl_route_maps.RTE_TYPE_GROOMED, tbl_route_types.RTE_TYPE_MODE, tbl_route_types.RTE_TYPE_MODE_CODE, tbl_route_types.RTE_TYPE_MODE_CODE2, tbl_route_types.RTE_TYPE_MAP_COLOR FROM tbl_route_maps LEFT JOIN tbl_route_types ON tbl_route_maps.RTE_TYPE_GROOMED = tbl_route_types.RTE_TYPE WHERE RTE_SHP_FILE_FOLDER='1954_June' GROUP BY RTE_TYPE ORDER BY RTE_TYPE DESC;")
    # }
    # if(generateYear==1954){
    #   mapYear="1954_December"
    #   #output_query<-paste0("SELECT tbl_route_maps.ID, tbl_route_maps.RTE_SHP_FILE_NAME, tbl_route_maps.RTE_SHP_FILE_FOLDER, tbl_route_maps.RTE_TYPE_GROOMED, tbl_route_maps.RTE_NUM, tbl_route_types.RTE_TYPE_MODE, tbl_route_types.RTE_TYPE_MODE_CODE FROM tbl_route_maps LEFT JOIN tbl_route_types ON tbl_route_maps.RTE_TYPE_GROOMED = tbl_route_types.RTE_TYPE WHERE RTE_SHP_FILE_FOLDER='1954_December' ORDER BY RTE_TYPE_MODE_CODE DESC, RTE_NUM;")
    #   output_query_route_style<-paste0("SELECT tbl_route_maps.RTE_TYPE, tbl_route_maps.RTE_TYPE_GROOMED, tbl_route_types.RTE_TYPE_MODE, tbl_route_types.RTE_TYPE_MODE_CODE, tbl_route_types.RTE_TYPE_MODE_CODE2, tbl_route_types.RTE_TYPE_MAP_COLOR FROM tbl_route_maps LEFT JOIN tbl_route_types ON tbl_route_maps.RTE_TYPE_GROOMED = tbl_route_types.RTE_TYPE WHERE RTE_SHP_FILE_FOLDER='1954_December' GROUP BY RTE_TYPE ORDER BY RTE_TYPE DESC;")
    # }
    # 
    # output_rs_route_style = dbSendQuery(routesDb,output_query_route_style)
    # output_dbRows_route_style<-dbFetch(output_rs_route_style, 999999)
    # if (nrow(output_dbRows_route_style)==0){
    #   print (paste0("Zero rows for ",mapYear))
    #   dbClearResult(output_rs_route_style)
    # 
    # } else {
    # 
    #   for (i_route_style in 1:nrow(output_dbRows_route_style)) {
    #     print(paste0("Route Style for ", mapYear))
    #     print(output_dbRows_route_style[i_route_style, 1])
    # 
    #   writeLines(paste0("          if (feature.properties.RTE_TYPE == '",output_dbRows_route_style[i_route_style, 1],"') {"), outputFileHtmlCon)
    #   writeLines('            layer.setStyle({', outputFileHtmlCon)
    #   writeLines(paste0("              color: '",output_dbRows_route_style[i_route_style, 6],"'"), outputFileHtmlCon)
    #   writeLines("            });", outputFileHtmlCon)
    #   writeLines("          }", outputFileHtmlCon)
    # 
    #   }
    #   dbClearResult(output_rs_route_style)
    # 
    # }



    # writeLines("          if (feature.properties.RTE_TYPE == 'Main Route - Regular') {", outputFileHtmlCon)
    # writeLines('            layer.setStyle({', outputFileHtmlCon)
    # writeLines("              color: 'red'", outputFileHtmlCon)
    # writeLines("            });", outputFileHtmlCon)
    # writeLines("          } else {", outputFileHtmlCon)
    # writeLines("            if (feature.properties.RTE_TYPE == 'Transfer Route - Regular') {", outputFileHtmlCon)
    # writeLines("              layer.setStyle({", outputFileHtmlCon)
    # writeLines("                color: 'green'", outputFileHtmlCon)
    # writeLines("              });", outputFileHtmlCon)
    # writeLines("            } else {", outputFileHtmlCon)
    # writeLines("              layer.setStyle({", outputFileHtmlCon)
    # writeLines("                color: 'blue'", outputFileHtmlCon)
    # writeLines("              });", outputFileHtmlCon)
    # writeLines("            }", outputFileHtmlCon)
    # writeLines("          }", outputFileHtmlCon)


    # writeLines("        }", outputFileHtmlCon)

    
    writeLines("      });", outputFileHtmlCon)
    
    
    
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
    
    writeLines("// Urban extent", outputFileHtmlCon)
    writeLines("      $.ajax({", outputFileHtmlCon)
    writeLines("        type: 'POST',", outputFileHtmlCon)
    writeLines(paste0("        url: 'http://jeffblackadar.ca/oc-transpo/urban_growth_",urbanGrowthYear,".geojson',"), outputFileHtmlCon)
    writeLines("        dataType: 'json',", outputFileHtmlCon)
    writeLines("        success: function(response) {", outputFileHtmlCon)
    writeLines("          geojsonLayer = L.geoJson(response);", outputFileHtmlCon)
    writeLines("          geojsonLayer.setStyle({", outputFileHtmlCon)
    writeLines("            color: 'brown',", outputFileHtmlCon)
    writeLines("            weight: 1", outputFileHtmlCon)
    writeLines("          });", outputFileHtmlCon)
    #This popup seems to displace the popup for the routes.
    #writeLines(paste0("          geojsonLayer.bindPopup('Urban extent ",urbanGrowthYear,".')"), outputFileHtmlCon)
    writeLines("          geojsonLayer.addTo(map);", outputFileHtmlCon)
    writeLines(paste0("          controlLayers.addOverlay(geojsonLayer, 'Urban Extent ",urbanGrowthYear,"');"), outputFileHtmlCon)
    writeLines("          map.fitBounds(geojsonLayer.getBounds());", outputFileHtmlCon)
    writeLines("        }", outputFileHtmlCon)
    writeLines("      });", outputFileHtmlCon)
    writeLines("", outputFileHtmlCon)

    #Write a geojson for each RTE_TYPE so they can be added to the map individually
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
        print(paste0("Separate geojson file in year ", mapYear, " for "))
        print(output_dbRows_route_style[i_route_style, 1])
        routeLayerName <- paste0(gsub("-","",gsub(" ","",output_dbRows_route_style[i_route_style, 1])),"Layer")
        writeLines("")
        writeLines(paste0("// layer for ",output_dbRows_route_style[i_route_style, 1]), outputFileHtmlCon)
        writeLines("      $.ajax({", outputFileHtmlCon)
        writeLines("        type: 'POST',", outputFileHtmlCon)
        writeLines(paste0("        url: 'http://jeffblackadar.ca/oc-transpo/",mapYear,"-",gsub(" ","-",output_dbRows_route_style[i_route_style, 1]),".geojson',"), outputFileHtmlCon)
        writeLines("        dataType: 'json',", outputFileHtmlCon)
        writeLines("        success: function(response) {", outputFileHtmlCon)
        writeLines(paste0("          ",routeLayerName," = L.geoJson(response);"), outputFileHtmlCon)
        writeLines(paste0("          ",routeLayerName,".setStyle({"), outputFileHtmlCon)
        writeLines(paste0("            color: '",output_dbRows_route_style[i_route_style, 6],"',"), outputFileHtmlCon)
        writeLines("            weight: 2,", outputFileHtmlCon)
        writeLines('            opacity: 1', outputFileHtmlCon)
        writeLines("          });", outputFileHtmlCon)
        writeLines(paste0("          ",routeLayerName,".addTo(map);"), outputFileHtmlCon)
        writeLines(paste0("          controlLayers.addOverlay(",routeLayerName,", '",output_dbRows_route_style[i_route_style, 1],"');"), outputFileHtmlCon)
        #writeLines("          map.fitBounds(geojsonLayer.getBounds());", outputFileHtmlCon)
        writeLines("        }", outputFileHtmlCon)
        writeLines("      });", outputFileHtmlCon)
        writeLines("", outputFileHtmlCon)
        

      }
      dbClearResult(output_rs_route_style)
      
    }
    
    
    
    writeLines("      controlLayers.addOverlay(basemap, 'Today (OSM)');", outputFileHtmlCon)
    #writeLines(paste0("      controlLayers.addOverlay(geojson, 'Bus routes ",mapYear,"');"), outputFileHtmlCon)
    writeLines("      ", outputFileHtmlCon)
    
    writeLines("    });", outputFileHtmlCon)
    writeLines("  };", outputFileHtmlCon)
    writeLines("  </script>", outputFileHtmlCon)
    
    writeLines(paste0("    <h1>Ottawa mass transit routes ",mapYear,"</h1>"), outputFileHtmlCon)
    writeLines(paste0(pageLinks), outputFileHtmlCon)
    
    writeLines("    </body>", outputFileHtmlCon)
    writeLines("    </html>", outputFileHtmlCon)
    close(outputFileHtmlCon)
  }
  
}
dbDisconnect(routesDb)
