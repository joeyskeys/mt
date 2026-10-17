#include <type_traits>

#include <mt/mt.hpp>

static_assert(std::is_class_v<mt::Device>);
static_assert(std::is_class_v<mt::CompletionToken>);
static_assert(std::is_class_v<mt::ResourceRetirementQueue>);
static_assert(std::is_class_v<mt::TextureRegion>);
static_assert(std::is_class_v<mt::Renderer>);
static_assert(std::is_class_v<mt::Viewport>);
static_assert(std::is_class_v<mt::PipelineCache>);
static_assert(std::is_class_v<mt::BinaryArchive>);
static_assert(std::is_class_v<mt::MeshObjectShaderLayout>);

int main() {
    return mt::library_version() == nullptr ? 1 : 0;
}

