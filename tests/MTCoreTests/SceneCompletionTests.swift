import XCTest
@testable import MTCore

final class SceneCompletionTests: XCTestCase {
    func testProceduralGeometryAndViewsRetainIndexedData() {
        let plane = Mesh.plane(name: "plane", size: 2)
        XCTAssertEqual(plane.vertexCount, 4)
        XCTAssertEqual(plane.indexCount, 6)

        let view = plane.makeView(
            vertexOffset: 1,
            vertexCount: 2,
            indexOffset: 2,
            indexCount: 3,
            baseVertex: -1
        )
        XCTAssertTrue(view.isIndexed)
        XCTAssertTrue(
            view.validate(
                vertexCount: plane.vertexCount,
                indexCount: plane.indexCount
            )
        )
        XCTAssertFalse(
            MeshView(
                meshName: "invalid",
                vertexOffset: 4,
                vertexCount: 1,
                indexOffset: 0,
                indexCount: 0,
                baseVertex: 0
            ).validate(
                vertexCount: plane.vertexCount,
                indexCount: plane.indexCount
            )
        )

        let cube = Mesh.cube(name: "cube")
        XCTAssertEqual(cube.vertexCount, 24)
        XCTAssertEqual(cube.indexCount, 36)
        let grid = Mesh.grid(name: "grid", columns: 4, rows: 3)
        XCTAssertEqual(grid.vertexCount, 20)
        XCTAssertEqual(grid.indexCount, 72)
        let instances = InstancedMeshFixture.cubeFixture()
        XCTAssertEqual(instances.instanceCount, 2)
        XCTAssertEqual(instances.instanceAt(1)?.objectID, 1)
        let text = Mesh.textFixture(
            name: "text",
            text: "MT",
            glyphWidth: 0.8,
            glyphHeight: 1.2
        )
        XCTAssertEqual(text.vertexCount, 8)
        XCTAssertEqual(text.indexCount, 12)
    }

    func testCurveTessellationAndMeshletPayload() {
        let curve = Curve(name: "path")
        XCTAssertTrue(
            curve.appendPoint(
                CurvePoint(
                    position: Vector3(x: 0, y: 0, z: 0),
                    width: 1,
                    color: Vector4(x: 1, y: 0, z: 0, w: 1)
                )
            )
        )
        XCTAssertTrue(
            curve.appendPoint(
                CurvePoint(
                    position: Vector3(x: 1, y: 1, z: 0),
                    width: 1,
                    color: Vector4(x: 0, y: 1, z: 0, w: 1)
                )
            )
        )
        XCTAssertEqual(curve.pointCount, 2)
        XCTAssertEqual(curve.tessellateAsLines(name: "tessellated")?.vertexCount, 2)
        let bezier = Curve(name: "bezier", interpolation: .bezier)
        for index in 0..<4 {
            XCTAssertTrue(
                bezier.appendPoint(
                    CurvePoint(
                        position: Vector3(
                            x: Float(index),
                            y: Float(index % 2),
                            z: 0
                        ),
                        width: 1,
                        color: Vector4(x: 1, y: 1, z: 1, w: 1)
                    )
                )
            )
        }
        XCTAssertGreaterThan(bezier.tessellatedPoints(segments: 4).count, 4)

        let payload = MeshletPayload.triangleFixture(name: "triangle.meshlet")
        XCTAssertTrue(payload.isValid)
        XCTAssertEqual(payload.meshletCount, 1)
        let metadata = MeshCullingMetadata(
            center: Vector3(x: 0, y: 0, z: 0),
            radius: 1,
            visibilityMask: UInt32.max,
            enabled: true,
            lod: MeshLODMetadata(
                levels: [
                    MeshLODLevel(
                        maxDistance: 10,
                        meshName: "lod0",
                        level: 0
                    )
                ],
                fallbackMeshName: "lod0"
            )
        )
        XCTAssertEqual(
            metadata.makeRendererCullingItem(id: 7, distance: 2)?.lodRanges.count,
            1
        )
        let mesh = Mesh.triangle(name: "native")
        let initialRevision = mesh.revision
        mesh.meshletPayload = payload
        mesh.cullingMetadata = metadata
        XCTAssertGreaterThan(mesh.revision, initialRevision)
        XCTAssertEqual(mesh.makeView().indexCount, 3)
    }

    func testSceneVersioningAndGPULayoutContract() {
        let scene = Scene()
        let object = SceneObject(
            name: "object",
            meshName: "cube",
            transform: Transform.identity(),
            materialID: 12,
            visibilityMask: 7,
            enabled: true,
            meshView: MeshView(
                meshName: "cube",
                vertexOffset: 0,
                vertexCount: 24,
                indexOffset: 0,
                indexCount: 36,
                baseVertex: 0
            )
        )
        let initialRevision = scene.revision
        XCTAssertTrue(scene.addObject(object))
        XCTAssertGreaterThan(scene.revision, initialRevision)
        let gpuData = SceneObjectGPUData(object: object)
        XCTAssertEqual(gpuData.enabled, 1)
        XCTAssertEqual(
            MemoryLayout<SceneObjectGPUData>.size,
            MemoryLayout<UInt32>.size * 16
        )
        XCTAssertEqual(scene.gpuVersion, 0)
        XCTAssertNil(scene.gpuScene)
    }

