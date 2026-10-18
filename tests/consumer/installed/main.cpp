#include <mt/mt.hpp>

int main() {
    if (mt::library_version() == nullptr) {
        return 1;
    }

    const auto devices = mt::Device::enumerate();
    auto device = mt::Device::systemDefault();
    if (devices.empty()) {
        return device ? 2 : 0;
    }
    if (!device) {
        return 3;
    }

    auto queue = device->createCommandQueue();
    if (!queue) {
        return 4;
    }
    auto commandBuffer = queue->makeCommandBuffer();
    if (!commandBuffer) {
        return 5;
    }

    // This is intentionally an encoder-free submission. It proves that the
    // installed target can cross the Swift/C++ boundary, enumerate a real
    // device, create a queue and command buffer, and submit work without
    // depending on source-tree headers or a window system.
    if (!commandBuffer->commit()) {
        return 6;
    }
    commandBuffer->waitUntilCompleted();
    if (!commandBuffer->didSucceed()) {
        return 7;
    }

    // This fixture executes a baseline offscreen clear and reads the result
    // back through the installed Swift implementation. It is intentionally
    // headless and uses the fixture's managed/shared fallback for the target
    // storage mode, so the consumer remains valid across Mac GPU families.
    if (!mt::OffscreenValidationFixture::validateClearReadback(*device)) {
        return 8;
    }
    return 0;
}

