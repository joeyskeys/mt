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
option(MT_BUILD_APPKIT "Build the optional AppKit/CAMetalLayer adapter" OFF)
option(MT_BUILD_MTKVIEW "Build the optional MTKView adapter" OFF)
option(
    MT_BUILD_INSTALLED_CONSUMER
    "Run the standalone installed-package consumer test"
    OFF
)

include(GNUInstallDirs)
include(CMakePackageConfigHelpers)

find_library(MT_METAL_FRAMEWORK Metal REQUIRED)
find_library(MT_FOUNDATION_FRAMEWORK Foundation REQUIRED)
find_library(MT_QUARTZCORE_FRAMEWORK QuartzCore REQUIRED)
if(MT_BUILD_APPKIT)
    find_library(MT_APPKIT_FRAMEWORK AppKit REQUIRED)
endif()
if(MT_BUILD_MTKVIEW)
    find_library(MT_METALKIT_FRAMEWORK MetalKit REQUIRED)
endif()

add_library(
    mt
    Sources/MTCore/MTCore.swift
    Sources/MTCore/Renderer.swift
    Sources/MTCore/Scene.swift
    Sources/MTCore/Viewport.swift
    Sources/MTCore/Input.swift
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

if(MT_BUILD_APPKIT)
    add_library(
        mt-appkit
        Sources/MTAppKit/AppKitSurface.swift
    )
    add_library(mt::mt-appkit ALIAS mt-appkit)
    set_target_properties(
        mt-appkit
        PROPERTIES
            Swift_MODULE_NAME MTAppKit
            EXPORT_NAME mt-appkit
    )
    target_compile_features(mt-appkit INTERFACE cxx_std_20)
    target_compile_options(
        mt-appkit
        PUBLIC
            "$<$<COMPILE_LANGUAGE:Swift>:-cxx-interoperability-mode=default>"
    )
    target_link_libraries(
        mt-appkit
        PUBLIC
            mt::mt
            ${MT_APPKIT_FRAMEWORK}
            ${MT_METAL_FRAMEWORK}
            ${MT_QUARTZCORE_FRAMEWORK}
    )
    target_include_directories(
        mt-appkit
        PUBLIC
            $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
            $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}>
            $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
            $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/mt>
    )
    _swift_generate_cxx_header(mt-appkit MTAppKit-Swift.h)
endif()

if(MT_BUILD_MTKVIEW)
    add_library(
        mt-mtkview
        Sources/MTMetalKit/MTKViewSurface.swift
    )
    add_library(mt::mt-mtkview ALIAS mt-mtkview)
    set_target_properties(
        mt-mtkview
        PROPERTIES
            Swift_MODULE_NAME MTMetalKit
            EXPORT_NAME mt-mtkview
    )
    target_compile_features(mt-mtkview INTERFACE cxx_std_20)
    target_compile_options(
        mt-mtkview
        PUBLIC
            "$<$<COMPILE_LANGUAGE:Swift>:-cxx-interoperability-mode=default>"
    )
    target_link_libraries(
        mt-mtkview
        PUBLIC
            mt::mt
            ${MT_METALKIT_FRAMEWORK}
            ${MT_METAL_FRAMEWORK}
            ${MT_QUARTZCORE_FRAMEWORK}
    )
    target_include_directories(
        mt-mtkview
        PUBLIC
            $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
            $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}>
            $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
            $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/mt>
    )
    _swift_generate_cxx_header(mt-mtkview MTMetalKit-Swift.h)
endif()

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
    FILES_MATCHING
        PATTERN "*.hpp"
        PATTERN "appkit.hpp" EXCLUDE
        PATTERN "mtkview.hpp" EXCLUDE
)

install(
    DIRECTORY shaders/built_in/
    DESTINATION ${CMAKE_INSTALL_DATADIR}/mt/shaders/built_in
    FILES_MATCHING
        PATTERN "*.metal"
)

install(
    FILES ${CMAKE_CURRENT_BINARY_DIR}/MTCore-Swift.h
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/mt
)

if(MT_BUILD_APPKIT)
    install(
        TARGETS mt-appkit
        EXPORT mtTargets
        ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
        LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
        RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
        INCLUDES DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
    )
    install(
        FILES
            ${CMAKE_CURRENT_BINARY_DIR}/MTAppKit-Swift.h
            ${CMAKE_CURRENT_SOURCE_DIR}/include/mt/appkit.hpp
        DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/mt
    )
endif()

if(MT_BUILD_MTKVIEW)
    install(
        TARGETS mt-mtkview
        EXPORT mtTargets
        ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
        LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
        RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
        INCLUDES DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
    )
    install(
        FILES
            ${CMAKE_CURRENT_BINARY_DIR}/MTMetalKit-Swift.h
            ${CMAKE_CURRENT_SOURCE_DIR}/include/mt/mtkview.hpp
        DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/mt
    )
endif()

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
        ${CMAKE_CURRENT_SOURCE_DIR}/cmake/mtMetal.cmake
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/mt
)

if(MT_BUILD_TESTS)
    enable_testing()
    add_subdirectory(tests)
endif()

if(MT_BUILD_EXAMPLES)
    add_subdirectory(examples)
endif()

