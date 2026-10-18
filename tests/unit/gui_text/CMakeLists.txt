if(MT_BUILD_IMGUI)
    add_executable(mt-test-imgui-api imgui_api.cpp)
    target_link_libraries(mt-test-imgui-api PRIVATE mt::mt-imgui)
    target_compile_features(mt-test-imgui-api PRIVATE cxx_std_20)
    add_test(
        NAME mt.unit.gui_text.imgui
        COMMAND mt-test-imgui-api
    )
endif()

if(MT_BUILD_TEXT)
    add_executable(mt-test-text-api text_api.cpp)
    target_link_libraries(mt-test-text-api PRIVATE mt::mt-text)
    target_compile_features(mt-test-text-api PRIVATE cxx_std_20)
    add_test(
        NAME mt.unit.gui_text.text
        COMMAND mt-test-text-api
    )
endif()

if(MT_BUILD_FREETYPE_BRIDGE)
    add_executable(mt-test-freetype-api freetype_api.cpp)
    target_link_libraries(mt-test-freetype-api PRIVATE mt::mt-freetype)
    target_compile_features(mt-test-freetype-api PRIVATE cxx_std_20)
    add_test(
        NAME mt.unit.gui_text.freetype
        COMMAND mt-test-freetype-api
    )
endif()
