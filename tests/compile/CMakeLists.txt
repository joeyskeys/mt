add_executable(mt-test-public-headers public_headers.cpp)
target_link_libraries(mt-test-public-headers PRIVATE mt::mt)
target_compile_features(mt-test-public-headers PRIVATE cxx_std_20)

add_test(
    NAME mt.compile.public_headers
    COMMAND mt-test-public-headers
)

