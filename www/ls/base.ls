tooltip = new Tooltip!
map = L.map do
    *   'map'
    *   minZoom: 6,
        maxZoom: 10,
        zoom: 7,
        center: [49.7, 15.5]

allYears = years = [1996 1998 2002 2006 2010 2013]
currentYearOptions = allYears
currentYear = 2013
currentParty = \vitezove
currentLayer = null
srcPrefix = "../data"
getLayer = (party, year) ->
    L.tileLayer do
        *   "#srcPrefix/#party-#year/{z}/{x}/{y}.png"
        *   attribution: '<a href="http://creativecommons.org/licenses/by-nc-sa/3.0/cz/" target = "_blank">CC BY-NC-SA 3.0 CZ</a> <a target="_blank" href="http://ihned.cz">IHNED.cz</a>, data <a target="_blank" href="http://www.volby.cz">ČSÚ</a>'
            zIndex: 1

mapLayer = L.tileLayer do
    *   "http://ihned-mapy.s3.amazonaws.com/desaturized/{z}/{x}/{y}.png"
    *   zIndex: 2
        opacity: 0.65
        attribution: 'mapová data &copy; přispěvatelé OpenStreetMap, obrazový podkres <a target="_blank" href="http://ihned.cz">IHNED.cz</a>'
map.on \zoomend ->
    | map.getZoom! >= 10 => map.addLayer mapLayer
    | otherwise         => map.removeLayer mapLayer

getGrid = (party, year) ->
    new L.UtfGrid "#srcPrefix/#party-#year/{z}/{x}/{y}.json", useJsonP: no
        ..on \mouseover (e) ->
            {name, year, partyResults} = e.data
            txt = switch
            | e.data.id == "592935" and year <= 1998
                "V roce #{e.data.year} zde nikdo nevolil"
            | otherwise
                if currentParty == \koalice
                    out = ["<b>#{name}</b>, rok #year<br />"]
                    for side, index in partyResults
                        out.push "<b>#{if index == 0 then 'Koalice' else 'Opozice'}</b></br />"
                        for {abbr, percent, count} in side
                            out.push "#{abbr}: #{(percent * 100).toFixed 2}%  (#{count} hlasů)<br />"
                else
                    out = for {abbr, percent, count} in partyResults
                        if count is null or count is void
                            "<b>#{name}</b>: #{abbr} zde v roce #{year} nekandidovali"
                        switch currentParty
                        | \vitezove => "<b>#{name}</b>: v roce #{year} zvítězila #{abbr}, #{(percent * 100).toFixed 2}%  (#{count} hlasů)"
                        | \nevolici => "<b>#{name}</b>: v roce #{year} nešlo k volbám #{(percent * 100).toFixed 2}% voličů (#{count} lidí)"
                        | otherwise => "<b>#{name}</b>: volební výsledek #{abbr} v roce #{year}: #{(percent * 100).toFixed 2}%  (#{count} hlasů)"

                out.join ""
            tooltip.display txt
        ..on \mouseout -> tooltip.hide!

selectParty = (party) ->
    currentParty := party
    currentYearOptions :=
        | parties[party].years => that
        | otherwise            => allYears
    if currentYear not in currentYearOptions
        currentYear := currentYearOptions[currentYearOptions.length - 1]
    updateYearSelector currentYearOptions
    selectLayer currentParty, currentYear

selectLayer = (party, year) ->
    if currentLayer
        lastLayer = currentLayer
        setTimeout do
            ->
                map.removeLayer lastLayer.map
                map.removeLayer lastLayer.grid
            300
    layer = getLayer party, year
    grid  = getGrid party, year

    map.addLayer layer
    map.addLayer grid
    $year.html year
    drawLegend party
    currentLayer :=
        map: layer
        grid: grid


opts =
    min: 0
    max: years.length - 1
    value: years[years.length - 1]
    slide: (evt, ui) ->
        currentYear := currentYearOptions[ui.value]
        selectLayer currentParty, currentYear

