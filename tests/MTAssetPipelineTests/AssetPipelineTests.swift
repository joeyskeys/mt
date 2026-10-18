import Foundation
import MTAssetPipeline
import MTCore
import XCTest

final class AssetPipelineTests: XCTestCase {
    private func triangle() -> AssetMesh {
        AssetMesh(
            name: "triangle",
            vertices: [
                AssetVertex(
                    position: AssetVector3(x: 0, y: 1, z: 0),
                    normal: AssetVector3(x: 0, y: 1, z: 0),
                    texcoord: AssetVector2(x: 0, y: 1)
                ),
                AssetVertex(
                    position: AssetVector3(x: -1, y: 0, z: 0),
                    normal: AssetVector3(x: 0, y: 1, z: 0),
                    texcoord: AssetVector2(x: 0, y: 0)
                ),
                AssetVertex(
                    position: AssetVector3(x: 1, y: 0, z: 0),
                    normal: AssetVector3(x: 0, y: 1, z: 0),
                    texcoord: AssetVector2(x: 1, y: 0)
                )
            ],
            indices: [0, 1, 2]
        )
    }

    private func sourceMetadata(format: String = "fixture") -> AssetSourceMetadata {
        AssetSourceMetadata(
            sourceURI: "fixture://triangle",
            format: format,
            importerName: "test-importer",
            importerVersion: "1.0",
            contentHash: "fixture",
            coordinateSystem: .rightHandedYUp,
            colorSpace: .linear
        )
    }

    func testCoordinateConversionAndAutomaticWindingAreObservable() {
        let pipeline = AssetPipeline()
        let zUp = AssetConversionPolicy(
            sourceCoordinates: .rightHandedYUp,
            targetCoordinates: .rightHandedZUp
        )
        let converted = pipeline.convertMesh(triangle(), policy: zUp)

        XCTAssertTrue(converted.succeeded)
        XCTAssertFalse(converted.didReverseWinding)
        XCTAssertEqual(converted.mesh?.vertex(at: 0)?.position.z, 1)
        XCTAssertEqual(converted.mesh?.vertex(at: 0)?.position.y, 0)

        let leftHanded = AssetCoordinateSystem(
            upAxis: .y,
            forwardAxis: .z,
            handedness: .left,
            unitScale: 1
        )
        let reflected = pipeline.convertMesh(
            triangle(),
            policy: AssetConversionPolicy(
                sourceCoordinates: .rightHandedYUp,
                targetCoordinates: leftHanded
            )
        )
        XCTAssertTrue(reflected.succeeded)
        XCTAssertTrue(reflected.didReverseWinding)
        XCTAssertEqual(reflected.mesh?.indexCount, 3)
    }

    func testPlan16ConversionReportsDroppedChannelsAndBuildsMeshlets() {
        var mesh = triangle()
        mesh.vertices[0].hasTangent = true
        mesh.vertices[0].tangent = AssetVector4(
            x: 1,
            y: 0,
            z: 0,
            w: 1
        )
        mesh.vertices[0].hasColor = true
        mesh.meshletDescriptors = [
            AssetMeshletDescriptor(
                vertexOffset: 0,
                vertexCount: 3,
                primitiveOffset: 0,
                primitiveCount: 1,
                lodLevel: 0,
                boundsCenter: AssetVector3(x: 0, y: 0, z: 0),
                boundsRadius: 1
            )
        ]
        mesh.meshletVertexData = Array(repeating: 0, count: 36)
        mesh.meshletPrimitiveData = [0, 1, 2]

        let result = AssetPipeline().convertMesh(mesh)
        XCTAssertTrue(result.succeeded)
        XCTAssertEqual(result.discardedTangentCount, 1)
        XCTAssertEqual(result.discardedColorCount, 1)
        XCTAssertTrue(result.mesh?.retainsMeshletRepresentation ?? false)
        XCTAssertTrue(
            result.diagnostics.contains {
                $0.code == .lossyConversion
            }
        )
    }

    func testMaterialConversionClampsAndMapsToPBRData() {
        let result = AssetPipeline().convertMaterial(
            AssetMaterial(
                name: "material",
                baseColor: AssetVector4(x: 1, y: 0.5, z: 0, w: 1),
                emissiveColor: AssetVector4(x: 0, y: 0, z: 0, w: 1),
                metallic: 2,
                roughness: -1,
                normalScale: -2,
                occlusionStrength: 3
            )
        )
        XCTAssertTrue(result.succeeded)
        XCTAssertEqual(result.data?.metallic, 1)
        XCTAssertEqual(result.data?.roughness, 0)
        XCTAssertEqual(result.data?.normalScale, 0)
        XCTAssertEqual(result.data?.occlusionStrength, 1)
        XCTAssertTrue(
            result.diagnostics.contains {
                $0.code == .lossyConversion
            }
        )
    }

