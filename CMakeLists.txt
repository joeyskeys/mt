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
    MT_BUILD_HOST_EXAMPLES
    "Build optional native AppKit and MTKView window consumers"
    OFF
)
option(
    MT_BUILD_GUI_TEXT_EXAMPLES
    "Build optional ImGui-boundary and text-atlas consumers"
    OFF
)
option(
    MT_BUILD_IMGUI
    "Build the optional ImGui coordination boundary"
    OFF
)
option(
    MT_BUILD_TEXT
    "Build the optional CoreText glyph and text integration"
    OFF
)
option(
    MT_BUILD_FREETYPE_BRIDGE
    "Build the optional value-only FreeType glyph bridge"
    OFF
)
option(
    MT_BUILD_ASSET_PIPELINE
    "Build the optional importer, conversion, and serialization boundary"
    OFF
)
option(
    MT_BUILD_ASSET_PIPELINE_EXAMPLES
    "Build the optional asset-pipeline consumer example"
    OFF
)
option(
    MT_BUILD_EXTERNAL_RESOURCES
    "Build the optional IOSurface and external-resource integration"
    OFF
)
option(
    MT_BUILD_PYTHON
    "Build the optional Python C++ extension"
    OFF
)
option(
    MT_BUILD_INSTALLED_CONSUMER
    "Run the standalone installed-package consumer test"
    OFF
)

include(GNUInstallDirs)
include(CMakePackageConfigHelpers)
set(
    MT_PYTHON_INSTALL_DIR
    "${CMAKE_INSTALL_LIBDIR}"
    CACHE PATH
    "Install directory for the optional mt Python extension"
)
set(
    MT_PYTHON_EXECUTABLE
    ""
    CACHE FILEPATH
    "Python interpreter used for the optional mt Python extension"
)
set(
    MT_PYTHON_ROOT
    ""
    CACHE PATH
    "Python installation prefix used for the optional mt Python extension"
)
set(
    MT_PYTHON_INCLUDE_DIR
    ""
    CACHE PATH
    "Python include directory override for the optional mt Python extension"
)
set(
    MT_PYTHON_LIBRARY
    ""
    CACHE FILEPATH
    "Python library override for the optional mt Python extension"
)

find_library(MT_METAL_FRAMEWORK Metal REQUIRED)
find_library(MT_FOUNDATION_FRAMEWORK Foundation REQUIRED)
find_library(MT_QUARTZCORE_FRAMEWORK QuartzCore REQUIRED)
if(MT_BUILD_APPKIT OR MT_BUILD_MTKVIEW OR MT_BUILD_HOST_EXAMPLES)
    find_library(MT_APPKIT_FRAMEWORK AppKit REQUIRED)
endif()
if(MT_BUILD_MTKVIEW)
    find_library(MT_METALKIT_FRAMEWORK MetalKit REQUIRED)
endif()
if(MT_BUILD_FREETYPE_BRIDGE)
    set(MT_BUILD_TEXT ON)
endif()
if(MT_BUILD_TEXT)
    find_library(MT_CORETEXT_FRAMEWORK CoreText REQUIRED)
    find_library(MT_COREGRAPHICS_FRAMEWORK CoreGraphics REQUIRED)
endif()
if(MT_BUILD_EXTERNAL_RESOURCES)
    find_library(MT_IOSURFACE_FRAMEWORK IOSurface REQUIRED)
endif()
if(MT_BUILD_PYTHON)
    if(MT_PYTHON_EXECUTABLE)
        set(
            Python3_EXECUTABLE
            "${MT_PYTHON_EXECUTABLE}"
            CACHE FILEPATH
            "Selected Python interpreter for mt"
            FORCE
        )
    endif()
    if(MT_PYTHON_ROOT)
        set(
            Python3_ROOT_DIR
            "${MT_PYTHON_ROOT}"
            CACHE PATH
            "Selected Python root for mt"
            FORCE
        )
    endif()
    if(MT_PYTHON_INCLUDE_DIR)
        set(
            Python3_INCLUDE_DIR
            "${MT_PYTHON_INCLUDE_DIR}"
            CACHE PATH
            "Selected Python include directory for mt"
            FORCE
        )
    endif()
    if(MT_PYTHON_LIBRARY)
        set(
            Python3_LIBRARY
            "${MT_PYTHON_LIBRARY}"
            CACHE FILEPATH
            "Selected Python library for mt"
            FORCE
        )
    endif()
    find_package(
        Python3
        COMPONENTS
            Interpreter
            Development.Module
        REQUIRED
    )
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
        Sources/MTAppKit/AppKitInput.swift
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
            ${MT_APPKIT_FRAMEWORK}
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

