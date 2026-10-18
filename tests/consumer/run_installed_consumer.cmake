if(NOT DEFINED MT_SOURCE_DIR OR NOT DEFINED MT_BINARY_DIR)
    message(FATAL_ERROR
        "MT_SOURCE_DIR and MT_BINARY_DIR are required")
endif()

if(NOT DEFINED MT_BUILD_TYPE)
    set(MT_BUILD_TYPE "${CMAKE_BUILD_TYPE}")
endif()
if(NOT DEFINED MT_INSTALL_LIBDIR OR MT_INSTALL_LIBDIR STREQUAL "")
    set(MT_INSTALL_LIBDIR "lib")
endif()
if(NOT DEFINED MT_PYTHON_INSTALL_DIR OR MT_PYTHON_INSTALL_DIR STREQUAL "")
    set(MT_PYTHON_INSTALL_DIR "${MT_INSTALL_LIBDIR}")
endif()

set(MT_INSTALLED_CONSUMER_HOSTS OFF)
if(MT_BUILD_APPKIT OR MT_BUILD_MTKVIEW)
    set(MT_INSTALLED_CONSUMER_HOSTS ON)
endif()

set(MT_INSTALLED_CONSUMER_GUI_TEXT OFF)
if(MT_BUILD_IMGUI OR MT_BUILD_TEXT OR MT_BUILD_FREETYPE_BRIDGE)
    set(MT_INSTALLED_CONSUMER_GUI_TEXT ON)
endif()

set(MT_INSTALLED_CONSUMER_ASSET_PIPELINE OFF)
if(MT_BUILD_ASSET_PIPELINE)
    set(MT_INSTALLED_CONSUMER_ASSET_PIPELINE ON)
endif()

set(MT_INSTALLED_CONSUMER_EXTERNAL_RESOURCES OFF)
if(MT_BUILD_EXTERNAL_RESOURCES)
    set(MT_INSTALLED_CONSUMER_EXTERNAL_RESOURCES ON)
endif()

set(MT_INSTALLED_CONSUMER_PYTHON OFF)
if(MT_BUILD_PYTHON)
    set(MT_INSTALLED_CONSUMER_PYTHON ON)
endif()

if(NOT DEFINED MT_INSTALLED_CONSUMER_BINARY_DIR)
    set(
        MT_INSTALLED_CONSUMER_BINARY_DIR
        "${MT_BINARY_DIR}/installed-consumer"
    )
endif()

if(NOT DEFINED MT_INSTALLED_CONSUMER_PREFIX)
    set(
        MT_INSTALLED_CONSUMER_PREFIX
        "${MT_BINARY_DIR}/installed-consumer-prefix"
    )
endif()

if(IS_ABSOLUTE "${MT_PYTHON_INSTALL_DIR}")
    set(
        MT_INSTALLED_PYTHON_PATH
        "${MT_PYTHON_INSTALL_DIR}"
    )
else()
    set(
        MT_INSTALLED_PYTHON_PATH
        "${MT_INSTALLED_CONSUMER_PREFIX}/${MT_PYTHON_INSTALL_DIR}"
    )
endif()

execute_process(
    COMMAND "${CMAKE_COMMAND}"
        --install "${MT_BINARY_DIR}"
        --prefix "${MT_INSTALLED_CONSUMER_PREFIX}"
    RESULT_VARIABLE install_result
)
if(NOT install_result EQUAL 0)
    message(FATAL_ERROR "Installing mt for the consumer test failed.")
endif()

