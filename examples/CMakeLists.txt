add_executable(mt-example-consumer-smoke consumer_smoke/main.cpp)
target_link_libraries(mt-example-consumer-smoke PRIVATE mt::mt)
target_compile_features(mt-example-consumer-smoke PRIVATE cxx_std_20)

