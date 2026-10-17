#include <array>
#include <cstdint>
#include <type_traits>

#include <mt/built_in_shaders.hpp>

// These host-side layouts intentionally mirror mesh_object.metal. Keep the
// definitions simple and standard-layout so a future metallib reflection
// test can compare them against the compiled MSL types.
struct MTMeshObjectPayload {
    std::uint32_t objectIndex;
};

struct alignas(16) MTMeshVertex {
    std::array<float, 4> position;
};

static_assert(std::is_standard_layout_v<MTMeshObjectPayload>);
static_assert(std::is_standard_layout_v<MTMeshVertex>);
static_assert(sizeof(MTMeshObjectPayload) == 4);
static_assert(alignof(MTMeshVertex) == 16);
static_assert(sizeof(MTMeshVertex) == 16);
static_assert(std::is_class_v<mt::MeshObjectShaderLayout>);

int main() {
    return 0;
}
