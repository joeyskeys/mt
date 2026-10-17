#include <type_traits>

#include <mt/binding.hpp>
#include <mt/binary_archive.hpp>
#include <mt/depth_stencil.hpp>
#include <mt/pipeline.hpp>
#include <mt/pipeline_cache.hpp>
#include <mt/shader.hpp>

static_assert(std::is_class_v<mt::FunctionConstants>);
static_assert(std::is_class_v<mt::ParameterBlock>);
static_assert(std::is_class_v<mt::ShaderFunction>);
static_assert(std::is_class_v<mt::ShaderLibrary>);
static_assert(std::is_class_v<mt::BindingLayout>);
static_assert(std::is_class_v<mt::PipelineReflection>);
static_assert(std::is_class_v<mt::StencilFaceDescriptor>);
static_assert(std::is_class_v<mt::DepthStencilDescriptor>);
static_assert(std::is_class_v<mt::PipelineCacheKey>);
static_assert(std::is_class_v<mt::DepthStencilState>);
static_assert(std::is_class_v<mt::LinkedFunctions>);
static_assert(std::is_class_v<mt::DynamicLibrary>);
static_assert(std::is_class_v<mt::BinaryArchive>);
static_assert(std::is_class_v<mt::PipelineCache>);
static_assert(std::is_class_v<mt::ArgumentBufferTable>);
static_assert(std::is_class_v<mt::RenderPipelineDescriptor>);
static_assert(std::is_class_v<mt::ComputePipelineDescriptor>);
static_assert(std::is_class_v<mt::RenderPipeline>);
static_assert(std::is_class_v<mt::ComputePipeline>);

int main() {
    return 0;
}

