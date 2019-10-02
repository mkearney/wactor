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
                         doc_prop_max = 0.950,
                         doc_prop_min = 0.001,
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
    self$.tfidf_m <- apply(msd, 2, mean)
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
  # print = function(...) {
  #   len <- length(self$.vocab$term)
  #   x <- as.data.frame(self)
  #   attr(x, "len") <- len
  #   print(x, ...)
  # }
  )
)
