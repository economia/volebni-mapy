tooltip = new Tooltip!
map = L.map do
    *   'map'
    *   minZoom: 2
        maxZoom: 5
        zoom: 2
        center: [-55,-143]
        crs: L.CRS.Simple
years = [1996 1998 2002 2006 2010]
firstYearIndex = years.length - 1
currentLayer = null
layers = for year in years
    L.tileLayer "../data/kscm-#year/{z}/{x}/{y}.png"
grids = for let year in years
    grid = new L.UtfGrid "../data/kscm-#year/{z}/{x}/{y}.json", useJsonP: no
        ..on \mouseover (e) ->
            str = switch
            | e.data.id == "592935" and year <= 1998
                "<b>#{e.data.name}</b><br />V roce #{e.data.year} zde nikdo nevolil"
            | e.data.count is not null
                "<b>#{e.data.name}</b><br />Volební výsledek #{e.data.abbr} v roce #{e.data.year}: #{(e.data.percent * 100).toFixed 2}%  (#{e.data.count} hlasů)<br />"
            | otherwise
                "<b>#{e.data.name}</b><br />Volební výsledek v roce #{e.data.year} se nepodařilo zjistit"
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
    $year.html years[id]
    currentLayer :=
        map: layers[id]
        grid: grids[id]


opts =
    min: 0
    max: years.length - 1
    value: firstYearIndex
    slide: (evt, ui) ->
        selectLayer ui.value
$body = $ \body
$slider = $ "<div></div>"
    ..addClass "slider"
    ..appendTo $body
    ..slider opts

$year = $ "<span></span>"
    ..addClass "year"
    ..appendTo $body

selectLayer firstYearIndex
$gradientContainer = $ "<div></div>"
    ..addClass \gradientContainer
    ..appendTo $body
colors = <[#FFF5F0 #FEE0D2 #FCBBA1 #FC9272 #FB6A4A #EF3B2C #CB181D #A50F15 #67000D]>
values = [0 0.04 0.08 0.12 0.18 0.22 0.24 0.4 0.7]
colors.forEach (color, index) ->
    value = values[index]
    ele = $ "<div></div>"
        ..css \background color
        ..html "#{Math.round value * 100}%"
        ..appendTo $gradientContainer

    if index >= 5
        ele.addClass \dark
