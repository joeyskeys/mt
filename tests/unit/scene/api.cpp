#include <type_traits>

#include <mt/assets.hpp>
#include <mt/built_in_shaders.hpp>
#include <mt/lights.hpp>
#include <mt/material.hpp>
#include <mt/scene.hpp>

static_assert(std::is_class_v<mt::Vector2>);
static_assert(std::is_class_v<mt::Vector3>);
static_assert(std::is_class_v<mt::Vector4>);
static_assert(std::is_class_v<mt::Matrix4x4>);
static_assert(std::is_class_v<mt::Transform>);
static_assert(std::is_class_v<mt::MeshVertex>);
static_assert(std::is_class_v<mt::Mesh>);
static_assert(std::is_class_v<mt::MeshGPU>);
static_assert(std::is_class_v<mt::DrawableManager>);
static_assert(std::is_class_v<mt::Lines>);
static_assert(std::is_class_v<mt::Points>);
static_assert(std::is_class_v<mt::SceneObject>);
static_assert(std::is_class_v<mt::Scene>);
static_assert(std::is_class_v<mt::Material>);
static_assert(std::is_class_v<mt::MaterialManager>);
static_assert(std::is_class_v<mt::Light>);
static_assert(std::is_class_v<mt::LightGPUData>);
static_assert(std::is_class_v<mt::BuiltInFrameData>);
static_assert(std::is_class_v<mt::FixedColorMaterialData>);
static_assert(std::is_class_v<mt::LightManager>);
static_assert(std::is_class_v<mt::BuiltInShaderLayout>);
static_assert(std::is_class_v<mt::MeshObjectShaderLayout>);

int main() {
    return 0;
}

