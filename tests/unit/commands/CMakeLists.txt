add_executable(mt-test-commands-api api.cpp)
target_link_libraries(mt-test-commands-api PRIVATE mt::mt)
target_compile_features(mt-test-commands-api PRIVATE cxx_std_20)

add_test(
    NAME mt.unit.commands.api
    COMMAND mt-test-commands-api
)

