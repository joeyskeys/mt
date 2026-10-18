if(MT_BUILD_EXTERNAL_RESOURCES)
    add_executable(mt-test-external-resources-api api.cpp)
    target_link_libraries(
        mt-test-external-resources-api
        PRIVATE
            mt::mt
            mt::mt-external-resources
    )
    target_compile_features(mt-test-external-resources-api PRIVATE cxx_std_20)
    add_test(
        NAME mt.unit.external_resources.api
        COMMAND mt-test-external-resources-api
    )
endif()
