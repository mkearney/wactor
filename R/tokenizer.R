
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
    return(prepend_class(eval(expr), "tokenizer"))
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
