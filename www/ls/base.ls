tooltip = new Tooltip!
map = L.map do
    *   'map'
    *   minZoom: 2
        maxZoom: 5
        zoom: 2
        center: [-70,-160]
        crs: L.CRS.Simple
years = [1996 1998 2002 2006 2010]
currentLayer = null
layers = years.map (year) ->
    L.tileLayer "../data/kscm-#year/{z}/{x}/{y}.png"
selectLayer = (id) ->
    if currentLayer
        lastLayer = currentLayer
        setTimeout do
            -> map.removeLayer lastLayer
            300
    currentLayer := layers[id].addTo map


selectLayer years.length - 1
