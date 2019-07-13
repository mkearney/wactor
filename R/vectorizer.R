

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
      tf[, 1:ncol(tf)] <- tf - e$.tfidf_m
      tf[, 1:ncol(tf)] <- tf / e$.tfidf_sd
    }
    tf
  }

  ## return environment
  structure(
    e,
    class = c("vactorizer", "list")
  )
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
  if (NROW(chr) > 0) {
    x <- data.table::as.data.table(as.matrix(x))
    chr <- data.table::as.data.table(chr)
    x <- cbind(chr, x)
  }
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
