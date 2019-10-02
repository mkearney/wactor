std_dev <- function(x, na.rm = TRUE) {
  sqrt(variance(x, na.rm = na.rm))
}

variance <- function(x, na.rm = TRUE) {
  cppvariance(x, na.rm)
}


prepend_class <- function(x, ...) {
  `class<-`(x, unique(c(..., class(x))))
}

append_class <- function(x, ...) {
  `class<-`(x, unique(c(class(x), ...)))
}

`%||%` <- function(x, y) {
  if (is_null(x))
    y
  else x
}

is_null <- function(x) is.null(x)

caller_env <- function(n = 1) {
  parent.frame(n + 1)
}


scale_with_params <- function(x, m, sd) {
  ncol <- length(m)
  nrow <- nrow(x)
  (x - matrix(m,
    nrow = nrow,
    ncol = ncol,
    byrow = TRUE)) / matrix(sd,
      nrow = nrow,
      ncol = ncol,
      byrow = TRUE)
}
