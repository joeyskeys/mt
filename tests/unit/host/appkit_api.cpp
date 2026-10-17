#include <type_traits>

#include <mt/appkit.hpp>

static_assert(std::is_class_v<mt::AppKitSurfaceConfiguration>);
static_assert(std::is_class_v<mt::AppKitSurfaceAdapter>);

int main() {
    return 0;
}

