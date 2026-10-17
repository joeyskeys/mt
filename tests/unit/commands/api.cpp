#include <type_traits>

#include <mt/command_buffer.hpp>
#include <mt/command_encoder.hpp>
#include <mt/frame.hpp>
#include <mt/lifetime.hpp>
#include <mt/render_pass.hpp>
#include <mt/surface.hpp>

static_assert(std::is_class_v<mt::CommandBuffer>);
static_assert(std::is_class_v<mt::CompletionToken>);
static_assert(std::is_class_v<mt::RenderEncoder>);
static_assert(std::is_class_v<mt::ComputeEncoder>);
static_assert(std::is_class_v<mt::BlitEncoder>);
static_assert(std::is_class_v<mt::RenderPassDescriptor>);
static_assert(std::is_class_v<mt::Drawable>);
static_assert(std::is_class_v<mt::Surface>);
static_assert(std::is_class_v<mt::Frame>);
static_assert(std::is_class_v<mt::FrameScheduler>);

int main() {
    return 0;
}

