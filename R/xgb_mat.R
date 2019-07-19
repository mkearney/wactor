
xgb_mat <- function(x, ..., y = NULL, split = NULL) {
  UseMethod("xgb_mat")
}
xgb_mat.data.frame <- function(x, ..., y = NULL, split = NULL) {
  x <- as.matrix.data.frame(x, rownames.force = FALSE)
  xgb_mat(x, ..., y = y, split = split)
}

xgb_mat.matrix <- function(x, ..., y = NULL, split = NULL) {
  x <- cbind(x, ...)
  if (is.null(split)) {
    if (is.null(y)) {
      #return(xgboost::xgb.DMatrix(x))
      return(x)
    }
    #return(xgboost::xgb.DMatrix(x, label = y))
    return(cbind(x, label = y))
  }
  train_rows <- sample(seq_len(nrow(x)), nrow(x) * split)
  if (is.null(y)) {
    return(list(
      #train = xgboost::xgb.DMatrix(x[train_rows, ]),
      train = x[train_rows, ],
      #test = xgboost::xgb.DMatrix(x[-train_rows, ])
      test = x[-train_rows, ],
    ))
  }
  list(
    train = xgboost::xgb.DMatrix(x[train_rows, , drop = FALSE],
      label = y[train_rows]),
    test = xgboost::xgb.DMatrix(x[-train_rows, , drop = FALSE],
      label = y[-train_rows])
  )
}

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
