import XCTest
@testable import MTCore

final class ResourcesTests: XCTestCase {
    func testBufferCreationMappingSlicesAndDynamicAllocation() {
        guard let device = Device.systemDefault() else {
            return
        }

        let descriptor = BufferDescriptor(
            length: 256,
            usage: UInt32(
                BufferUsage.uniform.rawValue | BufferUsage.storage.rawValue
            ),
            storageMode: .shared,
            cpuCacheMode: .defaultCache,
            hazardMode: .defaultMode,
            label: "mt buffer test"
        )
        guard let buffer = device.createBuffer(descriptor) else {
            XCTFail("A shared buffer should be creatable.")
            return
        }

        XCTAssertEqual(buffer.length, 256)
        XCTAssertEqual(buffer.storageMode, .shared)
        XCTAssertTrue(buffer.isCPUVisible)
        XCTAssertNotNil(buffer.map())

        var source = Array(repeating: UInt8(7), count: 32)
        var destination = Array(repeating: UInt8(0), count: 32)
        source.withUnsafeBytes { bytes in
            XCTAssertTrue(
                buffer.upload(
                    source: bytes.baseAddress!,
                    length: UInt64(bytes.count),
                    offset: 16
                )
            )
        }
        destination.withUnsafeMutableBytes { bytes in
            XCTAssertTrue(
                buffer.read(
                    destination: bytes.baseAddress!,
                    length: UInt64(bytes.count),
                    offset: 16
                )
            )
        }
        XCTAssertEqual(destination, source)

        guard let slice = buffer.makeSlice(offset: 16, length: 32) else {
            XCTFail("A valid buffer slice should be creatable.")
            return
        }
        XCTAssertEqual(slice.offset, 16)
        XCTAssertEqual(slice.length, 32)
        XCTAssertNotNil(slice.map())
        XCTAssertNil(buffer.makeSlice(offset: 240, length: 32))

        guard let allocator = device.createDynamicBuffer(
            capacity: 256,
            alignment: 64,
            label: "mt dynamic buffer"
        ) else {
            XCTFail("A dynamic buffer allocator should be creatable.")
            return
        }
        XCTAssertEqual(allocator.allocate(length: 1)?.offset, 0)
        XCTAssertEqual(allocator.allocate(length: 1)?.offset, 64)
        allocator.reset()
        XCTAssertEqual(allocator.used, 0)
    }

    func testTextureSamplerAndAttachmentDescriptors() {
        guard let device = Device.systemDefault() else {
            return
        }

        let textureDescriptor = TextureDescriptor(
            textureType: .twoD,
            pixelFormat: .rgba8Unorm,
            width: 16,
            height: 16,
            depth: 1,
            arrayLength: 1,
            mipLevelCount: 1,
            sampleCount: 1,
            usage: UInt32(
                TextureUsage.shaderRead.rawValue
                    | TextureUsage.shaderWrite.rawValue
                    | TextureUsage.renderTarget.rawValue
                    | TextureUsage.pixelFormatView.rawValue
            ),
            storageMode: .shared,
            cpuCacheMode: .defaultCache,
            hazardMode: .defaultMode,
            label: "mt texture test"
        )
        guard let texture = device.createTexture(textureDescriptor) else {
            XCTFail("A shared texture should be creatable.")
            return
        }

        XCTAssertEqual(texture.textureType, .twoD)
        XCTAssertEqual(texture.pixelFormat, .rgba8Unorm)
        XCTAssertEqual(texture.width, 16)
        XCTAssertEqual(texture.height, 16)
        XCTAssertEqual(texture.sampleCount, 1)
        XCTAssertTrue(texture.isCPUVisibleTexture)
        XCTAssertNotNil(texture.makeView(pixelFormat: .rgba8Unorm))

        let rowBytes = 16 * 4
        var source = Array(repeating: UInt8(3), count: rowBytes * 16)
        var destination = Array(repeating: UInt8(0), count: rowBytes * 16)
        source.withUnsafeBytes { bytes in
            XCTAssertTrue(
                texture.replaceBaseLevel2D(
                    source: bytes.baseAddress!,
                    bytesPerRow: UInt64(rowBytes),
                    bytesPerImage: UInt64(source.count)
                )
            )
        }
        destination.withUnsafeMutableBytes { bytes in
            XCTAssertTrue(
                texture.readBaseLevel2D(
                    destination: bytes.baseAddress!,
                    bytesPerRow: UInt64(rowBytes),
                    bytesPerImage: UInt64(destination.count)
                )
            )
        }
        XCTAssertEqual(destination, source)

        let samplerDescriptor = SamplerDescriptor(
            minFilter: .linear,
            magFilter: .linear,
            mipFilter: .notMipmapped,
            addressModeS: .clampToEdge,
            addressModeT: .clampToEdge,
            addressModeR: .clampToEdge,
            compareFunction: .always,
            maxAnisotropy: 1,
            lodMinClamp: 0,
            lodMaxClamp: 16,
            label: "mt sampler test"
        )
        XCTAssertNotNil(device.createSampler(samplerDescriptor))

        let target = RenderTarget(texture: texture)
        let renderPass = RenderPassDescriptor(colorTexture: texture)
        XCTAssertTrue(renderPass.setColorAttachment(target))

        let depthDescriptor = TextureDescriptor(
            textureType: .twoD,
            pixelFormat: .depth32Float,
            width: 16,
            height: 16,
            depth: 1,
            arrayLength: 1,
            mipLevelCount: 1,
            sampleCount: 1,
            usage: UInt32(TextureUsage.renderTarget.rawValue),
            storageMode: .gpuPrivate,
            cpuCacheMode: .defaultCache,
            hazardMode: .defaultMode,
            label: "mt depth test"
        )
        if let depthTexture = device.createTexture(depthDescriptor) {
            let depth = DepthAttachment(
                texture: depthTexture,
                loadAction: .clear,
                storeAction: .dontCare,
                clearDepth: 1
            )
            XCTAssertTrue(renderPass.setDepthAttachment(depth))
            XCTAssertTrue(renderPass.hasDepthAttachment)
            XCTAssertTrue(renderPass.validate())
        }
    }

