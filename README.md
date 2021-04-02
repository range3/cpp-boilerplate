# cpp-boilerplate

- VSCode - Remote Container
- CMake as modern as possible
- Conan package manager
- formatters
  - cmake-format
  - clang-format
- Linters
  - clang-tidy
  - include-what-you-use
- RPATH support for installed binaries and libraries
- Uninstall target: `cmake --build . --target uninstall`
- [Reasonable compiler warings](https://lefticus.gitbooks.io/cpp-best-practices/content/02-Use_the_Tools_Available.html)
- [Doctest](https://github.com/onqtam/doctest)

- TODO
  - sanitizers
  - GitHub Actions

# Usage
## Pre-requirements
### w/ VSCode and Containers (RECOMMENDED)
- WSL2 configuration and Docker Desktop for windows (for Windows user)
- VSCode with the Visual Studio Code Remote - Containers extension

These automatically install all required tools and other extensions in the container.

### w/o VSCode and Containers 
- Python
  - for installing devtools
- compilers
  - g++ or clang

See .devcontainer/Dockerfile for details.

## Build on Terminal (using CMake and Make)
```bash
$ cd /path/to/project-root
# Install dependencies
$ conan install . -if build-Release
$ conan install . -s build_type=Debug -if build-Debug
# release build
$ cd build-Release
$ cmake .. -DCMAKE_BUILD_TYPE=Release
$ cmake --build .
# debug build
$ cd ../build-Debug
$ cmake .. -DCMAKE_BUILD_TYPE=Debug
$ cmake --build .
```

## Build on VSCode (CMake tools extension: ms-vscode.cmake-tools)
```bash
$ cd /path/to/project-root
$ conan install . -if build-Release
$ conan install . -s build_type=Debug -if build-Debug
# Ready to build.
# The extension automatically executes cmake config and build
```

## Example: Build using Clang
```bash
$ cd /path/to/project-root
$ conan profile show clang
Configuration for profile clang:

[settings]
os=Linux
os_build=Linux
arch=x86_64
arch_build=x86_64
compiler=clang
compiler.version=7.0
compiler.libcxx=libstdc++11
build_type=Release
[options]
[build_requires]
[env]
CC=/usr/bin/clang
CXX=/usr/bin/clang++
$ conan install . \ # build dependencies using clang
  --profile clang \ # use "clang" profile
  --build missing \ # build dependencies from source only if prebuild package is missing
  -if build         # to the "build" build directory
$ cd build
$ CC=/usr/bin/clang CXX=/usr/bin/clang++ cmake ..
$ cmake --build .
```

## Test
```bash
$ cd build-Debug
$ cmake .. -DCPP_BOILERPLATE_BUILD_TEST=ON # default ON if the project is a root project otherwise OFF.
$ cmake --build . --target test
```

## Install / Uninstall example
```bash
$ cd /path/to/project-root/build-Release
$ cmake .. -DCMAKE_INSTALL_PREFIX=../install-Release
$ cmake --build . --target install
$ cmake --build . --target uninstall
```

## Format CMakeLists.txt and c++ source/headers
Using `cmake-format` and `clang-foramt` via CMake targets
```bash
$ cd build-Debug
$ cmake --build . --target format # show diff
$ cmake --build . --target check-format # for CI 
$ cmake --build . --target fix-format # inplace edit files
```

## Lint by clang-tidy
- First of all, configure `.clang-tidy` as you like.

### on VSCode
- The `llvm-vs-code-extensions.vscode-clangd` extension supports the clangd clang language server that invokes clang-tidy
  - It needs`project_root/compile_commands.json`
- `ms-vscode.cmake-tools` automatically copy the file from the build directory to the project root if cmake configuration finished successfully.

### on Terminal
- Build time analysis
  - `CXX=clang++ cmake .. -DCPP_BOILERPLATE_CLANG_TIDY=ON` then `cmake --build .`
- Use custom targets
  - `cmake --build . --target clang-tidy`
  - `cmake --build . --target fix-clang-tidy`
- Manual
  - Just exec `run-clang-tidy`. It relies on `compile_commands.json`.
  - `run-clang-tidy -fix` fix the files.

## Lint by include-what-you-use
### on Terminal
- Build time analysis
  - `CXX=clang++ cmake .. -DCPP_BOILERPLATE_IWYU=ON` then `cmake --build .`
- Use custom targets
  - `cmake --build . --target iwyu`
  - `cmake --build . --target fix-iwyu`
- Manual
  - Just exec `iwyu_tools -p build-Debug`. It relies on `compile_commands.json`.
  - `iwyu_tool -p build-Debug | fix_include` fix the files mentiond in the iwyu_tools output.

# Tips
## PUBLIC vs PRIVATE vs INTERFACE related to target_link_libraries()
https://stackoverflow.com/questions/26037954/cmake-target-link-libraries-interface-dependencies
```
If you are creating a shared library and your source cpp files #include the headers of another library (Say, QtNetwork for example), but your header files don't include QtNetwork headers, then QtNetwork is a PRIVATE dependency.

If your source files and your headers include the headers of another library, then it is a PUBLIC dependency.

If your header files but not your source files include the headers of another library, then it is an INTERFACE dependency.

Other build properties of PUBLIC and INTERFACE dependencies are propagated to consuming libraries. http://www.cmake.org/cmake/help/v3.0/manual/cmake-buildsystem.7.html#transitive-usage-requirements
```
