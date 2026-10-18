#include <array>
#include <cstdint>
#include <type_traits>

#include <mt/built_in_shaders.hpp>
#include <mt/scene.hpp>

struct MTSceneObjectGPUData {
    std::array<float, 9> transform;
    std::uint32_t materialIDLow;
    std::uint32_t materialIDHigh;
    std::uint32_t visibilityMask;
    std::uint32_t enabled;
    std::array<std::uint32_t, 3> reserved;
};

struct MTMaterialColor {
    std::array<float, 4> color;
};

struct MTPhongMaterial {
    std::array<float, 4> baseColor;
    std::array<float, 4> specularColor;
    std::array<float, 4> scalarData;
};

struct MTPBRMaterial {
    std::array<float, 4> baseColor;
    std::array<float, 4> emissiveColor;
    std::array<float, 4> scalarData;
};

struct MTShadowMaterial {
    std::array<float, 16> lightViewProjection;
    std::array<float, 4> bias;
};

struct MTClusterAssignment {
    std::uint32_t lightOffset;
    std::uint32_t lightCount;
    std::uint32_t overflow;
    std::uint32_t reserved;
};

static_assert(std::is_standard_layout_v<MTSceneObjectGPUData>);
static_assert(std::is_standard_layout_v<MTPhongMaterial>);
static_assert(std::is_standard_layout_v<MTPBRMaterial>);
static_assert(std::is_standard_layout_v<MTShadowMaterial>);
static_assert(sizeof(MTSceneObjectGPUData) == 64);
static_assert(sizeof(MTMaterialColor) == 16);
static_assert(sizeof(MTPhongMaterial) == 48);
static_assert(sizeof(MTPBRMaterial) == 48);
static_assert(sizeof(MTShadowMaterial) == 80);
static_assert(sizeof(MTClusterAssignment) == 16);
static_assert(std::is_class_v<mt::BuiltInShaderLayout>);
static_assert(std::is_class_v<mt::SceneObjectGPUData>);

int main() {
    return 0;
}