execute_process(
    COMMAND "${CMAKE_COMMAND}"
        -S "${MT_SOURCE_DIR}/tests/consumer/installed"
        -B "${MT_INSTALLED_CONSUMER_BINARY_DIR}"
        -DCMAKE_PREFIX_PATH=${MT_INSTALLED_CONSUMER_PREFIX}
        -DCMAKE_BUILD_TYPE=${MT_BUILD_TYPE}
        -DMT_INSTALLED_CONSUMER_HOSTS=${MT_INSTALLED_CONSUMER_HOSTS}
        -DMT_INSTALLED_CONSUMER_GUI_TEXT=${MT_INSTALLED_CONSUMER_GUI_TEXT}
        -DMT_INSTALLED_CONSUMER_ASSET_PIPELINE=${MT_INSTALLED_CONSUMER_ASSET_PIPELINE}
        -DMT_INSTALLED_CONSUMER_EXTERNAL_RESOURCES=${MT_INSTALLED_CONSUMER_EXTERNAL_RESOURCES}
        -DMT_INSTALLED_CONSUMER_PYTHON=${MT_INSTALLED_CONSUMER_PYTHON}
        -DMT_INSTALLED_CONSUMER_PYTHON_EXECUTABLE=${MT_PYTHON_EXECUTABLE}
    RESULT_VARIABLE configure_result
)
if(NOT configure_result EQUAL 0)
    message(FATAL_ERROR "Configuring the installed consumer failed.")
endif()

execute_process(
    COMMAND "${CMAKE_COMMAND}"
        --build "${MT_INSTALLED_CONSUMER_BINARY_DIR}"
        --config "${MT_BUILD_TYPE}"
    RESULT_VARIABLE build_result
)
if(NOT build_result EQUAL 0)
    message(FATAL_ERROR "Building the installed consumer failed.")
endif()

set(
    consumer_executable
    "${MT_INSTALLED_CONSUMER_BINARY_DIR}/mt-installed-consumer"
)

execute_process(
    COMMAND "${consumer_executable}"
    RESULT_VARIABLE run_result
)
if(NOT run_result EQUAL 0)
    message(FATAL_ERROR "Running the installed consumer failed.")
endif()

if(MT_INSTALLED_CONSUMER_HOSTS)
    execute_process(
        COMMAND
            "${MT_INSTALLED_CONSUMER_BINARY_DIR}/mt-installed-host-consumer"
        RESULT_VARIABLE host_run_result
    )
    if(NOT host_run_result EQUAL 0)
        message(FATAL_ERROR "Running the installed host consumer failed.")
    endif()
endif()

if(MT_INSTALLED_CONSUMER_GUI_TEXT)
    execute_process(
        COMMAND
            "${MT_INSTALLED_CONSUMER_BINARY_DIR}/mt-installed-gui-text-consumer"
        RESULT_VARIABLE gui_text_run_result
    )
    if(NOT gui_text_run_result EQUAL 0)
        message(FATAL_ERROR
            "Running the installed GUI/text consumer failed.")
    endif()
endif()

if(MT_INSTALLED_CONSUMER_ASSET_PIPELINE)
    execute_process(
        COMMAND
            "${MT_INSTALLED_CONSUMER_BINARY_DIR}/mt-installed-asset-pipeline-consumer"
        RESULT_VARIABLE asset_pipeline_run_result
    )
    if(NOT asset_pipeline_run_result EQUAL 0)
        message(FATAL_ERROR
            "Running the installed asset-pipeline consumer failed.")
    endif()
endif()

if(MT_INSTALLED_CONSUMER_EXTERNAL_RESOURCES)
    execute_process(
        COMMAND
            "${MT_INSTALLED_CONSUMER_BINARY_DIR}/mt-installed-external-resources-consumer"
        RESULT_VARIABLE external_resources_run_result
    )
    if(NOT external_resources_run_result EQUAL 0)
        message(FATAL_ERROR
            "Running the installed external-resource consumer failed.")
    endif()
endif()

if(MT_INSTALLED_CONSUMER_PYTHON)
    if(NOT MT_PYTHON_EXECUTABLE)
        message(FATAL_ERROR
            "MT_BUILD_PYTHON validation requires MT_PYTHON_EXECUTABLE.")
    endif()
    execute_process(
        COMMAND
            "${CMAKE_COMMAND}"
            -E
            env
            "PYTHONPATH=${MT_INSTALLED_PYTHON_PATH}"
            "${MT_PYTHON_EXECUTABLE}"
            "${MT_SOURCE_DIR}/tests/python/import_smoke.py"
        RESULT_VARIABLE python_run_result
    )
    if(NOT python_run_result EQUAL 0)
        message(FATAL_ERROR "Running the installed Python consumer failed.")
    endif()
endif()

