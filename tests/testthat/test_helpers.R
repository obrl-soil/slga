context('helpers')

test_that(
  'transform_bb functions as expected',
  c(
    # function is only called when its clear that data is not already in 4283
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
    expect_equal(attr(val1, 'crs')$epsg, 4283),
    expect_equivalent(val1[1], 143.7221117),
    expect_equivalent(val1[2], -40.1699999),
    expect_equivalent(val1[3], 144.204006),
    expect_equivalent(val1[4], -39.57),
    # now test in 3577
    aoi2 <- structure(c(1021763.636335253,  -4374038.1744254353,
                        1052795.4510353433, -4442887.2711811019),
                     names = c("xmin", "ymin", "xmax", "ymax"),
                     class = "bbox", crs = sf::st_crs(3577)),
    val2 <- slga:::transform_bb(aoi2),
    expect_is(val2, 'bbox'),
    expect_equal(attr(val2, 'crs')$epsg, 4283),
    expect_equivalent(val2[1], 143.75),
    expect_equivalent(val2[2], -40.1966433),
    expect_equivalent(val2[3], 144.18),
    expect_equivalent(val2[4], -39.543595)
    # val1 and val2 aren't 1000% equal but that's ok, they're pretty damn close
  )
)

test_that(
  'align_aoi functions as expected',
  c(
    aoi <- structure(c(143.75, -40.17, 144.18, -39.57),
                      names = c("xmin", "ymin", "xmax", "ymax"),
                      class = "bbox", crs = sf::st_crs(4283)),
    val1 <- slga:::align_aoi(aoi, 'NAT'),
    val2 <- slga:::align_aoi(aoi, 'TAS'),
    expect_is(val1, 'bbox'),
    expect_equal(attr(val1, 'crs')$epsg, 4283),
    expect_is(val2, 'bbox'),
    expect_equal(attr(val2, 'crs')$epsg, 4283),
    expect_equivalent(val1[1], 143.749583),
    expect_equivalent(val1[2], -40.1704166),
    expect_equivalent(val1[3], 144.180416),
    expect_equivalent(val1[4], -39.569583),
    expect_equivalent(val1[1], val2[1]),
    expect_equivalent(val1[2], val2[2]),
    expect_equivalent(val1[3], val2[3]),
    expect_equivalent(val1[4], val2[4]),
    val3 <- slga:::align_aoi(aoi, 'NAT', snap = 'in'),
    # in is inside out
    expect_true(val1[[1]] < val3[[1]]),
    expect_true(val1[[2]] < val3[[2]]),
    expect_true(val1[[3]] > val3[[3]]),
    expect_true(val1[[4]] > val3[[4]]),
    # by only one cell
    expect_equivalent(val1[1] - val3[1], -0.0008333333),
    expect_equivalent(val1[2] - val3[2], -0.0008333333),
    expect_equivalent(val1[3] - val3[3], 0.0008333333),
    expect_equivalent(val1[4] - val3[4], 0.0008333333),
    val4 <- slga:::align_aoi(aoi, 'NAT', snap = 'near'),
    # near is near
    expect_true(val1[[1]] == val4[[1]]),
    expect_true(val1[[2]] != val4[[2]]),
    expect_error(slga:::align_aoi(aoi, 'NAT', snap = 'wherever')),
    val5 <- slga:::align_aoi(val1, 'NAT'),
    expect_equal(val1, val5)
  )
)

test_that(
  'validate_aoi functions as expected',
  c(
    aoi <- structure(c(143.75, -40.17, 144.18, -39.57),
                     names = c("xmin", "ymin", "xmax", "ymax"),
                     class = "bbox", crs = sf::st_crs(4283)),
    val1 <- slga:::validate_aoi(aoi, 'NAT'),
    val2 <- slga:::validate_aoi(aoi, 'TAS'),
    expect_is(val1, 'bbox'),
    expect_equal(attr(val1, 'crs')$epsg, 4283),
    expect_is(val2, 'bbox'),
    expect_equal(attr(val2, 'crs')$epsg, 4283),
    expect_error(slga:::validate_aoi(aoi, 'SA')),
    aoi_simple <- c(143.75, -40.17, 144.18, -39.57),
    val3 <- slga:::validate_aoi(aoi_simple, 'NAT'),
    expect_equal(val1, val3),
    aoi_raster <- raster::extent(sf::st_sf(sf::st_as_sfc(val1), 4283)),
    val4 <- slga:::validate_aoi(aoi_raster, 'NAT'),
    expect_equal(val1, val4),
    library(raster),
    data('ki_surface_clay'),
    val5 <- slga:::validate_aoi(ki_surface_clay, 'NAT'),
    val6 <- slga:::validate_aoi(raster::extent(ki_surface_clay), 'NAT'),
    expect_equivalent(val5, val6),
    expect_error(slga:::validate_aoi('1', 'NAT')),
    val7 <- sf::st_as_sfc(aoi, crs = 4283),
    expect_equal(slga:::validate_aoi(val7, 'NAT'), val1),
    val7a <- sf::st_sf(val7),
    expect_equal(slga:::validate_aoi(val7a, 'NAT'), val1),
    val8 <- st_bbox(sf::st_transform(sf::st_as_sfc(aoi, crs = 4283), 28356)),
    val9 <- val8,
    attr(val9, 'crs')$epsg <- NA,
    expect_equal(slga:::validate_aoi(val8, 'NAT'), slga:::validate_aoi(val9, 'NAT')),
    expect_equal(slga:::validate_aoi(val9, 'NAT'), slga:::validate_aoi(val9, 'NAT'))
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

test_that(
  'convert_aoi functions as expected',
  c(badx_aoi <- c(c(144.18, -40.17, 143.75, -39.57)),
    bady_aoi <- c(c(143.75, -39.57, 144.18, -40.17)),
    bado_aoi <- c(c(143.75, 144.18, -40.17, -39.57)),
    expect_error(slga:::convert_aoi(badx_aoi)),
    expect_error(slga:::convert_aoi(bady_aoi)),
    expect_error(slga:::convert_aoi(bado_aoi)),
  )
)
