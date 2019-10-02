tbl_sum.wactor_df <- function(x) {
  c(`A wactor` = format_wactor_nums(x))
}

as.data.frame.wactor <- function(x, ...) {
  x <- tibble::as_tibble(x$.vocab)
  `class<-`(x, c("wactor_df", class(x)))
}

levels.wactor <- function(x) x$vocab

objname <- function(x) attr(x, ".objname")

print.wactor <- function(x, ...) {
  len <- length(x$.text)
  x <- as.data.frame(x)
  attr(x, "len") <- len
  print(x, ...)
}

format_wactor_num <- function(x) {
  prettyNum(x, big.mark = ",")
}

format_wactor_nums <- function(x) {
  paste0(
    format_wactor_num(nrow(x)), " (words) x ",
    format_wactor_num(attr(x, "len")), " (train docs)"
  )
}