    func testHeapAndSynchronizationObjects() {
        guard let device = Device.systemDefault() else {
            return
        }

        let heapDescriptor = HeapDescriptor(
            size: 1024 * 1024,
            storageMode: .gpuPrivate,
            cpuCacheMode: .defaultCache,
            hazardMode: .defaultMode,
            label: "mt heap test"
        )
        if let heap = device.createHeap(heapDescriptor) {
            XCTAssertGreaterThanOrEqual(
                heap.maxAvailableSize(alignment: 256),
                0
            )
        }

        let fence = device.createFence(label: "mt fence test")
        let event = device.createSharedEvent(label: "mt event test")
        XCTAssertNotNil(fence)
        XCTAssertNotNil(event)
        XCTAssertEqual(event?.signaledValue, 0)
    }

    func testResourceUsageFencesAndSharedEventsEncodeExplicitly() {
        guard let device = Device.systemDefault(),
              let queue = device.createCommandQueue(),
              let commandBuffer = queue.makeCommandBuffer(),
              let fence = device.createFence(label: "mt encoder fence"),
              let event = device.createSharedEvent(label: "mt encoder event")
        else {
            return
        }

        let bufferDescriptor = BufferDescriptor(
            length: 256,
            usage: UInt32(BufferUsage.storage.rawValue),
            storageMode: .shared,
            cpuCacheMode: .defaultCache,
            hazardMode: .defaultMode,
            label: "mt encoder buffer"
        )
        let textureDescriptor = TextureDescriptor(
            textureType: .twoD,
            pixelFormat: .rgba8Unorm,
            width: 8,
            height: 8,
            depth: 1,
            arrayLength: 1,
            mipLevelCount: 1,
            sampleCount: 1,
            usage: UInt32(
                TextureUsage.shaderRead.rawValue
                    | TextureUsage.renderTarget.rawValue
            ),
            storageMode: .gpuPrivate,
            cpuCacheMode: .defaultCache,
            hazardMode: .defaultMode,
            label: "mt encoder texture"
        )
        guard let buffer = device.createBuffer(bufferDescriptor),
              let texture = device.createTexture(textureDescriptor)
        else {
            return
        }
        let pass = RenderPassDescriptor(colorTexture: texture)
        guard let encoder = commandBuffer.makeRenderEncoder(pass) else {
            return
        }

        XCTAssertTrue(encoder.useBuffer(buffer, usage: .readWrite))
        XCTAssertTrue(encoder.useTexture(texture, usage: .read))
        XCTAssertTrue(encoder.updateFence(fence))
        XCTAssertTrue(encoder.endEncoding())
        guard let compute = commandBuffer.makeComputeEncoder() else {
            return
        }
        XCTAssertTrue(compute.waitForFence(fence))
        XCTAssertTrue(compute.endEncoding())
        XCTAssertTrue(commandBuffer.signal(event, value: 1))
        XCTAssertTrue(commandBuffer.waitFor(event, value: 1))
        XCTAssertTrue(commandBuffer.commit())
    }
}

