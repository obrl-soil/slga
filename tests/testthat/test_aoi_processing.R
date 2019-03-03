context('aoi processing')

test_that(
  'aoi_convert functions as expected',
  c(badx_aoi <- c(144.18, -40.17, 143.75, -39.57),
    bady_aoi <- c(143.75, -39.57, 144.18, -40.17),
    bado_aoi <- c(143.75, 144.18, -40.17, -39.57),
    expect_error(slga:::aoi_convert(badx_aoi)),
    expect_error(slga:::aoi_convert(bady_aoi)),
    expect_error(slga:::aoi_convert(bado_aoi))
  )
)

test_that(
  'aoi_transform functions as expected',
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
    val1 <- slga:::aoi_transform(aoi1),
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
    val2 <- slga:::aoi_transform(aoi2),
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
  'aoi_overlaps functions as expected',
  c(
    aoi <- structure(c(150.0, -27, 151.0, -26),
                      names = c("xmin", "ymin", "xmax", "ymax"),
                      class = "bbox", crs = sf::st_crs(4283)),
    expect_false(slga:::aoi_overlaps(aoi, 'TAS')),
     expect_true(slga:::aoi_overlaps(aoi, 'NAT'))
  )
)

test_that(
  'aoi_align functions as expected',
  c(
    aoi <- structure(c(143.75, -40.17, 144.18, -39.57),
                     names = c("xmin", "ymin", "xmax", "ymax"),
                     class = "bbox", crs = sf::st_crs(4283)),
    val1 <- slga:::aoi_align(aoi, 'NAT'),
    val2 <- slga:::aoi_align(aoi, 'TAS'),
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
    val3 <- slga:::aoi_align(aoi, 'NAT', snap = 'in'),
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
    val4 <- slga:::aoi_align(aoi, 'NAT', snap = 'near'),
    # near is near
    expect_true(val1[[1]] == val4[[1]]),
    expect_true(val1[[2]] != val4[[2]]),
    expect_error(slga:::aoi_align(aoi, 'NAT', snap = 'wherever')),
    val5 <- slga:::aoi_align(val1, 'NAT'),
    expect_equal(val1, val5),
    # where aoi is from a single point
    aoi <- structure(c(150.0, -27, 150.0, -27),
                     names = c("xmin", "ymin", "xmax", "ymax"),
                     class = "bbox", crs = sf::st_crs(4283)),
    val6 <- slga:::aoi_align(aoi, 'NAT'),
    expect_true(val6[1] != val6[3]),
    expect_true(val6[2] != val6[4]),
    val7 <- slga:::aoi_align(aoi, 'NAT', snap = 'in'),
    expect_true(val7[1] != val7[3]),
    expect_true(val7[2] != val7[4]),
    expect_true(val7[1] < val7[3]),
    expect_true(val7[2] < val7[4]),
    expect_equal(val6, val7)
  )
)

test_that(
  'aoi_tile functions as expected',
  c(
    lrge_aoi <- structure(c(148, -27, 151.5, -21.5),
                          names = c("xmin", "ymin", "xmax", "ymax"),
                          class = "bbox", crs = sf::st_crs(4283)),
    t1 <- aoi_tile(lrge_aoi, 'NAT'),
    expect_is(t1, 'list'),
    expect_length(t1, 24L),
    expect_is(t1[[1]], 'bbox'),
    smol_aoi <- structure(c(148, -27, 148.5, -26.5),
                          names = c("xmin", "ymin", "xmax", "ymax"),
                          class = "bbox", crs = sf::st_crs(4283)),
    t2 <- aoi_tile(smol_aoi, 'NAT'),
    expect_is(t2, 'bbox')
  )
)

test_that(
  'validate_aoi functions as expected',
  c(
    aoi <- structure(c(143.75, -40.17, 144.18, -39.57),
                     names = c("xmin", "ymin", "xmax", "ymax"),
                     class = "bbox", crs = sf::st_crs(4283)),
    expect_error(validate_aoi(aoi)), # no product supplied
    val1 <- slga:::validate_aoi(aoi, 'NAT'), # normal bbox input
    val2 <- slga:::validate_aoi(aoi, 'TAS'), # normal bbox input
    expect_is(val1, 'bbox'),
    expect_equal(attr(val1, 'crs')$epsg, 4283),
    expect_is(val2, 'bbox'),
    expect_equal(attr(val2, 'crs')$epsg, 4283),
    expect_error(slga:::validate_aoi(aoi, 'SA')), # no overlap
    # convert from simple
    aoi_simple <- c(143.75, -40.17, 144.18, -39.57),
    val3 <- slga:::validate_aoi(aoi_simple, 'NAT'),
    expect_equal(val1, val3),
    # convert from raster extent
    aoi_raster <- raster::extent(sf::st_sf(sf::st_as_sfc(val1), 4283)),
    val4 <- slga:::validate_aoi(aoi_raster, 'NAT'),
    expect_equal(val1, val4),
    # convert from actual raster
    library(raster),
    data('ki_surface_clay'),
    val5 <- slga:::validate_aoi(ki_surface_clay, 'NAT'),
    val6 <- slga:::validate_aoi(raster::extent(ki_surface_clay), 'NAT'),
    expect_equivalent(val5, val6),
    expect_error(slga:::validate_aoi('1', 'NAT')),
    # convert from sfc
    val7 <- sf::st_as_sfc(aoi, crs = 4283),
    expect_equal(slga:::validate_aoi(val7, 'NAT'), val1),
    # convert from sfg
    expect_equal(slga:::validate_aoi(val7[[1]], 'NAT'), val1),
    # convert from sf
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
  'validate_poi functions as expected',
  c(
    expect_error(slga:::validate_poi(c(151, 27), 'NAT')),
    poi <- c(151, -27),
    v1 <- slga:::validate_poi(poi, 'NAT'),
    v2 <- slga:::validate_poi(poi, 'NAT', buff = 3),
    expect_is(v1, 'bbox'),
    expect_is(v2, 'bbox'),
    expect_equal(attr(v1, 'crs')$epsg, 4283),
    expect_equal(attr(v2, 'crs')$epsg, 4283),
    expect_true(v1[1] < poi[1]), # v1 encloses poi
    expect_true(v1[2] < poi[2]),
    expect_true(v1[3] > poi[1]),
    expect_true(v1[4] > poi[2]),
    expect_equal(as.vector(abs(v1[1] - v1[3])), 0.0008333333), # v1 is 1x1 cell
    expect_equal(as.vector(abs(v1[2] - v1[4])), 0.0008333333),
    expect_true(v2[1] < v1[1]),  # v2 encloses v1
    expect_true(v2[2] < v1[2]),
    expect_true(v2[3] > v1[3]),
    expect_true(v2[4] > v1[4]),
    # poi is an sf point
    poi_xy <- st_point(c(151, -27)),
    v3 <- slga:::validate_poi(poi_xy, 'NAT'),
    expect_equal(v1, v3),
    # poi is an sfc_POINT of length 1 (e.g. from splitting an sfc)
    poi_sfc <- sf::st_sfc(poi_xy),
    v4 <- slga:::validate_poi(poi_sfc, 'NAT'),
    expect_equal(v1, v4),
    # poi is an sf object with 1 row (e.g. from splitting an sf data frame)
    poi_sf <- sf::st_sf(poi_sfc),
    poi_sf$id <- 1,
    v5 <- slga:::validate_poi(poi_sf, 'NAT'),
    expect_equal(v1, v5)
    )
)


