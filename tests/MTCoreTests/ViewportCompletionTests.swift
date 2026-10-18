import XCTest
@testable import MTCore

final class ViewportCompletionTests: XCTestCase {
    func testMeshVertexReadbackRetainsCPUIndexedData() {
        let mesh = Mesh.triangle(name: "triangle")
        XCTAssertEqual(mesh.vertexCount, 3)
        XCTAssertEqual(mesh.indexCount, 3)
        XCTAssertEqual(mesh.vertex(at: 0)?.position.y, 0.5)
        XCTAssertEqual(mesh.vertex(at: 1)?.position.x, -0.5)
        XCTAssertNil(mesh.vertex(at: mesh.vertexCount))
    }

    func testNearestVertexSelectionIsDeterministic() {
        guard let device = Device.systemDefault() else {
            return
        }
        let viewport = Viewport(device: device)
        let candidates = [
            ViewportVertexCandidate(
                objectID: 4,
                vertexID: 9,
                screenPosition: Vector2(x: 10, y: 10),
                depth: 0.5
            ),
            ViewportVertexCandidate(
                objectID: 2,
                vertexID: 7,
                screenPosition: Vector2(x: 10, y: 10),
                depth: 0.5
            ),
            ViewportVertexCandidate(
                objectID: 1,
                vertexID: 2,
                screenPosition: Vector2(x: 11, y: 10),
                depth: 0.1
            )
        ]
        let result = viewport.selectNearestVertex(
            candidates: candidates,
            x: 10,
            y: 10,
            maxDistance: 2
        )
        XCTAssertTrue(result.hit)
        XCTAssertEqual(result.objectID, 2)
        XCTAssertEqual(result.vertexID, 7)
        XCTAssertEqual(result.distanceSquared, 0)
    }

    func testSceneObjectIDsFollowSceneOrderAndSurviveMutation() {
        guard let device = Device.systemDefault() else {
            return
        }
        let viewport = Viewport(device: device)
        let scene = Scene()
        XCTAssertTrue(
            scene.addObject(
                SceneObject(
                    name: "first",
                    meshName: "mesh",
                    transform: Transform.identity(),
                    materialID: 0,
                    visibilityMask: UInt32.max,
                    enabled: true
                )
            )
        )
        XCTAssertTrue(
            scene.addObject(
                SceneObject(
                    name: "second",
                    meshName: "mesh",
                    transform: Transform.identity(),
                    materialID: 0,
                    visibilityMask: UInt32.max,
                    enabled: true
                )
            )
        )
        XCTAssertEqual(viewport.synchronizeSceneObjectIDs(scene), 2)
        let firstID = viewport.objectID("first")
        let secondID = viewport.objectID("second")
        XCTAssertNotEqual(firstID, secondID)
        XCTAssertEqual(viewport.synchronizeSceneObjectIDs(scene), 2)
        XCTAssertEqual(viewport.objectID("first"), firstID)
        XCTAssertEqual(viewport.objectID("second"), secondID)
        XCTAssertTrue(scene.removeObject("first"))
        XCTAssertEqual(viewport.synchronizeSceneObjectIDs(scene), 1)
        XCTAssertEqual(viewport.objectID("first"), 0)
        XCTAssertEqual(viewport.objectID("second"), secondID)
        XCTAssertTrue(
            scene.addObject(
                SceneObject(
                    name: "first",
                    meshName: "mesh",
                    transform: Transform.identity(),
                    materialID: 0,
                    visibilityMask: UInt32.max,
                    enabled: true
                )
            )
        )
        XCTAssertEqual(viewport.synchronizeSceneObjectIDs(scene), 2)
        XCTAssertEqual(viewport.objectID("first"), firstID)
    }

