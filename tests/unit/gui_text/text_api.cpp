#include <type_traits>

#include <mt/text.hpp>

static_assert(std::is_class_v<mt::CoreTextFont>);
static_assert(std::is_class_v<mt::TextAtlas>);
static_assert(std::is_class_v<mt::TextAtlasRegion>);
static_assert(std::is_class_v<mt::TextLayout>);
static_assert(std::is_class_v<mt::TextMesh>);
static_assert(std::is_class_v<mt::TextMeshGPU>);
static_assert(std::is_class_v<mt::TextMeshBuilder>);

int main() {
    return 0;
}
