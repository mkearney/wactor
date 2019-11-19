
#' As wactor
#'
#' Convert data into object of type 'wactor'
#'
#' @param .x Input text vector
#' @param ... Other args passed to Wactr$new(...)
#' @return An object of type wactor
#' @export
as_wactor <- function(.x, ...) {
  UseMethod("as_wactor")
}

#' @export
as_wactor.default <- function(.x, ...) {
  Wactr$new(.x, ...)
}


#' Create wactor
#'
#' Create an object of type 'wactor'
#'
#' @param .x Input text vector
#' @param ... Other args passed to Wactr$new(...)
#' @return An object of type wactor
#' @examples
#'
#' ## create
#' w <- wactor(c("a", "a", "a", "b", "b", "c"))
#'
#' ## summarize
#' summary(w)
#'
#' ## plot
#' plot(w)
#'
#' ## predict
#' predict(w)
#'
#' ## use on NEW data
#' dtm(w, letters[1:5])
#'
#' ## dtm() is the same as predict()
#' predict(w, letters[1:5])
#'
#' ## works if you specify 'newdata' too
#' predict(w, newdata = letters[1:5])
#'
#' @export
wactor <- function(.x, ...) {
  UseMethod("wactor")
}

#' @export
wactor.default <- function(.x, ...) {
  Wactr$new(.x, ...)
}


#' Term frequency inverse document frequency
#'
#' Converts character vector into a term frequency inverse document frequency
#' (TFIDF) matrix
#'
#' @param object Input object containing dictionary (column), e.g., wactor
#' @param .x Text from which the tfidf matrix will be created
#' @return A c-style matrix
#' @examples
#'
#' ## create wactor
#' w <- wactor(letters)
#'
#' ## use wactor to create tfidf of same vector
#' tfidf(w, letters)
#'
#' ## using the initial data is the default; so you don't actually have to
#' ## respecify it
#' tfidf(w)
#'
#' ## use wactor to create tfidf on new vector
#' tfidf(w, c("a", "e", "i", "o", "u"))
#'
#' ## apply directly to character vector
#' tfidf(letters)
#'
#' @export
tfidf <- function(object, .x = NULL) UseMethod("tfidf")

#' @export
tfidf.wactor <- function(object, .x = NULL) {
  object$tfidf(.x %||% object$.text)
}

#' @export
tfidf.character <- function(object, .x = NULL) {
  object <- wactor(object)
  object$tfidf(.x %||% object$.text)
}

#' Document term frequency
#'
#' Converts character vector into document term matrix (dtm)
#'
#' @param object Input object containing dictionary (column), e.g., wactor
#' @param .x Text from which the document term matrix will be created
#' @return A c-style matrix
#' @examples
#'
#' ## create wactor
#' w <- wactor(letters)
#'
#' ## use wactor to create dtm of same vector
#' dtm(w, letters)
#'
#' ## using the initial data is the default; so you don't actually have to
#' ## respecify it
#' dtm(w)
#'
#' ## use wactor to create dtm on new vector
#' dtm(w, c("a", "e", "i", "o", "u"))
#'
#' ## apply directly to character vector
#' dtm(letters)
#'
#' @export
dtm <- function(object, .x = NULL) UseMethod("dtm")

#' @export
dtm.wactor <- function(object, .x = NULL) {
  object$dtm(.x %||% object$.text)
}

#' @export
dtm.character <- function(object, .x = NULL) {
  object <- wactor(object)
  object$dtm(.x %||% object$.text)
}

#' @export
predict.wactor <- function(object, ...) {
  dots <- list(object = object, ...)
  names(dots)[names(dots) == "newdata"] <- ".x"
  do.call("dtm", dots)
}

#' @export
summary.wactor <- function(object, ...) {
  len <- length(object$.vocab$term)
  x <- as.data.frame(object)
  attr(x, "len") <- len
  x
}

#' @export
plot.wactor <- function(x, n = 20, ...) {
  x <- utils::head(as.data.frame(x), n)
  x$term <- factor(x$term, levels = rev(unique(x$term)))
  ggplot2::ggplot(x, ggplot2::aes(x = term, y = term_count)) +
    ggplot2::geom_col() +
    ggplot2::coord_flip()
}

#' @export
as.data.frame.wactor <- function(x, ...) {
  tibble::as_tibble(x$.vocab)
}

#' @export
levels.wactor <- function(x) x$.vocab


#' @export
print.wactor <- function(x, ...) {
  len <- length(x$.text)
  x <- as.data.frame(x)
  attr(x, "len") <- len
  print(x, ...)
}
