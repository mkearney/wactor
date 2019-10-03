// [[Rcpp::plugins(cpp11)]]
#include <Rcpp.h>
using namespace Rcpp;

#include <vector>
#include <numeric>

// [[Rcpp::export]]
double cppvariance(NumericVector x, const bool narm = true) {

  // Omit missing values if called for
  if (narm) {
    x = na_omit(x);
  }
  size_t sz = x.size();
  if (sz == 1)
    return 0.0;

  // Calculate the mean
  double mean = std::accumulate(x.begin(), x.end(), 0.0) / sz;

  // Now calculate the variance
  auto variance_func = [&mean, &sz](double accumulator, const double& val) {
    return accumulator + ((val - mean) * (val - mean) / (sz - 1));
  };

  return std::accumulate(x.begin(), x.end(), 0.0, variance_func);
}
