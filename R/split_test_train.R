
#' Split into test and train data sets
#'
#' Randomly partition input into a list of \code{train} and \code{test} data sets
#'
#' @param .data Input data. If atomic (numeric, integer, character, etc.), the
#'   input is first converted to a data frame with a column  name of "x."
#' @param .p Proportion of data that should be used for the \code{train} data set
#'   output. The default value is 0.80, meaning the \code{train} output will include
#'   roughly 80 pct. of the input cases while the \code{test} output will include roughly
#'   20 oct..
#' @param ... Optional. The response (outcome) variable. Uses tidy evaluation
#'   (quotes are not necessary). This is only relevant if the identified
#'   variable is categorical–i.e., character, factor, logical–in which case it
#'   is used to ensure a uniform distribution for the \code{train} output data set.
#'   If a value is supplied, uniformity in response level observations is
#'   prioritized over the \code{.p} (train proportion) value.
#' @return A list with \code{train} and \code{test} tibbles (data.frames)
#'
#' @examples
#'
#' ## example data frame
#' d <- data.frame(
#'   x = rnorm(100),
#'   y = rnorm(100),
#'   z = c(rep("a", 80), rep("b", 20))
#' )
#'
#' ## split using defaults
#' split_test_train(d)
#'
#' ## split 0.60/0.40
#' split_test_train(d, 0.60)
#'
#' ## split with equal response level obs
#' split_test_train(d, 0.80, label = z)
#'
#' ## apply to atomic data
#' split_test_train(letters)
#'
#' @export
split_test_train <- function(.data, .p = 0.80, ...) {
  UseMethod("split_test_train")
}

#' @export
split_test_train.data.frame <- function(.data, .p = 0.80, ...) {
  split_test_train(tibble::as_tibble(.data), .p, ...)
}

#' @export
split_test_train.tbl_df <- function(.data, .p = 0.80, ...) {
  dots <- capture_dots(...)
  if (length(dots) == 2) {
    stop("split_test_train can only accept one response variable", call. = FALSE)
  }
  n <- round(nrow(.data) * .p, 0)
  r <- seq_len(nrow(.data))
  if (length(dots) > 0 && !is.numeric(y <- eval(dots[[1]], envir = .data))) {
    ty <- table(y)
    ny <- length(ty)
    lo <- min(as.integer(ty))
    if ((n / ny) > lo) {
      n <- lo * ny
    }
    r <- split(r, y)
  }
  r <- sampleit(r, n)
  list(
    train = .data[r, ],
    test = .data[-r, ]
  )
}


#' @export
split_test_train.default <- function(.data, .p = 0.80, ...) {
  if (!is.recursive(.data)) {
    .data <- list(x = .data)
  }
  split_test_train(tibble::as_tibble(.data), .p, ...)
}
