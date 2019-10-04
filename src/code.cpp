#include <vector>
#include <numeric>

#include <Rcpp.h>
using namespace Rcpp;

// [[Rcpp::plugins(cpp17)]]

// [[Rcpp::export]]
long double cppvar(NumericVector x, const bool narm = true) {
  // deal with missingness
  if (narm) {
    x = na_omit(x);
  }

  // number of obs
  size_t sz = x.size();
  if (sz == 1)
    return 0.0;

  // calculate the mean
  long double mean = std::accumulate(x.begin(), x.end(), 0.0) / sz;

  // calculate the variance
  return std::accumulate((*&x).begin(), (*&x).end(), 0.0,
    // Lambda expression begins
    [&mean, &sz](long double accumulator, const long double& val) {
      return accumulator + ((val - mean) * (val - mean) / (sz - 1));
    } // Lambda expression ends
  );
}

// [[Rcpp::export]]
long double cppsd(NumericVector x, const bool narm = true) {
  // deal with missingness
  if (narm) {
    x = na_omit(x);
  }

  // number of obs
  size_t sz = x.size();
  if (sz == 1)
    return 0.0;

  // calculate the mean
  long double mean = std::accumulate(x.begin(), x.end(), 0.0) / sz;

  // calculate the variance
  return sqrt(std::accumulate(x.begin(), x.end(), 0.0,
    // Lambda expression begins
    [&mean, &sz](long double accumulator, const long double& val) {
      return accumulator + ((val - mean) * (val - mean) / (sz - 1));
    } // Lambda expression ends
  ));
}

// [[Rcpp::export]]
long double cppmean(NumericVector x, const bool narm = true) {
  // deal with missingness
  if (narm) {
    x = na_omit(x);
  }

  // number of obs
  size_t sz = x.size();
  if (sz == 1)
    return 0.0;

  // calculate the mean
  return std::accumulate(x.begin(), x.end(), 0.0) / sz;
}
