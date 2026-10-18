#include <type_traits>

#include <mt/mt.hpp>

#if defined(MT_INSTALLED_HAS_APPKIT)
#include <mt/appkit.hpp>
#endif

#if defined(MT_INSTALLED_HAS_MTKVIEW)
#include <mt/mtkview.hpp>
#endif

static_assert(std::is_class_v<mt::Device>);

#if defined(MT_INSTALLED_HAS_APPKIT)
static_assert(std::is_class_v<mt::AppKitSurfaceAdapter>);
static_assert(std::is_class_v<mt::AppKitWindowHost>);
static_assert(std::is_class_v<mt::AppKitInputTranslator>);
#endif

#if defined(MT_INSTALLED_HAS_MTKVIEW)
static_assert(std::is_class_v<mt::MTKViewSurfaceAdapter>);
static_assert(std::is_class_v<mt::MTKViewWindowHost>);
#endif

int main() {
    return mt::library_version() == nullptr ? 1 : 0;
}
