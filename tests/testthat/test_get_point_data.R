context('point_data_queries')


test_that(
  'get_soils_point fails where it oughta',
  c(
    expect_error(get_soils_point('NAT', 'CLY', 'VAL', 1, c(151, -27),
                                 buff_shp = 'phantom')),
    expect_error(get_soils_point('NAT', 'CLY', 'VAL', 1, c(151, -27),
                                 buff_shp = 'circle', stat = c('mean', 'median'))),
    expect_error(get_soils_point('TAS', 'CEC',  'VAL', 1, c(151, -27)))
  )
)

test_that(
  'get_lscape_point fails where it oughta',
  c(
    expect_error(get_lscape_point('SLPPC', c(151, -27),
                                  buff_shp = 'phantom')),
    expect_error(get_lscape_point('SLPPC', c(151, -27),
                                  buff_shp = 'circle', stat = c('mean', 'median')))
  )
)
