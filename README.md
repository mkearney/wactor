
<!-- README.md is generated from README.Rmd. Please edit that file -->

# wactor <img src='man/figures/logo.png' align="right" height="200" />

<!-- badges: start -->

[![Travis build
status](https://travis-ci.org/mkearney/wactor.svg?branch=master)](https://travis-ci.org/mkearney/wactor)
[![AppVeyor build
status](https://ci.appveyor.com/api/projects/status/github/mkearney/wactor?branch=master&svg=true)](https://ci.appveyor.com/project/mkearney/wactor)
[![CRAN
status](https://www.r-pkg.org/badges/version/wactor)](https://CRAN.R-project.org/package=wactor)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
[![Codecov test
coverage](https://codecov.io/gh/mkearney/wactor/branch/master/graph/badge.svg)](https://codecov.io/gh/mkearney/wactor?branch=master)
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
x <- c(
  "This test is a test",
  "This one will be a test",
  "This this was a test",
  "And this is the fourth test",
  "Fifth: the test!",
  "And the sixth test",
  "This is the seventh test",
  "This test is going to be a test",
  "This one will have been a test",
  "This this has been a test"
)

## for demonstration purposes, store as a data frame as well
data <- tibble::tibble(
  text = x,
  value = rnorm(length(x)),
  z = c(rep(TRUE, 7), rep(FALSE, 3))
)
```

### `split_test_train()`

A convenience function for splitting an input object into test and train
data frames. This is often useful for splitting a single data frame:

``` r
## split into test/train data sets
split_test_train(data)
#> $train
#> # A tibble: 8 x 3
#>   text                              value z    
#>   <chr>                             <dbl> <lgl>
#> 1 This test is a test             -0.0691 TRUE 
#> 2 This this was a test             1.21   TRUE 
#> 3 Fifth: the test!                -1.59   TRUE 
#> 4 And the sixth test               0.614  TRUE 
#> 5 This is the seventh test         0.282  TRUE 
#> 6 This test is going to be a test -0.446  FALSE
#> 7 This one will have been a test   0.146  FALSE
#> 8 This this has been a test       -0.0697 FALSE
#> 
#> $test
#> # A tibble: 2 x 3
#>   text                         value z    
#>   <chr>                        <dbl> <lgl>
#> 1 This one will be a test     -1.59  TRUE 
#> 2 And this is the fourth test -0.760 TRUE
```

By default, `split_test_train()` returns 80% of the input data in the
`train` data set and 20% of the input data in the `test` data set. This
proportion of data used in the returned training data can be adjusted
via the `.p` argument:

``` r
## split into test/train data sets–with 70% of data in training set
split_test_train(data, .p = 0.70)
#> $train
#> # A tibble: 7 x 3
#>   text                              value z    
#>   <chr>                             <dbl> <lgl>
#> 1 This one will be a test         -1.59   TRUE 
#> 2 This this was a test             1.21   TRUE 
#> 3 Fifth: the test!                -1.59   TRUE 
#> 4 This is the seventh test         0.282  TRUE 
#> 5 This test is going to be a test -0.446  FALSE
#> 6 This one will have been a test   0.146  FALSE
#> 7 This this has been a test       -0.0697 FALSE
#> 
#> $test
#> # A tibble: 3 x 3
#>   text                          value z    
#>   <chr>                         <dbl> <lgl>
#> 1 This test is a test         -0.0691 TRUE 
#> 2 And this is the fourth test -0.760  TRUE 
#> 3 And the sixth test           0.614  TRUE
```

When predicting categorical variables, it’s often desireable to ensure
the training data set has an even number of observations for each level
in the response variable. This can be achieved by indicating the
\[column\] name of the categorical response variable using tidy
evaluation. This will prioritize evenly balanced observations over the
specified proportion in training data:

``` r
## ensure evenly balanced groups in `train` data set
split_test_train(data, .p = 0.70, z)
#> $train
#> # A tibble: 6 x 3
#>   text                              value z    
#>   <chr>                             <dbl> <lgl>
#> 1 And this is the fourth test     -0.760  TRUE 
#> 2 Fifth: the test!                -1.59   TRUE 
#> 3 This is the seventh test         0.282  TRUE 
#> 4 This test is going to be a test -0.446  FALSE
#> 5 This one will have been a test   0.146  FALSE
#> 6 This this has been a test       -0.0697 FALSE
#> 
#> $test
#> # A tibble: 4 x 3
#>   text                      value z    
#>   <chr>                     <dbl> <lgl>
#> 1 This test is a test     -0.0691 TRUE 
#> 2 This one will be a test -1.59   TRUE 
#> 3 This this was a test     1.21   TRUE 
#> 4 And the sixth test       0.614  TRUE
```

The `split_test_train()` doesn’t only work on data frames. It’s also
possible to split atomic vectors (i.e., character, numeric, logical):

``` r
## OR split character vector into test/train data sets
(d <- split_test_train(x))
#> $train
#> # A tibble: 8 x 1
#>   x                             
#>   <chr>                         
#> 1 This test is a test           
#> 2 This one will be a test       
#> 3 This this was a test          
#> 4 And this is the fourth test   
#> 5 Fifth: the test!              
#> 6 This is the seventh test      
#> 7 This one will have been a test
#> 8 This this has been a test     
#> 
#> $test
#> # A tibble: 2 x 1
#>   x                              
#>   <chr>                          
#> 1 And the sixth test             
#> 2 This test is going to be a test
```

### `wactor()`

Use `wactor()` to convert a character vector into a `wactor` object. The
code below uses the previously split \[into test/train\] text data `d`
described above.

``` r
## create wactor
w <- wactor(d$train$x)
```

### `dtm()`

Get the document term frequency matrix

``` r
## term frequency–inverse document frequency
dtm(w)
#> 8 x 16 sparse Matrix of class "dgCMatrix"
#>    [[ suppressing 16 column names 'test', 'this', 'a' ... ]]
#>                                  
#> 1 2 1 1 1 . . . . . . . . . . . .
#> 2 1 1 1 . . . 1 1 . . . . . 1 . .
#> 3 1 2 1 . . . . . . . . . . . 1 .
#> 4 1 1 . 1 1 . . . . . 1 1 . . . .
#> 5 1 . . . 1 . . . . . . . 1 . . .
#> 6 1 1 . 1 1 . . . . . . . . . . 1
#> 7 1 1 1 . . 1 1 1 . 1 . . . . . .
#> 8 1 2 1 . . 1 . . 1 . . . . . . .

## same thing as dtm
predict(w)
#> 8 x 16 sparse Matrix of class "dgCMatrix"
#>    [[ suppressing 16 column names 'test', 'this', 'a' ... ]]
#>                                  
#> 1 2 1 1 1 . . . . . . . . . . . .
#> 2 1 1 1 . . . 1 1 . . . . . 1 . .
#> 3 1 2 1 . . . . . . . . . . . 1 .
#> 4 1 1 . 1 1 . . . . . 1 1 . . . .
#> 5 1 . . . 1 . . . . . . . 1 . . .
#> 6 1 1 . 1 1 . . . . . . . . . . 1
#> 7 1 1 1 . . 1 1 1 . 1 . . . . . .
#> 8 1 2 1 . . 1 . . 1 . . . . . . .
```

### `tfidf()`

or term frequency–inverse document frequency matrix

``` r
## apply to other data
tfidf(w)
#> 8 x 16 Matrix of class "dgeMatrix"
#>         test this          a         is        the       been        one       will        has
#> 1 -1.9144652  NaN  0.9772545  1.3140178 -0.6749656 -0.5379438 -0.5379438 -0.5379438 -0.3535534
#> 2  0.5954691  NaN  0.6172134 -0.7205904 -0.6749656 -0.5379438  1.7793527  1.7793527 -0.3535534
#> 3  0.2369071  NaN  0.9772545 -0.7205904 -0.6749656 -0.5379438 -0.5379438 -0.5379438 -0.3535534
#> 4  0.5954691  NaN -1.1829923  0.9749164  0.6106831 -0.5379438 -0.5379438 -0.5379438 -0.3535534
#> 5 -1.1973411  NaN -1.1829923 -0.7205904  1.8963318 -0.5379438 -0.5379438 -0.5379438 -0.3535534
#> 6  0.2369071  NaN -1.1829923  1.3140178  0.8678129 -0.5379438 -0.5379438 -0.5379438 -0.3535534
#> 7  0.8515849  NaN  0.3600411 -0.7205904 -0.6749656  1.4483103  1.4483103  1.4483103 -0.3535534
#> 8  0.5954691  NaN  0.6172134 -0.7205904 -0.6749656  1.7793527 -0.5379438 -0.5379438  2.4748737
#>         have     fourth        and      fifth         be        was    seventh
#> 1 -0.3535534 -0.3535534 -0.3535534 -0.3535534 -0.3535534 -0.3535534 -0.3535534
#> 2 -0.3535534 -0.3535534 -0.3535534 -0.3535534  2.4748737 -0.3535534 -0.3535534
#> 3 -0.3535534 -0.3535534 -0.3535534 -0.3535534 -0.3535534  2.4748737 -0.3535534
#> 4 -0.3535534  2.4748737  2.4748737 -0.3535534 -0.3535534 -0.3535534 -0.3535534
#> 5 -0.3535534 -0.3535534 -0.3535534  2.4748737 -0.3535534 -0.3535534 -0.3535534
#> 6 -0.3535534 -0.3535534 -0.3535534 -0.3535534 -0.3535534 -0.3535534  2.4748737
#> 7  2.4748737 -0.3535534 -0.3535534 -0.3535534 -0.3535534 -0.3535534 -0.3535534
#> 8 -0.3535534 -0.3535534 -0.3535534 -0.3535534 -0.3535534 -0.3535534 -0.3535534
```

Or apply the wactor on **new data**

``` r
## document term frequecy of new data
dtm(w, d$test$x)
#> 2 x 16 sparse Matrix of class "dgCMatrix"
#>    [[ suppressing 16 column names 'test', 'this', 'a' ... ]]
#>                                  
#> 1 1 . . . 1 . . . . . . 1 . . . .
#> 2 2 1 1 1 . . . . . . . . . 1 . .

## same thing as dtm
predict(w, d$test$x)
#> 2 x 16 sparse Matrix of class "dgCMatrix"
#>    [[ suppressing 16 column names 'test', 'this', 'a' ... ]]
#>                                  
#> 1 1 . . . 1 . . . . . . 1 . . . .
#> 2 2 1 1 1 . . . . . . . . . 1 . .

## term frequency–inverse document frequency of new data
tfidf(w, d$test$x)
#> 2 x 16 Matrix of class "dgeMatrix"
#>        test this          a         is        the       been        one       will        has
#> 1 -1.197341  NaN -1.1829923 -0.7205904  1.8963318 -0.5379438 -0.5379438 -0.5379438 -0.3535534
#> 2 -1.197341  NaN  0.6172134  0.9749164 -0.6749656 -0.5379438 -0.5379438 -0.5379438 -0.3535534
#>         have     fourth        and      fifth         be        was    seventh
#> 1 -0.3535534 -0.3535534  5.3033009 -0.3535534 -0.3535534 -0.3535534 -0.3535534
#> 2 -0.3535534 -0.3535534 -0.3535534 -0.3535534  2.4748737 -0.3535534 -0.3535534
```
