# Declaration et nommage du projet
project(parser)

# Minimum version of CMake to build this project
cmake_minimum_required(VERSION 2.6)

# Includes
include_directories(${CMAKE_CURRENT_SOURCE_DIR})
include_directories(${CMAKE_CURRENT_BINARY_DIR})

# Packages
find_package(BISON)
find_package(FLEX)

# Variables
set(CXX "clang++")
set(CMAKE_CXX_FLAGS_DEBUG "-Wall -W -Werror -pedantic -g")
set(CMAKE_CXX_FLAGS "-O3 -Wall -W -pedantic")

# Files
file(GLOB HH_FILES *.hh)
file(GLOB SRC_FILES *.cc)

# BISON and FLEX
bison_target(Parser parser.yy ${CMAKE_CURRENT_BINARY_DIR}/parser.cc)
flex_target(Scanner scanner.ll ${CMAKE_CURRENT_BINARY_DIR}/scanner.cc)
add_flex_bison_dependency(Scanner Parser)

# Output directoru
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})

# Add the binary and sources
add_executable(
  sc
  ${HH_FILES}
  ${SRC_FILES}
  ${FLEX_Scanner_OUTPUTS}
  ${BISON_Parser_OUTPUTS}
)
