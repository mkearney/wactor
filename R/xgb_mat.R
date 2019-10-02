#' xgb matrix
#'
#' Simple wrapper for creating a xgboost matrix
#'
#' @param x Input data
#' @param ... Other data to cbind
#' @param y Label vector
#' @param split Optional number between 0-1 indicating the desired split between
#'  train and test
#' @export
xgb_mat <- function(x, ..., y = NULL, split = NULL) {
  UseMethod("xgb_mat")
}

#' @export
xgb_mat.data.frame <- function(x, ..., y = NULL, split = NULL) {
  x <- as.matrix.data.frame(x, rownames.force = FALSE)
  xgb_mat(x, ..., y = y, split = split)
}

#' @export
xgb_mat.default <- function(x, ..., y = NULL, split = NULL) {
  x <- as.matrix(x)
  xgb_mat(x, ..., y = y, split = split)
}

#' @export
xgb_mat.matrix <- function(x, ..., y = NULL, split = NULL) {
  x <- cbind(x, ...)
  if (is.null(split)) {
    if (is.null(y)) {
      return(xgboost::xgb.DMatrix(x))
    }
    return(xgboost::xgb.DMatrix(x, label = y))
  }
  train_rows <- sample(seq_len(nrow(x)), nrow(x) * split)
  if (is.null(y)) {
    return(list(
      train = xgboost::xgb.DMatrix(x[train_rows, , drop = FALSE]),
      test = xgboost::xgb.DMatrix(x[-train_rows, , drop = FALSE])
    ))
  }
  list(
    train = xgboost::xgb.DMatrix(x[train_rows, , drop = FALSE],
      label = y[train_rows]),
    test = xgboost::xgb.DMatrix(x[-train_rows, , drop = FALSE],
      label = y[-train_rows])
  )
}

#' @export
xgb_mat.dgCMatrix <- function(x, ..., y = NULL, split = NULL) {
  x <- cbind(x, ...)
  if (is.null(split)) {
    if (is.null(y)) {
      return(xgboost::xgb.DMatrix(x))
    }
    return(xgboost::xgb.DMatrix(x, label = y))
  }
  train_rows <- sample(seq_len(nrow(x)), nrow(x) * split)
  if (is.null(y)) {
    return(list(
      train = xgboost::xgb.DMatrix(x[train_rows, , drop = FALSE]),
      test = xgboost::xgb.DMatrix(x[-train_rows, , drop = FALSE])
    ))
  }
  list(
    train = xgboost::xgb.DMatrix(x[train_rows, , drop = FALSE],
      label = y[train_rows]),
    test = xgboost::xgb.DMatrix(x[-train_rows, , drop = FALSE],
      label = y[-train_rows])
  )
}



#' @export
xgb_mat.dgCMatrix <- function(x, ..., y = NULL, split = NULL) {
  x <- cbind(x, ...)
  if (is.null(split)) {
    if (is.null(y)) {
      return(xgboost::xgb.DMatrix(x))
    }
    return(xgboost::xgb.DMatrix(x, label = y))
  }
  train_rows <- sample(seq_len(nrow(x)), nrow(x) * split)
  if (is.null(y)) {
    return(list(
      train = xgboost::xgb.DMatrix(x[train_rows, , drop = FALSE]),
      test = xgboost::xgb.DMatrix(x[-train_rows, , drop = FALSE])
    ))
  }
  list(
    train = xgboost::xgb.DMatrix(x[train_rows, , drop = FALSE],
      label = y[train_rows]),
    test = xgboost::xgb.DMatrix(x[-train_rows, , drop = FALSE],
      label = y[-train_rows])
  )
}
