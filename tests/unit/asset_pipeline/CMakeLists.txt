if(MT_BUILD_ASSET_PIPELINE)
    add_executable(mt-test-asset-pipeline-api api.cpp)
    target_link_libraries(
        mt-test-asset-pipeline-api
        PRIVATE
            mt::mt-asset-pipeline
    )
    target_compile_features(mt-test-asset-pipeline-api PRIVATE cxx_std_20)
    add_test(
        NAME mt.unit.asset_pipeline.api
        COMMAND mt-test-asset-pipeline-api
    )
endif()
