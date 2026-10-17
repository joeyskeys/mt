#include <type_traits>

#include <mt/buffer.hpp>
#include <mt/heap.hpp>
#include <mt/lifetime.hpp>
#include <mt/sampler.hpp>
#include <mt/synchronization.hpp>
#include <mt/texture.hpp>
#include <mt/transfer.hpp>

static_assert(std::is_class_v<mt::Buffer>);
static_assert(std::is_class_v<mt::BufferSlice>);
static_assert(std::is_class_v<mt::DynamicBufferAllocator>);
static_assert(std::is_class_v<mt::Texture>);
static_assert(std::is_class_v<mt::TextureView>);
static_assert(std::is_class_v<mt::CompletionToken>);
static_assert(std::is_class_v<mt::ResourceRetirementQueue>);
static_assert(std::is_class_v<mt::BufferResourceSlot>);
static_assert(std::is_class_v<mt::TextureResourceSlot>);
static_assert(std::is_class_v<mt::ResourceRegistry>);
static_assert(std::is_class_v<mt::Sampler>);
static_assert(std::is_class_v<mt::RenderTarget>);
static_assert(std::is_class_v<mt::DepthAttachment>);
static_assert(std::is_class_v<mt::Heap>);
static_assert(std::is_class_v<mt::Fence>);
static_assert(std::is_class_v<mt::SharedEvent>);
static_assert(std::is_class_v<mt::BufferRange>);
static_assert(std::is_class_v<mt::TextureRegion>);
static_assert(std::is_class_v<mt::TextureTransferDescriptor>);
static_assert(std::is_class_v<mt::ResourceVersion>);

int main() {
    return 0;
}

