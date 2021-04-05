#include <fmt/core.h>
#include <zlib.h>
#include <vector>
#include "cpp_boilerplate/version.h"

using namespace std;

auto main() -> int {
  vector<int> v;

  fmt::print(
      "cpp_boilerplate version is {}\n"
      "fmt version is {}\n"
      "zlib version is {}\n",
      CPP_BOILERPLATE_VERSION, FMT_VERSION, ZLIB_VERSION);
  return 0;
}
