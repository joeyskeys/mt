import XCTest
@testable import MTCore

final class MetalFeaturesTests: XCTestCase {
    private let argumentBufferSource = """
    #include <metal_stdlib>
    using namespace metal;

    struct ArgumentData {
        device float *values [[id(0)]];
        texture2d<float> color [[id(1)]];
        sampler linearSampler [[id(2)]];
    };

    kernel void mt_argument_kernel(
        constant ArgumentData &args [[buffer(0)]],
        uint id [[thread_position_in_grid]]
    ) {
        if (id == 0) {
            args.values[0] = args.color.sample(
                args.linearSampler,
                float2(0.5)
            ).r;
        }
    }
    """

    func testFeatureRecordsExposeMetalNativeLimits() {
        guard let device = Device.systemDefault() else {
            return
        }

        let capabilities = device.capabilities
        let mesh = capabilities.meshShaderCapabilities
        let arguments = capabilities.argumentBufferCapabilities
        let indirect = capabilities.indirectCommandCapabilities
        let tile = capabilities.tileShaderCapabilities
        let rayTracing = capabilities.rayTracingCapabilities

        XCTAssertEqual(mesh.supported, capabilities.meshShaders)
        XCTAssertEqual(
            arguments.supported,
            capabilities.argumentBufferTier != .unsupported
        )
        XCTAssertEqual(indirect.supported, capabilities.indirectCommandBuffers)
        XCTAssertEqual(tile.supported, capabilities.tileShaders)
        XCTAssertEqual(rayTracing.supported, capabilities.rayTracing)
        XCTAssertGreaterThan(capabilities.maxThreadsPerThreadgroup, 0)
    }

