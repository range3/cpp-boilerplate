function cmake_config() {
  BUILD_TYPE=${1:-Release}
  PROFILE=${2:-default}

  conan install . --profile ${PROFILE} --build missing -s build_type=${BUILD_TYPE} -if build-${BUILD_TYPE}
  case "$PROFILE" in
    "clang" )
      CC=clang CXX=clang++ cmake -S . -B build-${BUILD_TYPE} -DCMAKE_BUILD_TYPE=${BUILD_TYPE};;
    *)
      cmake -S . -B build-${BUILD_TYPE} -DCMAKE_BUILD_TYPE=${BUILD_TYPE};;
  esac
}