    func testPickingAttachmentsReportExplicitConfigurationAndFormats() {
        guard let device = Device.systemDefault() else {
            return
        }
        let viewport = Viewport(device: device)
        XCTAssertTrue(viewport.resize(width: 32, height: 24))
        let selection = viewport.configurePicking(
            ViewportPickingConfiguration(
                captureDepth: true,
                captureNormal: true,
                preferMemoryless: true
            )
        )
        XCTAssertTrue(selection.requestedPath == .memoryless)
        if selection.selectedPath == .baseline {
            XCTAssertTrue(selection.usedFallback)
            XCTAssertTrue(selection.fallbackAvailable)
        }
        guard let pass = viewport.makePickingRenderPass() else {
            return
        }
        XCTAssertEqual(pass.colorAttachmentCount, 2)
        XCTAssertEqual(pass.colorFormat(at: 1), .rgba32Float)
        XCTAssertTrue(viewport.pickingDepthReadbackTexture != nil)
        XCTAssertTrue(viewport.pickingNormalReadbackTexture != nil)
    }

    func testABufferPickingSelectionAndCapacityAreObservable() {
        guard let device = Device.systemDefault() else {
            return
        }
        let viewport = Viewport(device: device)
        XCTAssertTrue(viewport.resize(width: 16, height: 8))
        let acceleration = viewport.configurePicking(
            ViewportPickingConfiguration(
                preferABuffer: true,
                aBufferNodesPerPixel: 4,
                aBufferMaxNodes: 1024
            )
        )
        XCTAssertEqual(acceleration.selectedPath, .baseline)
        XCTAssertEqual(viewport.pickingSelection.requestedPath, .aBuffer)
        if viewport.pickingSelection.selectedPath == .aBuffer {
            XCTAssertTrue(viewport.makePickingRenderPass() != nil)
            XCTAssertEqual(viewport.aBufferNodeCapacity, 16 * 8 * 4)
        } else {
            XCTAssertTrue(viewport.pickingSelection.usedFallback)
            XCTAssertTrue(viewport.pickingSelection.fallbackAvailable)
        }
    }

    func testABufferConfigurationRejectsInvalidCapacity() {
        guard let device = Device.systemDefault() else {
            return
        }
        let viewport = Viewport(device: device)
        XCTAssertTrue(viewport.resize(width: 8, height: 8))
        _ = viewport.configurePicking(
            ViewportPickingConfiguration(
                preferABuffer: true,
                aBufferNodesPerPixel: 0
            )
        )
        XCTAssertEqual(viewport.pickingSelection.requestedPath, .aBuffer)
        XCTAssertEqual(
            viewport.pickingSelection.selectedPath,
            .baseline
        )
        XCTAssertEqual(
            viewport.pickingSelection.fallbackReason,
            .invalidRequest
        )
    }

    func testABufferFallsBackWhenTheExtentExceedsItsConfiguredNodeLimit() {
        guard let device = Device.systemDefault() else {
            return
        }
        let viewport = Viewport(device: device)
        XCTAssertTrue(viewport.resize(width: 16, height: 8))
        _ = viewport.configurePicking(
            ViewportPickingConfiguration(
                preferABuffer: true,
                aBufferNodesPerPixel: 8,
                aBufferMaxNodes: 1
            )
        )
        guard viewport.pickingSelection.selectedPath == .aBuffer else {
            return
        }
        XCTAssertNotNil(viewport.makePickingRenderPass())
        XCTAssertEqual(viewport.pickingSelection.selectedPath, .baseline)
        XCTAssertEqual(
            viewport.pickingSelection.fallbackReason,
            .resourcesUnavailable
        )
    }

