#include <type_traits>

#include <mt/argument_buffer.hpp>
#include <mt/acceleration_structure.hpp>
#include <mt/counter.hpp>
#include <mt/indirect.hpp>
#include <mt/mesh.hpp>
#include <mt/metal.hpp>
#include <mt/profiling.hpp>
#include <mt/ray_tracing.hpp>
#include <mt/tile.hpp>

static_assert(std::is_class_v<mt::MeshShaderCapabilities>);
static_assert(std::is_class_v<mt::ArgumentBufferCapabilities>);
static_assert(std::is_class_v<mt::IndirectCommandCapabilities>);
static_assert(std::is_class_v<mt::TileShaderCapabilities>);
static_assert(std::is_class_v<mt::RayTracingCapabilities>);
static_assert(std::is_class_v<mt::SIMDGroupCapabilities>);
static_assert(std::is_class_v<mt::MetalCapabilityAvailability>);
static_assert(std::is_class_v<mt::MetalCapabilityLimit>);
static_assert(std::is_class_v<mt::MetalCapabilityDiagnostic>);
static_assert(std::is_class_v<mt::AccelerationStructureSizes>);
static_assert(std::is_class_v<mt::CounterDescription>);
static_assert(std::is_class_v<mt::CounterSetDescription>);
static_assert(std::is_class_v<mt::CounterSampleResolution>);
static_assert(std::is_class_v<mt::Extent3D>);
static_assert(std::is_class_v<mt::MeshDispatchDescriptor>);
static_assert(std::is_class_v<mt::IndirectCommandBufferDescriptor>);
static_assert(std::is_class_v<mt::ArgumentBuffer>);
static_assert(std::is_class_v<mt::IndirectCommandBuffer>);
static_assert(std::is_class_v<mt::IndirectRenderCommand>);
static_assert(std::is_class_v<mt::IndirectComputeCommand>);
static_assert(std::is_class_v<mt::TilePipelineDescriptor>);
static_assert(std::is_class_v<mt::TilePipeline>);
static_assert(std::is_class_v<mt::TriangleGeometryDescriptor>);
static_assert(std::is_class_v<mt::MotionTriangleGeometryDescriptor>);
static_assert(std::is_class_v<mt::BoundingBoxGeometryDescriptor>);
static_assert(std::is_class_v<
              mt::PrimitiveAccelerationStructureDescriptor>);
static_assert(std::is_class_v<
              mt::InstanceAccelerationStructureDescriptor>);
static_assert(std::is_class_v<mt::AccelerationStructure>);
static_assert(std::is_class_v<mt::CounterSampleBuffer>);
static_assert(std::is_class_v<mt::IntersectionFunctionTable>);
static_assert(std::is_class_v<mt::AccelerationStructureCommandEncoder>);

int main() {
    return 0;
}

