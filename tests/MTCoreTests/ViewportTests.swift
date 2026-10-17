import XCTest
@testable import MTCore

final class ViewportTests: XCTestCase {
    private let pickingSource = """
    #include <metal_stdlib>
    using namespace metal;

    vertex float4 viewport_pick_vertex(uint vertexID [[vertex_id]]) {
        float2 positions[3] = {
            float2(-1.0, -1.0),
            float2(3.0, -1.0),
            float2(-1.0, 3.0)
        };
        return float4(positions[vertexID], 0.0, 1.0);
    }

    fragment float4 viewport_pick_fragment(
        constant uint &id [[buffer(0)]]
    ) {
        return float4(
            float(id & 0x000000ffu) / 255.0,
            float((id >> 8) & 0x000000ffu) / 255.0,
            float((id >> 16) & 0x000000ffu) / 255.0,
            float((id >> 24) & 0x000000ffu) / 255.0
        );
    }
    """

    private func makePickingPipeline(device: Device) -> RenderPipeline? {
        guard let library = device.createShaderLibraryFromSource(
            source: pickingSource,
            label: "mt viewport picking test"
        ),
        let vertex = library.function("viewport_pick_vertex"),
        let fragment = library.function("viewport_pick_fragment")
        else {
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

    private func makeView() -> RenderView {
        RenderView(
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
    }

    func testPickingIDEncodingAndVertexOverflowAreExplicit() {
        let id = PickingID(rawValue: 0x04030201)
        let color = id.normalizedColor()
        XCTAssertEqual(color.x, 1.0 / 255.0, accuracy: 0.000001)
        XCTAssertEqual(color.y, 2.0 / 255.0, accuracy: 0.000001)
        XCTAssertEqual(color.z, 3.0 / 255.0, accuracy: 0.000001)
        XCTAssertEqual(color.w, 4.0 / 255.0, accuracy: 0.000001)

        let decoded = PickingID.fromBytes(
            red: 1,
            green: 2,
            blue: 3,
            alpha: 4
        )
        XCTAssertEqual(decoded.rawValue, id.rawValue)
        XCTAssertEqual(PickingID.vertex(7)?.rawValue, 8)
        XCTAssertNil(PickingID.vertex(UInt32.max))
    }

    func testFeatureLifecycleAndStableObjectIDs() {
        guard let device = Device.systemDefault() else {
            return
        }

        let viewport = Viewport(device: device)
        let feature = ViewportFeature(
            name: "scene",
            kind: .noOp,
            phase: .scene,
            enabled: true
        )
        let featureID = viewport.addFeature(feature)
        XCTAssertNotEqual(featureID, 0)
        XCTAssertEqual(viewport.featureCount, 1)
        XCTAssertEqual(viewport.addFeature(feature), 0)
        XCTAssertTrue(viewport.resize(width: 16, height: 16))
        XCTAssertEqual(feature.resizeCount, 1)

        XCTAssertTrue(
            viewport.update(
                ViewportUpdate(
                    frameIndex: 4,
                    timeSeconds: 1,
                    camera: ViewportCamera.identity()
                )
            )
        )
        XCTAssertEqual(feature.updateCount, 1)
        XCTAssertEqual(feature.lastFrameIndex, 4)

        let firstID = viewport.registerObject("first")
        let secondID = viewport.registerObject("second")
        XCTAssertNotEqual(firstID, 0)
        XCTAssertNotEqual(secondID, 0)
        XCTAssertNotEqual(firstID, secondID)
        XCTAssertEqual(viewport.objectID("first"), firstID)
        XCTAssertEqual(viewport.objectName(secondID), "second")
        XCTAssertEqual(viewport.registerObject("first"), 0)
        XCTAssertTrue(viewport.unregisterObject("first"))
        XCTAssertEqual(viewport.objectID("first"), 0)

        guard let surface = Surface.offscreen(
            device: device,
            width: 16,
            height: 16,
            format: .bgra8Unorm
        ),
        let drawable = surface.nextDrawable(),
        let renderPass = surface.makeRenderPassDescriptor(drawable),
        let queue = device.createCommandQueue(),
        let commandBuffer = queue.makeCommandBuffer()
        else {
            return
        }
        XCTAssertTrue(
            viewport.record(
                commandBuffer,
                renderPass: renderPass,
                view: makeView()
            )
        )
        XCTAssertEqual(feature.recordCount, 1)
        XCTAssertTrue(commandBuffer.commit())
        XCTAssertTrue(viewport.removeFeature(featureID))
        XCTAssertFalse(feature.isAttached)
    }

    func testToolkitNeutralInputEventsUpdateViewportState() {
        guard let device = Device.systemDefault() else {
            return
        }
        let viewport = Viewport(device: device)
        XCTAssertTrue(viewport.resize(width: 16, height: 16))
        XCTAssertTrue(
            viewport.handleInput(
                HostInputEvent.pointerMoved(
                    x: 4,
                    y: 5,
                    modifiers: InputModifiers.none()
                )
            )
        )
        XCTAssertEqual(viewport.pointerPosition.x, 4)
        XCTAssertEqual(viewport.pointerPosition.y, 5)
        XCTAssertTrue(
            viewport.handleInput(
                HostInputEvent.scroll(
                    deltaX: 1,
                    deltaY: -2,
                    modifiers: InputModifiers.none()
                )
            )
        )
        XCTAssertEqual(viewport.scrollDelta.y, -2)
        XCTAssertTrue(viewport.handleInput(HostInputEvent.focus(true)))
        XCTAssertTrue(viewport.isFocused)
        XCTAssertTrue(
            viewport.handleInput(
                HostInputEvent(
                    kind: .pointerButton,
                    x: 4,
                    y: 5,
                    deltaX: 0,
                    deltaY: 0,
                    button: 1,
                    pressed: true,
                    keyCode: 0,
                    modifiers: InputModifiers.none(),
                    width: 0,
                    height: 0,
                    focused: true
                )
            )
        )
        XCTAssertEqual(viewport.lastButton, 1)
        XCTAssertTrue(viewport.isButtonPressed)
        XCTAssertTrue(viewport.handleInput(HostInputEvent.close()))
        XCTAssertTrue(viewport.isClosed)
    }

    func testOverlayRecordingUsesAnExplicitLoadStorePass() {
        guard let device = Device.systemDefault(),
              let surface = Surface.offscreen(
                  device: device,
                  width: 16,
                  height: 16,
                  format: .bgra8Unorm
              ),
              let drawable = surface.nextDrawable(),
              let renderPass = surface.makeRenderPassDescriptor(drawable),
              let queue = device.createCommandQueue(),
              let commandBuffer = queue.makeCommandBuffer()
        else {
            return
        }

        let viewport = Viewport(device: device)
        XCTAssertTrue(viewport.resize(width: 16, height: 16))
        let featureID = viewport.addAxesFeature("axes")
        XCTAssertNotEqual(featureID, 0)
        XCTAssertTrue(
            viewport.recordOverlay(
                commandBuffer,
                renderPass: renderPass,
                view: makeView()
            )
        )
        guard let storedFeature = viewport.feature(featureID) else {
            XCTFail("The viewport did not retain its overlay feature.")
            return
        }
        XCTAssertEqual(storedFeature.recordCount, 1)
        XCTAssertFalse(commandBuffer.hasActiveEncoder)
        XCTAssertTrue(commandBuffer.commit())
    }

    func testClearPickingReadbackIsPolledAfterCommandCompletion() {
        guard let device = Device.systemDefault() else {
            return
        }
        let viewport = Viewport(device: device)
        XCTAssertTrue(viewport.resize(width: 16, height: 16))

        guard let renderPass = viewport.makePickingRenderPass(),
              let queue = device.createCommandQueue(),
              let commandBuffer = queue.makeCommandBuffer(),
              let encoder = commandBuffer.makeRenderEncoder(renderPass)
        else {
            return
        }
        XCTAssertTrue(encoder.endEncoding())
        XCTAssertTrue(
            viewport.schedulePickReadback(
                commandBuffer,
                request: ViewportPickRequest(
                    mode: .object,
                    x: 8,
                    y: 8,
                    objectID: 0
                )
            )
        )
        XCTAssertNil(viewport.pollPickResult())
        XCTAssertTrue(viewport.resize(width: 8, height: 8))
        XCTAssertTrue(commandBuffer.commit())
        commandBuffer.waitUntilCompleted()
        guard let result = viewport.pollPickResult() else {
            XCTFail("A completed picking command did not produce a result.")
            return
        }
        XCTAssertFalse(result.hit)
        XCTAssertEqual(result.rawID, 0)
    }

    func testObjectAndVertexPickingReadBackRegisteredIDs() {
        guard let device = Device.systemDefault(),
              let pipeline = makePickingPipeline(device: device),
              let queue = device.createCommandQueue()
        else {
            return
        }

        let viewport = Viewport(device: device)
        XCTAssertTrue(viewport.resize(width: 16, height: 16))
        let objectID = viewport.registerObject("triangle")
        XCTAssertNotEqual(objectID, 0)

        guard let objectPass = viewport.makePickingRenderPass(),
              let objectCommandBuffer = queue.makeCommandBuffer(),
              let objectEncoder = objectCommandBuffer.makeRenderEncoder(
                  objectPass
              )
        else {
            return
        }
        let objectParameters = ParameterBlock(length: 4)
        XCTAssertTrue(objectParameters.setUInt32(0, value: objectID))
        XCTAssertTrue(objectEncoder.setRenderPipeline(pipeline))
        XCTAssertTrue(objectEncoder.setFragmentBytes(objectParameters, index: 0))
        XCTAssertTrue(
            objectEncoder.drawPrimitives(
                primitiveType: .triangle,
                vertexStart: 0,
                vertexCount: 3,
                instanceCount: 1,
                baseInstance: 0
            )
        )
        XCTAssertTrue(objectEncoder.endEncoding())
        XCTAssertTrue(
            viewport.schedulePickReadback(
                objectCommandBuffer,
                request: ViewportPickRequest(
                    mode: .object,
                    x: 8,
                    y: 8,
                    objectID: 0
                )
            )
        )
        XCTAssertTrue(objectCommandBuffer.commit())
        objectCommandBuffer.waitUntilCompleted()
        guard let objectResult = viewport.pollPickResult() else {
            XCTFail("The object picking result was unavailable.")
            return
        }
        XCTAssertTrue(objectResult.hit)
        XCTAssertEqual(objectResult.objectID, objectID)
        XCTAssertEqual(objectResult.vertexID, 0)

        guard let vertexPass = viewport.makePickingRenderPass(),
              let vertexCommandBuffer = queue.makeCommandBuffer(),
              let vertexEncoder = vertexCommandBuffer.makeRenderEncoder(
                  vertexPass
              ),
              let vertexPickID = PickingID.vertex(7)
        else {
            return
        }
        let vertexParameters = ParameterBlock(length: 4)
        XCTAssertTrue(vertexParameters.setUInt32(0, value: vertexPickID.rawValue))
        XCTAssertTrue(vertexEncoder.setRenderPipeline(pipeline))
        XCTAssertTrue(vertexEncoder.setFragmentBytes(vertexParameters, index: 0))
        XCTAssertTrue(
            vertexEncoder.drawPrimitives(
                primitiveType: .triangle,
                vertexStart: 0,
                vertexCount: 3,
                instanceCount: 1,
                baseInstance: 0
            )
        )
        XCTAssertTrue(vertexEncoder.endEncoding())
        XCTAssertTrue(
            viewport.schedulePickReadback(
                vertexCommandBuffer,
                request: ViewportPickRequest(
                    mode: .vertex,
                    x: 8,
                    y: 8,
                    objectID: objectID
                )
            )
        )
        XCTAssertTrue(vertexCommandBuffer.commit())
        vertexCommandBuffer.waitUntilCompleted()
        guard let vertexResult = viewport.pollPickResult() else {
            XCTFail("The vertex picking result was unavailable.")
            return
        }
        XCTAssertTrue(vertexResult.hit)
        XCTAssertEqual(vertexResult.objectID, objectID)
        XCTAssertEqual(vertexResult.vertexID, 7)
    }
}

