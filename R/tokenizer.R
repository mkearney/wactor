
as_fun <- function(x) {
  if (is.function(x)) {
    return(x)
  }

  ## convert string to function
  if (is.character(x)) {
    x <- get(x, envir = rlang::caller_env())
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
