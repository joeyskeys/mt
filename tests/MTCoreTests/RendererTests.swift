import XCTest
@testable import MTCore

final class RendererTests: XCTestCase {
    private let source = """
    #include <metal_stdlib>
    using namespace metal;

    vertex float4 renderer_vertex(uint vertexID [[vertex_id]]) {
        float2 positions[3] = {
            float2(0.0, 0.5),
            float2(-0.5, -0.5),
            float2(0.5, -0.5)
        };
        return float4(positions[vertexID], 0.0, 1.0);
    }

    fragment float4 renderer_fragment() {
        return float4(1.0);
    }
    """

    private func makePipeline(device: Device) -> RenderPipeline? {
        guard let library = device.createShaderLibraryFromSource(
                  source: source,
                  label: "mt renderer scheduling test"
              ),
              let vertex = library.function("renderer_vertex"),
              let fragment = library.function("renderer_fragment") else {
            return nil
        }
        let descriptor = RenderPipelineDescriptor()
        descriptor.setVertexFunction(vertex)
        descriptor.setFragmentFunction(fragment)
        _ = descriptor.setColorAttachment(
            ColorAttachmentDescriptor(
                pixelFormat: .bgra8Unorm,
                blendingEnabled: false,
                sourceRGBBlendFactor: .one,
                destinationRGBBlendFactor: .zero,
                rgbBlendOperation: .add,
                sourceAlphaBlendFactor: .one,
                destinationAlphaBlendFactor: .zero,
                alphaBlendOperation: .add,
                writeMask: 15
            ),
            index: 0
        )
        return device.createRenderPipeline(descriptor)
    }

    func testPassSchedulingAndTransparentSortAreDeterministic() {
        guard let device = Device.systemDefault(),
              let pipeline = makePipeline(device: device),
              let vertexBuffer = device.createBuffer(
                  BufferDescriptor(
                      length: 64,
                      usage: UInt32(BufferUsage.vertex.rawValue),
                      storageMode: .shared,
                      cpuCacheMode: .defaultCache,
                      hazardMode: .defaultMode,
                      label: "mt renderer scheduling vertices"
                  )
              ) else {
            return
        }

        let opaque = RenderBatch(
            pipeline: pipeline,
            vertexBuffer: vertexBuffer,
            primitiveType: .triangle,
            vertexStart: 0,
            vertexCount: 3,
            instanceCount: 1,
            baseInstance: 0,
            transparent: false,
            label: "opaque"
        )
        opaque.sortKey = 2
        opaque.participatesInDepthPrepass = true
        opaque.castsShadow = true
        let farTransparent = RenderBatch(
            pipeline: pipeline,
            vertexBuffer: vertexBuffer,
            primitiveType: .triangle,
            vertexStart: 0,
            vertexCount: 3,
            instanceCount: 1,
            baseInstance: 0,
            transparent: true,
            label: "far transparent"
        )
        farTransparent.sortKey = 100
        let nearTransparent = RenderBatch(
            pipeline: pipeline,
            vertexBuffer: vertexBuffer,
            primitiveType: .triangle,
            vertexStart: 0,
            vertexCount: 3,
            instanceCount: 1,
            baseInstance: 0,
            transparent: true,
            label: "near transparent"
        )
        nearTransparent.sortKey = 10

        let renderer = Renderer.forward(device: device)
        let opaqueID = renderer.addBatch(opaque)
        let farID = renderer.addBatch(farTransparent)
        let nearID = renderer.addBatch(nearTransparent)
        XCTAssertEqual(renderer.schedule(for: .opaque).batchIDs, [opaqueID])
        XCTAssertEqual(
            renderer.schedule(for: .transparent).batchIDs,
            [farID, nearID]
        )
        XCTAssertEqual(
            renderer.schedule(for: .depthPrepass).batchIDs,
            [opaqueID]
        )
        XCTAssertEqual(
            renderer.schedule(for: .shadow).batchIDs,
            [opaqueID]
        )
        XCTAssertEqual(opaque.kind, .triangles)
        XCTAssertEqual(nearTransparent.pass, .transparent)
    }

    func testForwardPlusConfigurationAndResizeAreExplicit() {
        guard let device = Device.systemDefault() else {
            return
        }

        let renderer = Renderer.forwardPlus(device: device)
        XCTAssertTrue(renderer.isActive)
        XCTAssertEqual(renderer.kind, .forwardPlus)
        XCTAssertTrue(renderer.resize(width: 320, height: 160))
        XCTAssertEqual(renderer.drawableSize.width, 320)

        let configuration = ForwardPlusConfiguration(
            tileWidth: 16,
            tileHeight: 16,
            depthSlices: 4,
            maxLightsPerCluster: 32
        )
        XCTAssertTrue(renderer.configureForwardPlus(configuration))
        XCTAssertEqual(renderer.clusterCount, 800)
        XCTAssertFalse(
            renderer.configureForwardPlus(
                ForwardPlusConfiguration(
                    tileWidth: 0,
                    tileHeight: 16,
                    depthSlices: 4,
                    maxLightsPerCluster: 32
                )
            )
        )
    }