    func testPPMLoaderAndTexturePolicyAreDeterministic() {
        let bytes: [UInt8] = [
            80, 54, 10, // P6
            50, 32, 49, 10, // 2 1
            50, 53, 53, 10, // 255
            255, 0, 0, 0, 255, 0
        ]
        let loaded = AssetTextureLoader().loadPPM(bytes: bytes)
        XCTAssertTrue(loaded.succeeded)
        XCTAssertEqual(loaded.texture?.width, 2)
        XCTAssertEqual(loaded.texture?.pixelFormat, .rgba8Unorm)
        XCTAssertEqual(loaded.texture?.levels.first?.pixels, [
            255, 0, 0, 255,
            0, 255, 0, 255
        ])

        let source = AssetTexture(
            name: "mipped",
            pixelFormat: .rgba8Unorm,
            colorSpace: .linear,
            origin: .topLeft,
            levels: [
                AssetTextureLevel(
                    width: 2,
                    height: 2,
                    pixels: [
                        255, 0, 0, 255,
                        0, 255, 0, 255,
                        0, 0, 255, 255,
                        255, 255, 255, 255
                    ]
                )
            ]
        )
        let policy = AssetConversionPolicy(
            sourceCoordinates: .rightHandedYUp,
            targetCoordinates: .rightHandedYUp,
            targetUVOrigin: .bottomLeft,
            textureFormatPolicy: .bgra8Unorm,
            mipPolicy: .generate
        )
        let converted = AssetPipeline().convertTexture(
            source,
            policy: policy
        )
        XCTAssertTrue(converted.succeeded)
        XCTAssertEqual(converted.texture?.pixelFormat, .bgra8Unorm)
        XCTAssertEqual(converted.texture?.mipLevelCount, 2)
        guard let firstLevel = converted.texture?.levels.first else {
            XCTFail("The converted texture has no base level.")
            return
        }
        XCTAssertEqual(
            Array(firstLevel.pixels.prefix(4)),
            [UInt8(255), UInt8(0), UInt8(0), UInt8(255)]
        )
    }

    func testSerializationRoundTripAndUnversionedMigration() throws {
        let document = AssetDocument(
            name: "fixture",
            source: sourceMetadata(),
            meshes: [triangle()],
            materials: [AssetMaterial(name: "material")],
            nodes: [
                AssetNode(
                    name: "node",
                    meshName: "triangle",
                    transform: .identity,
                    materialID: 0,
                    visibilityMask: UInt32.max,
                    enabled: true
                )
            ]
        )
        guard let bytes = AssetSerializer.encode(document: document) else {
            XCTFail("The fixture should serialize.")
            return
        }
        let decoded = AssetSerializer.decode(bytes: bytes)
        XCTAssertTrue(decoded.succeeded)
        XCTAssertFalse(decoded.migrated)
        XCTAssertEqual(decoded.document?.name, "fixture")
        XCTAssertEqual(decoded.document?.meshes.count, 1)

        var legacyObject = try XCTUnwrap(
            JSONSerialization.jsonObject(
                with: Data(bytes),
                options: []
            ) as? [String: Any]
        )
        legacyObject.removeValue(forKey: "schemaMajor")
        legacyObject.removeValue(forKey: "schemaMinor")
        let legacyBytes = try JSONSerialization.data(
            withJSONObject: legacyObject,
            options: []
        )
        let migrated = AssetSerializer.decode(bytes: Array(legacyBytes))
        XCTAssertTrue(migrated.succeeded)
        XCTAssertTrue(migrated.migrated)
        XCTAssertEqual(
            migrated.document?.schemaMinor,
            AssetSerializer.currentSchemaMinor
        )
    }

    func testImporterAdapterAndDocumentConversionKeepOwnershipExplicit() {
        let document = AssetDocument(
            name: "fixture",
            source: sourceMetadata(),
            meshes: [triangle()],
            curves: [
                AssetCurve(
                    name: "path",
                    points: [
                        AssetCurvePoint(
                            position: AssetVector3(x: 0, y: 0, z: 0),
                            width: 1,
                            color: AssetVector4(x: 1, y: 1, z: 1, w: 1)
                        ),
                        AssetCurvePoint(
                            position: AssetVector3(x: 1, y: 0, z: 0),
                            width: 1,
                            color: AssetVector4(x: 1, y: 1, z: 1, w: 1)
                        )
                    ]
                )
            ],
            nodes: [
                AssetNode(
                    name: "node",
                    meshName: "triangle",
                    transform: .identity,
                    materialID: 0,
                    visibilityMask: UInt32.max,
                    enabled: true
                )
            ]
        )
        let adapter = AssetImporterAdapter(
            importerName: "external",
            importerVersion: "1",
            supportedFormats: ["fixture"]
        )
        XCTAssertTrue(adapter.supports(format: "FIXTURE"))
        XCTAssertTrue(adapter.validate(document: document).succeeded)

        let converted = AssetPipeline().convertDocument(document)
        XCTAssertTrue(converted.succeeded)
        XCTAssertEqual(converted.meshes.count, 1)
        XCTAssertEqual(converted.curves.count, 1)
        XCTAssertEqual(converted.scene?.objectCount, 1)
    }
}
