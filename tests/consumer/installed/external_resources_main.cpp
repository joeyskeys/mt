#include <type_traits>

#include <mt/external_resources.hpp>

#if !defined(MT_INSTALLED_HAS_EXTERNAL_RESOURCES)
#error "The installed external-resource target was not linked."
#endif

static_assert(std::is_class_v<mt::IOSurfaceTextureDescriptor>);
static_assert(std::is_class_v<mt::IOSurfaceBufferDescriptor>);
static_assert(std::is_class_v<mt::ExternalSharedEventBridge>);

int main() {
    const mt::ExternalEventSyncPolicy policy =
        mt::ExternalEventSyncPolicy::none();
    return policy.isValid() ? 0 : 1;
}
