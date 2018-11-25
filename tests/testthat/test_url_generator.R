context('url generator')

test_that(
  'url generates correctly',
  c(
    # testing on king island with a plain vector aoi
    aoi <- c(143.75, -40.17, 144.18, -39.57),
    val1 <- slga:::make_slga_url('TAS', 'CLY', 'value', 1, aoi),
    expect_is(val1, 'character'),
    expect_equal(nchar(val1), 267),
    expect_equal(val1, "http://www.asris.csiro.au/ArcGis/services/TERN/CLY_ACLEP_AU_TAS_N/MapServer/WCSServer?REQUEST=GetCoverage&SERVICE=WCS&VERSION=1.0.0&COVERAGE=1&CRS=EPSG:4283&BBOX=143.749583333896,-40.1704166669525,144.180416667236,-39.5695833336095&WIDTH=517&HEIGHT=721&FORMAT=GeoTIFF"),
    # make sure depths work
    val2 <- slga:::make_slga_url('TAS', 'CLY', 'value', 5, aoi),
    expect_is(val2, 'character'),
    expect_equal(nchar(val2), 268),
    expect_equal(val2, "http://www.asris.csiro.au/ArcGis/services/TERN/CLY_ACLEP_AU_TAS_N/MapServer/WCSServer?REQUEST=GetCoverage&SERVICE=WCS&VERSION=1.0.0&COVERAGE=13&CRS=EPSG:4283&BBOX=143.749583333896,-40.1704166669525,144.180416667236,-39.5695833336095&WIDTH=517&HEIGHT=721&FORMAT=GeoTIFF")
    )
)
