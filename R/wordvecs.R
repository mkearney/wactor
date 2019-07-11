
prepend_class <- function(x, ...) {
  `class<-`(x, unique(c(..., class(x))))
}
append_class <- function(x, ...) {
  `class<-`(x, unique(c(class(x), ...)))
}

as_fun <- function(expr) {
  if (is.function(expr)) {
    return(expr)
  }
  ## convert string to expression
  if (is.character(expr)) {
    expr <- str2expression(expr)
  }
  ## convert expression to quosure
  if (inherits(expr, "call")) {
    expr <- rlang::quo(!!expr)
  }
  ## convert anything else to quosure
  if (!rlang::is_quosure(expr)) {
    expr <- rlang::as_quosure(expr, env = rlang::caller_env())
  }
  ## return if it's already a function call
  if (grepl("function\\s?\\(.*\\)",
    rlang::expr_text(rlang::quo_get_expr(expr)))) {
    return(rlang::as_function(expr))
  }

  ## otherwise determine first arg name and create a function for it
  pd <- getParseData(parse(text = rlang::quo_get_expr(expr)))
  pd <- pd[(grep("SYMBOL_FUNCTION|^SYMBOL$", pd$token)[1] + 1):nrow(pd), ]
  arg <- pd$text[grep("SYMBOL", pd$token)[1]]
  if (length(arg) == 0 || is.na(arg) || identical(arg, "NA")) {
    arg <- "x"
  }
  expr <- parse(text = paste0('function(', arg, ') ',
    deparse(rlang::quo_get_expr(expr))))

  ## return function call
  eval(expr)
}

validate_tokenizer_ <- function(expr) {

  ## if already quosure or function then return
  if (tryCatch(is.function(eval(expr)),
    error = function(e) FALSE)) {
    return(prepend_class(expr, "tokenizer"))
  }

  ## if null, return default tokenizer
  if (tryCatch(is.null(eval(expr)),
    error = function(e) FALSE)) {
    expr <- function(x) {
      tokenizers::tokenize_words(x, lowercase = TRUE)
    }
    return(prepend_class(expr, "tokenizer"))
  }

  ## convert expression into function
  expr <- as_fun(expr)

  ## return as tokenizer quosure
  return(prepend_class(expr, "tokenizer"))
}

##
validate_tokenizer <- function(tokenizer = NULL) {

  ## validate and fix commmon tokenizer spec problem
  tokenizer <- validate_tokenizer_(tokenizer)

  ## return
  tokenizer
}


config_vectorizer <- function(x, tokenizer = NULL,
                              max_words = 20000,
                              doc_prop_max = 1.00,
                              doc_prop_min = 0.001) {

  if (!is.null(train_rows <- get_train_rows(x))) {
    x <- x[train_rows]
  }

  ## initialize output environment
  e <- new.env(parent = emptyenv())
  ## ccreate/config tokenizer
  e$tokenizer <- validate_tokenizer(substitute(tokenizer))

  ## tokenize training strings
  i <- text2vec::itoken(
    iterable           = x,
    progressbar        = FALSE,
    ids                = seq_along(x),
    tokenizer          = e$tokenizer)

  ## create and prune vocab
  vocab <- text2vec::prune_vocabulary(
    vocabulary         = text2vec::create_vocabulary(i),
    doc_proportion_max = doc_prop_max,
    doc_proportion_min = doc_prop_min,
    vocab_term_max     = max_words)

  ## vectorizer
  e$vectorizer <- text2vec::vocab_vectorizer(vocab)

  ## remove constant
  e$vocab <- vocab

  ## document-term matrix
  e$dtm <- function(x) {
    x <- text2vec::itoken(
      iterable           = x,
      progressbar        = FALSE,
      ids                = seq_along(x),
      tokenizer          = e$tokenizer)
    text2vec::create_dtm(x, e$vectorizer)
  }

  ## create tfidf method
  e$.tfidf <- text2vec::TfIdf$new()

  ## fit on data
  msd <- e$.tfidf$fit_transform(e$dtm(x))
  e$.tfidf_m <- apply(msd, 2, mean)
  e$.tfidf_sd <- apply(msd, 2, sd)

  ## export function for creating tfidfs
  e$tfidf <- function(x, normalize = TRUE) {
    tf <- e$.tfidf$transform(e$dtm(x))
    if (normalize) {
      tf[, 1:ncol(tf)] <- (tf - e$.tfidf_m) / e$.tfidf_sd
    }
    tf
  }

  ## return environment
  structure(
    e,
    class = c("vactorizer", "environment")
  )
}

prettysum <- function(x) {
  prettyNum(sum(x, na.rm = TRUE), big.mark = ",")
}

print.vactorizer <- function(x, ...) {
  cat("# A vactorizer:",
    prettysum(x$vocab$doc_count), "(documents) x",
    prettysum(x$vocab$term_count), "(words)", fill = TRUE)
  cat(paste0("<environment: ", environmentName(x), ">"), fill = TRUE)
}

print.vactor <- function(x, ...) {
  v <- levels(x)
  print(as.character(x))
  cat("# A vactor:",
    prettysum(v$vocab$doc_count), "(documents) x",
    prettysum(v$vocab$term_count), "(words)", fill = TRUE)
}

get_train_rows <- function(x) attr(x, "train_rows")

add_train_rows <- function(x, p = 0.8) {
  attr(x, "train_rows") <- sample(seq_len(NROW(x)), NROW(x) * p)
  x
}


#x <- rt
#x <- x <- x[grep("^quoted|^retweet", names(x), invert = TRUE)]
vectorize <- function(x, ..., .args = NULL) {
  f <- dplyr::select(x, ...)
  x <- x[!names(x) %in% names(f)]
  num <- dapr::vap_lgl(x, is.numeric)
  chr <- x[!num]
  x <- model.matrix(~ ., x[num])
  if (is.null(.args)) {
    .args <- list()
  }
  vs <- dapr::ilap(f, ~ {
    .args$x <- f[[.i]]
    v <- do.call(config_vectorizer, .args)
    .x <- v$tfidf(f[[.i]])
    colnames(.x) <- paste0("v", .i, colnames(.x))
    attr(.x, "vectorizer") <- v
    .x
  })
  x <- Reduce(cbind, vs, x)

  #x <- xgb_mat(Reduce(cbind, vs, x))
  if (NROW(chr) > 0) {
    x <- data.table::as.data.table(as.matrix(x))
    chr <- data.table::as.data.table(chr)
    x <- cbind(chr, x)
  }
  x
}


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
    train = xgboost::xgb.DMatrix(x[train_rows, ],
      label = y[train_rows]),
    test = xgboost::xgb.DMatrix(x[-train_rows, ],
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
      train = xgboost::xgb.DMatrix(x[train_rows, ]),
      test = xgboost::xgb.DMatrix(x[-train_rows, ])
    ))
  }
  list(
    train = xgboost::xgb.DMatrix(x[train_rows, ],
      label = y[train_rows]),
    test = xgboost::xgb.DMatrix(x[-train_rows, ],
      label = y[-train_rows])
  )
}


levels.vactor <- function(x) attr(x, "levels")

vactor <- function(x, levels = NULL, ...) {
  if (is.null(levels)) {
    levels <- config_vectorizer(x, ...)
  }
  attr(x, "levels") <- levels
  prepend_class(x, "vactor")
}
