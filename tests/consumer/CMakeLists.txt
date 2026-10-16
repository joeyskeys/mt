add_executable(mt-test-external-consumer main.cpp)
target_link_libraries(mt-test-external-consumer PRIVATE mt::mt)
target_compile_features(mt-test-external-consumer PRIVATE cxx_std_20)

add_test(
    NAME mt.consumer.external
    COMMAND mt-test-external-consumer
)

