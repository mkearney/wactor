
#' Configure vectorizer
#'
#' Create a vectorizer object
#'
#' @param x Data (character vector where each observation is a document of text)
#'   that will be tokenized and used to build a dictionary. For machine learning
#'   models, this should include only the training data.
#' @param tokenizer Function used to tokenize text.
#' @param max_words Maximum number of words/tokens to use.
#' @param doc_prop_max Maximum proportion of documents in which term appears
#' @param doc_prop_min Minimum proportion of documents in which term appears
#' @return A vectorizer
#' @export
config_vectorizer <- function(x, tokenizer = NULL,
                              max_words = 20000,
                              doc_prop_max = 1.00,
                              doc_prop_min = 0.001) {

  if (!is.null(train_rows <- get_train_rows(x))) {
    x <- x[train_rows]
  }

  ## initialize output environment
  e <- list()
  ## ccreate/config tokenizer
  e$tokenizer <- validate_tokenizer(substitute(tokenizer))

  ## tokenize training strings
  i <- text2vec::itoken(
    iterable           = x,
    progressbar        = FALSE,
    ids                = seq_along(x),
    tokenizer          = e$tokenizer)

  ## create and prune vocab
  e$vocab <- text2vec::prune_vocabulary(
    vocabulary         = text2vec::create_vocabulary(i),
    doc_proportion_max = doc_prop_max,
    doc_proportion_min = doc_prop_min,
    vocab_term_max     = max_words)

  ## vectorizer
  e$vectorizer <- text2vec::vocab_vectorizer(e$vocab)

  ## document-term matrix
  e$dtm <- function(x) {
    x <- text2vec::itoken(
      iterable           = x,
      progressbar        = FALSE,
      ids                = seq_along(x),
      tokenizer          = e$tokenizer)
    suppressWarnings(text2vec::create_dtm(x, e$vectorizer))
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
      tf <- scale_with_params(tf, e$.tfidf_m, e$.tfidf_sd)
    }
    tf
  }

  ## return environment
  structure(
    e,
    class = c("vactorizer", "list")
  )
}

scale_with_params <- function(x, m, sd) {
  ncol <- length(m)
  nrow <- nrow(x)
  (x - matrix(m,
    nrow = nrow,
    ncol = ncol,
    byrow = TRUE)) / matrix(sd,
      nrow = nrow,
      ncol = ncol,
      byrow = TRUE)
}



prettysum <- function(x) {
  prettyNum(sum(x, na.rm = TRUE), big.mark = ",")
}
prettylen <- function(x) {
  prettyNum(length(x), big.mark = ",")
}
print.vactorizer <- function(x, ...) {
  cat("# A vactorizer:",
    #prettysum(x$vocab$doc_count), "(documents) x",
    prettylen(x$vocab$term_count), "(words)", fill = TRUE)
  cat(paste0("<environment: ", environmentName(x), ">"), fill = TRUE)
}

get_train_rows <- function(x) attr(x, "train_rows")

add_train_rows <- function(x, p = 0.8) {
  attr(x, "train_rows") <- sample(seq_len(NROW(x)), NROW(x) * p)
  x
}

levels.vactor <- function(x) attr(x, "levels")

vactor <- function(x, levels = NULL, ...) {
  if (is.null(levels)) {
    levels <- config_vectorizer(x, ...)
  }
  attr(x, "levels") <- levels
  prepend_class(x, "vactor")
}
