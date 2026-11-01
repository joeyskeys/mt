# This source file is part of the Swift open source project
#
# Copyright (c) 2023 Apple Inc. and the Swift project authors.
# Licensed under Apache License 2.0 with Runtime Library Exception
#
# See https://swift.org/LICENSE.txt for license information.

# Generate the bridging header from Swift to C++.
#
# target: the name of the target to generate headers for.
#         This target must build Swift source files.
# header: the name of the header file to generate.
#
# NOTE: This logic will eventually be unstreamed into CMake.
function(_swift_generate_cxx_header target header)
    if(NOT TARGET ${target})
        message(FATAL_ERROR "Target ${target} not defined.")
    endif()

    if(NOT DEFINED CMAKE_Swift_COMPILER)
        message(
            WARNING
            "Swift not enabled in project. Cannot generate headers for Swift files."
        )
        return()
    endif()

    cmake_parse_arguments(ARG "" "" "SEARCH_PATHS;MODULE_NAME" ${ARGN})

    if(NOT ARG_MODULE_NAME)
        get_target_property(target_module_name ${target} Swift_MODULE_NAME)
        if(
            NOT target_module_name
            OR target_module_name STREQUAL "target_module_name-NOTFOUND"
        )
            set(target_module_name ${target})
        endif()
        set(ARG_MODULE_NAME "${target_module_name}")
    endif()

    # CMake's Xcode generator does not consistently translate the
    # Swift_MODULE_NAME target property into Xcode's SWIFT_MODULE_NAME build
    # setting. Keep the compiled module name aligned with the generated header.
    set_property(
        TARGET ${target}
        PROPERTY XCODE_ATTRIBUTE_SWIFT_MODULE_NAME "${ARG_MODULE_NAME}"
    )

    if(ARG_SEARCH_PATHS)
        list(TRANSFORM ARG_SEARCH_PATHS PREPEND "-I")
    endif()

    if(APPLE AND CMAKE_OSX_SYSROOT)
        set(SDK_FLAGS "-sdk" "${CMAKE_OSX_SYSROOT}")
    elseif(WIN32)
        set(SDK_FLAGS "-sdk" "$ENV{SDKROOT}")
    elseif(CMAKE_SYSROOT)
        set(SDK_FLAGS "-sdk" "${CMAKE_SYSROOT}")
    endif()

    cmake_path(
        APPEND
        CMAKE_CURRENT_BINARY_DIR
        include
        OUTPUT_VARIABLE
        base_path
    )

    cmake_path(
        APPEND
        base_path
        ${header}
        OUTPUT_VARIABLE
        header_path
    )

    cmake_path(
        APPEND
        CMAKE_CURRENT_BINARY_DIR
        "${ARG_MODULE_NAME}.emit-module.d"
        OUTPUT_VARIABLE
        depfile_path
    )

    set(
        _AllSources
        $<PATH:ABSOLUTE_PATH,$<TARGET_PROPERTY:${target},SOURCES>,${CMAKE_CURRENT_SOURCE_DIR}>
    )
    set(_SwiftSources $<FILTER:${_AllSources},INCLUDE,\\.swift$>)

    add_custom_command(
        OUTPUT ${header_path}
        DEPENDS ${_SwiftSources}
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
        COMMAND
            ${CMAKE_Swift_COMPILER}
            -typecheck
            ${ARG_SEARCH_PATHS}
            ${_SwiftSources}
            ${SDK_FLAGS}
            -module-name
            "${ARG_MODULE_NAME}"
            -cxx-interoperability-mode=default
            -emit-clang-header-path
            ${header_path}
            -emit-dependencies
        DEPFILE "${depfile_path}"
        WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
        COMMENT "Generating '${header_path}'"
        COMMAND_EXPAND_LISTS
    )

    # Add the generated header to the public interface so dependents can find it.
    target_include_directories(
        ${target}
        PUBLIC
            "$<BUILD_INTERFACE:${base_path}>"
    )

    # Add it to the target so changes to the header trigger rebuilds.
    target_sources(${target} PRIVATE ${header_path})
endfunction()
