context('url_generator')

test_that(
  'soils url generates correctly',
  c(
    # testing on king island with a plain vector aoi
    aoi <- c(143.75, -40.17, 144.18, -39.57),
    val1 <- slga:::make_soils_url('TAS', 'CLY', 'value', 1, aoi),
    expect_is(val1, 'character'),
    expect_equal(val1, "http://www.asris.csiro.au/ArcGis/services/TERN/CLY_ACLEP_AU_TAS_N/MapServer/WCSServer?REQUEST=GetCoverage&SERVICE=WCS&VERSION=1.0.0&COVERAGE=1&CRS=EPSG:4283&BBOX=143.749583333896,-40.1704166669525,144.180416667236,-39.5695833336095&WIDTH=517&HEIGHT=721&FORMAT=GeoTIFF"),
    # make sure depths work
    val2 <- slga:::make_soils_url('TAS', 'CLY', 'value', 5, aoi),
    expect_is(val2, 'character'),
    expect_equal(val2, "http://www.asris.csiro.au/ArcGis/services/TERN/CLY_ACLEP_AU_TAS_N/MapServer/WCSServer?REQUEST=GetCoverage&SERVICE=WCS&VERSION=1.0.0&COVERAGE=13&CRS=EPSG:4283&BBOX=143.749583333896,-40.1704166669525,144.180416667236,-39.5695833336095&WIDTH=517&HEIGHT=721&FORMAT=GeoTIFF"),
    expect_error(slga:::make_soils_url('NT', 'CLY', 'value', 1, aoi)),
    expect_error(slga:::make_soils_url('TAS', 'unicorns', 'value', 1, aoi)),
    expect_error(slga:::make_soils_url('TAS', 'CLY', 'fairies', 1, aoi)),
    expect_error(slga:::make_soils_url('TAS', 'CLY', 'value', 11, aoi)),
    expect_error(slga:::make_soils_url('TAS', 'CLY', 'value', 1, 'leprechauns')),
    val3 <- slga:::make_soils_url('TAS', 'CLY', req_type = 'cap'),
    expect_equal(val3, "http://www.asris.csiro.au/ArcGis/services/TERN/CLY_ACLEP_AU_TAS_N/MapServer/WCSServer?REQUEST=GetCapabilities&SERVICE=WCS&VERSION=1.0.0"),
    val4 <- slga:::make_soils_url('TAS', 'CLY', req_type = 'desc'),
    expect_equal(val4, "http://www.asris.csiro.au/ArcGis/services/TERN/CLY_ACLEP_AU_TAS_N/MapServer/WCSServer?REQUEST=DescribeCoverage&SERVICE=WCS&VERSION=1.0.0"),
    val5 <- slga:::make_soils_url('TAS', 'CLY', 'value', 1, req_type = 'desc'),
    expect_equal(val5, "http://www.asris.csiro.au/ArcGis/services/TERN/CLY_ACLEP_AU_TAS_N/MapServer/WCSServer?REQUEST=DescribeCoverage&SERVICE=WCS&VERSION=1.0.0&COVERAGE=1"),
    expect_error(slga:::make_soils_url('TAS', req_type = 'desc')),
    expect_error(slga:::make_soils_url('TAS', req_type = 'cap')),
    expect_error(slga:::make_soils_url('TAS', req_type = 'capybara'))
    )
)

test_that(
  'lscape url generates correctly',
  c(
    # testing on king island with a plain vector aoi
    aoi <- c(143.75, -40.17, 144.18, -39.57),
    val1 <- slga:::make_lscape_url('SLPPC', aoi),
    expect_is(val1, 'character'),
    expect_equal(nchar(val1), 276),
    expect_equal(val1, "http://www.asris.csiro.au/ArcGis/services/TERN/SRTM_attributes_3s_ACLEP_AU/MapServer/WCSServer?REQUEST=GetCoverage&SERVICE=WCS&VERSION=1.0.0&COVERAGE=6&CRS=EPSG:4283&BBOX=143.749583333896,-40.1704166669533,144.180416667236,-39.5695833336103&WIDTH=517&HEIGHT=721&FORMAT=GeoTIFF"),
    expect_error(slga:::make_lscape_url('bigfoot', aoi)),
    expect_error(slga:::make_lscape_url('ASPCT', 'leprechauns')),
    val2 <- slga:::make_lscape_url(req_type = 'desc'),
    expect_equal(val2, "http://www.asris.csiro.au/ArcGis/services/TERN/SRTM_attributes_3s_ACLEP_AU/MapServer/WCSServer?REQUEST=DescribeCoverage&SERVICE=WCS&VERSION=1.0.0"),
    val3 <- slga:::make_lscape_url('SLPPC', req_type = 'desc'),
    expect_equal(val3, "http://www.asris.csiro.au/ArcGis/services/TERN/SRTM_attributes_3s_ACLEP_AU/MapServer/WCSServer?REQUEST=DescribeCoverage&SERVICE=WCS&VERSION=1.0.0&COVERAGE=6"),
    val4 <- slga:::make_lscape_url(req_type = 'cap'),
    expect_equal(val4, "http://www.asris.csiro.au/ArcGis/services/TERN/SRTM_attributes_3s_ACLEP_AU/MapServer/WCSServer?REQUEST=GetCapabilities&SERVICE=WCS&VERSION=1.0.0"),
    expect_error(slga:::make_lscape_url(req_type = 'capybara'))
    )
)
