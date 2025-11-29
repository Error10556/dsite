cmake_minimum_required(VERSION 3.28)
project(dsite VERSION 1.0.0 LANGUAGES CXX)

find_package(DInterp 1.0.0 EXACT REQUIRED)
find_package(oatpp 1.4.0 REQUIRED)

add_executable(dsite main.cpp)
target_link_libraries(dsite PRIVATE DInterp::dinterptools oatpp::oatpp)
