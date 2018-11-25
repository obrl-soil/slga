context('helpers')

test_that(
  'transform_bb functions as expected',
  c(
    # function is only called when its clear that data is not already in 4326
    # see helpers.R lines 144-157
    # testing on King Island in UTM
    # this is fun b/c King Island is right on a UTM boundary
    # see https://polydesmida.info/locationsintasmania/kingis.html
    aoi1 <- structure(c(220820.20919087972, 5614919.8981960956,
                        259867.18631781312, 5549560.540934111),
                     names = c("xmin", "ymin", "xmax", "ymax"),
                     class = "bbox", crs = sf::st_crs(28355)),
    val1 <- slga:::transform_bb(aoi1),
    expect_is(val1, 'bbox'),
    expect_equal(attr(val1, 'crs')$epsg, 4326),
    expect_equivalent(val1[1], 143.75),
    expect_equivalent(val1[2], -40.17),
    expect_equivalent(val1[3], 144.18),
    expect_equivalent(val1[4], -39.57),
    # now test in 3577
    aoi2 <- structure(c(1021763.636335253,  -4374038.1744254353,
                        1052795.4510353433, -4442887.2711811019),
                     names = c("xmin", "ymin", "xmax", "ymax"),
                     class = "bbox", crs = sf::st_crs(3577)),
    val2 <- slga:::transform_bb(aoi2),
    expect_is(val2, 'bbox'),
    expect_equal(attr(val2, 'crs')$epsg, 4326),
    expect_equivalent(val2[1], 143.75),
    expect_equivalent(val2[2], -40.17),
    expect_equivalent(val2[3], 144.18),
    expect_equivalent(val2[4], -39.57)
    # val1 and val2 aren't 1000% equal but that's ok, they're pretty damn close
  )
)

test_that(
  'align_aoi functions as expected',
  # only testing snap = 'out' for now as not using the others
  c(
    aoi <- structure(c(143.75, -40.17, 144.18, -39.57),
                      names = c("xmin", "ymin", "xmax", "ymax"),
                      class = "bbox", crs = sf::st_crs(4326)),
    val1 <- slga:::validate_aoi(aoi, 'NAT'),
    val2 <- slga:::validate_aoi(aoi, 'TAS'),
    expect_is(val1, 'bbox'),
    expect_equal(attr(val1, 'crs')$epsg, 4326),
    expect_is(val2, 'bbox'),
    expect_equal(attr(val2, 'crs')$epsg, 4326),
    expect_equivalent(val1[1], 143.749583),
    expect_equivalent(val1[2], -40.1704166),
    expect_equivalent(val1[3], 144.180416),
    expect_equivalent(val1[4], -39.569583),
    expect_equivalent(val1[1], val2[1]),
    expect_equivalent(val1[2], val2[2]),
    expect_equivalent(val1[3], val2[3]),
    expect_equivalent(val1[4], val2[4])
  )
)

test_that(
  'validate_aoi functions as expected',
  c(
    aoi <- structure(c(143.75, -40.17, 144.18, -39.57),
                     names = c("xmin", "ymin", "xmax", "ymax"),
                     class = "bbox", crs = sf::st_crs(4326)),
    val1 <- slga:::validate_aoi(aoi, 'NAT'),
    val2 <- slga:::validate_aoi(aoi, 'TAS'),
    expect_is(val1, 'bbox'),
    expect_equal(attr(val1, 'crs')$epsg, 4326),
    expect_is(val2, 'bbox'),
    expect_equal(attr(val2, 'crs')$epsg, 4326),
    expect_error(slga:::validate_aoi(aoi, 'SA')),
    aoi_simple <- c(143.75, -40.17, 144.18, -39.57),
    val3 <- slga:::validate_aoi(aoi_simple, 'NAT'),
    expect_equal(val1, val3),
    aoi_raster <- raster::extent(sf::st_sf(sf::st_as_sfc(val1), 4326)),
    val4 <- slga:::validate_aoi(aoi_raster, 'NAT'),
    expect_equal(val1, val4)
    # can't test raster obj without demo data
  )
)

test_that(
  'check_avail functions as expected',
  c(
    val1 <- slga:::check_avail('TAS', 'AWC'),
    val2 <- slga:::check_avail('WA', 'AWC'),
    expect_is(val1, 'logical'),
    expect_length(val1, 1),
    expect_equal(val1, FALSE),
    expect_is(val2, 'logical'),
    expect_equal(val2, TRUE)
  )
)