    func testMaterialContractsAndBuiltInDataAlignment() {
        let phong = PhongMaterialData(
            baseColor: Vector4(x: 1, y: 1, z: 1, w: 1),
            specularColor: Vector4(x: 1, y: 1, z: 1, w: 1),
            shininess: 32
        )
        let pbr = PBRMaterialData(
            baseColor: Vector4(x: 1, y: 1, z: 1, w: 1),
            emissiveColor: Vector4(x: 0, y: 0, z: 0, w: 0),
            metallic: 0,
            roughness: 0.5,
            normalScale: 1,
            occlusionStrength: 1
        )
        XCTAssertEqual(phong.makeParameterBlock().length, 48)
        XCTAssertEqual(pbr.makeParameterBlock().length, 48)
        XCTAssertEqual(
            DirectionalShadowMaterialData(
                lightViewProjection: Matrix4x4.identity(),
                depthBias: 0.001,
                normalBias: 0.01
            ).makeParameterBlock().length,
            80
        )

        XCTAssertEqual(SamplerFallbackPolicy.linearClamp.rawValue, 1)
        XCTAssertEqual(MaterialBindingPath.directSlots.rawValue, 0)
        let layouts = BuiltInShaderLayout.all
        XCTAssertEqual(layouts.count, 9)
        XCTAssertTrue(layouts.allSatisfy { $0.hasValidDataContract() })
        XCTAssertTrue(layouts.dropLast().allSatisfy { $0.supportsIndexedFallback })
        XCTAssertFalse(layouts.last?.supportsIndexedFallback ?? true)
        XCTAssertEqual(
            BuiltInShaderLayout.forFamily(.physicallyBased).sourceName,
            "physically_based.metal"
        )
    }

    func testLightClusterAndShadowFixturesAreDeterministic() {
        let lights = LightManager.fixture()
        XCTAssertEqual(lights.lightCount, 2)
        XCTAssertTrue(lights.light("key")?.castsShadow == true)
        XCTAssertEqual(
            ShadowMapDescriptor.directionalFixture().cascades,
            4
        )

        let plan = ForwardPlusClusterPlan(
            columns: 2,
            rows: 1,
            slices: 1,
            clusterCount: 2,
            maxLightsPerCluster: 4,
            overflowCount: 0,
            bounds: [
                ForwardPlusClusterBounds(
                    minX: -1,
                    minY: -1,
                    minZ: 0,
                    maxX: 0,
                    maxY: 1,
                    maxZ: 1
                ),
                ForwardPlusClusterBounds(
                    minX: 0,
                    minY: -1,
                    minZ: 0,
                    maxX: 1,
                    maxY: 1,
                    maxZ: 1
                )
            ],
            assignments: [
                ForwardPlusClusterAssignment(
                    lightOffset: 0,
                    lightCount: 1,
                    overflow: false
                ),
                ForwardPlusClusterAssignment(
                    lightOffset: 1,
                    lightCount: 0,
                    overflow: false
                )
            ],
            lightIndices: [0]
        )
        let data = LightClusterData(plan: plan)
        XCTAssertEqual(data.clusterCount, 2)
        XCTAssertEqual(data.lightIndices, [0])
        XCTAssertEqual(
            MemoryLayout<LightClusterAssignmentGPUData>.size,
            16
        )
    }

    func testDeviceGuardedSceneReplacementRetiresPreviousBuffers() {
        guard let device = Device.systemDefault(),
              let queue = device.createCommandQueue(
                  label: "mt scene completion test"
              ),
              let commandBuffer = queue.makeCommandBuffer()
        else {
            return
        }
        let token = commandBuffer.makeCompletionToken()

        let drawables = DrawableManager()
        let mesh = Mesh.triangle(name: "triangle")
        XCTAssertTrue(drawables.addMesh(mesh))
        let first = drawables.syncToGPU(
            device: device,
            storageMode: .shared,
            label: "mt.scene.first",
            after: token
        )
        XCTAssertEqual(first.uploadedCount, 1)
        mesh.appendVertex(
            MeshVertex(
                position: Vector3(x: 0, y: 0, z: 1),
                normal: Vector3(x: 0, y: 0, z: 1),
                texcoord: Vector2(x: 0, y: 0)
            )
        )
        let second = drawables.syncToGPU(
            device: device,
            storageMode: .shared,
            label: "mt.scene.second",
            after: token
        )
        XCTAssertEqual(second.uploadedCount, 1)
        XCTAssertGreaterThan(drawables.retirementQueue.count, 0)

        let scene = Scene()
        XCTAssertTrue(
            scene.addObject(
                SceneObject(
                    name: "object",
                    meshName: "triangle",
                    transform: Transform.identity(),
                    materialID: 0,
                    visibilityMask: UInt32.max,
                    enabled: true
                )
            )
        )
        XCTAssertNotNil(
            scene.syncToGPU(
                device: device,
                storageMode: .shared,
                label: "mt.scene.objects.first"
            )
        )
        XCTAssertTrue(
            scene.updateObject(
                SceneObject(
                    name: "object",
                    meshName: "triangle",
                    transform: Transform(
                        position: Vector3(x: 1, y: 0, z: 0),
                        rotation: Vector3(x: 0, y: 0, z: 0),
                        scale: Vector3(x: 1, y: 1, z: 1)
                    ),
                    materialID: 0,
                    visibilityMask: UInt32.max,
                    enabled: true
                )
            )
        )
        XCTAssertNotNil(
            scene.syncToGPU(
                device: device,
                storageMode: .shared,
                label: "mt.scene.objects.second",
                after: token,
                retirementQueue: drawables.retirementQueue
            )
        )
        XCTAssertGreaterThan(scene.gpuVersion, 1)
        XCTAssertTrue(commandBuffer.commit())
        commandBuffer.waitUntilCompleted()
        _ = drawables.collectRetiredResources()
    }
}
