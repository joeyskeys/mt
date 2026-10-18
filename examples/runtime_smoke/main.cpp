#include <iostream>
#include <string_view>

#include <mt/mt.hpp>

namespace {

struct ExampleRequirement {
    std::string_view name;
    std::string_view requirement;
    std::string_view fallback;
};

constexpr ExampleRequirement kRequirements[] = {
    {"device_info", "Metal device enumeration", "report no device"},
    {"offscreen_triangle", "render target and render encoder",
     "skip when no device"},
    {"window_triangle", "AppKit/CAMetalLayer adapter",
     "use offscreen consumer"},
    {"indexed_mesh", "shared vertex/index buffers and depth",
     "use direct vertex draw"},
    {"compute_image", "compute pipeline and blit readback",
     "skip compute path"},
    {"mesh_triangle", "mesh shaders", "use indexed fallback"},
    {"argument_buffer_materials", "argument buffers", "use direct slots"},
    {"gpu_culling", "indirect command buffers", "use CPU culling"},
    {"tile_pass", "tile shaders and memoryless attachments",
     "use stored render pass"},
    {"forward_plus", "Forward+ cluster preparation", "use Forward"},
    {"viewport_picking", "viewport ID pass and readback",
     "use RGBA8 baseline"},
};

const ExampleRequirement* findRequirement(std::string_view name) {
    for (const auto& requirement : kRequirements) {
        if (requirement.name == name) {
            return &requirement;
        }
    }
    return nullptr;
}

bool nativePathAvailable(
    std::string_view name,
    const mt::DeviceCapabilities& capabilities
) {
    if (name == "mesh_triangle") {
        return capabilities.meshShaders();
    }
    if (name == "argument_buffer_materials") {
        return capabilities.maxArgumentBufferSamplerCount() > 0;
    }
    if (name == "gpu_culling") {
        return capabilities.indirectCommandBuffers();
    }
    if (name == "tile_pass") {
        return capabilities.tileShaders()
            && capabilities.memorylessAttachments();
    }
    if (name == "window_triangle") {
        // This executable is deliberately host-neutral. The AppKit adapter is
        // a separate target, so the launcher selects its documented fallback.
        return false;
    }
    return true;
}

} // namespace

int main(int argc, char** argv) {
    const std::string_view name =
        argc > 1 ? std::string_view(argv[1]) : "device_info";
    const auto* requirement = findRequirement(name);
    if (requirement == nullptr) {
        std::cerr << "unknown mt validation example: " << name << '\n';
        return 2;
    }

    std::cout << "example=" << requirement->name << '\n'
              << "requires=" << requirement->requirement << '\n'
              << "fallback=" << requirement->fallback << '\n';

    const auto devices = mt::Device::enumerate();
    auto device = mt::Device::systemDefault();
    std::cout << "device_count=" << devices.size() << '\n';
    if (!device) {
        return devices.empty() ? 0 : 3;
    }

    const auto capabilities = device->capabilities();
    const bool nativePath = nativePathAvailable(name, capabilities);
    std::cout << "native_path=" << (nativePath ? "available" : "unsupported")
              << '\n';
    if (!nativePath) {
        std::cout << "fallback_path=" << requirement->fallback << '\n';
    }

    auto queue = device->createCommandQueue();
    if (!queue) {
        return 4;
    }
    auto commandBuffer = queue->makeCommandBuffer();
    if (!commandBuffer || !commandBuffer->commit()) {
        return 5;
    }
    commandBuffer->waitUntilCompleted();
    return 0;
}
