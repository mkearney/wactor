test_that("xgb_mat works", {
  d <- data.frame(
    x = rnorm(100),
    y = rnorm(100)
  )
  z <- c(rep(1, 80), rep(0, 20))

  m1 <- xgb_mat(d)
  expect_true(inherits(m1, "xgb.DMatrix"))

  m2 <- xgb_mat(d, split = 0.8)
  expect_true(is.list(m2))
  expect_named(m2)
  expect_true(all(c("train", "test") %in% names(m2)))

  m3 <- xgb_mat(d, y = z)
  expect_true(all(c("x", "y") %in% colnames(m3)))
  expect_true(is.numeric(xgboost::getinfo(m3, "label")))
})
