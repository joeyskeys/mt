include(CMakeParseArguments)

function(mt_add_metallib TARGET)
    set(options)
    set(one_value_args
        OUTPUT_DIRECTORY
        OUTPUT_NAME
        SDK
        DEPLOYMENT_TARGET
        INSTALL_DESTINATION
    )
    set(multi_value_args
        SOURCES
        COMPILE_OPTIONS
        METALLIB_OPTIONS
    )
    cmake_parse_arguments(
        MT_METAL
        "${options}"
        "${one_value_args}"
        "${multi_value_args}"
        ${ARGN}
    )

    if(NOT MT_METAL_SOURCES)
        message(FATAL_ERROR
            "mt_add_metallib(${TARGET}) requires at least one SOURCES entry")
    endif()

    find_program(MT_XCRUN_EXECUTABLE xcrun REQUIRED)

    if(NOT MT_METAL_OUTPUT_DIRECTORY)
        set(MT_METAL_OUTPUT_DIRECTORY
            "${CMAKE_CURRENT_BINARY_DIR}/${TARGET}.metal")
    endif()
    if(NOT MT_METAL_OUTPUT_NAME)
        set(MT_METAL_OUTPUT_NAME "${TARGET}.metallib")
    endif()
    if(NOT MT_METAL_SDK)
        set(MT_METAL_SDK macosx)
    endif()
    if(NOT MT_METAL_DEPLOYMENT_TARGET)
        if(CMAKE_OSX_DEPLOYMENT_TARGET)
            set(MT_METAL_DEPLOYMENT_TARGET
                "${CMAKE_OSX_DEPLOYMENT_TARGET}")
        else()
            set(MT_METAL_DEPLOYMENT_TARGET 13.0)
        endif()
    endif()

    set(_air_files)
    foreach(_source IN LISTS MT_METAL_SOURCES)
        get_filename_component(_source_absolute "${_source}" ABSOLUTE
            BASE_DIR "${CMAKE_CURRENT_SOURCE_DIR}")
        get_filename_component(_source_name "${_source}" NAME_WE)
        set(_air_file
            "${MT_METAL_OUTPUT_DIRECTORY}/${_source_name}.air")
        add_custom_command(
            OUTPUT "${_air_file}"
            COMMAND "${CMAKE_COMMAND}" -E make_directory
                "${MT_METAL_OUTPUT_DIRECTORY}"
            COMMAND "${MT_XCRUN_EXECUTABLE}"
                --sdk "${MT_METAL_SDK}"
                metal
                -c "${_source_absolute}"
                -o "${_air_file}"
                "-mmacosx-version-min=${MT_METAL_DEPLOYMENT_TARGET}"
                ${MT_METAL_COMPILE_OPTIONS}
            DEPENDS "${_source_absolute}"
            VERBATIM
        )
        list(APPEND _air_files "${_air_file}")
    endforeach()

    set(_metallib
        "${MT_METAL_OUTPUT_DIRECTORY}/${MT_METAL_OUTPUT_NAME}")
    add_custom_command(
        OUTPUT "${_metallib}"
        COMMAND "${CMAKE_COMMAND}" -E make_directory
            "${MT_METAL_OUTPUT_DIRECTORY}"
        COMMAND "${MT_XCRUN_EXECUTABLE}"
            --sdk "${MT_METAL_SDK}"
            metallib
            ${MT_METAL_METALLIB_OPTIONS}
            ${_air_files}
            -o "${_metallib}"
        DEPENDS ${_air_files}
        VERBATIM
    )

    add_custom_target("${TARGET}" DEPENDS "${_metallib}")
    set_property(
        TARGET "${TARGET}"
        PROPERTY MT_METALLIB "${_metallib}"
    )

    if(MT_METAL_INSTALL_DESTINATION)
        install(
            FILES "${_metallib}"
            DESTINATION "${MT_METAL_INSTALL_DESTINATION}"
        )
    endif()

    set("${TARGET}_METALLIB" "${_metallib}" PARENT_SCOPE)
endfunction()