parties =
    vitezove:
        name: "Vítězové voleb"
    koalice:
        name: "Vládní koalice"
        colors: <[#0571B0 #CA0020]>
        values: <[koal opo. ]>
    nevolici:
        name: "Nevoliči"
        colors: <[#FFFFFF #F0F0F0 #D9D9D9 #BDBDBD #969696 #737373 #525252 #252525 #000000]>
        values: [0 0.068 0.134 0.200 0.268 0.335 0.402 0.478 1]
    ano:
        name: "ANO 2011"
        colors: <[#F7FCF0 #E0F3DB #CCEBC5 #A8DDB5 #7BCCC4 #4EB3D3 #2B8CBE #0868AC #084081]>
        values: [0, 0.036, 0.073, 0.106, 0.145, 0.181, 0.218, 0.259, 0.525]
        years: [2013]
    usvit:
        name: "Úsvit"
        colors: <[#FFFFCC #FFEDA0 #FED976 #FEB24C #FD8D3C #FC4E2A #E31A1C #BD0026 #800026]>
        values: [0, 0.017, 0.034, 0.05ě, 0.069, 0.086, 0.103, 0.123, 0.329]
        years: [2013]
    ods:
        name: \ODS
        colors: <[#FFF7FB #ECE7F2 #D0D1E6 #A6BDDB #74A9CF #3690C0 #0570B0 #045A8D #023858]>
        values: [0, 0.06, 0.12, 0.18, 0.24, 0.30, 0.36, 0.43, 0.79]
    cssd:
        name: \ČSSD
        colors: <[ #FFFFE5 #FFF7BC #FEE391 #FEC44F #FE9929 #EC7014 #CC4C02 #993404 #662506 ]>
        values: [0, 0.06, 0.12, 0.18, 0.24, 0.3, 0.36, 0.42, 1]
    kscm:
        name: \KSČM
        colors: <[#FFF5F0 #FEE0D2 #FCBBA1 #FC9272 #FB6A4A #EF3B2C #CB181D #A50F15 #67000D ]>
        values: [0, 0.046, 0.093, 0.139, 0.185, 0.231, 0.278, 0.330, 0.698]
    vv:
        name: \VV
        colors: <[ #F7FBFF #DEEBF7 #C6DBEF #9ECAE1 #6BAED6 #4292C6 #2171B5 #08519C #08306B  ]>
        values: [0, 0.022, 0.044, 0.066, 0.088, 0.111, 0.133, 0.158, 0.358]
        years: [2010]
    kdu:
        name: "KDU-ČSL"
        colors: <[#FFFFE5 #FFF7BC #FEE391 #FEC44F #FE9929 #EC7014 #CC4C02 #993404 #662506 ]>
        values: [0, 0.037, 0.075, 0.112, 0.149, 0.187, 0.224, 0.267, 0.819]
    sz:
        name: \SZ
        colors: <[#F7FCF5 #E5F5E0 #C7E9C0 #A1D99B #74C476 #41AB5D #238B45 #006D2C #00441B ]>
        values: [0, 0.011, 0.022, 0.034, 0.045, 0.057, 0.068, 0.081, 0.33]
        years: [1998 2002 2006 2010, 2013]
    oda:
        name: \ODA
        colors: <[#FFF7FB #ECE7F2 #D0D1E6 #A6BDDB #74A9CF #3690C0 #0570B0 #045A8D #023858 ]>
        values: [0, 0.012, 0.023, 0.035, 0.047, 0.059, 0.070, 0.084, 0.346]
        years: [1996 2002]
    top:
        name: "TOP 09"
        colors: <[#F7F4F9 #E7E1EF #D4B9DA #C994C7 #DF65B0 #E7298A #CE1256 #980043 #67001F ]>
        values: [0, 0.030, 0.061, 0.091, 0.121, 0.151, 0.182, 0.216, 0.491]
        years: [2010 2013]
    spr:
        name: "SPR-RSČ"
        colors: <[#FFF7F3 #FDE0DD #FCC5C0 #FA9FB5 #F768A1 #DD3497 #AE017E #7A0177 #49006A ]>
        values: [0, 0.021, 0.042, 0.063, 0.084, 0.105, 0.126, 0.15, 0.5]
        years: [1996 1998]
hashParty = location.hash.substr 1
if parties.hasOwnProperty hashParty
    currentParty = hashParty
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
$partySelectorContainer = $ "<div></div>"
    ..addClass \partySelectorContainer
    ..appendTo $body
$partySelector = $ "<select>"
    ..appendTo $partySelectorContainer
    ..on \change ->
        selectParty @value

for id, props of parties
    $ "<option value='#id'>#{props.name}</option>"
        ..appendTo $partySelector
$partySelector.chosen!

drawLegend = (party) ->
    $gradientContainer.empty!
    {values, colors} = parties[party]
    return if not colors
    for color, index in colors
        value = if party == \koalice
             values[index]
        else
            "#{Math.round values[index] * 100}%"
        ele = $ "<div></div>"
            ..css \background color
            ..html "#{value}"
            ..appendTo $gradientContainer

        if index >= 5
            ele.addClass \dark

updateYearSelector = (years) ->
    if years.length == 1
        $slider.addClass \disabled
    else
        $slider.removeClass \disabled
    $slider.slider "option" "max" years.length - 1

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
$ '.search form' .on \submit (evt) ->
    geocoder ?:= new google.maps.Geocoder();
    evt.preventDefault!
    address = $ '.search input' .val!
    _gaq.push ['_trackEvent' 'geocode' address]
    (err) <~ geocode address
    if err
        alert "Bohužel danou adresu se nám nepodařilo nalézt."
selectParty currentParty, currentYear