if(MT_BUILD_IMGUI)
    add_library(
        mt-imgui
        Sources/MTImGui/ImGuiIntegration.swift
    )
    add_library(mt::mt-imgui ALIAS mt-imgui)
    set_target_properties(
        mt-imgui
        PROPERTIES
            Swift_MODULE_NAME MTImGui
            EXPORT_NAME mt-imgui
    )
    target_compile_features(mt-imgui INTERFACE cxx_std_20)
    target_compile_options(
        mt-imgui
        PUBLIC
            "$<$<COMPILE_LANGUAGE:Swift>:-cxx-interoperability-mode=default>"
    )
    target_link_libraries(mt-imgui PUBLIC mt::mt)
    target_include_directories(
        mt-imgui
        PUBLIC
            $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
            $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}>
            $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
            $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/mt>
    )
    _swift_generate_cxx_header(mt-imgui MTImGui-Swift.h)
endif()

if(MT_BUILD_TEXT)
    add_library(
        mt-text
        Sources/MTText/CoreTextText.swift
    )
    add_library(mt::mt-text ALIAS mt-text)
    set_target_properties(
        mt-text
        PROPERTIES
            Swift_MODULE_NAME MTText
            EXPORT_NAME mt-text
    )
    target_compile_features(mt-text INTERFACE cxx_std_20)
    target_compile_options(
        mt-text
        PUBLIC
            "$<$<COMPILE_LANGUAGE:Swift>:-cxx-interoperability-mode=default>"
    )
    target_link_libraries(
        mt-text
        PUBLIC
            mt::mt
            ${MT_CORETEXT_FRAMEWORK}
            ${MT_COREGRAPHICS_FRAMEWORK}
    )
    target_include_directories(
        mt-text
        PUBLIC
            $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
            $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}>
            $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
            $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/mt>
    )
    _swift_generate_cxx_header(mt-text MTText-Swift.h)
endif()

if(MT_BUILD_FREETYPE_BRIDGE)
    add_library(
        mt-freetype
        Sources/MTFreeType/FreeTypeBridge.swift
    )
    add_library(mt::mt-freetype ALIAS mt-freetype)
    set_target_properties(
        mt-freetype
        PROPERTIES
            Swift_MODULE_NAME MTFreeType
            EXPORT_NAME mt-freetype
    )
    target_compile_features(mt-freetype INTERFACE cxx_std_20)
    target_compile_options(
        mt-freetype
        PUBLIC
            "$<$<COMPILE_LANGUAGE:Swift>:-cxx-interoperability-mode=default>"
    )
    target_link_libraries(mt-freetype PUBLIC mt::mt-text)
    target_include_directories(
        mt-freetype
        PUBLIC
            $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
            $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}>
            $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
            $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/mt>
    )
    _swift_generate_cxx_header(mt-freetype MTFreeType-Swift.h)
endif()

if(MT_BUILD_ASSET_PIPELINE)
    add_library(
        mt-asset-pipeline
        Sources/MTAssetPipeline/AssetPipeline.swift
    )
    add_library(mt::mt-asset-pipeline ALIAS mt-asset-pipeline)
    set_target_properties(
        mt-asset-pipeline
        PROPERTIES
            Swift_MODULE_NAME MTAssetPipeline
            EXPORT_NAME mt-asset-pipeline
    )
    target_compile_features(mt-asset-pipeline INTERFACE cxx_std_20)
    target_compile_options(
        mt-asset-pipeline
        PUBLIC
            "$<$<COMPILE_LANGUAGE:Swift>:-cxx-interoperability-mode=default>"
    )
    target_link_libraries(
        mt-asset-pipeline
        PUBLIC
            mt::mt
    )
    target_include_directories(
        mt-asset-pipeline
        PUBLIC
            $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
            $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}>
            $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
            $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/mt>
    )
    _swift_generate_cxx_header(
        mt-asset-pipeline
        MTAssetPipeline-Swift.h
    )
endif()

