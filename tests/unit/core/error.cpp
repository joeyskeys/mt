#include <cassert>
#include <string_view>

#include <mt/error.hpp>

int main() {
    const mt::Error error(
        mt::ErrorCode::not_supported,
        "mesh shaders are unavailable",
        "create_mesh_pipeline");

    assert(error);
    assert(error.code() == mt::ErrorCode::not_supported);
    assert(error.message() == std::string_view("mesh shaders are unavailable"));
    assert(error.operation() == std::string_view("create_mesh_pipeline"));
    assert(mt::error_code_name(error.code()) == "not_supported");

    const mt::Error empty;
    assert(!empty);

    return 0;
}

