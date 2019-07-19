#' @export
Wactor <- R6::R6Class("wactor", list(
  .text = NULL,
  .vectorizer = NULL,
  .vocab = NULL,
  .tokenizer = NULL,
  dtm = NULL,
  tfidf = NULL,
  initialize  = function(text = character(), ...) {
    self$.text       <- text
    self$.vectorizer <- config_vectorizer(text, ...)
    self$.vocab      <- self$.vectorizer$vocab
    self$.tokenizer  <- self$.vectorizer$tokenizer
    self$dtm         <- self$.vectorizer$dtm
    self$tfidf       <- self$.vectorizer$tfidf
  },
  print = function(...) {
    len <- length(self$.vocab$term)
    x <- as.data.frame(self)
    attr(x, "len") <- len
    print(x, ...)
  })
)