    func testABufferReturnsOverlappingObjectHitsWhenSupported() {
        guard let device = Device.systemDefault(),
              let fixture = ViewportFixture(
                  device: device,
                  width: 64,
                  height: 64
              ) else {
            return
        }
        _ = fixture.viewport.configurePicking(
            ViewportPickingConfiguration(
                preferABuffer: true,
                aBufferNodesPerPixel: 4,
                aBufferMaxNodes: 32_768
            )
        )
        guard fixture.viewport.pickingSelection.selectedPath == .aBuffer
        else {
            return
        }
        XCTAssertTrue(
            fixture.scene.addObject(
                SceneObject(
                    name: "fixture.triangle.overlap",
                    meshName: "fixture.triangle",
                    transform: Transform.identity(),
                    materialID: 0,
                    visibilityMask: UInt32.max,
                    enabled: true
                )
            )
        )
        XCTAssertEqual(
            fixture.viewport.synchronizeSceneObjectIDs(fixture.scene),
            2
        )
        guard let queue = device.createCommandQueue(),
              let commandBuffer = queue.makeCommandBuffer() else {
            return
        }
        XCTAssertTrue(
            fixture.viewport.recordPicking(
                commandBuffer,
                scene: fixture.scene,
                drawables: fixture.drawables,
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
            XCTFail("The completed A-buffer pick did not produce a result.")
            return
        }
        XCTAssertTrue(result.usedABuffer)
        XCTAssertGreaterThanOrEqual(result.hitCount, 2)
        XCTAssertFalse(result.overflowed)
        XCTAssertNotNil(result.hit(at: 0))
        XCTAssertNotNil(result.hit(at: 1))
    }

    func testABufferReportsOverflowForAFullBoundedNodePool() {
        guard let device = Device.systemDefault(),
              let fixture = ViewportFixture(
                  device: device,
                  width: 64,
                  height: 64
              ) else {
            return
        }
        for index in 1...9 {
            XCTAssertTrue(
                fixture.scene.addObject(
                    SceneObject(
                        name: "fixture.overflow.\(index)",
                        meshName: "fixture.triangle",
                        transform: Transform.identity(),
                        materialID: 0,
                        visibilityMask: UInt32.max,
                        enabled: true
                    )
                )
            )
        }
        _ = fixture.viewport.configurePicking(
            ViewportPickingConfiguration(
                preferABuffer: true,
                aBufferNodesPerPixel: 1,
                aBufferMaxNodes: 4096
            )
        )
        guard fixture.viewport.pickingSelection.selectedPath == .aBuffer
        else {
            return
        }
        XCTAssertEqual(
            fixture.viewport.synchronizeSceneObjectIDs(fixture.scene),
            10
        )
        guard let queue = device.createCommandQueue(),
              let commandBuffer = queue.makeCommandBuffer() else {
            return
        }
        XCTAssertTrue(
            fixture.viewport.recordPicking(
                commandBuffer,
                scene: fixture.scene,
                drawables: fixture.drawables,
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
            XCTFail("The completed A-buffer overflow pick did not produce a result.")
            return
        }
        XCTAssertTrue(result.usedABuffer)
        XCTAssertTrue(result.overflowed)
    }

    func testABufferVertexPickingKeepsMultipleVerticesForOneObject() {
        guard let device = Device.systemDefault(),
              let fixture = ViewportFixture(
                  device: device,
                  width: 64,
                  height: 64
              ) else {
            return
        }
        let points = Mesh(name: "fixture.overlap.points")
        for _ in 0..<2 {
            XCTAssertTrue(
                points.appendVertex(
                    MeshVertex(
                        position: Vector3(x: 0, y: 0, z: 0),
                        normal: Vector3(x: 0, y: 0, z: 1),
                        texcoord: Vector2(x: 0, y: 0)
                    )
                )
            )
        }
        XCTAssertTrue(fixture.drawables.addMesh(points))
        XCTAssertTrue(
            fixture.scene.addObject(
                SceneObject(
                    name: "fixture.overlap.points",
                    meshName: points.name,
                    transform: Transform.identity(),
                    materialID: 0,
                    visibilityMask: UInt32.max,
                    enabled: true
                )
            )
        )
        _ = fixture.viewport.configurePicking(
            ViewportPickingConfiguration(
                preferABuffer: true,
                aBufferNodesPerPixel: 4,
                aBufferMaxNodes: 16_384,
                vertexPointSize: 5
            )
        )
        guard fixture.viewport.pickingSelection.selectedPath == .aBuffer
        else {
            return
        }
        XCTAssertEqual(
            fixture.viewport.synchronizeSceneObjectIDs(fixture.scene),
            2
        )
        let pointsID = fixture.viewport.objectID("fixture.overlap.points")
        guard let queue = device.createCommandQueue(),
              let commandBuffer = queue.makeCommandBuffer() else {
            return
        }
        XCTAssertTrue(
            fixture.viewport.recordPicking(
                commandBuffer,
                scene: fixture.scene,
                drawables: fixture.drawables,
                mode: .vertex
            )
        )
        XCTAssertTrue(
            fixture.viewport.schedulePickReadback(
                commandBuffer,
                request: ViewportPickRequest(
                    mode: .vertex,
                    x: 32,
                    y: 32,
                    objectID: pointsID
                )
            )
        )
        XCTAssertTrue(commandBuffer.commit())
        commandBuffer.waitUntilCompleted()
        guard let result = fixture.viewport.pollPickResult() else {
            XCTFail("The completed A-buffer vertex pick did not produce a result.")
            return
        }
        XCTAssertTrue(result.usedABuffer)
        XCTAssertGreaterThanOrEqual(result.hitCount, 2)
        XCTAssertEqual(result.hit(at: 0)?.objectID, pointsID)
        XCTAssertEqual(result.hit(at: 1)?.objectID, pointsID)
    }

    func testABufferReadbackRetainsItsExtentAcrossResize() {
        guard let device = Device.systemDefault(),
              let fixture = ViewportFixture(
                  device: device,
                  width: 64,
                  height: 64
              ) else {
            return
        }
        _ = fixture.viewport.configurePicking(
            ViewportPickingConfiguration(
                preferABuffer: true,
                aBufferNodesPerPixel: 4,
                aBufferMaxNodes: 32_768
            )
        )
        guard fixture.viewport.pickingSelection.selectedPath == .aBuffer
        else {
            return
        }
        guard let queue = device.createCommandQueue(),
              let commandBuffer = queue.makeCommandBuffer() else {
            return
        }
        XCTAssertTrue(
            fixture.viewport.recordPicking(
                commandBuffer,
                scene: fixture.scene,
                drawables: fixture.drawables
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
        XCTAssertTrue(fixture.viewport.resize(width: 32, height: 32))
        XCTAssertTrue(commandBuffer.commit())
        commandBuffer.waitUntilCompleted()
        guard let result = fixture.viewport.pollPickResult() else {
            XCTFail("The resized in-flight A-buffer pick did not produce a result.")
            return
        }
        XCTAssertTrue(result.usedABuffer)
        XCTAssertEqual(result.x, 32)
        XCTAssertEqual(result.y, 32)
    }

    func testFeatureExtensionUsesValueOnlyRegistration() {
        guard let device = Device.systemDefault() else {
            return
        }
        let viewport = Viewport(device: device)
        let feature = ViewportFeatureExtension(
            name: "measurements",
            phase: .screenOverlay,
            requiredFeatures: 0,
            fallbackAvailable: true
        )
        XCTAssertTrue(viewport.registerFeatureExtension(feature))
        XCTAssertEqual(viewport.extensionCount, 1)
        XCTAssertTrue(viewport.featureExtensionIsSupported("measurements"))
        XCTAssertTrue(
            viewport.updateFeatureExtension(
                ViewportFeatureExtension(
                    name: "measurements",
                    phase: .screenOverlay,
                    requiredFeatures: 0,
                    fallbackAvailable: true,
                    enabled: false
                )
            )
        )
        XCTAssertFalse(viewport.featureExtension("measurements")?.enabled ?? true)
        XCTAssertTrue(viewport.removeFeatureExtension("measurements"))
    }

    func testEditorFixtureCreatesSceneAndBuiltInFeatureSet() {
        guard let device = Device.systemDefault(),
              let fixture = ViewportFixture(
                  device: device,
                  width: 64,
                  height: 64
              ) else {
            return
        }
        XCTAssertEqual(fixture.scene.objectCount, 1)
        XCTAssertEqual(fixture.drawables.meshCount, 1)
        XCTAssertNotEqual(fixture.sceneObjectID, 0)
        XCTAssertNotEqual(fixture.axesFeatureID, 0)
        XCTAssertNotEqual(fixture.gridFeatureID, 0)
        XCTAssertNotEqual(fixture.labelsFeatureID, 0)
        XCTAssertNotEqual(fixture.vertexPointsFeatureID, 0)
        XCTAssertEqual(fixture.makeVertexCandidates().count, 3)
    }
}