    func testArgumentBufferEncodingIsCapabilityGated() {
        guard let device = Device.systemDefault(),
              let library = device.createShaderLibraryFromSource(
                  source: argumentBufferSource,
                  label: "mt argument buffer test"
              ),
              let function = library.function("mt_argument_kernel")
        else {
            return
        }

        guard device.capabilities.argumentBufferCapabilities.supported else {
            return
        }
        guard let argumentBuffer = device.createArgumentBuffer(
            function: function,
            bufferIndex: 0,
            storageMode: .shared,
            label: "mt argument buffer"
        ) else {
            XCTFail(device.errorDescription)
            return
        }

        XCTAssertGreaterThan(argumentBuffer.encodedLength, 0)
        XCTAssertGreaterThan(argumentBuffer.alignment, 0)

        let bufferDescriptor = BufferDescriptor(
            length: 16,
            usage: UInt32(BufferUsage.storage.rawValue),
            storageMode: .shared,
            cpuCacheMode: .defaultCache,
            hazardMode: .defaultMode,
            label: "mt argument data"
        )
        guard let buffer = device.createBuffer(bufferDescriptor) else {
            return
        }
        XCTAssertTrue(argumentBuffer.setBuffer(buffer, offset: 0, index: 0))

        let textureDescriptor = TextureDescriptor(
            textureType: .twoD,
            pixelFormat: .rgba8Unorm,
            width: 1,
            height: 1,
            depth: 1,
            arrayLength: 1,
            mipLevelCount: 1,
            sampleCount: 1,
            usage: UInt32(TextureUsage.shaderRead.rawValue),
            storageMode: .gpuPrivate,
            cpuCacheMode: .defaultCache,
            hazardMode: .defaultMode,
            label: "mt argument texture"
        )
        guard let texture = device.createTexture(textureDescriptor) else {
            return
        }
        XCTAssertTrue(argumentBuffer.setTexture(texture, index: 1))

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
            lodMaxClamp: 1,
            label: "mt argument sampler"
        )
        guard let sampler = device.createSampler(samplerDescriptor) else {
            return
        }
        XCTAssertTrue(argumentBuffer.setSampler(sampler, index: 2))
    }

    func testIndirectCommandBufferIsCapabilityGated() {
        guard let device = Device.systemDefault(),
              device.capabilities.indirectCommandBuffers else {
            return
        }

        let descriptor = IndirectCommandBufferDescriptor(
            commandTypes: UInt32(IndirectCommandType.draw.rawValue),
            inheritBuffers: false,
            inheritPipelineState: false,
            maxCommandCount: 4,
            maxVertexBufferBindCount: 1,
            maxFragmentBufferBindCount: 1,
            maxKernelBufferBindCount: 1,
            label: "mt indirect commands"
        )
        guard let commands = device.createIndirectCommandBuffer(descriptor)
        else {
            XCTFail(device.errorDescription)
            return
        }

        XCTAssertEqual(commands.maxCommandCount, 4)
        XCTAssertTrue(commands.reset(rangeStart: 0, count: 4))
        XCTAssertNotNil(commands.renderCommand(0))
        XCTAssertNil(commands.renderCommand(4))
    }

    func testMeshAndTileDescriptorsValidateBeforeRuntimeUse() {
        let mesh = MeshDispatchDescriptor(
            threadgroups: Extent3D(width: 1, height: 1, depth: 1),
            threadsPerObjectGroup: Extent3D(width: 32, height: 1, depth: 1),
            threadsPerMeshGroup: Extent3D(width: 32, height: 1, depth: 1)
        )
        XCTAssertEqual(mesh.threadgroups.width, 1)

        let tile = TilePipelineDescriptor()
        XCTAssertTrue(tile.setColorAttachment(.rgba8Unorm, index: 0))
        XCTAssertFalse(tile.setColorAttachment(.invalid, index: 0))
        XCTAssertFalse(tile.setColorAttachment(.rgba8Unorm, index: 8))
    }

    func testCapabilityRecordsDistinguishUnknownAndMeasuredZero() {
        let unknown = MetalCapabilityLimit.unknown
        let measuredZero = MetalCapabilityLimit.measured(0)

        XCTAssertFalse(unknown.known)
        XCTAssertEqual(unknown.value, 0)
        XCTAssertTrue(measuredZero.known)
        XCTAssertEqual(measuredZero.value, 0)
    }

    func testDeviceCapabilityRecordsExposeAvailabilityProvenance() {
        guard let device = Device.systemDefault() else {
            return
        }

        let availability = device.capabilities.availability(
            for: .rayTracing
        )
        XCTAssertNotEqual(availability.state, .unknown)
        XCTAssertGreaterThan(availability.operatingSystemMajor, 0)
        XCTAssertFalse(availability.source.isEmpty)
        XCTAssertEqual(
            availability.isUsable,
            device.capabilities.rayTracing
        )
        XCTAssertFalse(
            device.capabilities.meshShaderCapabilities.payloadLimit.known
        )
        XCTAssertEqual(
            device.capabilities.simdGroupCapabilities.supported,
            device.capabilities.supports(.simdGroups)
        )
    }

    func testNativeRayTracingDescriptorsRejectInvalidRanges() {
        let triangle = TriangleGeometryDescriptor()
        XCTAssertFalse(triangle.validate())
        XCTAssertFalse(triangle.validationError.isEmpty)

        let primitive = PrimitiveAccelerationStructureDescriptor()
        XCTAssertFalse(primitive.addTriangleGeometry(triangle))
        XCTAssertEqual(primitive.geometryCount, 0)

        let instance = InstanceAccelerationStructureDescriptor()
        XCTAssertFalse(instance.validate())
        XCTAssertFalse(instance.validationError.isEmpty)
    }

    func testMotionGeometryRequiresMultipleKeyframes() {
        let motion = MotionTriangleGeometryDescriptor()
        XCTAssertFalse(motion.validate())
        XCTAssertEqual(motion.keyframeCount, 0)
        XCTAssertFalse(motion.validationError.isEmpty)
    }

    func testCounterResolutionValueIsCppSafe() {
        let resolution = CounterSampleResolution(
            rangeStart: 2,
            sampleCount: 3,
            data: [1, 2, 3, 4]
        )
        XCTAssertEqual(resolution.rangeStart, 2)
        XCTAssertEqual(resolution.sampleCount, 3)
        XCTAssertEqual(resolution.data.count, 4)
    }

    func testCounterSampleBufferIsCapabilityGatedAndPollable() {
        guard let device = Device.systemDefault(),
              device.capabilities.counterSampling,
              let counterSet = device.counterSetDescriptions().first,
              let sampleBuffer = device.createCounterSampleBuffer(
                  counterSetName: counterSet.name,
                  sampleCount: 2,
                  storageMode: .shared,
                  label: "mt counter samples"
              ) else {
            return
        }

        XCTAssertEqual(sampleBuffer.sampleCount, 2)
        XCTAssertTrue(sampleBuffer.isCPUReadable)
        _ = sampleBuffer.resolve(rangeStart: 0, sampleCount: 2)
    }

    func testTileDescriptorExposesNativeThreadLimit() {
        let descriptor = TilePipelineDescriptor()
        descriptor.maxTotalThreadsPerThreadgroup = 64
        XCTAssertTrue(descriptor.validate())
        XCTAssertEqual(descriptor.maxTotalThreadsPerThreadgroup, 64)
    }

    func testMemorylessTexturesRejectCpuOrShaderUsage() {
        guard let device = Device.systemDefault(),
              device.capabilities.memorylessAttachments else {
            return
        }

        let descriptor = TextureDescriptor(
            textureType: .twoD,
            pixelFormat: .rgba8Unorm,
            width: 4,
            height: 4,
            depth: 1,
            arrayLength: 1,
            mipLevelCount: 1,
            sampleCount: 1,
            usage: UInt32(
                TextureUsage.renderTarget.rawValue
                    | TextureUsage.shaderRead.rawValue
            ),
            storageMode: .memoryless,
            cpuCacheMode: .defaultCache,
            hazardMode: .defaultMode,
            label: "invalid memoryless"
        )
        XCTAssertNil(device.createTexture(descriptor))
        XCTAssertEqual(
            device.lastCapabilityDiagnostic.kind,
            .invalid
        )
    }

    func testMemorylessRenderPassRejectsPersistentStoreAction() {
        guard let device = Device.systemDefault(),
              device.capabilities.memorylessAttachments,
              let texture = device.createTexture(
                  TextureDescriptor(
                      textureType: .twoD,
                      pixelFormat: .rgba8Unorm,
                      width: 4,
                      height: 4,
                      depth: 1,
                      arrayLength: 1,
                      mipLevelCount: 1,
                      sampleCount: 1,
                      usage: UInt32(TextureUsage.renderTarget.rawValue),
                      storageMode: .memoryless,
                      cpuCacheMode: .defaultCache,
                      hazardMode: .defaultMode,
                      label: "memoryless render pass"
                  )
              ) else {
            return
        }

        let renderPass = RenderPassDescriptor(colorTexture: texture)
        renderPass.colorStoreAction = .store
        XCTAssertFalse(renderPass.validate())
        XCTAssertFalse(renderPass.validationError.isEmpty)
        renderPass.colorStoreAction = .dontCare
        renderPass.imageblockSampleLength = 128
        renderPass.threadgroupMemoryLength = 256
        renderPass.tileWidth = 16
        renderPass.tileHeight = 16
        XCTAssertTrue(renderPass.validate())
    }

    func testUnsupportedNativeRayTracingDoesNotFallBackSilently() {
        guard let device = Device.systemDefault(),
              !device.capabilities.rayTracing else {
            return
        }

        let descriptor = PrimitiveAccelerationStructureDescriptor()
        XCTAssertNil(device.accelerationStructureSizes(descriptor))
        XCTAssertEqual(
            device.lastCapabilityDiagnostic.kind,
            .unsupported
        )
        XCTAssertEqual(
            device.lastCapabilityDiagnostic.feature,
            .rayTracing
        )
        XCTAssertFalse(device.lastCapabilityDiagnostic.fallbackAvailable)
    }
}

