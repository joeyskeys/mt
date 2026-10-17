import XCTest
@testable import MTCore

final class ShadersTests: XCTestCase {
    private let source = """
    #include <metal_stdlib>
    using namespace metal;

    struct TestVertexOut {
        float4 position [[position]];
    };

    vertex TestVertexOut mt_test_vertex(uint vertexID [[vertex_id]]) {
        float2 positions[3] = {
            float2(0.0, 0.5),
            float2(-0.5, -0.5),
            float2(0.5, -0.5)
        };
        TestVertexOut out;
        out.position = float4(positions[vertexID], 0.0, 1.0);
        return out;
    }

    fragment float4 mt_test_fragment() {
        return float4(1.0);
    }

    kernel void mt_test_kernel(uint id [[thread_position_in_grid]]) {
    }

    constant bool mt_enabled [[function_constant(0)]];

    kernel void mt_specialized_kernel(uint id [[thread_position_in_grid]]) {
        if (mt_enabled && id == 0) {
        }
    }
    """

    func testShaderLibraryFunctionLookupAndConstants() {
        guard let device = Device.systemDefault(),
              let library = device.createShaderLibraryFromSource(
                  source: source,
                  label: "mt shader test"
              )
        else {
            return
        }

        XCTAssertGreaterThanOrEqual(library.functionCount, 3)
        XCTAssertEqual(library.functionName(0).isEmpty, false)
        XCTAssertEqual(
            library.function("mt_test_vertex")?.functionType,
            .vertex
        )
        XCTAssertEqual(
            library.function("mt_test_fragment")?.functionType,
            .fragment
        )
        XCTAssertEqual(
            library.function("mt_test_kernel")?.functionType,
            .kernel
        )

        let constants = FunctionConstants()
        XCTAssertTrue(constants.setBool(0, value: true))
        XCTAssertTrue(constants.setInt32(1, value: 4))
        XCTAssertTrue(constants.setUInt32(2, value: 8))
        XCTAssertTrue(constants.setFloat(3, value: 1))
        XCTAssertTrue(constants.setDouble(4, value: 2))
        XCTAssertNotNil(
            library.specializedFunction(
                "mt_specialized_kernel",
                constants: constants
            )
        )
    }

    func testParameterBlockWritesInlineValues() {
        let parameters = ParameterBlock(length: 16)
        XCTAssertTrue(parameters.setUInt32(0, value: 7))
        XCTAssertTrue(parameters.setFloat(4, value: 0.5))
        XCTAssertTrue(parameters.setDouble(8, value: 2))
        XCTAssertFalse(parameters.setUInt32(16, value: 1))
        parameters.clear()
        XCTAssertEqual(parameters.length, 16)
    }

    func testBindingLayoutRejectsDuplicates() {
        let layout = BindingLayout()
        let binding = BindingInfo(
            name: "frameData",
            kind: .buffer,
            stages: UInt32(ShaderStage.vertex.rawValue),
            index: 0,
            arrayLength: 1,
            dataSize: 64,
            alignment: 16,
            updateFrequency: .perFrame
        )

        XCTAssertTrue(layout.addBinding(binding))
        XCTAssertFalse(layout.addBinding(binding))
        XCTAssertEqual(layout.count, 1)
        XCTAssertFalse(layout.validationError.isEmpty)
    }

    func testShaderAndPipelineSignaturesAreDeterministic() {
        let constants = FunctionConstants()
        XCTAssertTrue(constants.setBool(0, value: true))
        XCTAssertTrue(constants.setUInt32(2, value: 7))
        XCTAssertEqual(constants.signature, "0=bool:1;2=uint32:7")

        let layout = BindingLayout()
        XCTAssertTrue(layout.addBinding(BindingInfo(
            name: "frameData",
            kind: .buffer,
            stages: UInt32(ShaderStage.vertex.rawValue),
            index: 0,
            arrayLength: 1,
            dataSize: 64,
            alignment: 16,
            updateFrequency: .perFrame
        )))
        XCTAssertFalse(layout.signature.isEmpty)

        let key = PipelineCacheKey(
            deviceRegistryID: 42,
            kind: .render,
            shaderSignature: "vertex|fragment",
            layoutSignature: layout.signature,
            descriptorSignature: "sample=1"
        )
        XCTAssertTrue(key.identifier.contains("vertex|fragment"))
        XCTAssertTrue(key.identifier.contains(layout.signature))
    }

    func testArgumentBufferTableAndDepthStencilValueTypes() {
        let table = ArgumentBufferTable()
        XCTAssertEqual(table.count, 0)
        table.removeAll()
        XCTAssertEqual(table.count, 0)

        let face = StencilFaceDescriptor(
            stencilCompareFunction: .equal,
            stencilFailureOperation: .keep,
            depthFailureOperation: .zero,
            depthStencilPassOperation: .replace,
            readMask: 0xFF,
            writeMask: 0x0F
        )
        let descriptor = DepthStencilDescriptor(
            depthCompareFunction: .lessEqual,
            depthWriteEnabled: true,
            frontFaceStencil: face,
            backFaceStencil: .default,
            label: "depth"
        )
        XCTAssertEqual(descriptor.frontFaceStencil.writeMask, 0x0F)
        XCTAssertTrue(descriptor.depthWriteEnabled)
    }

