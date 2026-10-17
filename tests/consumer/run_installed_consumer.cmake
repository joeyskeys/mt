if(NOT DEFINED MT_SOURCE_DIR OR NOT DEFINED MT_BINARY_DIR)
    message(FATAL_ERROR
        "MT_SOURCE_DIR and MT_BINARY_DIR are required")
endif()

if(NOT DEFINED MT_BUILD_TYPE)
    set(MT_BUILD_TYPE "${CMAKE_BUILD_TYPE}")
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

