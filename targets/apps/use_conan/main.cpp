#include <fmt/core.h>
#include <zlib.h>
#include <vector>

using namespace std;

int main() {
  std::vector<int> v;
  fmt::print(
      "fmt version is {}\n"
      "zlib version is {}\n",
      FMT_VERSION, ZLIB_VERSION);
  return 0;
}
