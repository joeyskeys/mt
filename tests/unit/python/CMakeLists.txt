if(MT_BUILD_PYTHON)
    add_executable(mt-test-python-api api.cpp)
    target_link_libraries(mt-test-python-api PRIVATE mt::mt)
    target_compile_features(mt-test-python-api PRIVATE cxx_std_20)
    add_test(
        NAME mt.unit.python.api
        COMMAND mt-test-python-api
    )

    add_test(
        NAME mt.unit.python.import
        COMMAND
            "${Python3_EXECUTABLE}"
            "${PROJECT_SOURCE_DIR}/tests/python/import_smoke.py"
    )
    set_tests_properties(
        mt.unit.python.import
        PROPERTIES
            ENVIRONMENT "PYTHONPATH=$<TARGET_FILE_DIR:mt-python>"
    )
endif()
