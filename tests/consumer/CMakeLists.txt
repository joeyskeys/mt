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
            -DMT_BUILD_APPKIT=${MT_BUILD_APPKIT}
            -DMT_BUILD_MTKVIEW=${MT_BUILD_MTKVIEW}
            -DMT_BUILD_IMGUI=${MT_BUILD_IMGUI}
            -DMT_BUILD_TEXT=${MT_BUILD_TEXT}
            -DMT_BUILD_FREETYPE_BRIDGE=${MT_BUILD_FREETYPE_BRIDGE}
            -DMT_BUILD_ASSET_PIPELINE=${MT_BUILD_ASSET_PIPELINE}
            -DMT_BUILD_EXTERNAL_RESOURCES=${MT_BUILD_EXTERNAL_RESOURCES}
            -DMT_BUILD_PYTHON=${MT_BUILD_PYTHON}
            -DMT_PYTHON_EXECUTABLE=${MT_PYTHON_EXECUTABLE}
            -DMT_PYTHON_INSTALL_DIR=${MT_PYTHON_INSTALL_DIR}
            -DMT_INSTALL_LIBDIR=${CMAKE_INSTALL_LIBDIR}
            -P ${CMAKE_CURRENT_SOURCE_DIR}/run_installed_consumer.cmake
    )
endif()

