
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
#> 1 This one will be a test         -1.00   TRUE 
#> 2 This this was a test             0.439  TRUE 
#> 3 And this is the fourth test     -0.0876 TRUE 
#> 4 Fifth: the test!                 2.49   TRUE 
#> 5 This is the seventh test        -0.136  TRUE 
#> 6 This test is going to be a test  0.304  FALSE
#> 7 This one will have been a test   0.457  FALSE
#> 8 This this has been a test       -1.51   FALSE
#> 
#> $test
#> # A tibble: 2 x 3
#>   text                value z    
#>   <chr>               <dbl> <lgl>
#> 1 This test is a test 0.208 TRUE 
#> 2 And the sixth test  0.296 TRUE
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
#> 1 This test is a test             0.208  TRUE 
#> 2 This this was a test            0.439  TRUE 
#> 3 And this is the fourth test    -0.0876 TRUE 
#> 4 And the sixth test              0.296  TRUE 
#> 5 This is the seventh test       -0.136  TRUE 
#> 6 This one will have been a test  0.457  FALSE
#> 7 This this has been a test      -1.51   FALSE
#> 
#> $test
#> # A tibble: 3 x 3
#>   text                             value z    
#>   <chr>                            <dbl> <lgl>
#> 1 This one will be a test         -1.00  TRUE 
#> 2 Fifth: the test!                 2.49  TRUE 
#> 3 This test is going to be a test  0.304 FALSE
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
#> 1 This test is a test              0.208 TRUE 
#> 2 This this was a test             0.439 TRUE 
#> 3 Fifth: the test!                 2.49  TRUE 
#> 4 This test is going to be a test  0.304 FALSE
#> 5 This one will have been a test   0.457 FALSE
#> 6 This this has been a test       -1.51  FALSE
#> 
#> $test
#> # A tibble: 4 x 3
#>   text                          value z    
#>   <chr>                         <dbl> <lgl>
#> 1 This one will be a test     -1.00   TRUE 
#> 2 And this is the fourth test -0.0876 TRUE 
#> 3 And the sixth test           0.296  TRUE 
#> 4 This is the seventh test    -0.136  TRUE
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
#> 5 And the sixth test             
#> 6 This is the seventh test       
#> 7 This test is going to be a test
#> 8 This this has been a test      
#> 
#> $test
#> # A tibble: 2 x 1
#>   x                             
#>   <chr>                         
#> 1 Fifth: the test!              
#> 2 This one will have been a test
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
#> 8 x 17 sparse Matrix of class "dgCMatrix"
#>    [[ suppressing 17 column names 'test', 'this', 'a' ... ]]
#>                                    
#> 1 2 1 1 1 . . . . . . . . . . . . .
#> 2 1 1 1 . . . 1 . . . . . . . 1 . 1
#> 3 1 2 1 . . . . . 1 . . . . . . . .
#> 4 1 1 . 1 1 1 . . . . . . . 1 . . .
#> 5 1 . . . 1 1 . . . . . . 1 . . . .
#> 6 1 1 . 1 1 . . . . . . . . . . 1 .
#> 7 2 1 1 1 . . 1 . . . 1 1 . . . . .
#> 8 1 2 1 . . . . 1 . 1 . . . . . . .

