require! fs

option 'testFile' 'File in (/lib or /test) to run test on' 'FILE'
option 'currentfile' 'Latest file that triggered the save' 'FILE'

externalScripts =
    \http://service.ihned.cz/js/leaflet/v0.6.4.js
    \http://service.ihned.cz/js/leaflet/utfgrid.min.js
    \http://service.ihned.cz/js/jquery.min.js
    \http://service.ihned.cz/js/jq-ui/v1.10.3.autocomplete.slider.min.js
    \http://service.ihned.cz/js/jq-ui/jquery.ui.touch-punch.v0.2.2.min.js
    \http://service.ihned.cz/js/chosen/chosen.jquery.min.js

externalStyles =
    \http://service.ihned.cz/js/tooltip/v1.1.2.css
    \http://service.ihned.cz/js/leaflet/v0.6.4.css
    \http://service.ihned.cz/js/jq-ui/v1.10.3.autocomplete.slider.min.css
    \http://service.ihned.cz/js/chosen/chosen.abs.min.css

deferScripts = <[ base.js ]>
gzippable = <[ ]>
build-styles = (options = {}) ->
    require! async
    (err, [external, local]) <~ async.parallel do
        *   (cb) -> fs.readFile "#__dirname/www/external.css", cb
            (cb) -> prepare-stylus options, cb
    fs.writeFile "#__dirname/www/screen.css", external + "\n\n\n" + local

prepare-stylus = (options, cb) ->
    console.log "Building Stylus"
    require! stylus
    (err, data) <~ fs.readFile "#__dirname/www/styl/screen.styl"
    data .= toString!
    stylusCompiler = stylus data
        ..include "#__dirname/www/styl/"
    if options.compression
        stylusCompiler.set \compress true
    (err, css) <~ stylusCompiler.render
    throw err if err
    console.log "Stylus built"
    cb null css

build-script = (file, cb) ->
    require! child_process.exec
    (err, result) <~ exec "lsc -o #__dirname/www/js -c #__dirname/#file"
    throw err if err
    cb?!

build-all-scripts = (cb) ->
    console.log "Building scripts..."
    require! child_process.exec
    (err, result) <~ exec "lsc -o #__dirname/www/js -c #__dirname/www/ls"
    throw err if err
    console.log "Scripts built"
    cb?!

download-external-scripts = (cb) ->
    console.log "Dowloading scripts..."
    require! request
    require! async
    (err, responses) <~ async.map externalScripts, request~get
    bodies = responses.map (.body)
    <~ fs.writeFile "#__dirname/www/external.js" bodies.join "\n;\n"
    console.log "Scripts loaded"
    cb?!

download-external-styles = (cb) ->
    console.log "Downloading styles"
    require! request
    require! async
    (err, responses) <~ async.map externalStyles, request~get
    contents = responses.map (.body)
    <~ fs.writeFile "#__dirname/www/external.css" contents.join "\n\n"
    console.log "Styles loaded"
    cb!

combine-scripts = (options = {}, cb) ->
    console.log "Combining scripts..."
    require! uglify: "uglify-js"
    (err, files) <~ fs.readdir "#__dirname/www/js"
    files .= filter -> it isnt '_loadExternal.js' and it isnt 'script.js.map'
    files .= sort (a, b) ->
        indexA = deferScripts.indexOf a
        indexB = deferScripts.indexOf b
        indexA - indexB
    files .= map -> "./www/js/#it"
    minifyOptions = {}
    if not options.compression
        minifyOptions
            ..compress     = no
            ..mangle       = no
            ..outSourceMap = "../js/script.js.map"
            ..sourceRoot   = "../../"
        files.unshift "./www/js/_loadExternal.js"
    result = uglify.minify files, minifyOptions

    {map, code} = result
    if not options.compression
        code += "\n//@ sourceMappingURL=./js/script.js.map"
        fs.writeFile "#__dirname/www/js/script.js.map", map
    else
        external = fs.readFileSync "#__dirname/www/external.js"
        code = external + code
    (err) <~ fs.writeFile "#__dirname/www/script.js", code
    console.log "Scripts combined"
    cb? err

run-script = (file) ->
    require! child_process.exec
    (err, stdout, stderr) <~ exec "lsc #__dirname/#file"
    throw err if err
    console.error stderr if stderr
    console.log stdout

test-script = (file) ->
    require! child_process.exec
    [srcOrTest, ...fileAddress] = file.split /[\\\/]/
    fileAddress .= join '/'
    (err, stdout, stderr) <~ exec "lsc -o #__dirname/lib -c #__dirname/src"
    throw stderr if stderr
    cmd = "mocha --compilers ls:livescript -R tap --bail #__dirname/test/#fileAddress"
    (err, stdout, stderr) <~ exec cmd
    niceTestOutput stdout, stderr, cmd

relativizeFilename = (file) ->
    file .= replace __dirname, ''
    file .= replace do
        new RegExp \\\\, \g
        '/'
    file .= substr 1

gzip-files = (cb) ->
    require! async
    (err) <~ async.map gzippable, gzip-file
    cb err

gzip-file = (file, cb) ->
    require! zlib
    gzip = zlib.createGzip!
    address        = "#__dirname/www/#file"
    gzippedAddress = "#__dirname/www/#file.gz"
    input  = fs.createReadStream address
    output = fs.createWriteStream gzippedAddress
    input.pipe gzip .pipe output

    cb!

task \build ->
    download-external-scripts!
    <~ download-external-styles
    build-styles compression: no
    <~ build-all-scripts
    combine-scripts compression: no
task \deploy ->
    download-external-scripts!
    <~ download-external-styles
    build-styles compression: yes
    <~ build-all-scripts
    <~ combine-scripts compression: yes
    <~ gzip-files!
task \build-styles ->
    build-styles compression: no
task \build-script ({currentfile}) ->
    file = relativizeFilename currentfile
    isServer = \src/ == file.substr 0, 4
    isTest = \test/ == file.substr 0, 5
    if isServer or isTest
        test-script file
    else
        <~ build-script file
        combine-scripts compression: no

niceTestOutput = (test, stderr, cmd) ->
    lines         = test.split "\n"
    oks           = 0
    fails         = 0
    out           = []
    shortOut      = []
    disabledTests = []
    for line in lines
        if 'ok' == line.substr 0, 2
            ++oks
        else if 'not' == line.substr 0,3
            ++fails
            out.push line
            shortOut.push line.match(/not ok [0-9]+ (.*)$/)[1]
        else if 'Disabled' == line.substr 0 8
            disabledTests.push line
        else if line and ('#' != line.substr 0, 1) and ('1..' != line.substr 0, 3)
            console.log line# if ('   ' != line.substr 0, 3)
    if oks && !fails
        console.log "Tests OK (#{oks})"
        disabledTests.forEach -> console.log it
    else
        #console.log "!!!!!!!!!!!!!!!!!!!!!!!    #{fails}    !!!!!!!!!!!!!!!!!!!!!!!"
        if out.length
            console.log shortOut.join ", "#line for line in shortOut
        else
            console.log "Tests did not run (error in testfile?)"
            console.log test
            console.log stderr
            console.log cmd
