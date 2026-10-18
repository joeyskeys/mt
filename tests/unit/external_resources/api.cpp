#include <type_traits>

#include <mt/external_resources.hpp>

static_assert(std::is_class_v<mt::ExternalResourceDiagnostic>);
static_assert(std::is_class_v<mt::IOSurfaceTextureDescriptor>);
static_assert(std::is_class_v<mt::IOSurfaceBufferDescriptor>);
static_assert(std::is_class_v<mt::ExternalEventSyncPolicy>);
static_assert(std::is_class_v<mt::ImportedExternalTexture>);
static_assert(std::is_class_v<mt::ImportedExternalBuffer>);
static_assert(std::is_class_v<mt::IOSurfaceResourceImporter>);
static_assert(std::is_class_v<mt::ExternalSharedEventBridge>);

int main() {
    return 0;
}