if(MT_BUILD_EXTERNAL_RESOURCES)
    add_library(
        mt-external-resources
        Sources/MTExternalResources/ExternalResources.swift
    )
    add_library(
        mt::mt-external-resources
        ALIAS
        mt-external-resources
    )
    set_target_properties(
        mt-external-resources
        PROPERTIES
            Swift_MODULE_NAME MTExternalResources
            EXPORT_NAME mt-external-resources
    )
    target_compile_features(mt-external-resources INTERFACE cxx_std_20)
    target_compile_options(
        mt-external-resources
        PUBLIC
            "$<$<COMPILE_LANGUAGE:Swift>:-cxx-interoperability-mode=default>"
    )
    target_link_libraries(
        mt-external-resources
        PUBLIC
            mt::mt
            ${MT_FOUNDATION_FRAMEWORK}
            ${MT_IOSURFACE_FRAMEWORK}
            ${MT_METAL_FRAMEWORK}
    )
    target_include_directories(
        mt-external-resources
        PUBLIC
            $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
            $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}>
            $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
            $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/mt>
    )
    _swift_generate_cxx_header(
        mt-external-resources
        MTExternalResources-Swift.h
    )
endif()

if(MT_BUILD_PYTHON)
    Python3_add_library(
        mt-python
        MODULE
        WITH_SOABI
        python/mt_module.cpp
    )
    set_target_properties(
        mt-python
        PROPERTIES
            OUTPUT_NAME mt
            PREFIX ""
            EXPORT_NAME mt-python
    )
    target_compile_features(mt-python PRIVATE cxx_std_20)
    target_link_libraries(
        mt-python
        PRIVATE
            mt::mt
            Python3::Module
    )
    target_include_directories(
        mt-python
        PRIVATE
            $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
            $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}>
    )
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
        PATTERN "imgui.hpp" EXCLUDE
        PATTERN "text.hpp" EXCLUDE
        PATTERN "freetype.hpp" EXCLUDE
        PATTERN "asset_pipeline.hpp" EXCLUDE
        PATTERN "external_resources.hpp" EXCLUDE
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

if(MT_BUILD_IMGUI)
    install(
        TARGETS mt-imgui
        EXPORT mtTargets
        ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
        LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
        RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
        INCLUDES DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
    )
    install(
        FILES
            ${CMAKE_CURRENT_BINARY_DIR}/MTImGui-Swift.h
            ${CMAKE_CURRENT_SOURCE_DIR}/include/mt/imgui.hpp
        DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/mt
    )
endif()

if(MT_BUILD_TEXT)
    install(
        TARGETS mt-text
        EXPORT mtTargets
        ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
        LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
        RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
        INCLUDES DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
    )
    install(
        FILES
            ${CMAKE_CURRENT_BINARY_DIR}/MTText-Swift.h
            ${CMAKE_CURRENT_SOURCE_DIR}/include/mt/text.hpp
        DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/mt
    )
endif()

if(MT_BUILD_FREETYPE_BRIDGE)
    install(
        TARGETS mt-freetype
        EXPORT mtTargets
        ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
        LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
        RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
        INCLUDES DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
    )
    install(
        FILES
            ${CMAKE_CURRENT_BINARY_DIR}/MTFreeType-Swift.h
            ${CMAKE_CURRENT_SOURCE_DIR}/include/mt/freetype.hpp
        DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/mt
    )
endif()

if(MT_BUILD_ASSET_PIPELINE)
    install(
        TARGETS mt-asset-pipeline
        EXPORT mtTargets
        ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
        LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
        RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
        INCLUDES DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
    )
    install(
        FILES
            ${CMAKE_CURRENT_BINARY_DIR}/MTAssetPipeline-Swift.h
            ${CMAKE_CURRENT_SOURCE_DIR}/include/mt/asset_pipeline.hpp
        DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/mt
    )
endif()

if(MT_BUILD_EXTERNAL_RESOURCES)
    install(
        TARGETS mt-external-resources
        EXPORT mtTargets
        ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
        LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
        RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
        INCLUDES DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
    )
    install(
        FILES
            ${CMAKE_CURRENT_BINARY_DIR}/MTExternalResources-Swift.h
            ${CMAKE_CURRENT_SOURCE_DIR}/include/mt/external_resources.hpp
        DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/mt
    )
endif()

if(MT_BUILD_PYTHON)
    install(
        TARGETS mt-python
        EXPORT mtPythonTargets
        LIBRARY DESTINATION ${MT_PYTHON_INSTALL_DIR}
        RUNTIME DESTINATION ${MT_PYTHON_INSTALL_DIR}
    )
    install(
        EXPORT mtPythonTargets
        FILE mtPythonTargets.cmake
        NAMESPACE mt::
        DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/mt
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

