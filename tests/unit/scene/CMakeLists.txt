add_executable(mt-test-scene-api api.cpp)
target_link_libraries(mt-test-scene-api PRIVATE mt::mt)
target_compile_features(mt-test-scene-api PRIVATE cxx_std_20)

add_test(
    NAME mt.unit.scene.api
    COMMAND mt-test-scene-api
)

add_executable(mt-test-scene-layout layout.cpp)
target_link_libraries(mt-test-scene-layout PRIVATE mt::mt)
target_compile_features(mt-test-scene-layout PRIVATE cxx_std_20)

add_test(
    NAME mt.unit.scene.layout
    COMMAND mt-test-scene-layout
)
