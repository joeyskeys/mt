add_executable(mt-test-resources-api api.cpp)
target_link_libraries(mt-test-resources-api PRIVATE mt::mt)
target_compile_features(mt-test-resources-api PRIVATE cxx_std_20)

add_test(
    NAME mt.unit.resources.api
    COMMAND mt-test-resources-api
)

