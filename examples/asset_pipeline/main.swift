import Foundation
import MTAssetPipeline
import Darwin

let ppm: [UInt8] = [
    80, 53, 10, // P5
    50, 32, 49, 10, // 2 1
    50, 53, 53, 10, // 255
    64, 192
]
let loaded = AssetTextureLoader().loadPPM(bytes: ppm)
guard let texture = loaded.texture else {
    print("asset texture load failed: \(loaded.diagnostics)")
    exit(1)
}

let mesh = AssetMesh(
    name: "example.mesh",
    vertices: [
        AssetVertex(
            position: AssetVector3(x: 0, y: 1, z: 0),
            normal: AssetVector3(x: 0, y: 0, z: 1),
            texcoord: AssetVector2(x: 0.5, y: 1)
        ),
        AssetVertex(
            position: AssetVector3(x: -1, y: -1, z: 0),
            normal: AssetVector3(x: 0, y: 0, z: 1),
            texcoord: AssetVector2(x: 0, y: 0)
        ),
        AssetVertex(
            position: AssetVector3(x: 1, y: -1, z: 0),
            normal: AssetVector3(x: 0, y: 0, z: 1),
            texcoord: AssetVector2(x: 1, y: 0)
        )
    ],
    indices: [0, 1, 2]
)
let document = AssetDocument(
    name: "asset-pipeline-example",
    source: AssetSourceMetadata(
        sourceURI: "memory://asset-pipeline-example",
        format: "fixture",
        importerName: "example",
        importerVersion: "1",
        contentHash: "example",
        coordinateSystem: .rightHandedYUp,
        colorSpace: .linear
    ),
    meshes: [mesh],
    textures: [texture]
)

guard let serialized = AssetSerializer.encode(document: document) else {
    print("asset serialization failed")
    exit(1)
}
let decoded = AssetSerializer.decode(bytes: serialized)
print(
    "asset pipeline: meshes=\(decoded.document?.meshes.count ?? 0) "
        + "textures=\(decoded.document?.textures.count ?? 0) "
        + "bytes=\(serialized.count)"
)