    func testReflectionRejectsMissingAndExtraBindings() {
        let resource = PipelineResourceInfo(
            name: "frameData",
            kind: .buffer,
            stages: UInt32(ShaderStage.vertex.rawValue),
            index: 0,
            arrayLength: 1,
            dataSize: 64,
            alignment: 16,
            access: .read
        )
        let reflection = PipelineReflection(resources: [resource])

        let missing = BindingLayout()
        XCTAssertFalse(reflection.validate(missing))
        XCTAssertTrue(
            reflection.validationError.contains("missing")
        )

        let extra = BindingLayout()
        XCTAssertTrue(extra.addBinding(BindingInfo(
            name: "frameData",
            kind: .buffer,
            stages: UInt32(ShaderStage.vertex.rawValue),
            index: 0,
            arrayLength: 1,
            dataSize: 64,
            alignment: 16,
            updateFrequency: .perFrame
        )))
        XCTAssertTrue(extra.addBinding(BindingInfo(
            name: "unused",
            kind: .sampler,
            stages: UInt32(ShaderStage.fragment.rawValue),
            index: 1,
            arrayLength: 1,
            dataSize: 0,
            alignment: 0,
            updateFrequency: .perMaterial
        )))
        XCTAssertFalse(reflection.validate(extra))
        XCTAssertTrue(reflection.validationError.contains("extra"))
    }

    func testMetalNativePipelineCompositionShapes() {
        let renderDescriptor = RenderPipelineDescriptor()
        let computeDescriptor = ComputePipelineDescriptor()
        let linkedFunctions = LinkedFunctions()
        renderDescriptor.setVertexLinkedFunctions(linkedFunctions)
        renderDescriptor.setFragmentLinkedFunctions(linkedFunctions)
        computeDescriptor.setLinkedFunctions(linkedFunctions)
        renderDescriptor.clearVertexLinkedFunctions()
        renderDescriptor.clearFragmentLinkedFunctions()
        computeDescriptor.clearLinkedFunctions()
        renderDescriptor.clearBinaryArchives()
        renderDescriptor.clearVertexPreloadedLibraries()
        renderDescriptor.clearFragmentPreloadedLibraries()
        computeDescriptor.clearBinaryArchives()
        computeDescriptor.clearPreloadedLibraries()
        XCTAssertTrue(computeDescriptor.setRequestedThreadgroupSize(
            Extent3D(width: 8, height: 8, depth: 1)
        ))
        XCTAssertEqual(
            computeDescriptor.requestedThreadgroupSize?.width,
            8
        )
        computeDescriptor.clearRequestedThreadgroupSize()
        XCTAssertEqual(linkedFunctions.functionCount, 0)
    }

    func testRenderAndComputePipelineCreation() {
        guard let device = Device.systemDefault(),
              let library = device.createShaderLibraryFromSource(
                  source: source,
                  label: "mt pipeline shader test"
              ),
              let vertex = library.function("mt_test_vertex"),
              let fragment = library.function("mt_test_fragment"),
              let kernel = library.function("mt_test_kernel")
        else {
            return
        }

        let renderDescriptor = RenderPipelineDescriptor()
        renderDescriptor.setVertexFunction(vertex)
        renderDescriptor.setFragmentFunction(fragment)
        renderDescriptor.sampleCount = 1
        renderDescriptor.label = "mt render pipeline"
        let color = ColorAttachmentDescriptor(
            pixelFormat: .bgra8Unorm,
            blendingEnabled: false,
            sourceRGBBlendFactor: .one,
            destinationRGBBlendFactor: .zero,
            rgbBlendOperation: .add,
            sourceAlphaBlendFactor: .one,
            destinationAlphaBlendFactor: .zero,
            alphaBlendOperation: .add,
            writeMask: 15
        )
        XCTAssertTrue(renderDescriptor.setColorAttachment(color, index: 0))
        renderDescriptor.setBindingLayout(BindingLayout())

        let cache = device.createPipelineCache()
        guard let cachedRenderPipeline = device.createRenderPipeline(
            renderDescriptor,
            cache: cache
        ) else {
            XCTFail(device.errorDescription)
            return
        }
        XCTAssertNotNil(device.createRenderPipeline(
            renderDescriptor,
            cache: cache
        ))
        XCTAssertEqual(cache.hits, 1)
        XCTAssertEqual(cache.misses, 1)
        XCTAssertEqual(cache.entryCount, 1)
        cache.invalidateAll()
        XCTAssertEqual(cache.entryCount, 0)
        if let archive = device.createBinaryArchive(label: "cache archive") {
            XCTAssertTrue(cache.attachPersistentArchive(archive))
            XCTAssertNotNil(cache.persistentArchive)
            cache.clearPersistentArchive()
            XCTAssertNil(cache.persistentArchive)
        }

        guard let renderPipeline = device.createRenderPipeline(
            renderDescriptor
        ) else {
            XCTFail(device.errorDescription)
            return
        }
        XCTAssertEqual(renderPipeline.info.sampleCount, 1)
        XCTAssertEqual(renderPipeline.reflection.resourceCount, 0)
        XCTAssertEqual(
            cachedRenderPipeline.info.sampleCount,
            renderPipeline.info.sampleCount
        )

        let computeDescriptor = ComputePipelineDescriptor()
        computeDescriptor.setFunction(kernel)
        computeDescriptor.label = "mt compute pipeline"
        computeDescriptor.setBindingLayout(BindingLayout())
        guard let computePipeline = device.createComputePipeline(
            computeDescriptor
        ) else {
            XCTFail(device.errorDescription)
            return
        }
        XCTAssertGreaterThan(computePipeline.threadExecutionWidth, 0)
        XCTAssertGreaterThan(computePipeline.maxThreadsPerThreadgroup, 0)

        let computeCache = device.createPipelineCache()
        XCTAssertNotNil(device.createComputePipeline(
            computeDescriptor,
            cache: computeCache
        ))
        XCTAssertNotNil(device.createComputePipeline(
            computeDescriptor,
            cache: computeCache
        ))
        XCTAssertEqual(computeCache.hits, 1)
        XCTAssertEqual(computeCache.misses, 1)
    }
}

