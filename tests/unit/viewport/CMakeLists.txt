add_executable(mt-test-viewport-api api.cpp)
target_link_libraries(mt-test-viewport-api PRIVATE mt::mt)
target_compile_features(mt-test-viewport-api PRIVATE cxx_std_20)

add_test(
    NAME mt.unit.viewport.api
    COMMAND mt-test-viewport-api
)

