add_executable(mt-example-consumer-smoke consumer_smoke/main.cpp)
target_link_libraries(mt-example-consumer-smoke PRIVATE mt::mt)
target_compile_features(mt-example-consumer-smoke PRIVATE cxx_std_20)

add_executable(mt-example-runtime-smoke runtime_smoke/main.cpp)
target_link_libraries(mt-example-runtime-smoke PRIVATE mt::mt)
target_compile_features(mt-example-runtime-smoke PRIVATE cxx_std_20)

if(MT_BUILD_HOST_EXAMPLES AND MT_BUILD_APPKIT)
    add_executable(
        mt-example-appkit-window
        appkit_window/main.swift
    )
    target_link_libraries(mt-example-appkit-window PRIVATE mt::mt-appkit)
endif()

if(MT_BUILD_HOST_EXAMPLES AND MT_BUILD_MTKVIEW)
    add_executable(
        mt-example-mtkview-window
        mtkview_window/main.swift
    )
    target_link_libraries(mt-example-mtkview-window PRIVATE mt::mt-mtkview)
endif()

if(MT_BUILD_GUI_TEXT_EXAMPLES AND MT_BUILD_IMGUI AND MT_BUILD_APPKIT)
    add_executable(
        mt-example-imgui-boundary
        imgui_boundary/main.swift
    )
    target_link_libraries(
        mt-example-imgui-boundary
        PRIVATE
            mt::mt-imgui
            mt::mt-appkit
    )
endif()

if(MT_BUILD_GUI_TEXT_EXAMPLES AND MT_BUILD_TEXT)
    add_executable(
        mt-example-text-atlas
        text_atlas/main.swift
    )
    target_link_libraries(mt-example-text-atlas PRIVATE mt::mt-text)
endif()

if(MT_BUILD_ASSET_PIPELINE_EXAMPLES AND MT_BUILD_ASSET_PIPELINE)
    add_executable(
        mt-example-asset-pipeline
        asset_pipeline/main.swift
    )
    target_link_libraries(
        mt-example-asset-pipeline
        PRIVATE
            mt::mt-asset-pipeline
    )
endif()

if(MT_BUILD_EXTERNAL_RESOURCES)
    add_executable(
        mt-example-external-resources
        external_resource/main.swift
    )
    target_link_libraries(
        mt-example-external-resources
        PRIVATE
            mt::mt-external-resources
    )
endif()

if(MT_BUILD_PYTHON)
    add_custom_target(
        mt-example-python
        SOURCES python_smoke.py
    )
endif()
