context('helpers')

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
