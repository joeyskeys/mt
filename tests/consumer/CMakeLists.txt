add_executable(mt-test-external-consumer main.cpp)
target_link_libraries(mt-test-external-consumer PRIVATE mt::mt)
target_compile_features(mt-test-external-consumer PRIVATE cxx_std_20)

add_test(
    NAME mt.consumer.external
    COMMAND mt-test-external-consumer
)

if(MT_BUILD_INSTALLED_CONSUMER)
    add_test(
        NAME mt.consumer.installed
        COMMAND ${CMAKE_COMMAND}
            -DMT_SOURCE_DIR=${PROJECT_SOURCE_DIR}
            -DMT_BINARY_DIR=${CMAKE_BINARY_DIR}
            -DMT_BUILD_TYPE=${CMAKE_BUILD_TYPE}
            -P ${CMAKE_CURRENT_SOURCE_DIR}/run_installed_consumer.cmake
    )
endif()

