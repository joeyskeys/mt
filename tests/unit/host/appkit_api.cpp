#include <type_traits>

#include <mt/appkit.hpp>

static_assert(std::is_class_v<mt::AppKitSurfaceConfiguration>);
static_assert(std::is_class_v<mt::AppKitSurfaceAdapter>);
static_assert(std::is_class_v<mt::AppKitWindowConfiguration>);
static_assert(std::is_class_v<mt::AppKitWindowHost>);
static_assert(std::is_class_v<mt::AppKitInputTranslator>);

int main() {
    return 0;
}

