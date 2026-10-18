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
static_assert(std::is_class_v<mt::MeshView>);
static_assert(std::is_class_v<mt::MeshInstanceData>);
static_assert(std::is_class_v<mt::InstancedMeshFixture>);
static_assert(std::is_enum_v<mt::CurveInterpolation>);
static_assert(std::is_class_v<mt::CurvePoint>);
static_assert(std::is_class_v<mt::Curve>);
static_assert(std::is_class_v<mt::MeshLODLevel>);
static_assert(std::is_class_v<mt::MeshLODMetadata>);
static_assert(std::is_class_v<mt::MeshCullingMetadata>);
static_assert(std::is_class_v<mt::MeshletPayload>);
static_assert(std::is_class_v<mt::MeshVertex>);
static_assert(std::is_class_v<mt::Mesh>);
static_assert(std::is_class_v<mt::MeshGPU>);
static_assert(std::is_class_v<mt::DrawableManager>);
static_assert(std::is_class_v<mt::DrawableSyncResult>);
static_assert(std::is_class_v<mt::Lines>);
static_assert(std::is_class_v<mt::Points>);
static_assert(std::is_class_v<mt::SceneObject>);
static_assert(std::is_class_v<mt::SceneObjectGPUData>);
static_assert(std::is_class_v<mt::SceneSyncResult>);
static_assert(std::is_class_v<mt::SceneGPU>);
static_assert(std::is_class_v<mt::Scene>);
static_assert(std::is_enum_v<mt::MaterialBindingPath>);
static_assert(std::is_enum_v<mt::SamplerFallbackPolicy>);
static_assert(std::is_class_v<mt::MaterialPipelineMetadata>);
static_assert(std::is_class_v<mt::MaterialTextureTable>);
static_assert(std::is_class_v<mt::MaterialSamplerTable>);
static_assert(std::is_class_v<mt::PhongMaterialData>);
static_assert(std::is_class_v<mt::PBRMaterialData>);
static_assert(std::is_class_v<mt::DirectionalShadowMaterialData>);
static_assert(std::is_class_v<mt::BillboardMaterialData>);
static_assert(std::is_class_v<mt::TextMaterialData>);
static_assert(std::is_class_v<mt::MeshVisualizationMaterialData>);
static_assert(std::is_class_v<mt::Material>);
static_assert(std::is_class_v<mt::MaterialManager>);
static_assert(std::is_class_v<mt::Light>);
static_assert(std::is_class_v<mt::LightGPUData>);
static_assert(std::is_class_v<mt::LightClusterData>);
static_assert(std::is_class_v<mt::LightClusterBoundsGPUData>);
static_assert(std::is_class_v<mt::LightClusterAssignmentGPUData>);
static_assert(std::is_class_v<mt::LightClusterResources>);
static_assert(std::is_class_v<mt::ShadowMapDescriptor>);
static_assert(std::is_class_v<mt::ShadowMap>);
static_assert(std::is_class_v<mt::BuiltInFrameData>);
static_assert(std::is_class_v<mt::FixedColorMaterialData>);
static_assert(std::is_class_v<mt::LightManager>);
static_assert(std::is_class_v<mt::BuiltInShaderLayout>);
static_assert(std::is_class_v<mt::MeshObjectShaderLayout>);

int main() {
    return 0;
}

