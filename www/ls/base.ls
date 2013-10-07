tooltip = new Tooltip!
map = L.map do
    *   'map'
    *   minZoom: 6,
        maxZoom: 10,
        zoom: 7,
        center: [49.7, 15.5]
years = [1998 2002 2006 2010]
firstYearIndex = years.length - 1
currentLayer = null
layers = for year in years
    L.tileLayer do
        *   "../data/protesty-#year/{z}/{x}/{y}.png"
        *   attribution: '<a href="http://creativecommons.org/licenses/by-nc-sa/3.0/cz/" target = "_blank">CC BY-NC-SA 3.0 CZ</a> <a target="_blank" href="http://ihned.cz">IHNED.cz</a>, data <a target="_blank" href="http://www.volby.cz">ČSÚ</a>'
mapLayer = L.tileLayer do
    *   "http://ihned-mapy.s3.amazonaws.com/desaturized/{z}/{x}/{y}.png"
    *   zIndex: 2
        opacity: 0.65
        attribution: 'mapová data &copy; přispěvatelé OpenStreetMap, obrazový podkres <a target="_blank" href="http://ihned.cz">IHNED.cz</a>'
map.on \zoomend ->
    | map.getZoom! >= 10 => map.addLayer mapLayer
    | otherwise         => map.removeLayer mapLayer
$ document .on \mouseout \#map ->
    clearTimeout longTextTimeout if longTextTimeout
    tooltip.hide!
longTextTimeout = null
grids = for let year in years
    grid = new L.UtfGrid "../data/protesty-#year/{z}/{x}/{y}.json", useJsonP: no
        ..on \mouseover (e) ->
            {name, year, partyResults} = e.data
            longText = "<b>#{name}</b>, rok #{year}<br />"
            shortText = longText
            longText += switch
            | e.data.id == "592935" and year <= 1998
                "V roce #{e.data.year} zde nikdo nevolil"
            | otherwise
                percentSum = 0
                countSum = 0
                out = for {abbr, percent, count} in partyResults
                    if count is null or count is void
                        "#{abbr}: zde nekandidovali"
                    else
                        percentSum += percent
                        countSum += count
                        "#{abbr}: #{(percent * 100).toFixed 2}%  (#{count} hlasů)"
                out.unshift "<b>Celkem: #{(percentSum * 100).toFixed 2}%</b> (#{countSum} hlasů)"
                shortText += out[0]
                out.join "<br />"

            tooltip.display shortText
            clearTimeout longTextTimeout if longTextTimeout
            longTextTimeout := setTimeout do
                -> tooltip.display longText
                1200
        ..on \mouseout ->
            tooltip.hide!
            clearTimeout longTextTimeout if longTextTimeout

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
    drawLegend years[id]
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

$gradientContainer = $ "<div></div>"
    ..addClass \gradientContainer
    ..appendTo $body

colors = <[#FFF5F0 #FEE0D2 #FCBBA1 #FC9272 #FB6A4A #EF3B2C #CB181D #A50F15 #67000D]>
drawLegend = (year) ->
    $gradientContainer.empty!
    values = switch year
        | 1998 => [0 0.10  0.125 0.138 0.150 0.163 0.178 0.2   0.42 ]
        | 2002 => [0 0.08  0.098 0.112 0.124 0.138 0.157 0.189 0.7  ]
        | 2006 => [0 0.044 0.059 0.070 0.08  0.091 0.104 0.124 0.52 ]
        | 2010 => [0 0.287 0.323 0.349 0.374 0.398 0.426 0.465 0.692]
    for color, index in colors
        value = values[index]
        ele = $ "<div></div>"
            ..css \background color
            ..html "#{Math.round value * 100}%"
            ..appendTo $gradientContainer

        if index >= 5
            ele.addClass \dark

geocoder = null
geocodeMarker = null
L.Icon.Default.imagePath = "http://service.ihned.cz/js/leaflet/images"
geocode = (address, cb) ->
    (results, status) <~ geocoder.geocode {address}
    return cb status if status isnt google.maps.GeocoderStatus.OK
    return cb 'no-results' unless results?.length > 0
    result = results[0]
    latlng = new L.LatLng do
        result.geometry.location.lat!
        result.geometry.location.lng!
    map.setView latlng, 10
    if geocodeMarker == null
        geocodeMarker := L.marker latlng
            ..on \mouseover -> map.removeLayer geocodeMarker
    geocodeMarker
        ..addTo map
        ..setLatLng latlng
    cb null
$ '.search button' .on \click (evt) ->
    geocoder ?:= new google.maps.Geocoder();
    evt.preventDefault!
    address = $ '.search input' .val!
    (err) <~ geocode address
    if err
        alert "Bohužel danou adresu se nám nepodařilo nalézt."
selectLayer firstYearIndex
