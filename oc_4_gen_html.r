library(RMariaDB)

# R needs a full path to find the settings file.
rmariadb.settingsfile<-"C:\\ProgramData\\MySQL\\MySQL Server 8.0\\oc_transpo_maps.cnf"

rmariadb.db<-"oc_transpo_maps"
routesDb<-dbConnect(RMariaDB::MariaDB(),default.file=rmariadb.settingsfile,group=rmariadb.db) 

# list the table. This confirms we connected to the database.
dbListTables(routesDb)

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
    dbClearResult(output_rs)
    outputFileHtml <- paste0("C:\\a_orgs\\carleton\\hist3814\\R\\oc-transpo-maps-data\\output\\",mapYear,".html")
    outputFileHtmlCon<-file(outputFileHtml, open = "w")

    writeLines('<!DOCTYPE html>', outputFileHtmlCon)
    writeLines('  <html>', outputFileHtmlCon)
    writeLines('  <head><meta http-equiv="Content-Type" content="text/html; charset=utf-8">', outputFileHtmlCon)
    writeLines('  <title></title>', outputFileHtmlCon)
    writeLines('  <link href="http://cdn.leafletjs.com/leaflet-0.6.4/leaflet.css" rel="stylesheet" /><script src="http://cdn.leafletjs.com/leaflet-0.6.4/leaflet.js"></script><script src="https://code.jquery.com/jquery-2.1.4.min.js"></script>', outputFileHtmlCon)
    writeLines('  <style type="text/css">#my-map {', outputFileHtmlCon)
    writeLines('  width:960px;', outputFileHtmlCon)
    writeLines('  height:700px;', outputFileHtmlCon)
    writeLines('}', outputFileHtmlCon)
    writeLines('</style>', outputFileHtmlCon)
    writeLines('  </head>', outputFileHtmlCon)
    writeLines('  <body>', outputFileHtmlCon)
    writeLines('  <div id="my-map"></div>', outputFileHtmlCon)
    writeLines('    <script>', outputFileHtmlCon)
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
    writeLines(paste0('    $.getJSON("',mapYear,'.geojson", function(data) {'), outputFileHtmlCon)
    writeLines('      geojson = L.geoJson(data, {', outputFileHtmlCon)
    writeLines('        onEachFeature: function(feature, layer) {', outputFileHtmlCon)
    writeLines('          layer.bindPopup(feature.properties.RTE_NUM + " " + feature.properties.RTE_TYPE);', outputFileHtmlCon)
    writeLines("          layer.setStyle({", outputFileHtmlCon)
    writeLines('            weight: 2,', outputFileHtmlCon)
    writeLines('            opacity: 1', outputFileHtmlCon)
    writeLines('          });', outputFileHtmlCon)
    writeLines("          if (feature.properties.RTE_TYPE == 'Main Route - Regular') {", outputFileHtmlCon)
    writeLines('            layer.setStyle({', outputFileHtmlCon)
    writeLines("              color: 'red'", outputFileHtmlCon)
    writeLines("            });", outputFileHtmlCon)
    writeLines("          } else {", outputFileHtmlCon)
    writeLines("            if (feature.properties.RTE_TYPE == 'Transfer Route - Regular') {", outputFileHtmlCon)
    writeLines("              layer.setStyle({", outputFileHtmlCon)
    writeLines("                color: 'green'", outputFileHtmlCon)
    writeLines("              });", outputFileHtmlCon)
    writeLines("            } else {", outputFileHtmlCon)
    writeLines("              layer.setStyle({", outputFileHtmlCon)
    writeLines("                color: 'blue'", outputFileHtmlCon)
    writeLines("              });", outputFileHtmlCon)
    writeLines("            }", outputFileHtmlCon)
    writeLines("          }", outputFileHtmlCon)
    writeLines("        }", outputFileHtmlCon)
    writeLines("      });", outputFileHtmlCon)
    writeLines("", outputFileHtmlCon)      
    writeLines("", outputFileHtmlCon)
    writeLines("      map = L.map('my-map')", outputFileHtmlCon)
    writeLines("      .fitBounds(geojson.getBounds());", outputFileHtmlCon)
    writeLines("      //    .setView([0.0,-10.0], 2);", outputFileHtmlCon)
    writeLines("      basemap.addTo(map);", outputFileHtmlCon)
    writeLines("      geojson.addTo(map);", outputFileHtmlCon)
    writeLines("", outputFileHtmlCon)      
    writeLines("      // add legend control layers - global variable with (null, null) allows indiv basemaps and overlays to be added inside functions below", outputFileHtmlCon)
    writeLines("      var controlLayers = L.control.layers(null, null, {", outputFileHtmlCon)
    writeLines('        position: "topright",', outputFileHtmlCon)
    writeLines("        collapsed: false // false = open by default", outputFileHtmlCon)
    writeLines("      }).addTo(map);", outputFileHtmlCon)
    writeLines("", outputFileHtmlCon)      
    writeLines("", outputFileHtmlCon)
    writeLines("      $.ajax({", outputFileHtmlCon)
    writeLines("        type: 'POST',", outputFileHtmlCon)
    writeLines("        url: 'http://jeffblackadar.ca/oc-transpo/urban_growth_1956.geojson',", outputFileHtmlCon)
    writeLines("        dataType: 'json',", outputFileHtmlCon)
    writeLines("        success: function(response) {", outputFileHtmlCon)
    writeLines("          geojsonLayer = L.geoJson(response);", outputFileHtmlCon)
    writeLines("          geojsonLayer.setStyle({", outputFileHtmlCon)
    writeLines("            color: 'brown',", outputFileHtmlCon)
    writeLines("            weight: 1", outputFileHtmlCon)
    writeLines("          });", outputFileHtmlCon)
    writeLines("          geojsonLayer.bindPopup('Urban extent 1956.')", outputFileHtmlCon)
    writeLines("          geojsonLayer.addTo(map);", outputFileHtmlCon)
    writeLines("          controlLayers.addOverlay(geojsonLayer, 'Urban Extent 1956');", outputFileHtmlCon)
    writeLines("          map.fitBounds(geojsonLayer.getBounds());", outputFileHtmlCon)
    writeLines("        }", outputFileHtmlCon)
    writeLines("      });", outputFileHtmlCon)
    writeLines("", outputFileHtmlCon)
    writeLines("      controlLayers.addOverlay(basemap, 'Today (OSM)');", outputFileHtmlCon)
    writeLines(paste0("      controlLayers.addOverlay(geojson, 'Bus routes ",mapYear,"');"), outputFileHtmlCon)
    writeLines("      ", outputFileHtmlCon)
    
    writeLines("    });", outputFileHtmlCon)
    writeLines("  };", outputFileHtmlCon)
    writeLines("  </script>", outputFileHtmlCon)
    
    writeLines(paste0("    <h1>Ottawa mass transit routes ",mapYear,"</h1>"), outputFileHtmlCon)
    
    writeLines("    </body>", outputFileHtmlCon)
    writeLines("    </html>", outputFileHtmlCon)
    close(outputFileHtmlCon)
  }
  
}
dbDisconnect(routesDb)
