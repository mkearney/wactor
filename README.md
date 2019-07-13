
<!-- README.md is generated from README.Rmd. Please edit that file -->

# wactor

<!-- badges: start -->

<!-- badges: end -->

A user-friendly factor-like interface for converting strings of text
into numeric vectors and rectangular data structures.

## Installation

<!-- You can install the released version of wactor from [CRAN](https://CRAN.R-project.org) with:

``` r
install.packages("wactor")
```
-->

You can install the development version from
[GitHub](https://github.com/mkearney/wactor) with:

``` r
## install {remotes} if not already
if (!requireNamespace("remotes")) {
  install.packages("remotes")
}
## install wactor for github
remotes::install_github("mkearney/wactor")
```

## Example

Let’s say we’re working with some text (e.g., natural language) data:

``` r
## load wactor package
library(wactor)

## text data (sentences)
s1 <- c(
  "This is a test",
  "This will be a test",
  "This was a test"
)
s2 <- c(
  "This is going to be a test",
  "This will have been a test",
  "This has been a test"
)
```

Use `Wactorizer` (an R6 object) to convert the text strings into numeric
vector/matrices:

``` r
## create wactor
w <- Wactorizer$new(s1)
```

Get the document term frequency matrix

``` r
## term frequency inverse document frequency
w$dtm(s1)
#> 3 x 7 sparse Matrix of class "dgCMatrix"
#>   test this a was will be is
#> 1    1    1 1   .    .  .  1
#> 2    1    1 1   .    1  1  .
#> 3    1    1 1   1    .  .  .
```

or term frequency inverse document frequency matrix

``` r
## apply to other data
w$tfidf(s2)
#> 3 x 7 sparse Matrix of class "dgCMatrix"
#>         test      this          a        was       will         be
#> 1  1.1547005 -1.560478 -1.5604780  8.0829038 -0.5773503 17.8476578
#> 2 -0.5773503 -2.113487 -0.5773503 -0.5773503  1.1547005  8.0829038
#> 3 -3.4641016 -2.625533 -3.4641016 -0.5773503  8.0829038 -0.5773503
#>           is
#> 1  1.1547005
#> 2 -0.5773503
#> 3 -0.5773503
```

Or apply the watctor to new data

``` r
w$dtm(s2)
#> 3 x 7 sparse Matrix of class "dgCMatrix"
#>   test this a was will be is
#> 1    1    1 1   .    .  1  1
#> 2    1    1 1   .    1  .  .
#> 3    1    1 1   .    .  .  .
w$tfidf(s2)
#> 3 x 7 sparse Matrix of class "dgCMatrix"
#>         test      this          a        was       will         be
#> 1  1.1547005 -1.560478 -1.5604780  8.0829038 -0.5773503 17.8476578
#> 2 -0.5773503 -2.113487 -0.5773503 -0.5773503  1.1547005  8.0829038
#> 3 -3.4641016 -2.625533 -3.4641016 -0.5773503  8.0829038 -0.5773503
#>           is
#> 1  1.1547005
#> 2 -0.5773503
#> 3 -0.5773503
```
