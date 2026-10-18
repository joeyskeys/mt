import XCTest
@testable import MTCore

final class OffscreenValidationTests: XCTestCase {
    private let solidColorSource = """
    #include <metal_stdlib>
    using namespace metal;

    vertex float4 mt_validation_vertex(uint vertexID [[vertex_id]]) {
        float2 positions[3] = {
            float2(-1.0, -1.0),
            float2(3.0, -1.0),
            float2(-1.0, 3.0)
        };
        return float4(positions[vertexID], 0.0, 1.0);
    }

    fragment float4 mt_validation_fragment() {
        return float4(1.0, 0.0, 0.0, 1.0);
    }
    """

    private let computeSource = """
    #include <metal_stdlib>
    using namespace metal;

    kernel void mt_validation_compute(
        device uint *values [[buffer(0)]],
        uint id [[thread_position_in_grid]]
    ) {
        values[id] = id * 3u + 7u;
    }
    """

    private func makeColorPipeline(device: Device) -> RenderPipeline? {
        guard let library = device.createShaderLibraryFromSource(
            source: solidColorSource,
            label: "mt validation solid color"
        ),
        let vertex = library.function("mt_validation_vertex"),
        let fragment = library.function("mt_validation_fragment") else {
            return nil
        }
        let descriptor = RenderPipelineDescriptor()
        descriptor.setVertexFunction(vertex)
        descriptor.setFragmentFunction(fragment)
        guard descriptor.setColorAttachment(
            ColorAttachmentDescriptor(
                pixelFormat: .rgba8Unorm,
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
        ) else {
            return nil
        }
        return device.createRenderPipeline(descriptor)
    }

    private func makeTexture(
        device: Device,
        width: UInt32,
        height: UInt32,
        mipLevelCount: UInt32 = 1
    ) -> Texture? {
        device.createTexture(
            TextureDescriptor(
                textureType: .twoD,
                pixelFormat: .rgba8Unorm,
                width: width,
                height: height,
                depth: 1,
                arrayLength: 1,
                mipLevelCount: mipLevelCount,
                sampleCount: 1,
                usage: UInt32(
                    TextureUsage.shaderRead.rawValue
                        | TextureUsage.renderTarget.rawValue
                ),
                storageMode: .shared,
                cpuCacheMode: .defaultCache,
                hazardMode: .defaultMode,
                label: "mt validation texture"
            )
        )
    }

    func testInstalledPackageClearFixtureHasKnownResult() throws {
        guard let device = Device.systemDefault() else {
            throw XCTSkip("No Metal device is available on this machine.")
        }
        XCTAssertTrue(
            OffscreenValidationFixture.validateClearReadback(device: device)
        )
    }

    func testOffscreenClearAndKnownColorReadback() throws {
        guard let device = Device.systemDefault() else {
            throw XCTSkip("No Metal device is available on this machine.")
        }
        guard let pipeline = makeColorPipeline(device: device),
              let texture = makeTexture(
                  device: device,
                  width: 16,
                  height: 16
              ),
              let queue = device.createCommandQueue(),
              let commandBuffer = queue.makeCommandBuffer() else {
            XCTFail("The offscreen color fixture could not be created.")
            return
        }
        let pass = RenderPassDescriptor(colorTexture: texture)
        pass.clearColor = ClearColor(red: 0, green: 0, blue: 0, alpha: 1)
        guard let encoder = commandBuffer.makeRenderEncoder(pass) else {
            XCTFail("The offscreen render encoder was unavailable.")
            return
        }
        XCTAssertTrue(encoder.setRenderPipeline(pipeline))
        XCTAssertTrue(
            encoder.drawPrimitives(
                primitiveType: .triangle,
                vertexStart: 0,
                vertexCount: 3,
                instanceCount: 1,
                baseInstance: 0
            )
        )
        XCTAssertTrue(encoder.endEncoding())
        XCTAssertTrue(commandBuffer.commit())
        commandBuffer.waitUntilCompleted()
        XCTAssertTrue(commandBuffer.didSucceed)

        var bytes = [UInt8](repeating: 0, count: 16 * 16 * 4)
        let didRead = bytes.withUnsafeMutableBytes { rawBytes in
            texture.readBaseLevel2D(
                destination: rawBytes.baseAddress!,
                bytesPerRow: 16 * 4,
                bytesPerImage: UInt64(bytes.count)
            )
        }
        XCTAssertTrue(didRead)
        let center = (8 * 16 + 8) * 4
        XCTAssertEqual(bytes[center], 255)
        XCTAssertEqual(bytes[center + 1], 0)
        XCTAssertEqual(bytes[center + 2], 0)
        XCTAssertEqual(bytes[center + 3], 255)
    }

    func testComputeToBufferAndReadbackAreDeterministic() throws {
        guard let device = Device.systemDefault() else {
            throw XCTSkip("No Metal device is available on this machine.")
        }
        guard let library = device.createShaderLibraryFromSource(
                  source: computeSource,
                  label: "mt validation compute"
              ),
              let function = library.function("mt_validation_compute") else {
            XCTFail("The compute validation shader could not be loaded.")
            return
        }
        let pipelineDescriptor = ComputePipelineDescriptor()
        pipelineDescriptor.setFunction(function)
        guard let pipeline = device.createComputePipeline(
            pipelineDescriptor
        ),
        let buffer = device.createBuffer(
                  BufferDescriptor(
                      length: 4 * 4,
                      usage: UInt32(BufferUsage.storage.rawValue),
                      storageMode: .shared,
                      cpuCacheMode: .defaultCache,
                      hazardMode: .defaultMode,
                      label: "mt validation compute output"
                  )
              ),
              let queue = device.createCommandQueue(),
              let commandBuffer = queue.makeCommandBuffer(),
              let encoder = commandBuffer.makeComputeEncoder() else {
            XCTFail("The compute validation fixture could not be created.")
            return
        }
        XCTAssertTrue(encoder.setComputePipeline(pipeline))
        XCTAssertTrue(encoder.setBuffer(buffer, offset: 0, index: 0))
        XCTAssertTrue(
            encoder.dispatchThreads(
                Extent3D(width: 4, height: 1, depth: 1),
                threadsPerThreadgroup: Extent3D(
                    width: 4,
                    height: 1,
                    depth: 1
                )
            )
        )
        XCTAssertTrue(encoder.endEncoding())
        XCTAssertTrue(commandBuffer.commit())
        commandBuffer.waitUntilCompleted()
        XCTAssertTrue(commandBuffer.didSucceed)

        var values = [UInt32](repeating: 0, count: 4)
        let didRead = values.withUnsafeMutableBytes { rawBytes in
            buffer.read(
                destination: rawBytes.baseAddress!,
                length: UInt64(rawBytes.count),
                offset: 0
            )
        }
        XCTAssertTrue(didRead)
        XCTAssertEqual(values, [7, 10, 13, 16])
    }

    func testBlitCopyAndMipmapFixturesUseExplicitStorage() throws {
        guard let device = Device.systemDefault() else {
            throw XCTSkip("No Metal device is available on this machine.")
        }
        guard let source = makeTexture(
                  device: device,
                  width: 2,
                  height: 2,
                  mipLevelCount: 2
              ),
              let destination = makeTexture(
                  device: device,
                  width: 2,
                  height: 2,
                  mipLevelCount: 2
              ),
              let queue = device.createCommandQueue(),
              let commandBuffer = queue.makeCommandBuffer(),
              let encoder = commandBuffer.makeBlitEncoder() else {
            XCTFail("The blit validation fixture could not be created.")
            return
        }
        let sourceBytes = [UInt8](
            repeating: 23,
            count: 2 * 2 * 4
        )
        let didUpload = sourceBytes.withUnsafeBytes { rawBytes in
            source.replaceBaseLevel2D(
                source: rawBytes.baseAddress!,
                bytesPerRow: 2 * 4,
                bytesPerImage: UInt64(sourceBytes.count)
            )
        }
        XCTAssertTrue(didUpload)
        XCTAssertTrue(encoder.generateMipmaps(source))
        XCTAssertTrue(encoder.copyTexture(source: source, destination: destination))
        XCTAssertTrue(encoder.endEncoding())
        XCTAssertTrue(commandBuffer.commit())
        commandBuffer.waitUntilCompleted()
        XCTAssertTrue(commandBuffer.didSucceed)

        var destinationBytes = [UInt8](
            repeating: 0,
            count: 2 * 2 * 4
        )
        let didRead = destinationBytes.withUnsafeMutableBytes { rawBytes in
            destination.readBaseLevel2D(
                destination: rawBytes.baseAddress!,
                bytesPerRow: 2 * 4,
                bytesPerImage: UInt64(destinationBytes.count)
            )
        }
        XCTAssertTrue(didRead)
        XCTAssertEqual(destinationBytes, sourceBytes)
    }

    func testMSAAResolveAndDepthAttachmentsAreValidated() throws {
        guard let device = Device.systemDefault() else {
            throw XCTSkip("No Metal device is available on this machine.")
        }
        guard device.capabilities.supportedSampleCounts.contains(4) else {
            throw XCTSkip("This device does not support four-sample MSAA.")
        }
        guard let multisample = device.createTexture(
                  TextureDescriptor(
                      textureType: .twoDMultisample,
                      pixelFormat: .rgba8Unorm,
                      width: 8,
                      height: 8,
                      depth: 1,
                      arrayLength: 1,
                      mipLevelCount: 1,
                      sampleCount: 4,
                      usage: UInt32(TextureUsage.renderTarget.rawValue),
                      storageMode: .gpuPrivate,
                      cpuCacheMode: .defaultCache,
                      hazardMode: .defaultMode,
                      label: "mt validation msaa"
                  )
              ),
              let resolve = makeTexture(
                  device: device,
                  width: 8,
                  height: 8
              ),
              let depth = device.createTexture(
                  TextureDescriptor(
                      textureType: .twoDMultisample,
                      pixelFormat: .depth32Float,
                      width: 8,
                      height: 8,
                      depth: 1,
                      arrayLength: 1,
                      mipLevelCount: 1,
                      sampleCount: 4,
                      usage: UInt32(TextureUsage.renderTarget.rawValue),
                      storageMode: .gpuPrivate,
                      cpuCacheMode: .defaultCache,
                      hazardMode: .defaultMode,
                      label: "mt validation msaa depth"
                  )
              ) else {
            XCTFail("The MSAA/depth validation fixture could not be created.")
            return
        }
        let target = RenderTarget(texture: multisample)
        XCTAssertTrue(target.setResolveTexture(resolve))
        let pass = RenderPassDescriptor(colorTexture: multisample)
        XCTAssertTrue(pass.setColorAttachment(target))
        pass.colorStoreAction = .multisampleResolve
        XCTAssertTrue(
            pass.setDepthAttachment(
                DepthAttachment(
                    texture: depth,
                    loadAction: .clear,
                    storeAction: .dontCare,
                    clearDepth: 1
                )
            )
        )
        XCTAssertTrue(pass.validate())
    }

    func testViewportPickingFixtureProducesKnownObjectResult() throws {
        guard let device = Device.systemDefault() else {
            throw XCTSkip("No Metal device is available on this machine.")
        }
        guard let fixture = ViewportFixture(
                  device: device,
                  width: 64,
                  height: 64
              ),
              let queue = device.createCommandQueue(),
              let commandBuffer = queue.makeCommandBuffer(),
              let pass = fixture.makePickingRenderPass() else {
            XCTFail("The viewport picking fixture could not be created.")
            return
        }
        XCTAssertTrue(
            fixture.viewport.recordPicking(
                commandBuffer,
                scene: fixture.scene,
                drawables: fixture.drawables,
                renderPass: pass,
                mode: .object
            )
        )
        XCTAssertTrue(
            fixture.viewport.schedulePickReadback(
                commandBuffer,
                request: ViewportPickRequest(
                    mode: .object,
                    x: 32,
                    y: 32,
                    objectID: 0
                )
            )
        )
        XCTAssertTrue(commandBuffer.commit())
        commandBuffer.waitUntilCompleted()
        guard let result = fixture.viewport.pollPickResult() else {
            XCTFail("The viewport result was unavailable.")
            return
        }
        XCTAssertTrue(result.hit)
        XCTAssertEqual(result.objectID, fixture.sceneObjectID)
    }
}
