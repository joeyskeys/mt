if(MT_BUILD_APPKIT)
    add_executable(mt-test-appkit-api appkit_api.cpp)
    target_link_libraries(mt-test-appkit-api PRIVATE mt::mt-appkit)
    target_compile_features(mt-test-appkit-api PRIVATE cxx_std_20)

    add_test(
        NAME mt.unit.host.appkit.api
        COMMAND mt-test-appkit-api
    )
endif()

if(MT_BUILD_MTKVIEW)
    add_executable(mt-test-mtkview-api mtkview_api.cpp)
    target_link_libraries(mt-test-mtkview-api PRIVATE mt::mt-mtkview)
    target_compile_features(mt-test-mtkview-api PRIVATE cxx_std_20)

    add_test(
        NAME mt.unit.host.mtkview.api
        COMMAND mt-test-mtkview-api
    )
endif()

