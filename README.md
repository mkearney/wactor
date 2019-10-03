
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
#> 1 This test is a test             -1.75   TRUE 
#> 2 This this was a test            -0.438  TRUE 
#> 3 And this is the fourth test     -0.319  TRUE 
#> 4 Fifth: the test!                -1.26   TRUE 
#> 5 And the sixth test              -2.04   TRUE 
#> 6 This test is going to be a test -0.0463 FALSE
#> 7 This one will have been a test   1.26   FALSE
#> 8 This this has been a test       -0.350  FALSE
#> 
#> $test
#> # A tibble: 2 x 3
#>   text                     value z    
#>   <chr>                    <dbl> <lgl>
#> 1 This one will be a test   1.68 TRUE 
#> 2 This is the seventh test -1.39 TRUE
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
#> 1 This test is a test             -1.75   TRUE 
#> 2 And this is the fourth test     -0.319  TRUE 
#> 3 Fifth: the test!                -1.26   TRUE 
#> 4 And the sixth test              -2.04   TRUE 
#> 5 This test is going to be a test -0.0463 FALSE
#> 6 This one will have been a test   1.26   FALSE
#> 7 This this has been a test       -0.350  FALSE
#> 
#> $test
#> # A tibble: 3 x 3
#>   text                      value z    
#>   <chr>                     <dbl> <lgl>
#> 1 This one will be a test   1.68  TRUE 
#> 2 This this was a test     -0.438 TRUE 
#> 3 This is the seventh test -1.39  TRUE
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
#> 1 This this was a test            -0.438  TRUE 
#> 2 And the sixth test              -2.04   TRUE 
#> 3 This is the seventh test        -1.39   TRUE 
#> 4 This test is going to be a test -0.0463 FALSE
#> 5 This one will have been a test   1.26   FALSE
#> 6 This this has been a test       -0.350  FALSE
#> 
#> $test
#> # A tibble: 4 x 3
#>   text                         value z    
#>   <chr>                        <dbl> <lgl>
#> 1 This test is a test         -1.75  TRUE 
#> 2 This one will be a test      1.68  TRUE 
#> 3 And this is the fourth test -0.319 TRUE 
#> 4 Fifth: the test!            -1.26  TRUE
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
#> 6 This test is going to be a test
#> 7 This one will have been a test 
#> 8 This this has been a test      
#> 
#> $test
#> # A tibble: 2 x 1
#>   x                       
#>   <chr>                   
#> 1 This test is a test     
#> 2 This is the seventh test
```

### `wactor()`

Use `wactor()` to convert a character vector into a `wactor` object. The
code below uses the previously split \[into test/train\] text data `d`
described above.

``` r
## create wactor
w <- wactor(d$train$x)
```

Get the document term frequency matrix

``` r
## term frequency–inverse document frequency
dtm(w)
#> 8 x 18 sparse Matrix of class "dgCMatrix"
#>    [[ suppressing 18 column names 'test', 'this', 'a' ... ]]
#>                                      
#> 1 1 1 1 . . . 1 . 1 1 . . . . . . . .
#> 2 1 2 1 . . . . . . . . . 1 . . . . .
#> 3 1 1 . 1 . 1 . 1 . . . . . . . . . 1
#> 4 1 . . 1 . . . . . . . 1 . . . . . .
#> 5 1 . . 1 . 1 . . . . . . . . . . 1 .
#> 6 2 1 1 . . . . 1 1 . . . . . 1 1 . .
#> 7 1 1 1 . 1 . 1 . . 1 1 . . . . . . .
#> 8 1 2 1 . 1 . . . . . . . . 1 . . . .

