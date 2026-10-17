add_executable(mt-test-metal-api api.cpp)
target_link_libraries(mt-test-metal-api PRIVATE mt::mt)
target_compile_features(mt-test-metal-api PRIVATE cxx_std_20)

add_test(
    NAME mt.unit.metal.api
    COMMAND mt-test-metal-api
)

