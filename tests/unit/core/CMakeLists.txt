function(mt_add_core_test name source)
    add_executable(mt-test-${name} ${source})
    target_link_libraries(mt-test-${name} PRIVATE mt::mt)
    target_compile_features(mt-test-${name} PRIVATE cxx_std_20)

    add_test(
        NAME mt.unit.core.${name}
        COMMAND mt-test-${name}
    )
endfunction()

mt_add_core_test(error error.cpp)
mt_add_core_test(result result.cpp)
mt_add_core_test(native_handle native_handle.cpp)

