#include <type_traits>
#include <iostream>

#include <mt/mt.hpp>

static_assert(std::is_class_v<mt::Device>);
static_assert(std::is_class_v<mt::CommandQueue>);
static_assert(std::is_class_v<mt::CommandBuffer>);
static_assert(std::is_class_v<mt::CompletionToken>);
static_assert(std::is_class_v<mt::ResourceRetirementQueue>);
static_assert(std::is_class_v<mt::ResourceRegistry>);
static_assert(std::is_class_v<mt::BufferRange>);
static_assert(std::is_class_v<mt::TextureTransferDescriptor>);
static_assert(std::is_class_v<mt::Renderer>);
static_assert(std::is_class_v<mt::Scene>);
static_assert(std::is_class_v<mt::Viewport>);

int main() {
    std::cout << "mt " << mt::library_version() << '\n';
    return 0;
}

