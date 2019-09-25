
#' As wactor
#'
#' Convert data into object of type 'wactor'
#'
#' @param .x Input text vector
#' @param ... Other args passed to Wactor$new(...)
#' @return An object of type wactor
#' @export
as_wactor <- function(.x, ...) {
  UseMethod("as_wactor")
}

#' @export
as_wactor.default <- function(.x, ...) {
  Wactor$new(.x, ...)
}

#' Term frequency inverse document frequency
#'
#' Converts character vector into a term frequency inverse document frequency
#' (TFIDF) matrix
#'
#' @param object Input object containing dictionary (column), e.g., wactor
#' @param .x Text from which the tfidf matrix will be created
#' @return A c-style matrix
#' @export
tfidf <- function(object, .x = NULL) UseMethod("tfidf")

#' @export
tfidf.wactor <- function(object, .x = NULL) {
  object$tfidf(.x %||% w$.text)
}

#' Document term frequency
#'
#' Converts character vector into document term matrix (dtm)
#'
#' @param object Input object containing dictionary (column), e.g., wactor
#' @param .x Text from which the document term matrix will be created
#' @return A c-style matrix
#' @export
dtm <- function(object, .x = NULL) UseMethod("dtm")

#' @export
dtm.wactor <- function(object, .x = NULL) {
  object$dtm(.x %||% w$.text)
}

#' @export
predict.wactor <- function(object, .x = NULL) {
  dtm(object, .x)
}

#' @export
summary.wactor <- function(object, .x) {
  len <- length(object$.vocab$term)
  x <- as.data.frame(object)
  attr(x, "len") <- len
  x
}

#' @export
plot.wactor <- function(object, n = 20) {
  x <- utils::head(as.data.frame(object), n)
  x$term <- factor(x$term, levels = rev(unique(x$term)))
  ggplot2::ggplot(x, ggplot2::aes(x = term, y = term_count)) +
    ggplot2::geom_col() +
    ggplot2::coord_flip()
}