    func testRendererLifecycleDoesNotOwnAWindowOrQueue() {
        guard let device = Device.systemDefault() else {
            return
        }

        let renderer = Renderer.forward(device: device)
        XCTAssertEqual(renderer.kind, .forward)
        XCTAssertTrue(
            renderer.update(frameIndex: 7, timeSeconds: 1.5)
        )
        XCTAssertEqual(renderer.statistics.frameIndex, 7)
        renderer.shutdown()
        XCTAssertEqual(renderer.state, .shutDown)
        XCTAssertFalse(renderer.isActive)
        XCTAssertFalse(renderer.resize(width: 1, height: 1))
    }

    func testRendererExposesNativeCapabilityAvailability() {
        guard let device = Device.systemDefault() else {
            return
        }

        let renderer = Renderer.forward(device: device)
        XCTAssertEqual(
            renderer.capabilityAvailability(.meshShaders).state,
            device.capabilities.availability(for: .meshShaders).state
        )
        XCTAssertEqual(
            renderer.lastCapabilityDiagnostic.kind,
            device.lastCapabilityDiagnostic.kind
        )
    }

    func testForwardRendererRecordsAnIndexedBatch() {
        guard let device = Device.systemDefault(),
              let library = device.createShaderLibraryFromSource(
                  source: source,
                  label: "mt renderer test"
              ),
              let vertex = library.function("renderer_vertex"),
              let fragment = library.function("renderer_fragment")
        else {
            return
        }

        let pipelineDescriptor = RenderPipelineDescriptor()
        pipelineDescriptor.setVertexFunction(vertex)
        pipelineDescriptor.setFragmentFunction(fragment)
        XCTAssertTrue(
            pipelineDescriptor.setColorAttachment(
                ColorAttachmentDescriptor(
                    pixelFormat: .bgra8Unorm,
                    blendingEnabled: false,
                    sourceRGBBlendFactor: .one,
                    destinationRGBBlendFactor: .zero,
                    rgbBlendOperation: .add,
                    sourceAlphaBlendFactor: .one,
                    destinationAlphaBlendFactor: .zero,
                    alphaBlendOperation: .add,
                    writeMask: 15
                ),
                index: 0
            )
        )
        guard let pipeline = device.createRenderPipeline(
            pipelineDescriptor
        ) else {
            XCTFail(device.errorDescription)
            return
        }

        let bufferDescriptor = BufferDescriptor(
            length: 64,
            usage: UInt32(BufferUsage.vertex.rawValue),
            storageMode: .shared,
            cpuCacheMode: .defaultCache,
            hazardMode: .defaultMode,
            label: "mt renderer vertex buffer"
        )
        guard let vertexBuffer = device.createBuffer(bufferDescriptor),
              let colorTexture = device.createTexture(
                  TextureDescriptor(
                      textureType: .twoD,
                      pixelFormat: .bgra8Unorm,
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
                      label: "mt renderer target"
                  )
              ),
              let queue = device.createCommandQueue(),
              let commandBuffer = queue.makeCommandBuffer()
        else {
            return
        }

        let batch = RenderBatch(
            pipeline: pipeline,
            vertexBuffer: vertexBuffer,
            primitiveType: .triangle,
            vertexStart: 0,
            vertexCount: 3,
            instanceCount: 1,
            baseInstance: 0,
            transparent: false,
            label: "triangle"
        )
        let renderer = Renderer.forward(device: device)
        XCTAssertNotEqual(renderer.addBatch(batch), 0)
        XCTAssertTrue(renderer.resize(width: 16, height: 16))

        let renderPass = RenderPassDescriptor(colorTexture: colorTexture)
        let view = RenderView(
            viewport: Extent(width: 16, height: 16),
            frameIndex: 1,
            timeSeconds: 0,
            clearColor: ClearColor(
                red: 0,
                green: 0,
                blue: 0,
                alpha: 1
            )
        )
        XCTAssertTrue(
            renderer.record(
                commandBuffer,
                renderPass: renderPass,
                view: view
            )
        )
        XCTAssertEqual(renderer.statistics.drawCallCount, 1)
        XCTAssertEqual(renderer.statistics.submittedInstanceCount, 1)
        XCTAssertFalse(commandBuffer.hasActiveEncoder)
        XCTAssertTrue(commandBuffer.commit())
        XCTAssertEqual(renderer.persistentStatistics.framesRecorded, 1)
        XCTAssertEqual(renderer.persistentStatistics.drawCallCount, 1)
    }

