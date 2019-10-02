
<!-- README.md is generated from README.Rmd. Please edit that file -->

# wactor

<!-- badges: start -->

<!-- badges: end -->

A user-friendly factor-like interface for converting strings of text
into numeric vectors and rectangular data
structures.

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

Use `wactor()` to convert a character vector into numeric
vectors/matrix:

``` r
## create wactor
w <- wactor(s1)
```

Get the document term frequency matrix

``` r
## term frequency–inverse document frequency
dtm(w)
#> 3 x 5 sparse Matrix of class "dgCMatrix"
#>   one is be was will
#> 1   .  1  .   .    .
#> 2   1  .  1   .    1
#> 3   .  .  .   1    .

## same thing as dtm
predict(w)
#> 3 x 5 sparse Matrix of class "dgCMatrix"
#>   one is be was will
#> 1   .  1  .   .    .
#> 2   1  .  1   .    1
#> 3   .  .  .   1    .
```

or term frequency–inverse document frequency matrix

``` r
## apply to other data
tfidf(w)
#> 3 x 5 Matrix of class "dgeMatrix"
#>          one         is         be        was       will
#> 1 -0.5773503  1.1547005 -0.5773503 -0.5773503 -0.5773503
#> 2  1.1547005 -0.5773503  1.1547005 -0.5773503  1.1547005
#> 3 -0.5773503 -0.5773503 -0.5773503  1.1547005 -0.5773503
```

Or apply the wactor on **new data**

``` r
## document term frequecy of new data
dtm(w, s2)
#> 3 x 5 sparse Matrix of class "dgCMatrix"
#>   one is be was will
#> 1   .  1  1   .    .
#> 2   1  .  .   .    1
#> 3   .  .  .   .    .

## same thing as dtm
predict(w, s2)
#> 3 x 5 sparse Matrix of class "dgCMatrix"
#>   one is be was will
#> 1   .  1  1   .    .
#> 2   1  .  .   .    1
#> 3   .  .  .   .    .

## term frequency–inverse document frequency of new data
tfidf(w, s2)
#> 3 x 5 Matrix of class "dgeMatrix"
#>          one         is         be        was       will
#> 1 -0.5773503  0.2886751  2.0207259 -0.5773503 -0.5773503
#> 2  2.0207259 -0.5773503 -0.5773503 -0.5773503  2.0207259
#> 3 -0.5773503 -0.5773503 -0.5773503 -0.5773503 -0.5773503
```
