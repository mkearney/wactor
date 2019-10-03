
as_fun <- function(x) {
  if (is.function(x)) {
    return(x)
  }

  ## convert string to function
  if (is.character(x)) {
    x <- get(x, envir = caller_env())
  } else {
    x <- eval(x)
  }
  ## check and return function call
  stopifnot(is.function(x))
  x
}

validate_tokenizer_ <- function(x) {

  ## if function then return
  if (tryCatch(is.function(x),
    error = function(e) FALSE)) {
    return(prepend_class(x, "tokenizer"))
  }

  ## if null, return default tokenizer otherwise validate function
  if (is.null(x)) {
    x <- function(x) tokenizers::tokenize_words(x, lowercase = TRUE)
  } else {
    x <- as_fun(x)
  }

  ## return as tokenizer function
  prepend_class(x, "tokenizer")
}

##
validate_tokenizer <- function(tokenizer = NULL) {

  ## validate and fix commmon tokenizer spec problem
  tokenizer <- validate_tokenizer_(tokenizer)

  ## return
  tokenizer
}

#' A wactor object
#'
#' A factor-like class for word vectors
#'
#' @export
Wactr <- R6::R6Class("wactor", list(
  .text = NULL,
  .vectorizer = NULL,
  .vocab = NULL,
  .tokenizer = NULL,
  .tfidf = NULL,
  .tfidf_m = NULL,
  .tfidf_sd = NULL,
  dtm = NULL,
  tfidf = NULL,
  initialize  = function(text = character(),
                         tokenizer = NULL,
                         max_words = 1000,
                         doc_prop_max = 1.000,
                         doc_prop_min = 0.000,
                         ...) {
    # if (!is.null(train_rows <- get_train_rows(text))) {
    #   text <- text[train_rows]
    # }
    self$.text <- text

    ## create/config tokenizer
    self$.tokenizer <- validate_tokenizer(substitute(tokenizer))

    ## tokenize training strings
    i <- text2vec::itoken(
      iterable           = self$.text,
      progressbar        = FALSE,
      ids                = seq_along(self$.text),
      tokenizer          = self$.tokenizer)

    ## create and prune vocab
    self$.vocab <- text2vec::prune_vocabulary(
      vocabulary         = text2vec::create_vocabulary(i),
      doc_proportion_max = doc_prop_max,
      doc_proportion_min = doc_prop_min,
      vocab_term_max     = max_words)

    ## vectorizer
    self$.vectorizer <- text2vec::vocab_vectorizer(self$.vocab)

    ## document-term matrix
    self$dtm <- function(x) {
      x <- text2vec::itoken(
        iterable           = x,
        progressbar        = FALSE,
        ids                = seq_along(x),
        tokenizer          = self$.tokenizer)
      suppressWarnings(text2vec::create_dtm(x, self$.vectorizer))
    }

    ## create tfidf method
    self$.tfidf <- text2vec::TfIdf$new()

    ## fit on data
    msd <- self$.tfidf$fit_transform(self$dtm(self$.text))
    self$.tfidf_m <- apply(msd, 2, the_mean)
    self$.tfidf_sd <- apply(msd, 2, std_dev)

    ## export function for creating tfidfs
    self$tfidf <- function(x, normalize = TRUE) {
      tf <- self$.tfidf$transform(self$dtm(x))
      if (normalize) {
        tf <- scale_with_params(tf, self$.tfidf_m, self$.tfidf_sd)
      }
      tf
    }

    ## return self
    self
  }
  )
)
