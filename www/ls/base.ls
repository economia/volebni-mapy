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
grids = years.map (year) ->
    grid = new L.UtfGrid "../data/kscm-#year/{z}/{x}/{y}.json", useJsonP: no
        ..on \mouseover (e) ->
            str = "<b>#{e.data.name}</b><br />Volební výsledek #{e.data.abbr} v roce #{e.data.year}: #{(e.data.percent * 100).toFixed 2}%  (#{e.data.count} hlasů)<br />"
            tooltip.display str
        ..on \mouseout ->
            tooltip.hide!

selectLayer = (id) ->
    if currentLayer
        lastLayer = currentLayer
        setTimeout do
            ->
                map.removeLayer lastLayer.map
                map.removeLayer lastLayer.grid
            300
    map.addLayer layers[id]
    map.addLayer grids[id]
    currentLayer :=
        map: layers[id]
        grid: grids[id]


selectLayer years.length - 1
