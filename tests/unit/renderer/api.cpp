#include <type_traits>

#include <mt/renderer.hpp>

static_assert(std::is_class_v<mt::RendererPass>);
static_assert(std::is_class_v<mt::RendererBatchKind>);
static_assert(std::is_class_v<mt::RendererFallbackReason>);
static_assert(std::is_class_v<mt::RenderView>);
static_assert(std::is_class_v<mt::ForwardPlusConfiguration>);
static_assert(std::is_class_v<mt::RendererStatistics>);
static_assert(std::is_class_v<mt::RendererPersistentStatistics>);
static_assert(std::is_class_v<mt::RendererPassSchedule>);
static_assert(std::is_class_v<mt::RendererPassInput>);
static_assert(std::is_class_v<mt::SubmissionSelection>);
static_assert(std::is_class_v<mt::ForwardPlusLightCoverage>);
static_assert(std::is_class_v<mt::ForwardPlusClusterBounds>);
static_assert(std::is_class_v<mt::ForwardPlusClusterAssignment>);
static_assert(std::is_class_v<mt::ForwardPlusClusterPlan>);
static_assert(std::is_class_v<mt::ForwardPlusComputeDispatch>);
static_assert(std::is_class_v<mt::ForwardPlusComputeResources>);
static_assert(std::is_class_v<mt::ForwardPlusRenderBindings>);
static_assert(std::is_class_v<mt::RendererLODRange>);
static_assert(std::is_class_v<mt::RendererCullingItem>);
static_assert(std::is_class_v<mt::RendererCullingResult>);
static_assert(std::is_class_v<mt::GPUCullingDispatch>);
static_assert(std::is_class_v<mt::MeshletDescriptor>);
static_assert(std::is_class_v<mt::RenderBatch>);
static_assert(std::is_class_v<mt::MeshletGPU>);
static_assert(std::is_class_v<mt::Renderer>);

int main() {
    return 0;
}

