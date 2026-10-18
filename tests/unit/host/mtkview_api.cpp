#include <type_traits>

#include <mt/mtkview.hpp>

static_assert(std::is_class_v<mt::MTKViewSurfaceConfiguration>);
static_assert(std::is_class_v<mt::MTKViewSurfaceAdapter>);
static_assert(std::is_class_v<mt::MTKViewWindowConfiguration>);
static_assert(std::is_class_v<mt::MTKViewWindowHost>);

int main() {
    return 0;
}

