context('metadata')

test_that(
  'metadata_lscape works',
  c(
    expect_error(slga::metadata_lscape('ASPCT', req_type = 'cov')),
    expect_error(slga::metadata_lscape('ASPCT', format = 'JSON')),
    expect_error(slga::metadata_lscape('CLY'))
  )
)

test_that(
  'metadata_soils works',
  c(
    expect_error(slga::metadata_soils('NAT_3D', 'CLY', req_type = 'cov')),
    expect_error(slga::metadata_soils('NAT_3D', 'CLY', format = 'JSON')),
    expect_error(slga::metadata_soils('ASPCT'))
  )
)