## same thing as dtm
predict(w)
#> 8 x 17 sparse Matrix of class "dgCMatrix"
#>    [[ suppressing 17 column names 'test', 'this', 'a' ... ]]
#>                                    
#> 1 2 1 1 1 . . . . . . . . . . . . .
#> 2 1 1 1 . . . 1 . . . . . . . 1 . 1
#> 3 1 2 1 . . . . . 1 . . . . . . . .
#> 4 1 1 . 1 1 1 . . . . . . . 1 . . .
#> 5 1 . . . 1 1 . . . . . . 1 . . . .
#> 6 1 1 . 1 1 . . . . . . . . . . 1 .
#> 7 2 1 1 1 . . 1 . . . 1 1 . . . . .
#> 8 1 2 1 . . . . 1 . 1 . . . . . . .
```

### `tfidf()`

or term frequency–inverse document frequency matrix

``` r
## create tf-idf matrix
tfidf(w)
#> 8 x 17 Matrix of class "dgeMatrix"
#>         test this          a         is        the        and         be       been        was
#> 1 -2.2242112    0  1.0090581  1.1911527 -0.7089959 -0.5262117 -0.5328606 -0.3535534 -0.3535534
#> 2  0.7414037    0  0.6462507 -0.9070245 -0.7089959 -0.5262117  1.9030735 -0.3535534 -0.3535534
#> 3  0.3177445    0  1.0090581 -0.9070245 -0.7089959 -0.5262117 -0.5328606 -0.3535534  2.4748737
#> 4  0.7414037    0 -1.1677863  0.8414565  0.8239682  1.1576657 -0.5328606 -0.3535534 -0.3535534
#> 5 -0.3177445    0 -1.1677863 -0.9070245  1.5904503  1.9996044 -0.5328606 -0.3535534 -0.3535534
#> 6  0.3177445    0 -1.1677863  1.1911527  1.1305610 -0.5262117 -0.5328606 -0.3535534 -0.3535534
#> 7 -0.3177445    0  0.1927414  0.4043362 -0.7089959 -0.5262117  1.2940900 -0.3535534 -0.3535534
#> 8  0.7414037    0  0.6462507 -0.9070245 -0.7089959 -0.5262117 -0.5328606  2.4748737 -0.3535534
#>          has         to      going      sixth     fourth        one    seventh       will
#> 1 -0.3535534 -0.3535534 -0.3535534 -0.3535534 -0.3535534 -0.3535534 -0.3535534 -0.3535534
#> 2 -0.3535534 -0.3535534 -0.3535534 -0.3535534 -0.3535534  2.4748737 -0.3535534  2.4748737
#> 3 -0.3535534 -0.3535534 -0.3535534 -0.3535534 -0.3535534 -0.3535534 -0.3535534 -0.3535534
#> 4 -0.3535534 -0.3535534 -0.3535534 -0.3535534  2.4748737 -0.3535534 -0.3535534 -0.3535534
#> 5 -0.3535534 -0.3535534 -0.3535534  2.4748737 -0.3535534 -0.3535534 -0.3535534 -0.3535534
#> 6 -0.3535534 -0.3535534 -0.3535534 -0.3535534 -0.3535534 -0.3535534  2.4748737 -0.3535534
#> 7 -0.3535534  2.4748737  2.4748737 -0.3535534 -0.3535534 -0.3535534 -0.3535534 -0.3535534
#> 8  2.4748737 -0.3535534 -0.3535534 -0.3535534 -0.3535534 -0.3535534 -0.3535534 -0.3535534
```

Or apply the wactor on **new data**

``` r
## document term frequecy of new data
dtm(w, d$test$x)
#> 2 x 17 sparse Matrix of class "dgCMatrix"
#>    [[ suppressing 17 column names 'test', 'this', 'a' ... ]]
#>                                    
#> 1 1 . . . 1 . . . . . . . . . . . .
#> 2 1 1 1 . . . . 1 . . . . . . 1 . 1

## same thing as dtm
predict(w, d$test$x)
#> 2 x 17 sparse Matrix of class "dgCMatrix"
#>    [[ suppressing 17 column names 'test', 'this', 'a' ... ]]
#>                                    
#> 1 1 . . . 1 . . . . . . . . . . . .
#> 2 1 1 1 . . . . 1 . . . . . . 1 . 1

## term frequency–inverse document frequency of new data
tfidf(w, d$test$x)
#> 2 x 17 Matrix of class "dgeMatrix"
#>         test this          a         is        the        and         be       been        was
#> 1 -3.4951890    0 -1.1677863 -0.9070245  3.8898965 -0.5262117 -0.5328606 -0.3535534 -0.3535534
#> 2  0.7414037    0  0.6462507 -0.9070245 -0.7089959 -0.5262117 -0.5328606  2.4748737 -0.3535534
#>          has         to      going      sixth     fourth        one    seventh       will
#> 1 -0.3535534 -0.3535534 -0.3535534 -0.3535534 -0.3535534 -0.3535534 -0.3535534 -0.3535534
#> 2 -0.3535534 -0.3535534 -0.3535534 -0.3535534 -0.3535534  2.4748737 -0.3535534  2.4748737
```

### `xgb_mat`

The wactor package also makes it easy to work with the
[{xgboost}](https://github.com/dmlc/xgboost) package:

``` r
## convert tfidf matrix into xgb.DMatrix
xgb_mat(tfidf(w, d$test$x))
#> xgb.DMatrix  dim: 2 x 17  info: NA  colnames: yes
```

The `xgb_mat()` function also allows users to specify a
response/label/outcome vector, e.g.:

``` r
## include a response variable
xgb_mat(tfidf(w, d$train$x), y = c(rep(0, 4), rep(1, 4)))
#> xgb.DMatrix  dim: 8 x 17  info: label  colnames: yes
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
#> [1]  train-error:0.333333    test-error:1.000000 
#> [2]  train-error:0.333333    test-error:1.000000 
#> [3]  train-error:0.333333    test-error:1.000000 
#> [4]  train-error:0.333333    test-error:1.000000
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
#> # of features: 17 
#> niter: 4
#> nfeatures : 17 
#> evaluation_log:
#>  iter train_error test_error
#>     1    0.333333          1
#>     2    0.333333          1
#>     3    0.333333          1
#>     4    0.333333          1
```