## same thing as dtm
predict(w)
#> 8 x 18 sparse Matrix of class "dgCMatrix"
#>    [[ suppressing 18 column names 'test', 'this', 'a' ... ]]
#>                                      
#> 1 1 1 1 . . . 1 . 1 1 . . . . . . . .
#> 2 1 2 1 . . . . . . . . . 1 . . . . .
#> 3 1 1 . 1 . 1 . 1 . . . . . . . . . 1
#> 4 1 . . 1 . . . . . . . 1 . . . . . .
#> 5 1 . . 1 . 1 . . . . . . . . . . 1 .
#> 6 2 1 1 . . . . 1 1 . . . . . 1 1 . .
#> 7 1 1 1 . 1 . 1 . . 1 1 . . . . . . .
#> 8 1 2 1 . 1 . . . . . . . . 1 . . . .
```

or term frequency–inverse document frequency matrix

``` r
## apply to other data
tfidf(w)
#> 8 x 18 Matrix of class "dgeMatrix"
#>         test         this          a        the       been        and        one         is         be
#> 1  0.6698906 -0.001051939  0.7766318 -0.6851065 -0.5379438 -0.5262117  1.7793527 -0.5328606  1.9030735
#> 2  0.1488646  1.648389118  1.1658164 -0.6851065 -0.5379438 -0.5262117 -0.5379438 -0.5328606 -0.5328606
#> 3  0.6698906 -0.001051939 -1.1692912  0.5328606 -0.5379438  1.1576657 -0.5379438  1.9030735 -0.5328606
#> 4 -1.9352396 -1.179224123 -1.1692912  1.7508276 -0.5379438 -0.5262117 -0.5379438 -0.5328606 -0.5328606
#> 5 -0.6326745 -1.179224123 -1.1692912  1.1418441 -0.5379438  1.9996044 -0.5379438 -0.5328606 -0.5328606
#> 6 -0.6326745 -0.295594985  0.2901510 -0.6851065 -0.5379438 -0.5262117 -0.5379438  1.2940900  1.2940900
#> 7  1.0420521 -0.169362251  0.4986428 -0.6851065  1.4483103 -0.5262117  1.4483103 -0.5328606 -0.5328606
#> 8  0.6698906  1.177120244  0.7766318 -0.6851065  1.7793527 -0.5262117 -0.5379438 -0.5328606 -0.5328606
#>         will       have      fifth        was        has         to      going      sixth     fourth
#> 1  1.7793527 -0.3535534 -0.3535534 -0.3535534 -0.3535534 -0.3535534 -0.3535534 -0.3535534 -0.3535534
#> 2 -0.5379438 -0.3535534 -0.3535534  2.4748737 -0.3535534 -0.3535534 -0.3535534 -0.3535534 -0.3535534
#> 3 -0.5379438 -0.3535534 -0.3535534 -0.3535534 -0.3535534 -0.3535534 -0.3535534 -0.3535534  2.4748737
#> 4 -0.5379438 -0.3535534  2.4748737 -0.3535534 -0.3535534 -0.3535534 -0.3535534 -0.3535534 -0.3535534
#> 5 -0.5379438 -0.3535534 -0.3535534 -0.3535534 -0.3535534 -0.3535534 -0.3535534  2.4748737 -0.3535534
#> 6 -0.5379438 -0.3535534 -0.3535534 -0.3535534 -0.3535534  2.4748737  2.4748737 -0.3535534 -0.3535534
#> 7  1.4483103  2.4748737 -0.3535534 -0.3535534 -0.3535534 -0.3535534 -0.3535534 -0.3535534 -0.3535534
#> 8 -0.5379438 -0.3535534 -0.3535534 -0.3535534  2.4748737 -0.3535534 -0.3535534 -0.3535534 -0.3535534
```

Or apply the wactor on **new data**

``` r
## document term frequecy of new data
dtm(w, d$test$x)
#> 2 x 18 sparse Matrix of class "dgCMatrix"
#>    [[ suppressing 18 column names 'test', 'this', 'a' ... ]]
#>                                      
#> 1 2 1 1 . . . . 1 . . . . . . . . . .
#> 2 1 1 . 1 . . . 1 . . . . . . . . . .

## same thing as dtm
predict(w, d$test$x)
#> 2 x 18 sparse Matrix of class "dgCMatrix"
#>    [[ suppressing 18 column names 'test', 'this', 'a' ... ]]
#>                                      
#> 1 2 1 1 . . . . 1 . . . . . . . . . .
#> 2 1 1 . 1 . . . 1 . . . . . . . . . .

## term frequency–inverse document frequency of new data
tfidf(w, d$test$x)
#> 2 x 18 Matrix of class "dgeMatrix"
#>         test      this         a        the       been        and        one       is         be
#> 1 -2.9772917 0.2345825  1.165816 -0.6851065 -0.5379438 -0.5262117 -0.5379438 2.390260 -0.5328606
#> 2 -0.6326745 0.5880342 -1.169291  1.1418441 -0.5379438 -0.5262117 -0.5379438 3.121041 -0.5328606
#>         will       have      fifth        was        has         to      going      sixth     fourth
#> 1 -0.5379438 -0.3535534 -0.3535534 -0.3535534 -0.3535534 -0.3535534 -0.3535534 -0.3535534 -0.3535534
#> 2 -0.5379438 -0.3535534 -0.3535534 -0.3535534 -0.3535534 -0.3535534 -0.3535534 -0.3535534 -0.3535534
```
