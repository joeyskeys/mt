add_executable(mt-test-renderer-api api.cpp)
target_link_libraries(mt-test-renderer-api PRIVATE mt::mt)
target_compile_features(mt-test-renderer-api PRIVATE cxx_std_20)

add_test(
    NAME mt.unit.renderer.api
    COMMAND mt-test-renderer-api
)

