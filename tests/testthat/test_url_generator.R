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
    expect_error(slga:::make_soils_url('TAS', req_type = 'capybara')),
    # big area requests - multiple GETs
    big_aoi <- c(145, -29, 146.8, -24.6),
    val6 <- slga:::make_soils_url('NAT', 'CLY', 'value', 5, big_aoi),
    expect_is(val6, 'list'),
    expect_length(val6, 10),
    expect_equal(val6[[1]], "http://www.asris.csiro.au/ArcGis/services/TERN/CLY_ACLEP_AU_NAT_C/MapServer/WCSServer?REQUEST=GetCoverage&SERVICE=WCS&VERSION=1.0.0&COVERAGE=13&CRS=EPSG:4283&BBOX=144.999583333916,-29.0004166667725,145.999583333932,-28.0004166667564&WIDTH=1200&HEIGHT=1200&FORMAT=GeoTIFF"),
    # big area, but only some tiles overlap product extent
    part_aoi <- c(147.2, -40, 150, -36),
    val7 <- slga:::make_soils_url('TAS', 'CLY', 'value', 1, aoi = part_aoi),
    expect_is(val7, 'list'),
    expect_length(val7, 2),
    # big area, and only one tile overlaps product extent
    part_aoi2 <- c(148, -40, 150, -36),
    val8 <- slga:::make_soils_url('TAS', 'CLY', 'value', 1, aoi = part_aoi2),
    expect_is(val8, 'character') # avoids mosaic
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
    expect_error(slga:::make_lscape_url(req_type = 'capybara')),
    expect_error(slga:::make_lscape_url(aoi = aoi)),
    # big areas
    big_aoi <- c(145, -29, 146.8, -24.6),
    val5 <- slga:::make_lscape_url('SLPPC', big_aoi),
    expect_is(val5, 'list'),
    expect_length(val5, 10),
    expect_equal(val5[[1]], "http://www.asris.csiro.au/ArcGis/services/TERN/SRTM_attributes_3s_ACLEP_AU/MapServer/WCSServer?REQUEST=GetCoverage&SERVICE=WCS&VERSION=1.0.0&COVERAGE=6&CRS=EPSG:4283&BBOX=144.999583333916,-29.000416666773,145.999583333932,-28.0004166667569&WIDTH=1200&HEIGHT=1200&FORMAT=GeoTIFF"),
    # big area, but only some tiles overlap product extent
    part_aoi <- c(141, -10.5, 144, -8),
    val7 <- slga:::make_lscape_url('SLPPC', aoi = part_aoi),
    expect_is(val7, 'list'),
    expect_length(val7, 4),
    # big area, and only one tile overlaps product extent
    part_aoi2 <- c(153.5, -10.1, 155, -8),
    val8 <- slga:::make_lscape_url('SLPPC', aoi = part_aoi2),
    expect_is(val8, 'character') # avoids mosaic
    )
)
