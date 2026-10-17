add_executable(mt-test-shaders-api api.cpp)
target_link_libraries(mt-test-shaders-api PRIVATE mt::mt)
target_compile_features(mt-test-shaders-api PRIVATE cxx_std_20)

add_executable(mt-test-shaders-layout layout.cpp)
target_link_libraries(mt-test-shaders-layout PRIVATE mt::mt)
target_compile_features(mt-test-shaders-layout PRIVATE cxx_std_20)

add_test(
    NAME mt.unit.shaders.api
    COMMAND mt-test-shaders-api
)

add_test(
    NAME mt.unit.shaders.layout
    COMMAND mt-test-shaders-layout
)

