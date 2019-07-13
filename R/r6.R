Vactorizer <- R6::R6Class("vactorizer",
  private = list(
    .text = NA_character_,
    .vectorizer = NULL,
    .tokenizer = NULL,
    .vocab = NULL,
    .dtm = NULL,
    .tfidf = NULL
  ),
  active = list(
    vectorizer = function(value) {
      if (missing(value)) {
        private$.vectorizer
      } else {
        stop("`$vectorizer` is read only", call. = FALSE)
      }
    },
    tokenizer = function(value) {
      if (missing(value)) {
        private$.tokenizer
      } else {
        stop("`$tokenizer` is read only", call. = FALSE)
      }
    },
    vocab = function(value) {
      if (missing(value)) {
        private$.vocab
      } else {
        stop("`$vocab` is read only", call. = FALSE)
      }
    },
    dtm = function(value) {
      if (missing(value)) {
        private$.dtm
      } else {
        stop("`$dtm` is read only", call. = FALSE)
      }
    },
    tfidf = function(value) {
      if (missing(value)) {
        private$.tfidf
      } else {
        stop("`$tfidf` is read only", call. = FALSE)
      }
    },
    text = function(value) {
      if (missing(value)) {
        private$.text
      } else {
        stopifnot(is.character(value))
        private$.text <- value
        self
      }
    }
  ),
  public = list(
    initialize = function(text, ...) {
      private$.text <- text
      private$.vectorizer <- config_vectorizer(text, ...)
      private$.vocab <- private$.vectorizer$vocab
      private$.tokenizer <- private$.vectorizer$tokenizer
      private$.dtm <- private$.vectorizer$dtm
      private$.tfidf <- private$.vectorizer$tfidf
    }
  )
)
