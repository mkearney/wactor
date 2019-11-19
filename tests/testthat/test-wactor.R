test_that("wactor works", {
  w <- wactor(letters)
  expect_named(w)
  expect_true(all(c(".text", "tfidf", "dtm", ".vocab") %in% names(w)))
  d <- as.data.frame(w)
  expect_true(is.data.frame(d))
  expect_equal(ncol(d), 3)
  expect_equal(nrow(d), 26)
  expect_gt(
    ncol(tfidf(w)),
    10
  )
  expect_gt(
    ncol(tfidf(letters)),
    10
  )
  expect_equal(
    nrow(tfidf(w)),
    nrow(d)
  )
  expect_gt(
    ncol(dtm(w)),
    10
  )
  expect_gt(
    ncol(dtm(letters)),
    10
  )
  expect_equal(
    predict(w),
    dtm(w)
  )
  expect_equal(
    predict(w, c("a", "b", "c", "c")),
    dtm(w, c("a", "b", "c", "c"))
  )
  expect_equal(
    predict(w, newdata = c("a", "b", "c", "c")),
    predict(w, c("a", "b", "c", "c")),
  )
  expect_equal(
    nrow(dtm(w)),
    nrow(d)
  )

})
