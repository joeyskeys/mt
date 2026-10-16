cmake_minimum_required(VERSION 3.25)

project(mt_installed_consumer LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

find_package(mt CONFIG REQUIRED)

add_executable(mt-installed-consumer main.cpp)
target_link_libraries(mt-installed-consumer PRIVATE mt::mt)

