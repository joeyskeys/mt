import XCTest
@testable import MTCore

final class SceneTests: XCTestCase {
    private let pipelineSource = """
    #include <metal_stdlib>
    using namespace metal;

    vertex float4 scene_vertex(
        uint vertexID [[vertex_id]],
        const device float3 *positions [[buffer(0)]]
    ) {
        return float4(positions[vertexID], 1.0);
    }

    fragment float4 scene_fragment() {
        return float4(1.0);
    }
    """

    private func makePipeline(device: Device) -> RenderPipeline? {
        guard let library = device.createShaderLibraryFromSource(
            source: pipelineSource,
            label: "mt scene test"
        ),
        let vertex = library.function("scene_vertex"),
        let fragment = library.function("scene_fragment")
        else {
            return nil
        }

        let descriptor = RenderPipelineDescriptor()
        descriptor.setVertexFunction(vertex)
        descriptor.setFragmentFunction(fragment)
        guard descriptor.setColorAttachment(
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
        ) else {
            return nil
        }
        return device.createRenderPipeline(descriptor)
    }

    private func makeLight(name: String) -> Light {
        Light(
            name: name,
            kind: .point,
            position: Vector3(x: 1, y: 2, z: 3),
            direction: Vector3(x: 0, y: -1, z: 0),
            color: Vector3(x: 1, y: 0.5, z: 0.25),
            intensity: 4,
            range: 10,
            innerConeAngle: 0,
            outerConeAngle: 0,
            castsShadow: true,
            enabled: true
        )
    }

    func testMeshAndPrimitiveGeometry() {
        let triangle = Mesh.triangle(name: "triangle")
        XCTAssertEqual(triangle.vertexCount, 3)
        XCTAssertEqual(triangle.indexCount, 3)
        XCTAssertEqual(
            triangle.vertexStride,
            UInt32(MemoryLayout<MeshVertex>.stride)
        )

        let vertex = MeshVertex(
            position: Vector3(x: 0, y: 0, z: 0),
            normal: Vector3(x: 0, y: 0, z: 1),
            texcoord: Vector2(x: 0, y: 0)
        )
        let lines = Lines(name: "lines")
        XCTAssertTrue(lines.append(vertex, vertex))
        XCTAssertEqual(lines.mesh.primitiveType, .line)
        XCTAssertEqual(lines.mesh.vertexCount, 2)

        let points = Points(name: "points")
        XCTAssertTrue(points.append(vertex))
        XCTAssertEqual(points.mesh.primitiveType, .point)
        XCTAssertEqual(points.mesh.vertexCount, 1)
    }

    func testMeshObjectShaderLayoutUsesNativeStages() {
        let layout = MeshObjectShaderLayout.standard()
        XCTAssertEqual(layout.objectEntryPoint, "mt_mesh_object")
        XCTAssertEqual(layout.meshEntryPoint, "mt_mesh_mesh")
        XCTAssertEqual(layout.fragmentEntryPoint, "mt_mesh_fragment")
        XCTAssertNotEqual(layout.requiredFeatures, 0)
    }

    func testMeshRejectsInvalidIndexAndPreservesStorageRules() {
        let mesh = Mesh(
            name: "uint16",
            vertexStride: Mesh.standardVertexStride,
            primitiveType: .triangle,
            indexType: .uint16
        )
        XCTAssertTrue(mesh.appendIndex(UInt32(UInt16.max)))
        XCTAssertFalse(mesh.appendIndex(UInt32(UInt16.max) + 1))
        XCTAssertEqual(mesh.indexCount, 1)

        let incompatible = Mesh(
            name: "custom",
            vertexStride: 12,
            primitiveType: .triangle,
            indexType: .uint32
        )
        XCTAssertFalse(incompatible.appendVertex(
            MeshVertex(
                position: Vector3(x: 0, y: 0, z: 0),
                normal: Vector3(x: 0, y: 0, z: 1),
                texcoord: Vector2(x: 0, y: 0)
            )
        ))
    }

    func testSceneAndDrawableManagerKeepStableNamedEntries() {
        let scene = Scene()
        let object = SceneObject(
            name: "triangle",
            meshName: "triangle",
            transform: Transform.identity(),
            materialID: 7,
            visibilityMask: UInt32.max,
            enabled: true
        )
        XCTAssertTrue(scene.addObject(object))
        XCTAssertFalse(scene.addObject(object))
        XCTAssertEqual(scene.objectCount, 1)
        XCTAssertEqual(scene.object("triangle")?.materialID, 7)

        var updated = object
        updated.transform.position = Vector3(x: 2, y: 0, z: 0)
        XCTAssertTrue(scene.updateObject(updated))
        XCTAssertEqual(scene.objectAt(0)?.transform.position.x, 2)
        XCTAssertTrue(scene.removeObject("triangle"))
        XCTAssertEqual(scene.objectCount, 0)

        let drawables = DrawableManager()
        let triangle = Mesh.triangle(name: "triangle")
        XCTAssertTrue(drawables.addMesh(triangle))
        XCTAssertFalse(drawables.addMesh(triangle))
        XCTAssertEqual(drawables.meshAt(0)?.name, "triangle")
        XCTAssertTrue(drawables.replaceMesh(Mesh(name: "triangle")))
        XCTAssertEqual(drawables.mesh("triangle")?.vertexCount, 0)
        XCTAssertTrue(drawables.removeMesh("triangle"))
        XCTAssertEqual(drawables.meshCount, 0)
    }

