
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

Here’s some basic text (e.g., natural language) data:

``` r
## load wactor package
library(wactor)

## text data (sentences)
s1 <- c(
  "This test is a test",
  "This one will be a test",
  "This this was a test"
)
s2 <- c(
  "This test is going to be a test",
  "This one will have been a test",
  "This this has been a test"
)
```

Use `Wactorizer` (an R6 object) to convert the text strings into numeric
vector/matrices:

``` r
## create wactor
w <- Wactor$new(s1)
```

Get the document term frequency matrix

``` r
## term frequency–inverse document frequency
w$dtm(s1)
#> 3 x 8 sparse Matrix of class "dgCMatrix"
#>   test this a was one will be is
#> 1    2    1 1   .   .    .  .  1
#> 2    1    1 1   .   1    1  1  .
#> 3    1    2 1   1   .    .  .  .
```

or term frequency–inverse document frequency matrix

``` r
## apply to other data
w$tfidf(s2)
#> 3 x 8 sparse Matrix of class "dgCMatrix"
#>         test      this           a        was        one       will         be         is
#> 1 -0.6163156 -1.601442 -1.80625987  2.0250371 -0.5773503 -0.5773503 22.0208971  1.1547005
#> 2  0.4402255 -2.052042 -1.80625987  9.8149546  1.5011107  4.2587036 -0.5773503 -0.5773503
#> 3 -3.1754265 -4.264079  0.04402255 -0.5773503 -0.5773503  2.0250371 -0.5773503 -0.5773503
```

Or apply the wactor object to new data

``` r
## document term frequecy
w$dtm(s2)
#> 3 x 8 sparse Matrix of class "dgCMatrix"
#>   test this a was one will be is
#> 1    2    1 1   .   .    .  1  1
#> 2    1    1 1   .   1    1  .  .
#> 3    1    2 1   .   .    .  .  .

## term frequency–inverse document frequency
w$tfidf(s2)
#> 3 x 8 sparse Matrix of class "dgCMatrix"
#>         test      this           a        was        one       will         be         is
#> 1 -0.6163156 -1.601442 -1.80625987  2.0250371 -0.5773503 -0.5773503 22.0208971  1.1547005
#> 2  0.4402255 -2.052042 -1.80625987  9.8149546  1.5011107  4.2587036 -0.5773503 -0.5773503
#> 3 -3.1754265 -4.264079  0.04402255 -0.5773503 -0.5773503  2.0250371 -0.5773503 -0.5773503
```
