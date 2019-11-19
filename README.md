
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
#>   text                             value z    
#>   <chr>                            <dbl> <lgl>
#> 1 This test is a test              0.523 TRUE 
#> 2 This one will be a test          0.362 TRUE 
#> 3 This this was a test            -1.61  TRUE 
#> 4 And this is the fourth test     -0.923 TRUE 
#> 5 Fifth: the test!                -1.17  TRUE 
#> 6 This test is going to be a test -0.192 FALSE
#> 7 This one will have been a test   0.531 FALSE
#> 8 This this has been a test       -1.85  FALSE
#> 
#> $test
#> # A tibble: 2 x 3
#>   text                     value z    
#>   <chr>                    <dbl> <lgl>
#> 1 And the sixth test        1.25 TRUE 
#> 2 This is the seventh test  1.13 TRUE
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
#>   text                             value z    
#>   <chr>                            <dbl> <lgl>
#> 1 This test is a test              0.523 TRUE 
#> 2 This one will be a test          0.362 TRUE 
#> 3 This this was a test            -1.61  TRUE 
#> 4 And this is the fourth test     -0.923 TRUE 
#> 5 This test is going to be a test -0.192 FALSE
#> 6 This one will have been a test   0.531 FALSE
#> 7 This this has been a test       -1.85  FALSE
#> 
#> $test
#> # A tibble: 3 x 3
#>   text                     value z    
#>   <chr>                    <dbl> <lgl>
#> 1 Fifth: the test!         -1.17 TRUE 
#> 2 And the sixth test        1.25 TRUE 
#> 3 This is the seventh test  1.13 TRUE
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
#>   text                             value z    
#>   <chr>                            <dbl> <lgl>
#> 1 This one will be a test          0.362 TRUE 
#> 2 And this is the fourth test     -0.923 TRUE 
#> 3 Fifth: the test!                -1.17  TRUE 
#> 4 This test is going to be a test -0.192 FALSE
#> 5 This one will have been a test   0.531 FALSE
#> 6 This this has been a test       -1.85  FALSE
#> 
#> $test
#> # A tibble: 4 x 3
#>   text                      value z    
#>   <chr>                     <dbl> <lgl>
#> 1 This test is a test       0.523 TRUE 
#> 2 This this was a test     -1.61  TRUE 
#> 3 And the sixth test        1.25  TRUE 
#> 4 This is the seventh test  1.13  TRUE
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
#> 1 This one will be a test        
#> 2 This this was a test           
#> 3 And this is the fourth test    
#> 4 Fifth: the test!               
#> 5 And the sixth test             
#> 6 This is the seventh test       
#> 7 This test is going to be a test
#> 8 This one will have been a test 
#> 
#> $test
#> # A tibble: 2 x 1
#>   x                        
#>   <chr>                    
#> 1 This test is a test      
#> 2 This this has been a test
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
#> 8 x 18 sparse Matrix of class "dgCMatrix"
#>    [[ suppressing 18 column names 'test', 'this', 'a' ... ]]
#>                                      
#> 1 1 1 1 . . . 1 1 1 . . . . . . . . .
#> 2 1 2 1 . . . . . . . . . 1 . . . . .
#> 3 1 1 . 1 1 1 . . . . . . . . . . 1 .
#> 4 1 . . 1 . . . . . . . 1 . . . . . .
#> 5 1 . . 1 . 1 . . . . . . . . . 1 . .
#> 6 1 1 . 1 1 . . . . . . . . . . . . 1
#> 7 2 1 1 . 1 . . 1 . . . . . 1 1 . . .
#> 8 1 1 1 . . . 1 . 1 1 1 . . . . . . .

