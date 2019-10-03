test_that("split_test_train works", {
  ## example data frame
  d <- data.frame(
    x = rnorm(100),
    y = rnorm(100),
    z = c(rep("a", 80), rep("b", 20))
  )

  ## split using defaults
  expect_true(is.list(split_test_train(d)))
  expect_named(split_test_train(d))
  expect_true(all(c("train", "test") %in% names(split_test_train(d))))
  expect_true(is.data.frame(split_test_train(d)[[1]]))

  ## split 0.60/0.40
  expect_equal(nrow(split_test_train(d, 0.60)[["train"]]), 60)

  ## split with equal response level obs
  expect_equal(nrow(split_test_train(d, 0.80, label = z)[["train"]]), 40)

  ## apply to atomic data
  expect_true(is.list(split_test_train(letters)))
  expect_named(split_test_train(letters))
  expect_true(all(c("train", "test") %in% names(split_test_train(letters))))
  expect_true(is.data.frame(split_test_train(letters)[[1]]))
})
