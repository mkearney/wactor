std_dev <- function(x, na.rm = TRUE) {
  cppsd(x, na.rm)
}

variance <- function(x, na.rm = TRUE) {
  cppvar(x, na.rm)
}

the_mean <- function(x, na.rm = TRUE) {
  cppmean(x, na.rm)
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


scale_with_params <- function(x, m, std) {
  ncol <- length(m)
  nrow <- nrow(x)
  divide <- function(e1, e2) {
    e <- `/`(e1, e2)
    e[e2 == 0 & e1 == 0] <- 0
    e
  }
  divide((x - matrix(m,
    nrow = nrow,
    ncol = ncol,
    byrow = TRUE)), matrix(std,
      nrow = nrow,
      ncol = ncol,
      byrow = TRUE))
}

sampleit <- function(x, n) {
  if (!is.list(x)) {
    sort(sample(x, n))
  } else {
    sort(unlist(lapply(x, sample, round(n / length(x)), 0), use.names = FALSE))
  }
}

capture_dots <- function(...) {
  eval(substitute(alist(...)), envir = parent.frame())
}
