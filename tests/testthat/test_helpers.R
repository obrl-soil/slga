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

test_that('filenamer is ok',
          c(
            expect_equal(slga_filenamer(product = 'NAT', attribute = 'CLY',
                                       component = 'ALL', depth = 1),
                         "NAT_CLY_ALL_000_005"))
          )

test_that('circmask is ok',
          c(
            v1 <- slga:::make_circ_mask(1),
            mat <- matrix(c(NA, 0, NA, 0, 0, 0, NA, 0, NA),
                          ncol = 3, nrow = 3, byrow = TRUE),
            expect_equal(v1, mat),
            expect_equal(slga:::make_circ_mask(0), as.matrix(0))
          )
        )
