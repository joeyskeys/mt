cmake_minimum_required(VERSION 3.26)

project(
    mt
    VERSION 0.1.0
    DESCRIPTION "Swift-first Metal library with C++ interoperability for macOS"
    LANGUAGES CXX Swift
)

include(AddSwift)

if(NOT APPLE)
    message(FATAL_ERROR "mt currently supports macOS only")
endif()

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_Swift_LANGUAGE_VERSION 5.9)
set(CMAKE_OSX_DEPLOYMENT_TARGET "13.0" CACHE STRING
    "Minimum macOS deployment target for mt")

option(MT_BUILD_TESTS "Build mt unit, header, and consumer tests" ON)
option(MT_BUILD_EXAMPLES "Build mt examples" ON)

include(GNUInstallDirs)
include(CMakePackageConfigHelpers)

find_library(MT_METAL_FRAMEWORK Metal REQUIRED)
find_library(MT_FOUNDATION_FRAMEWORK Foundation REQUIRED)
find_library(MT_QUARTZCORE_FRAMEWORK QuartzCore REQUIRED)

add_library(
    mt
    Sources/MTCore/MTCore.swift
)
add_library(mt::mt ALIAS mt)

set_target_properties(
    mt
    PROPERTIES
        Swift_MODULE_NAME MTCore
)

target_compile_features(mt INTERFACE cxx_std_20)

target_compile_options(
    mt
    PUBLIC
        "$<$<COMPILE_LANGUAGE:Swift>:-cxx-interoperability-mode=default>"
)

_swift_generate_cxx_header(mt MTCore-Swift.h)

target_include_directories(
    mt
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
        $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}>
        $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
        $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/mt>
)

target_link_libraries(
    mt
    PUBLIC
        ${MT_METAL_FRAMEWORK}
        ${MT_FOUNDATION_FRAMEWORK}
        ${MT_QUARTZCORE_FRAMEWORK}
)

set_target_properties(
    mt
    PROPERTIES
        EXPORT_NAME mt
)

install(
    TARGETS mt
    EXPORT mtTargets
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    INCLUDES DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
)

install(
    DIRECTORY include/
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
)

install(
    FILES ${CMAKE_CURRENT_BINARY_DIR}/MTCore-Swift.h
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/mt
)

install(
    EXPORT mtTargets
    FILE mtTargets.cmake
    NAMESPACE mt::
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/mt
)

configure_package_config_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/cmake/mtConfig.cmake.in
    ${CMAKE_CURRENT_BINARY_DIR}/mtConfig.cmake
    INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/mt
)

write_basic_package_version_file(
    ${CMAKE_CURRENT_BINARY_DIR}/mtConfigVersion.cmake
    COMPATIBILITY SameMajorVersion
)

install(
    FILES
        ${CMAKE_CURRENT_BINARY_DIR}/mtConfig.cmake
        ${CMAKE_CURRENT_BINARY_DIR}/mtConfigVersion.cmake
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/mt
)

if(MT_BUILD_TESTS)
    enable_testing()
    add_subdirectory(tests)
endif()

if(MT_BUILD_EXAMPLES)
    add_subdirectory(examples)
endif()

