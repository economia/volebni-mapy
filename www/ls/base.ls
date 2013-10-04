tooltip = new Tooltip!
map = L.map do
    *   'map'
    *   minZoom: 6,
        maxZoom: 10,
        zoom: 6,
        center: [50, 15]
years = [1998 2002 2006 2010]
firstYearIndex = years.length - 1
currentLayer = null
layers = for year in years
    L.tileLayer "../data/protesty-#year/{z}/{x}/{y}.png"
grids = for let year in years
    grid = new L.UtfGrid "../data/protesty-#year/{z}/{x}/{y}.json", useJsonP: no
        ..on \mouseover (e) ->
            {name, year, partyResults} = e.data
            str = "<b>#{name}</b>, rok #{year}<br />"
            str += switch
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
                out.unshift "Celkem: #{(percentSum * 100).toFixed 2}% (#{countSum} hlasů)"
                out.join "<br />"

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
        | 2010 => [0 0.075 0.15 0.225 0.3 0.375 0.45 0.525 0.7]
        | _    => [0 0.025 0.05 0.075 0.1 0.125 0.15 0.175 0.7]
    for color, index in colors
        value = values[index]
        ele = $ "<div></div>"
            ..css \background color
            ..html "#{Math.round value * 100}%"
            ..appendTo $gradientContainer

        if index >= 5
            ele.addClass \dark

selectLayer firstYearIndex