    func testLightManagerStoresUpdatesAndRemovesLights() {
        let manager = LightManager()
        let light = makeLight(name: "key")
        XCTAssertTrue(manager.addLight(light))
        XCTAssertFalse(manager.addLight(light))
        XCTAssertEqual(manager.lightCount, 1)
        XCTAssertEqual(manager.light("key")?.kind, .point)

        var updated = light
        updated.intensity = 8
        XCTAssertTrue(manager.updateLight(updated))
        XCTAssertEqual(manager.lightAt(0)?.intensity, 8)
        XCTAssertTrue(manager.removeLight("key"))
        XCTAssertEqual(manager.lightCount, 0)
    }

    func testBuiltInShaderLayoutsDescribeStableMetalEntryPoints() {
        let frame = BuiltInFrameData(
            modelViewProjection: Matrix4x4.identity()
        )
        let material = FixedColorMaterialData(
            color: Vector4(x: 1, y: 0.5, z: 0.25, w: 1)
        )
        XCTAssertEqual(
            MemoryLayout<BuiltInFrameData>.size,
            MemoryLayout<Float>.size * 16
        )
        XCTAssertEqual(
            MemoryLayout<FixedColorMaterialData>.size,
            MemoryLayout<Vector4>.size
        )
        XCTAssertEqual(frame.modelViewProjection.m00, 1)
        XCTAssertEqual(material.color.w, 1)
        XCTAssertEqual(
            frame.makeParameterBlock().length,
            UInt32(MemoryLayout<BuiltInFrameData>.size)
        )
        XCTAssertEqual(
            material.makeParameterBlock().length,
            UInt32(MemoryLayout<FixedColorMaterialData>.size)
        )

        let fixedColor = BuiltInShaderLayout.fixedColor()
        XCTAssertEqual(fixedColor.family, .fixedColor)
        XCTAssertEqual(fixedColor.vertexEntryPoint, "mt_fixed_color_vertex")
        XCTAssertEqual(fixedColor.fragmentEntryPoint, "mt_fixed_color_fragment")
        XCTAssertEqual(
            fixedColor.vertexStride,
            Mesh.standardVertexStride
        )
        XCTAssertEqual(fixedColor.vertexBufferIndex, 0)
        XCTAssertEqual(fixedColor.frameBufferIndex, 1)
        XCTAssertEqual(fixedColor.materialBufferIndex, 2)

        let clustering = BuiltInShaderLayout.lightClustering()
        XCTAssertEqual(clustering.family, .lightClustering)
        XCTAssertEqual(
            clustering.computeEntryPoint,
            "mt_light_cluster_kernel"
        )
    }

    func testDrawableUploadAndMeshBatchCreationUseExplicitGPUResources() {
        guard let device = Device.systemDefault(),
              let pipeline = makePipeline(device: device)
        else {
            return
        }

        let manager = DrawableManager()
        XCTAssertTrue(manager.addMesh(Mesh.triangle(name: "triangle")))
        guard let gpuMesh = manager.uploadMesh(
            "triangle",
            device: device,
            storageMode: .shared,
            label: "mt scene mesh"
        ) else {
            XCTFail(device.errorDescription)
            return
        }

        XCTAssertEqual(gpuMesh.vertexCount, 3)
        XCTAssertEqual(gpuMesh.indexCount, 3)
        guard let batch = gpuMesh.makeRenderBatch(
            pipeline: pipeline,
            transparent: false,
            label: "triangle batch"
        ) else {
            XCTFail("MeshGPU could not create a render batch.")
            return
        }
        XCTAssertTrue(batch.hasIndexBuffer)
        XCTAssertEqual(batch.vertexCount, 3)
    }

    func testMaterialManagerAndLightUploadAreDeviceScoped() {
        guard let device = Device.systemDefault(),
              let pipeline = makePipeline(device: device)
        else {
            return
        }

        let materials = MaterialManager()
        let material = Material(name: "default", pipeline: pipeline)
        XCTAssertTrue(material.isSupported(device: device))
        XCTAssertTrue(materials.addMaterial(material))
        XCTAssertFalse(materials.addMaterial(material))
        XCTAssertEqual(materials.materialAt(0)?.name, "default")
        XCTAssertTrue(materials.removeMaterial("default"))

        let lights = LightManager()
        XCTAssertTrue(lights.addLight(makeLight(name: "key")))
        guard let buffer = lights.upload(
            device: device,
            storageMode: .shared,
            label: "mt light data"
        ) else {
            XCTFail(device.errorDescription)
            return
        }
        XCTAssertGreaterThan(buffer.length, 0)
    }
}

