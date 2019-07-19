#include <Rcpp.h>
#include <iostream>
#include <string>
#include <sstream>
#include <algorithm>
#include <iterator>

using namespace Rcpp;

std::vector<std::string> tokenize_cpp(std::string s) {
  std::istringstream iss(s);
  std::vector<std::string> tokens;
  std::copy(std::istream_iterator<std::string>(iss),
    std::istream_iterator<std::string>(),
    std::back_inserter(tokens));
  return tokens;
}

//[[Rcpp::export]]
List tokenize_cpp_fun(std::vector<std::string> s) {
  //int const n = s.size();
  List o(s.size());
  for (int i = 0; i < s.size(); i++)
    o[i] = tokenize_cpp(s[i]);
  return o;
}
