context('get_data')

# can only cover the fails :/
test_that(
  'get_soils_raster functions as expected',
  c(
    expect_error(slga:::get_soils_raster('NAT', 'BDF'))
  )
)

test_that(
  'get_soils_data functions as expected',
  c(
    expect_error(slga:::get_soils_data('ASPCT')),
    expect_error(slga::get_soils_data('NAT', 'PHC', 'none', 1,
                                      c(143.75, -40.17, 143.751, -40.169),
                                      write_out = FALSE)),
    # no dir:
    expect_error(slga::get_soils_data('NAT', 'CLY', 'VAL', 1, write_out = TRUE))

  )
)

test_that(
  'get_lscape_data functions as expected',
  c(
    expect_error(slga::get_lscape_data('NAT', 'CLY')),
    # no dir:
    expect_error(
      slga::get_lscape_data('SLPPC', c(143.75, -40.17, 143.751, -40.169),
                            write_out = TRUE))

  )
)