## same thing as dtm
predict(w)
#> 8 x 18 sparse Matrix of class "dgCMatrix"
#>    [[ suppressing 18 column names 'test', 'this', 'a' ... ]]
#>                                      
#> 1 1 1 1 . . . 1 1 1 . . . . . . . . .
#> 2 1 2 1 . . . . . . . . . 1 . . . . .
#> 3 1 1 . 1 1 1 . . . . . . . . . . 1 .
#> 4 1 . . 1 . . . . . . . 1 . . . . . .
#> 5 1 . . 1 . 1 . . . . . . . . . 1 . .
#> 6 1 1 . 1 1 . . . . . . . . . . . . 1
#> 7 2 1 1 . 1 . . 1 . . . . . 1 1 . . .
#> 8 1 1 1 . . . 1 . 1 1 1 . . . . . . .
```

### `tfidf()`

or term frequency–inverse document frequency matrix

``` r
## create tf-idf matrix
tfidf(w)
#>         test        this          a        the         is        and        one         be       will
#> 1  0.7604596  0.13103552  0.9993288 -0.8761975 -0.7050698 -0.5262117  1.7793527  1.9030735  1.7793527
#> 2  0.2213996  1.98205976  1.3806741 -0.8761975 -0.7050698 -0.5262117 -0.5379438 -0.5328606 -0.5379438
#> 3  0.7604596  0.13103552 -0.9073974  0.3535534  1.2069839  1.1576657 -0.5379438 -0.5328606 -0.5379438
#> 4 -1.9348401 -1.19112465 -0.9073974  1.5833043 -0.7050698 -0.5262117 -0.5379438 -0.5328606 -0.5379438
#> 5 -0.5871903 -1.19112465 -0.9073974  0.9684289 -0.7050698  1.9996044 -0.5379438 -0.5328606 -0.5379438
#> 6  0.2213996  0.39546755 -0.9073974  0.5995036  1.5893946 -0.5262117 -0.5379438 -0.5328606 -0.5379438
#> 7 -0.5871903 -0.19950453  0.5226473 -0.8761975  0.7289704 -0.5262117 -0.5379438  1.2940900 -0.5379438
#> 8  1.1455024 -0.05784451  0.7269394 -0.8761975 -0.7050698 -0.5262117  1.4483103 -0.5328606  1.4483103
#>         been       have      fifth        was         to      going      sixth     fourth    seventh
#> 1 -0.3535534 -0.3535534 -0.3535534 -0.3535534 -0.3535534 -0.3535534 -0.3535534 -0.3535534 -0.3535534
#> 2 -0.3535534 -0.3535534 -0.3535534  2.4748737 -0.3535534 -0.3535534 -0.3535534 -0.3535534 -0.3535534
#> 3 -0.3535534 -0.3535534 -0.3535534 -0.3535534 -0.3535534 -0.3535534 -0.3535534  2.4748737 -0.3535534
#> 4 -0.3535534 -0.3535534  2.4748737 -0.3535534 -0.3535534 -0.3535534 -0.3535534 -0.3535534 -0.3535534
#> 5 -0.3535534 -0.3535534 -0.3535534 -0.3535534 -0.3535534 -0.3535534  2.4748737 -0.3535534 -0.3535534
#> 6 -0.3535534 -0.3535534 -0.3535534 -0.3535534 -0.3535534 -0.3535534 -0.3535534 -0.3535534  2.4748737
#> 7 -0.3535534 -0.3535534 -0.3535534 -0.3535534  2.4748737  2.4748737 -0.3535534 -0.3535534 -0.3535534
#> 8  2.4748737  2.4748737 -0.3535534 -0.3535534 -0.3535534 -0.3535534 -0.3535534 -0.3535534 -0.3535534
```

Or apply the wactor on **new data**

``` r
## document term frequecy of new data
dtm(w, d$test$x)
#> 2 x 18 sparse Matrix of class "dgCMatrix"
#>    [[ suppressing 18 column names 'test', 'this', 'a' ... ]]
#>                                      
#> 1 2 1 1 . 1 . . . . . . . . . . . . .
#> 2 1 2 1 . . . . . . 1 . . . . . . . .

## same thing as dtm
predict(w, d$test$x)
#> 2 x 18 sparse Matrix of class "dgCMatrix"
#>    [[ suppressing 18 column names 'test', 'this', 'a' ... ]]
#>                                      
#> 1 2 1 1 . 1 . . . . . . . . . . . . .
#> 2 1 2 1 . . . . . . 1 . . . . . . . .

## term frequency–inverse document frequency of new data
tfidf(w, d$test$x)
#>         test      this        a        the         is        and        one         be       will
#> 1 -3.0129600 0.3954676 1.380674 -0.8761975  1.5893946 -0.5262117 -0.5379438 -0.5328606 -0.5379438
#> 2  0.2213996 1.9820598 1.380674 -0.8761975 -0.7050698 -0.5262117 -0.5379438 -0.5328606 -0.5379438
#>         been       have      fifth        was         to      going      sixth     fourth    seventh
#> 1 -0.3535534 -0.3535534 -0.3535534 -0.3535534 -0.3535534 -0.3535534 -0.3535534 -0.3535534 -0.3535534
#> 2  3.6062446 -0.3535534 -0.3535534 -0.3535534 -0.3535534 -0.3535534 -0.3535534 -0.3535534 -0.3535534
```

### `xgb_mat`

The wactor package also makes it easy to work with the
[{xgboost}](https://github.com/dmlc/xgboost) package:

``` r
## convert tfidf matrix into xgb.DMatrix
xgb_mat(tfidf(w, d$test$x))
#> xgb.DMatrix  dim: 2 x 18  info: NA  colnames: yes
```

The `xgb_mat()` function also allows users to specify a
response/label/outcome vector, e.g.:

``` r
## include a response variable
xgb_mat(tfidf(w, d$train$x), y = c(rep(0, 4), rep(1, 4)))
#> xgb.DMatrix  dim: 8 x 18  info: label  colnames: yes
```

To return split (into test and train) data, specify a value between 0-1
to set the proportion of observations that should appear in the training
data set:

``` r
## split into test/train
xgb_data <- xgb_mat(tfidf(w, d$train$x), y = c(rep(0, 4), rep(1, 4)), split = 0.8)
```

The object returned by `xgb_mat()` can then easily be passed to
{xgboost} functions for powerful and fast machine learning\!

``` r
## specify hyper params
params <- list(
  max_depth = 2,
  eta = 0.25,
  objective = "binary:logistic"
)

## init training
xgboost::xgb.train(
  params,
  xgb_data$train,
  nrounds = 4,
  watchlist = xgb_data)
#> [1]  train-error:0.500000    test-error:0.500000 
#> [2]  train-error:0.500000    test-error:0.500000 
#> [3]  train-error:0.500000    test-error:0.500000 
#> [4]  train-error:0.500000    test-error:0.500000
#> ##### xgb.Booster
#> raw: 1.1 Kb 
#> call:
#>   xgboost::xgb.train(params = params, data = xgb_data$train, nrounds = 4, 
#>     watchlist = xgb_data)
#> params (as set within xgb.train):
#>   max_depth = "2", eta = "0.25", objective = "binary:logistic", silent = "1"
#> xgb.attributes:
#>   niter
#> callbacks:
#>   cb.print.evaluation(period = print_every_n)
#>   cb.evaluation.log()
#> # of features: 18 
#> niter: 4
#> nfeatures : 18 
#> evaluation_log:
#>  iter train_error test_error
#>     1         0.5        0.5
#>     2         0.5        0.5
#>     3         0.5        0.5
#>     4         0.5        0.5
```
