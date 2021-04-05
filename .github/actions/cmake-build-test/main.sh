#!/bin/bash
if [ x$(id -u) != x0 ]; then
  printf -v cmd_str '%q ' "$0" "$@"
  exec sudo su -c "$cmd_str" root
fi

set -ex

BUILD_TYPE=${1:-Release}
PROFILE=${2:-clang}
if [ $PROFILE = clang ]; then
  export CC=clang
  export CXX=clang++
fi

echo 'eval "$(pyenv virtualenv-init -)"' >> ~/.bashrc
. /etc/profile
pyenv activate venv-cpp-devtools
conan profile new default --detect
conan profile new clang --detect
conan profile update settings.compiler.libcxx=libstdc++11 default
conan profile update settings.compiler.libcxx=libstdc++11 clang
conan profile update settings.compiler=clang clang
conan profile update settings.compiler.version=7.0 clang
conan profile update env.CC=/usr/bin/clang clang
conan profile update env.CXX=/usr/bin/clang++ clang

mkdir build
cd build
conan install .. --profile ${PROFILE} --build missing -s build_type=${BUILD_TYPE}
cmake .. \
  -DCMAKE_BUILD_TYPE=${BUILD_TYPE} \
  -DCPP_BOILERPLATE_CLANG_TIDY=ON \
  -DCPP_BOILERPLATE_IWYU=ON
cmake ..
cp compile_commands.json ../
cmake --build . -v -- -j 1 
cmake --build . --target check-format
if [ $PROFILE = clang ]; then
  cmake --build . --target clang-tidy
  cmake --build . --target iwyu
fi
ctest -C ${BUILD_TYPE} -VV
