cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

project(CPMSol2Example)

# ---- Dependencies ----

include(../../cmake/CPM.cmake)

CPMAddPackage(
  NAME lua
  GITHUB_REPOSITORY lua/lua
  VERSION 5.3.5
  DOWNLOAD_ONLY YES
)

if(lua_ADDED)
  # lua has no CMakeLists, so we create our own target
  file(GLOB lua_sources ${lua_SOURCE_DIR}/*.c)
  list(REMOVE_ITEM lua_sources "${lua_SOURCE_DIR}/lua.c" "${lua_SOURCE_DIR}/luac.c")
  add_library(lua STATIC ${lua_sources})
  target_include_directories(lua SYSTEM PUBLIC $<BUILD_INTERFACE:${lua_SOURCE_DIR}>)
endif()

CPMAddPackage(
  NAME sol2
  GITHUB_REPOSITORY ThePhD/sol2
  VERSION 3.3.0
  # fix for clang 18.1.0, see https://github.com/ThePhD/sol2/issues/1581#issuecomment-2103463524
  PATCHES fix_for_clang.patch
)

# ---- Executable ----

add_executable(CPMSol2Example main.cpp)
target_compile_features(CPMSol2Example PRIVATE cxx_std_17)
target_link_libraries(CPMSol2Example sol2 lua)
