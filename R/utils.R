
prepend_class <- function(x, ...) {
  `class<-`(x, unique(c(..., class(x))))
}
append_class <- function(x, ...) {
  `class<-`(x, unique(c(class(x), ...)))
}

