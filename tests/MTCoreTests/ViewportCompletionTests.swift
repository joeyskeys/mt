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
