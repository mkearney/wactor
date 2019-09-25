
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