    func testForwardPlusClusterPlanTracksBoundsAndOverflow() {
        guard let device = Device.systemDefault() else {
            return
        }

        let renderer = Renderer.forwardPlus(device: device)
        XCTAssertTrue(renderer.resize(width: 32, height: 16))
        XCTAssertTrue(
            renderer.configureForwardPlus(
                ForwardPlusConfiguration(
                    tileWidth: 16,
                    tileHeight: 16,
                    depthSlices: 2,
                    maxLightsPerCluster: 2
                )
            )
        )

        guard let plan = renderer.makeForwardPlusClusterPlan(
            [
                ForwardPlusLightCoverage(
                    lightIndex: 3,
                    firstCluster: 0,
                    clusterCount: 1
                ),
                ForwardPlusLightCoverage(
                    lightIndex: 4,
                    firstCluster: 0,
                    clusterCount: 1
                ),
                ForwardPlusLightCoverage(
                    lightIndex: 5,
                    firstCluster: 0,
                    clusterCount: 1
                )
            ]
        ) else {
            XCTFail("Forward+ cluster planning failed")
            return
        }
        XCTAssertEqual(plan.clusterCount, 4)
        XCTAssertEqual(plan.bounds.count, 4)
        XCTAssertEqual(plan.assignments[0].lightCount, 2)
        XCTAssertTrue(plan.assignments[0].overflow)
        XCTAssertEqual(plan.overflowCount, 1)
        XCTAssertEqual(plan.bounds[0].minX, -1)
        XCTAssertEqual(plan.bounds[0].maxZ, 0.5)
    }

    func testCPUCullingTracksLODAndOverflow() {
        guard let device = Device.systemDefault() else {
            return
        }

        let renderer = Renderer.forward(device: device)
        let result = renderer.cull(
            [
                RendererCullingItem(
                    id: 1,
                    center: Vector3(x: 0, y: 0, z: 0),
                    radius: 1,
                    distance: 4,
                    visibilityMask: 1,
                    enabled: true,
                    lodRanges: [
                        RendererLODRange(maxDistance: 5, level: 0),
                        RendererLODRange(maxDistance: 20, level: 1)
                    ]
                ),
                RendererCullingItem(
                    id: 2,
                    center: Vector3(x: 0, y: 0, z: 0),
                    radius: 1,
                    distance: 8,
                    visibilityMask: 1,
                    enabled: true,
                    lodRanges: [
                        RendererLODRange(maxDistance: 20, level: 1)
                    ]
                ),
                RendererCullingItem(
                    id: 3,
                    center: Vector3(x: 0, y: 0, z: 0),
                    radius: 1,
                    distance: 30,
                    visibilityMask: 1,
                    enabled: true,
                    lodRanges: []
                )
            ],
            visibilityMask: 1,
            maxDistance: 10,
            maxVisibleCount: 1
        )
        XCTAssertEqual(result.visibleIDs, [1])
        XCTAssertEqual(result.visibleLODLevels, [0])
        XCTAssertEqual(result.overflowCount, 1)
        XCTAssertEqual(result.culledCount, 1)
        XCTAssertEqual(renderer.statistics.visibleObjectCount, 1)
    }

    func testRendererNativePolicyTypesRemainObservable() {
        let schedule = RendererPassSchedule(
            pass: .transparent,
            batchIDs: [7, 9]
        )
        XCTAssertEqual(schedule.batchCount, 2)
        XCTAssertEqual(
            RendererPass.allCases,
            [.depthPrepass, .shadow, .opaque, .transparent, .overlay]
        )

        let selection = SubmissionSelection(
            requestedPath: .mesh,
            selectedPath: .indexed,
            fallbackReason: .capabilityUnavailable,
            fallbackAvailable: true
        )
        XCTAssertTrue(selection.usedFallback)
        XCTAssertEqual(
            selection.fallbackReason,
            .capabilityUnavailable
        )
    }

    func testMeshletUploadRequiresCPUVisibleStagingStorage() {
        guard let device = Device.systemDefault() else {
            return
        }
        let descriptor = MeshletDescriptor(
            vertexOffset: 0,
            vertexCount: 3,
            primitiveOffset: 0,
            primitiveCount: 1,
            lodLevel: 0,
            boundsCenter: Vector3(x: 0, y: 0, z: 0),
            boundsRadius: 1
        )
        XCTAssertNil(
            MeshletGPU.upload(
                device: device,
                name: "private meshlet",
                descriptors: [descriptor],
                vertexData: [0, 1, 2],
                primitiveData: [0, 1, 2],
                storageMode: .gpuPrivate,
                label: ""
            )
        )
    }
}

