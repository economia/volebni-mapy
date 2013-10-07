require! {
    topojson
    fs
    d3
}
obce = require "#__dirname/../data/obce_medium.topo.json"
# console.log obce, obce.objects.obce
features = topojson.feature obce, obce.objects.obce .features
console.log d3.geo.centroid features[0]
# console.log features[0]
out = for feature in features
    [lon, lat] = d3.geo.centroid feature
    lon .= toFixed 2
    lat .= toFixed 2
    {id, name} = feature.properties

    [id, name, lat, lon].join ';'
out .= join "\n"
fs.writeFile "#__dirname/test.csv", out
