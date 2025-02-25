set(EXE_TARGET_NAME use_conan)

set(${EXE_TARGET_NAME}_SRC # cmf: sortable
                           main.cpp)

add_executable(${EXE_TARGET_NAME})

target_sources(${EXE_TARGET_NAME} PRIVATE ${${EXE_TARGET_NAME}_SRC})

target_compile_features(${EXE_TARGET_NAME} PUBLIC cxx_std_20)
set_target_properties(${EXE_TARGET_NAME} PROPERTIES CXX_EXTENSIONS OFF)

if(${PROJECT_NAME_UPPERCASE}_INTERPROCEDURAL_OPTIMIZATION)
  set_target_properties(${EXE_TARGET_NAME}
                        PROPERTIES INTERPROCEDURAL_OPTIMIZATION ON)
endif()

target_include_directories(${EXE_TARGET_NAME}
                           PRIVATE "${CMAKE_CURRENT_BINARY_DIR}")
target_link_libraries(
  ${EXE_TARGET_NAME} PRIVATE CONAN_PKG::fmt CONAN_PKG::zlib
                             cpp_boilerplate::cpp_boilerplate_version)

install(TARGETS ${EXE_TARGET_NAME} DESTINATION "${CMAKE_INSTALL_BINDIR}")
