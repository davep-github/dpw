  var map;
  var geocoder;
  var directions;
  var mainHeight = 0;
  var mapWidth = 400;
  var mapHeight = 335;
  var isRouteFormOpened = false;
  var heightCounter = 1;
  function onLoad() {
    var interval = setTimeout(initMap, 200);
  }

  function showRouteForm() {
		document.getElementById("searchBox").style.display = 'none';
		document.getElementById("routeSourceBox").style.display = 'block';
		document.getElementById("routeDestBox").style.display = 'block';
		document.getElementById("routeSource").focus();
		mainHeight = mapHeight + 73;
	    document.getElementById("main").style.height = (mapHeight + 73) + "px";
		isRouteFormOpened = true;
  }

  function hideRouteForm() {
		document.getElementById("searchBox").style.display = 'block';
		document.getElementById("routeSourceBox").style.display = 'none';
		document.getElementById("routeDestBox").style.display = 'none';
		document.getElementById("addressSource").focus();
		mainHeight = mapHeight + 43;
		document.getElementById("main").style.height = (mapHeight + 43) + "px";
		document.getElementById("routeErrorMessage").style.display = 'none';
		isRouteFormOpened = false;
  }
  function searchMap() {
	  var addressSource = document.getElementById("addressSource").value;
		
      if (geocoder) {
        geocoder.getLatLng(
          addressSource,
          function(point) {
            if (!point) {
            } else {
              map.setCenter(point, 13);
              var marker = new GMarker(point);
              map.addOverlay(marker);
              marker.openInfoWindowHtml(addressSource);
			  		document.getElementById("fotter").style.display = 'xxxxxxxxxxxxxxxx';

            }
          }
        );
      }
  }

  function getDirections() {
	  var source = document.getElementById("routeSource").value;
	  var destination = document.getElementById("routeDest").value;
      directionsPanel = document.getElementById("route");
	  if (directions!=null) directions.clear();
      directions = new GDirections(map, directionsPanel);
	  GEvent.addListener(directions, "error", function() {
	    // document.getElementById("main").innerHTML = directions.getStatus().code;
	     document.getElementById("routeErrorMessage").style.display = '';
	  });
	  GEvent.addListener(directions, "load", function() {
	     document.getElementById("main").style.width = "790px";
	     document.getElementById("map_canvas").style.width = "400px";

	     document.getElementById("route").style.height = (mapHeight - 12) +"px";
	     document.getElementById("route-container").style.height = (mapHeight) +"px";


	     document.getElementById("route-container").style.display = "block";
	     document.getElementById("clearRouteLink").style.display = 'block';
		 document.getElementById("routeErrorMessage").style.display = 'none';
		 document.getElementById("sizeLinks").style.display = 'none';

	  });
      directions.load("from: " + source + " to: " + destination);
  }
  function clearRoute() {
	  if (directions!=null) {
		 directions.clear();
		 document.getElementById("route-container").style.display = "none";
	     document.getElementById("map_canvas").style.width = mapWidth +"px";
		 document.getElementById("main").style.width = mapWidth +"px";
		 //document.getElementById("main").style.height = "490px";
		 	 document.getElementById("main").style.height = (mainHeight + heightCounter) + "px";
			 heightCounter++

		 document.getElementById("sizeLinks").style.display = 'block';

		 	//	 document.getElementById("main").innerHTML = mapWidth;

	  }
	   document.getElementById("clearRouteLink").style.display = 'none';
	 document.getElementById("routeErrorMessage").style.display = 'none';
  }
  function initMap() {

		

			if ((localStorage["width"]!=null) && (localStorage["width"]!="")) {
				 document.getElementById("main").style.width = localStorage["mainWidth"] + "px";
				 document.getElementById("main").style.height = localStorage["mainHeight"] + "px";
				 document.getElementById("map_canvas").style.width = localStorage["width"] + "px";
				 document.getElementById("map_canvas").style.height = localStorage["height"] + "px";

				  mainHeight = localStorage["mainHeight"] - 0;
				  mapWidth = localStorage["width"] - 0;
				  mapHeight = localStorage["height"] - 0;
			}



			document.getElementById("addressSource").focus();
			map = new GMap2(document.getElementById("map_canvas"));
			if ((localStorage["lat"]==null) || (localStorage["lat"]=="")) {
				map.setCenter(new GLatLng(37.4419, -92.1419), 2);
			} else {
				map.setCenter(new GLatLng(localStorage["lat"]-0, localStorage["long"]-0), localStorage["zoom"]-0);
			}
			map.setUIToDefault();
			geocoder = new GClientGeocoder();

			document.getElementById("addressSource").addEventListener("keyup", function(event) {
				if (event.keyCode==13) {
				   searchMap();
				}
			},false);
  }

  function setDefaultLocation() {
		var point = map.getCenter();
		localStorage["lat"]  = point.lat();
		localStorage["long"] = point.lng();
		localStorage["zoom"] = map.getZoom();
  }

  function setSize(size) {	
	 if (size==0) {
		mapWidth = 400;
		mapHeight = 335;
	    if (isRouteFormOpened) {
		  mainHeight = 516 - 110;
	    } else {
		  mainHeight = 490 - 110;
		}



	 } else if (size==1) {
		mapWidth = 490;
		mapHeight = 445;
	    if (isRouteFormOpened) {
		  mainHeight = 516
	    } else {
		  mainHeight = 490;
		}
	 } else if (size==2) {
		mapWidth = 790;
		mapHeight = 445 + 60;
	    if (isRouteFormOpened) {
		  mainHeight = 516 + 60;
	    } else {
		  mainHeight = 490 + 60;
		}
	 }

	 document.getElementById("map_canvas").style.width = mapWidth + "px"
	 document.getElementById("map_canvas").style.height = mapHeight + "px";
	 document.getElementById("main").style.width = mapWidth + "px";
	 document.getElementById("main").style.height = mainHeight + "px";


	localStorage["width"]      = mapWidth;
	localStorage["height"]     = mapHeight;
	localStorage["mainWidth"]  = mapWidth;
	localStorage["mainHeight"] = mainHeight;

  }