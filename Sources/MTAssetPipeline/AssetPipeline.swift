import Foundation
import MTCore

public enum AssetDiagnosticSeverity: Int32, Codable {
    case info
    case warning
    case error
}

public enum AssetDiagnosticCode: Int32, Codable {
    case none
    case invalidInput
    case invalidGeometry
    case invalidTexture
    case invalidIndex
    case unsupportedFormat
    case unsupportedVersion
    case lossyConversion
    case serialization
    case migration
    case capability
}

public struct AssetDiagnostic: Codable {
    public var severity: AssetDiagnosticSeverity
    public var code: AssetDiagnosticCode
    public var source: String
    public var field: String
    public var message: String

    public init(
        severity: AssetDiagnosticSeverity,
        code: AssetDiagnosticCode,
        source: String,
        field: String,
        message: String
    ) {
        self.severity = severity
        self.code = code
        self.source = source
        self.field = field
        self.message = message
    }
}

public final class AssetDiagnosticReport {
    private var storage: [AssetDiagnostic] = []

    public init() {}

    public var diagnostics: [AssetDiagnostic] {
        storage
    }

    public var diagnosticCount: UInt32 {
        UInt32(min(storage.count, Int(UInt32.max)))
    }

    public var errorCount: UInt32 {
        UInt32(
            min(
                storage.filter { $0.severity == .error }.count,
                Int(UInt32.max)
            )
        )
    }

    public var hasErrors: Bool {
        storage.contains { $0.severity == .error }
    }

    public func diagnostic(at index: UInt32) -> AssetDiagnostic? {
        guard index < UInt32(storage.count) else {
            return nil
        }
        return storage[Int(index)]
    }

    public func add(_ diagnostic: AssetDiagnostic) {
        storage.append(diagnostic)
    }

    public func add(
        severity: AssetDiagnosticSeverity,
        code: AssetDiagnosticCode,
        source: String,
        field: String,
        message: String
    ) {
        add(
            AssetDiagnostic(
                severity: severity,
                code: code,
                source: source,
                field: field,
                message: message
            )
        )
    }

    public func merge(_ diagnostics: [AssetDiagnostic]) {
        storage.append(contentsOf: diagnostics)
    }

    public func clear() {
        storage.removeAll(keepingCapacity: true)
    }
}

public enum AssetAxis: Int32, Codable {
    case x
    case y
    case z
}

public enum AssetHandedness: Int32, Codable {
    case right
    case left
}

public enum AssetWindingPolicy: Int32, Codable {
    case automatic
    case preserve
    case reverse
}

public enum AssetColorSpace: Int32, Codable {
    case unknown
    case linear
    case srgb
    case displayP3
}

public enum AssetTextureOrigin: Int32, Codable {
    case topLeft
    case bottomLeft
}

public enum AssetTextureFormatPolicy: Int32, Codable {
    case preserve
    case r8Unorm
    case rgba8Unorm
    case bgra8Unorm
}

public enum AssetTexturePixelFormat: Int32, Codable {
    case r8Unorm
    case rgba8Unorm
    case bgra8Unorm
}

public enum AssetMipPolicy: Int32, Codable {
    case baseOnly
    case preserve
    case generate
}

public enum AssetPrimitiveType: Int32, Codable {
    case point
    case line
    case triangle
}

public enum AssetAlphaMode: Int32, Codable {
    case opaque
    case mask
    case blend
}

public enum AssetTextureSemantic: Int32, Codable {
    case unknown
    case baseColor
    case normal
    case metallicRoughness
    case occlusion
    case emissive
    case opacity
}

public struct AssetVector2: Codable, Equatable {
    public var x: Float
    public var y: Float

    public init(x: Float, y: Float) {
        self.x = x
        self.y = y
    }
}

public struct AssetVector3: Codable, Equatable {
    public var x: Float
    public var y: Float
    public var z: Float

    public init(x: Float, y: Float, z: Float) {
        self.x = x
        self.y = y
        self.z = z
    }
}

public struct AssetVector4: Codable, Equatable {
    public var x: Float
    public var y: Float
    public var z: Float
    public var w: Float

    public init(x: Float, y: Float, z: Float, w: Float) {
        self.x = x
        self.y = y
        self.z = z
        self.w = w
    }
}

public struct AssetCoordinateSystem: Codable, Equatable {
    public var upAxis: AssetAxis
    public var forwardAxis: AssetAxis
    public var handedness: AssetHandedness
    public var unitScale: Float

    public init(
        upAxis: AssetAxis,
        forwardAxis: AssetAxis,
        handedness: AssetHandedness,
        unitScale: Float
    ) {
        self.upAxis = upAxis
        self.forwardAxis = forwardAxis
        self.handedness = handedness
        self.unitScale = unitScale
    }

    public static var rightHandedYUp: AssetCoordinateSystem {
        AssetCoordinateSystem(
            upAxis: .y,
            forwardAxis: .z,
            handedness: .right,
            unitScale: 1
        )
    }

    public static var rightHandedZUp: AssetCoordinateSystem {
        AssetCoordinateSystem(
            upAxis: .z,
            forwardAxis: .y,
            handedness: .right,
            unitScale: 1
        )
    }

    public var isValid: Bool {
        upAxis != forwardAxis
            && unitScale.isFinite
            && unitScale > 0
    }
}

public struct AssetConversionPolicy: Codable {
    public var sourceCoordinates: AssetCoordinateSystem
    public var targetCoordinates: AssetCoordinateSystem
    public var sourceColorSpace: AssetColorSpace
    public var targetColorSpace: AssetColorSpace
    public var sourceUVOrigin: AssetTextureOrigin
    public var targetUVOrigin: AssetTextureOrigin
    public var windingPolicy: AssetWindingPolicy
    public var textureFormatPolicy: AssetTextureFormatPolicy
    public var mipPolicy: AssetMipPolicy
    public var preserveTangents: Bool
    public var preserveVertexColors: Bool

    public init(
        sourceCoordinates: AssetCoordinateSystem,
        targetCoordinates: AssetCoordinateSystem,
        sourceColorSpace: AssetColorSpace = .unknown,
        targetColorSpace: AssetColorSpace = .unknown,
        sourceUVOrigin: AssetTextureOrigin = .topLeft,
        targetUVOrigin: AssetTextureOrigin = .topLeft,
        windingPolicy: AssetWindingPolicy = .automatic,
        textureFormatPolicy: AssetTextureFormatPolicy = .preserve,
        mipPolicy: AssetMipPolicy = .baseOnly,
        preserveTangents: Bool = true,
        preserveVertexColors: Bool = true
    ) {
        self.sourceCoordinates = sourceCoordinates
        self.targetCoordinates = targetCoordinates
        self.sourceColorSpace = sourceColorSpace
        self.targetColorSpace = targetColorSpace
        self.sourceUVOrigin = sourceUVOrigin
        self.targetUVOrigin = targetUVOrigin
        self.windingPolicy = windingPolicy
        self.textureFormatPolicy = textureFormatPolicy
        self.mipPolicy = mipPolicy
        self.preserveTangents = preserveTangents
        self.preserveVertexColors = preserveVertexColors
    }

    public static var identity: AssetConversionPolicy {
        AssetConversionPolicy(
            sourceCoordinates: .rightHandedYUp,
            targetCoordinates: .rightHandedYUp
        )
    }

    public var isValid: Bool {
        sourceCoordinates.isValid && targetCoordinates.isValid
    }
}

public struct AssetSourceMetadata: Codable {
    public var sourceURI: String
    public var format: String
    public var importerName: String
    public var importerVersion: String
    public var contentHash: String
    public var coordinateSystem: AssetCoordinateSystem
    public var colorSpace: AssetColorSpace

    public init(
        sourceURI: String,
        format: String,
        importerName: String,
        importerVersion: String,
        contentHash: String,
        coordinateSystem: AssetCoordinateSystem,
        colorSpace: AssetColorSpace
    ) {
        self.sourceURI = sourceURI
        self.format = format
        self.importerName = importerName
        self.importerVersion = importerVersion
        self.contentHash = contentHash
        self.coordinateSystem = coordinateSystem
        self.colorSpace = colorSpace
    }

    public static var unknown: AssetSourceMetadata {
        AssetSourceMetadata(
            sourceURI: "",
            format: "",
            importerName: "",
            importerVersion: "",
            contentHash: "",
            coordinateSystem: .rightHandedYUp,
            colorSpace: .unknown
        )
    }
}

public struct AssetVertex: Codable {
    public var position: AssetVector3
    public var normal: AssetVector3
    public var tangent: AssetVector4
    public var texcoord: AssetVector2
    public var color: AssetVector4
    public var hasTangent: Bool
    public var hasColor: Bool

    public init(
        position: AssetVector3,
        normal: AssetVector3,
        tangent: AssetVector4 = AssetVector4(x: 0, y: 0, z: 0, w: 1),
        texcoord: AssetVector2 = AssetVector2(x: 0, y: 0),
        color: AssetVector4 = AssetVector4(x: 1, y: 1, z: 1, w: 1),
        hasTangent: Bool = false,
        hasColor: Bool = false
    ) {
        self.position = position
        self.normal = normal
        self.tangent = tangent
        self.texcoord = texcoord
        self.color = color
        self.hasTangent = hasTangent
        self.hasColor = hasColor
    }
}

public struct AssetLODLevel: Codable {
    public var maxDistance: Float
    public var meshName: String
    public var level: UInt32

    public init(maxDistance: Float, meshName: String, level: UInt32) {
        self.maxDistance = maxDistance
        self.meshName = meshName
        self.level = level
    }
}

public struct AssetCullingMetadata: Codable {
    public var center: AssetVector3
    public var radius: Float
    public var visibilityMask: UInt32
    public var enabled: Bool

    public init(
        center: AssetVector3,
        radius: Float,
        visibilityMask: UInt32,
        enabled: Bool
    ) {
        self.center = center
        self.radius = radius
        self.visibilityMask = visibilityMask
        self.enabled = enabled
    }
}

public struct AssetMeshletDescriptor: Codable {
    public var vertexOffset: UInt32
    public var vertexCount: UInt32
    public var primitiveOffset: UInt32
    public var primitiveCount: UInt32
    public var lodLevel: UInt32
    public var boundsCenter: AssetVector3
    public var boundsRadius: Float

    public init(
        vertexOffset: UInt32,
        vertexCount: UInt32,
        primitiveOffset: UInt32,
        primitiveCount: UInt32,
        lodLevel: UInt32,
        boundsCenter: AssetVector3,
        boundsRadius: Float
    ) {
        self.vertexOffset = vertexOffset
        self.vertexCount = vertexCount
        self.primitiveOffset = primitiveOffset
        self.primitiveCount = primitiveCount
        self.lodLevel = lodLevel
        self.boundsCenter = boundsCenter
        self.boundsRadius = boundsRadius
    }
}

public struct AssetMesh: Codable {
    public var name: String
    public var primitiveType: AssetPrimitiveType
    public var vertices: [AssetVertex]
    public var indices: [UInt32]
    public var lodLevels: [AssetLODLevel]
    public var fallbackMeshName: String
    public var culling: AssetCullingMetadata?
    public var meshletDescriptors: [AssetMeshletDescriptor]
    public var meshletVertexData: [UInt8]
    public var meshletPrimitiveData: [UInt8]

    public init(
        name: String,
        primitiveType: AssetPrimitiveType = .triangle,
        vertices: [AssetVertex] = [],
        indices: [UInt32] = [],
        lodLevels: [AssetLODLevel] = [],
        fallbackMeshName: String = "",
        culling: AssetCullingMetadata? = nil,
        meshletDescriptors: [AssetMeshletDescriptor] = [],
        meshletVertexData: [UInt8] = [],
        meshletPrimitiveData: [UInt8] = []
    ) {
        self.name = name
        self.primitiveType = primitiveType
        self.vertices = vertices
        self.indices = indices
        self.lodLevels = lodLevels
        self.fallbackMeshName = fallbackMeshName
        self.culling = culling
        self.meshletDescriptors = meshletDescriptors
        self.meshletVertexData = meshletVertexData
        self.meshletPrimitiveData = meshletPrimitiveData
    }

    public var isValid: Bool {
        guard !name.isEmpty,
              !vertices.isEmpty,
              vertices.count <= Int(UInt32.max) else {
            return false
        }
        guard vertices.allSatisfy({ vertex in
            isFinite(vertex.position)
                && isFinite(vertex.normal)
                && isFinite(vertex.tangent)
                && isFinite(vertex.texcoord)
                && isFinite(vertex.color)
        }) else {
            return false
        }
        if primitiveType == .triangle && indices.count % 3 != 0 {
            return false
        }
        guard indices.allSatisfy({ $0 < UInt32(vertices.count) }) else {
            return false
        }
        if let culling {
            guard culling.radius.isFinite,
                  culling.radius >= 0,
                  isFinite(culling.center) else {
                return false
            }
        }
        guard lodLevels.allSatisfy({
            $0.maxDistance.isFinite
                && $0.maxDistance >= 0
                && !$0.meshName.isEmpty
        }),
        (lodLevels.isEmpty || !fallbackMeshName.isEmpty) else {
            return false
        }
        if !meshletDescriptors.isEmpty {
            guard !meshletVertexData.isEmpty,
                  !meshletPrimitiveData.isEmpty,
                  meshletDescriptors.allSatisfy({
                      $0.vertexCount > 0
                          && $0.primitiveCount > 0
                          && $0.boundsRadius.isFinite
                          && $0.boundsRadius >= 0
                          && isFinite($0.boundsCenter)
                  }) else {
                return false
            }
        }
        return true
    }
}

public struct AssetMeshConversionResult {
    public var normalizedMesh: AssetMesh?
    public var mesh: Mesh?
    public var diagnostics: [AssetDiagnostic]
    public var didReverseWinding: Bool
    public var discardedTangentCount: UInt32
    public var discardedColorCount: UInt32

    public init(
        normalizedMesh: AssetMesh?,
        mesh: Mesh?,
        diagnostics: [AssetDiagnostic],
        didReverseWinding: Bool,
        discardedTangentCount: UInt32,
        discardedColorCount: UInt32
    ) {
        self.normalizedMesh = normalizedMesh
        self.mesh = mesh
        self.diagnostics = diagnostics
        self.didReverseWinding = didReverseWinding
        self.discardedTangentCount = discardedTangentCount
        self.discardedColorCount = discardedColorCount
    }

    public var succeeded: Bool {
        mesh != nil && !diagnostics.contains { $0.severity == .error }
    }
}

public struct AssetTextureLevel: Codable {
    public var width: UInt32
    public var height: UInt32
    public var pixels: [UInt8]

    public init(width: UInt32, height: UInt32, pixels: [UInt8]) {
        self.width = width
        self.height = height
        self.pixels = pixels
    }
}

public struct AssetTexture: Codable {
    public var name: String
    public var pixelFormat: AssetTexturePixelFormat
    public var colorSpace: AssetColorSpace
    public var origin: AssetTextureOrigin
    public var levels: [AssetTextureLevel]

    public init(
        name: String,
        pixelFormat: AssetTexturePixelFormat,
        colorSpace: AssetColorSpace,
        origin: AssetTextureOrigin,
        levels: [AssetTextureLevel]
    ) {
        self.name = name
        self.pixelFormat = pixelFormat
        self.colorSpace = colorSpace
        self.origin = origin
        self.levels = levels
    }

    public var width: UInt32 {
        levels.first?.width ?? 0
    }

    public var height: UInt32 {
        levels.first?.height ?? 0
    }

    public var mipLevelCount: UInt32 {
        UInt32(min(levels.count, Int(UInt32.max)))
    }

    public var bytesPerPixel: UInt32 {
        pixelFormat == .r8Unorm ? 1 : 4
    }

    public var isValid: Bool {
        !name.isEmpty
            && !levels.isEmpty
            && levels.allSatisfy { level in
                guard level.width > 0, level.height > 0 else {
                    return false
                }
                guard let expected = byteCount(
                    width: level.width,
                    height: level.height,
                    bytesPerPixel: bytesPerPixel
                ) else {
                    return false
                }
                return expected <= UInt64(Int.max)
                    && expected == UInt64(level.pixels.count)
            }
            && levels.enumerated().allSatisfy { index, level in
                index == 0
                    || (
                        level.width
                            == max(1, levels[index - 1].width / 2)
                        && level.height
                            == max(1, levels[index - 1].height / 2)
                    )
            }
    }

    public func makeDescriptor(
        storageMode: StorageMode,
        usage: UInt32 = UInt32(TextureUsage.shaderRead.rawValue),
        label: String = ""
    ) -> TextureDescriptor? {
        guard isValid, levels.count <= Int(UInt32.max) else {
            return nil
        }
        return TextureDescriptor(
            textureType: .twoD,
            pixelFormat: pixelFormat.coreValue,
            width: width,
            height: height,
            depth: 1,
            arrayLength: 1,
            mipLevelCount: UInt32(levels.count),
            sampleCount: 1,
            usage: usage,
            storageMode: storageMode,
            cpuCacheMode: .defaultCache,
            hazardMode: .defaultMode,
            label: label.isEmpty ? name : label
        )
    }

    public func upload(
        device: Device,
        storageMode: StorageMode = .shared,
        usage: UInt32 = UInt32(TextureUsage.shaderRead.rawValue),
        label: String = ""
    ) -> Texture? {
        guard storageMode == .shared || storageMode == .managed,
              let descriptor = makeDescriptor(
                  storageMode: storageMode,
                  usage: usage,
                  label: label
              ),
              let texture = device.createTexture(descriptor) else {
            return nil
        }
        for (index, level) in levels.enumerated() {
            let didUpload = level.pixels.withUnsafeBufferPointer { buffer in
                guard let baseAddress = buffer.baseAddress else {
                    return false
                }
                let bytesPerRow = UInt64(level.width) * UInt64(bytesPerPixel)
                let region = TextureRegion(
                    mipLevel: UInt32(index),
                    slice: 0,
                    origin: Extent3D(width: 0, height: 0, depth: 0),
                    size: Extent3D(
                        width: level.width,
                        height: level.height,
                        depth: 1
                    )
                )
                return texture.uploadRegion(
                    source: UnsafeRawPointer(baseAddress),
                    transfer: TextureTransferDescriptor(
                        region: region,
                        bytesPerRow: bytesPerRow,
                        bytesPerImage: bytesPerRow * UInt64(level.height)
                    )
                )
            }
            guard didUpload else {
                return nil
            }
        }
        return texture
    }
}

public struct AssetTextureConversionResult {
    public var texture: AssetTexture?
    public var diagnostics: [AssetDiagnostic]

    public init(
        texture: AssetTexture?,
        diagnostics: [AssetDiagnostic]
    ) {
        self.texture = texture
        self.diagnostics = diagnostics
    }

    public var succeeded: Bool {
        texture != nil && !diagnostics.contains { $0.severity == .error }
    }
}

public struct AssetTextureLoadResult {
    public var texture: AssetTexture?
    public var diagnostics: [AssetDiagnostic]

    public init(
        texture: AssetTexture?,
        diagnostics: [AssetDiagnostic]
    ) {
        self.texture = texture
        self.diagnostics = diagnostics
    }

    public var succeeded: Bool {
        texture != nil && !diagnostics.contains { $0.severity == .error }
    }
}

public struct AssetTextureReference: Codable {
    public var name: String
    public var semantic: AssetTextureSemantic
    public var textureCoordinateSet: UInt32

    public init(
        name: String,
        semantic: AssetTextureSemantic,
        textureCoordinateSet: UInt32 = 0
    ) {
        self.name = name
        self.semantic = semantic
        self.textureCoordinateSet = textureCoordinateSet
    }
}

public struct AssetMaterial: Codable {
    public var name: String
    public var colorSpace: AssetColorSpace
    public var baseColor: AssetVector4
    public var emissiveColor: AssetVector4
    public var metallic: Float
    public var roughness: Float
    public var normalScale: Float
    public var occlusionStrength: Float
    public var alphaMode: AssetAlphaMode
    public var doubleSided: Bool
    public var textures: [AssetTextureReference]

    public init(
        name: String,
        colorSpace: AssetColorSpace = .linear,
        baseColor: AssetVector4 = AssetVector4(x: 1, y: 1, z: 1, w: 1),
        emissiveColor: AssetVector4 = AssetVector4(x: 0, y: 0, z: 0, w: 1),
        metallic: Float = 0,
        roughness: Float = 1,
        normalScale: Float = 1,
        occlusionStrength: Float = 1,
        alphaMode: AssetAlphaMode = .opaque,
        doubleSided: Bool = false,
        textures: [AssetTextureReference] = []
    ) {
        self.name = name
        self.colorSpace = colorSpace
        self.baseColor = baseColor
        self.emissiveColor = emissiveColor
        self.metallic = metallic
        self.roughness = roughness
        self.normalScale = normalScale
        self.occlusionStrength = occlusionStrength
        self.alphaMode = alphaMode
        self.doubleSided = doubleSided
        self.textures = textures
    }

    public var isValid: Bool {
        !name.isEmpty
            && isFinite(baseColor)
            && isFinite(emissiveColor)
            && metallic.isFinite
            && roughness.isFinite
            && normalScale.isFinite
            && occlusionStrength.isFinite
    }
}

public struct AssetMaterialConversionResult {
    public var material: AssetMaterial?
    public var data: PBRMaterialData?
    public var diagnostics: [AssetDiagnostic]

    public init(
        material: AssetMaterial?,
        data: PBRMaterialData?,
        diagnostics: [AssetDiagnostic]
    ) {
        self.material = material
        self.data = data
        self.diagnostics = diagnostics
    }

    public var succeeded: Bool {
        data != nil && !diagnostics.contains { $0.severity == .error }
    }
}

public enum AssetCurveInterpolation: Int32, Codable {
    case polyline
    case bezier
    case catmullRom
}

public struct AssetCurvePoint: Codable {
    public var position: AssetVector3
    public var width: Float
    public var color: AssetVector4

    public init(
        position: AssetVector3,
        width: Float,
        color: AssetVector4
    ) {
        self.position = position
        self.width = width
        self.color = color
    }
}

public struct AssetCurve: Codable {
    public var name: String
    public var interpolation: AssetCurveInterpolation
    public var points: [AssetCurvePoint]

    public init(
        name: String,
        interpolation: AssetCurveInterpolation = .polyline,
        points: [AssetCurvePoint] = []
    ) {
        self.name = name
        self.interpolation = interpolation
        self.points = points
    }

    public var isValid: Bool {
        !name.isEmpty
            && points.allSatisfy {
                $0.width.isFinite
                    && $0.width >= 0
                    && isFinite($0.position)
                    && isFinite($0.color)
            }
    }

    public func makeCoreCurve(
        policy: AssetConversionPolicy = .identity
    ) -> Curve? {
        guard isValid, policy.isValid else {
            return nil
        }
        let coreInterpolation: CurveInterpolation
        switch interpolation {
        case .polyline:
            coreInterpolation = .polyline
        case .bezier:
            coreInterpolation = .bezier
        case .catmullRom:
            coreInterpolation = .catmullRom
        }
        let curve = Curve(name: name, interpolation: coreInterpolation)
        for point in points {
            let convertedPosition = convertPosition(
                point.position,
                source: policy.sourceCoordinates,
                target: policy.targetCoordinates
            )
            guard curve.appendPoint(
                CurvePoint(
                    position: toCore(convertedPosition),
                    width: point.width,
                    color: toCore(
                        AssetColorConverter.convert(
                            point.color,
                            from: policy.sourceColorSpace,
                            to: policy.targetColorSpace
                        )
                    )
                )
            ) else {
                return nil
            }
        }
        return curve
    }
}

public struct AssetTransform: Codable {
    public var position: AssetVector3
    public var rotation: AssetVector3
    public var scale: AssetVector3

    public init(
        position: AssetVector3,
        rotation: AssetVector3,
        scale: AssetVector3
    ) {
        self.position = position
        self.rotation = rotation
        self.scale = scale
    }

    public static var identity: AssetTransform {
        AssetTransform(
            position: AssetVector3(x: 0, y: 0, z: 0),
            rotation: AssetVector3(x: 0, y: 0, z: 0),
            scale: AssetVector3(x: 1, y: 1, z: 1)
        )
    }

    public var isValid: Bool {
        isFinite(position)
            && isFinite(rotation)
            && isFinite(scale)
    }

    public func converted(
        policy: AssetConversionPolicy
    ) -> AssetTransform {
        guard policy.isValid else {
            return self
        }
        let convertedScale = convertDirection(
            scale,
            source: policy.sourceCoordinates,
            target: policy.targetCoordinates
        )
        return AssetTransform(
            position: convertPosition(
                position,
                source: policy.sourceCoordinates,
                target: policy.targetCoordinates
            ),
            rotation: convertDirection(
                rotation,
                source: policy.sourceCoordinates,
                target: policy.targetCoordinates
            ),
            scale: AssetVector3(
                x: abs(convertedScale.x),
                y: abs(convertedScale.y),
                z: abs(convertedScale.z)
            )
        )
    }
}

public struct AssetNode: Codable {
    public var name: String
    public var meshName: String
    public var transform: AssetTransform
    public var materialID: UInt64
    public var visibilityMask: UInt32
    public var enabled: Bool

    public init(
        name: String,
        meshName: String,
        transform: AssetTransform,
        materialID: UInt64,
        visibilityMask: UInt32,
        enabled: Bool
    ) {
        self.name = name
        self.meshName = meshName
        self.transform = transform
        self.materialID = materialID
        self.visibilityMask = visibilityMask
        self.enabled = enabled
    }

    public func makeSceneObject(
        policy: AssetConversionPolicy = .identity
    ) -> SceneObject {
        let convertedTransform = transform.converted(policy: policy)
        SceneObject(
            name: name,
            meshName: meshName,
            transform: Transform(
                position: toCore(convertedTransform.position),
                rotation: toCore(convertedTransform.rotation),
                scale: toCore(convertedTransform.scale)
            ),
            materialID: materialID,
            visibilityMask: visibilityMask,
            enabled: enabled
        )
    }

    public var isValid: Bool {
        !name.isEmpty && !meshName.isEmpty && transform.isValid
    }
}

public struct AssetDocument: Codable {
    public var schemaMajor: UInt32
    public var schemaMinor: UInt32
    public var name: String
    public var source: AssetSourceMetadata
    public var meshes: [AssetMesh]
    public var curves: [AssetCurve]
    public var materials: [AssetMaterial]
    public var textures: [AssetTexture]
    public var nodes: [AssetNode]

    public init(
        name: String,
        source: AssetSourceMetadata = .unknown,
        meshes: [AssetMesh] = [],
        curves: [AssetCurve] = [],
        materials: [AssetMaterial] = [],
        textures: [AssetTexture] = [],
        nodes: [AssetNode] = [],
        schemaMajor: UInt32 = AssetSerializer.currentSchemaMajor,
        schemaMinor: UInt32 = AssetSerializer.currentSchemaMinor
    ) {
        self.schemaMajor = schemaMajor
        self.schemaMinor = schemaMinor
        self.name = name
        self.source = source
        self.meshes = meshes
        self.curves = curves
        self.materials = materials
        self.textures = textures
        self.nodes = nodes
    }

    public var isValid: Bool {
        schemaMajor > 0
            && !name.isEmpty
            && source.coordinateSystem.isValid
            && meshes.allSatisfy { $0.isValid }
            && curves.allSatisfy { $0.isValid }
            && materials.allSatisfy { $0.isValid }
            && textures.allSatisfy { $0.isValid }
            && nodes.allSatisfy { $0.isValid }
    }
}

public struct AssetImportResult {
    public var document: AssetDocument?
    public var diagnostics: [AssetDiagnostic]

    public init(
        document: AssetDocument?,
        diagnostics: [AssetDiagnostic]
    ) {
        self.document = document
        self.diagnostics = diagnostics
    }

    public var succeeded: Bool {
        document != nil && !diagnostics.contains { $0.severity == .error }
    }
}

public struct AssetDocumentConversionResult {
    public var scene: Scene?
    public var meshes: [Mesh]
    public var curves: [Curve]
    public var materials: [PBRMaterialData]
    public var textures: [AssetTexture]
    public var diagnostics: [AssetDiagnostic]

    public init(
        scene: Scene?,
        meshes: [Mesh],
        curves: [Curve],
        materials: [PBRMaterialData],
        textures: [AssetTexture],
        diagnostics: [AssetDiagnostic]
    ) {
        self.scene = scene
        self.meshes = meshes
        self.curves = curves
        self.materials = materials
        self.textures = textures
        self.diagnostics = diagnostics
    }

    public var succeeded: Bool {
        scene != nil && !diagnostics.contains { $0.severity == .error }
    }
}

public final class AssetImporterAdapter {
    public let importerName: String
    public let importerVersion: String
    public let supportedFormats: [String]

    public init(
        importerName: String,
        importerVersion: String,
        supportedFormats: [String]
    ) {
        self.importerName = importerName
        self.importerVersion = importerVersion
        self.supportedFormats = supportedFormats.map {
            $0.lowercased()
        }
    }

    public func supports(format: String) -> Bool {
        let normalized = format.lowercased()
        return supportedFormats.isEmpty || supportedFormats.contains(normalized)
    }

    public func validate(
        document: AssetDocument,
        source: String = ""
    ) -> AssetImportResult {
        var diagnostics: [AssetDiagnostic] = []
        let sourceName = source.isEmpty ? document.source.sourceURI : source
        if !supports(format: document.source.format) {
            diagnostics.append(
                AssetDiagnostic(
                    severity: .error,
                    code: .unsupportedFormat,
                    source: sourceName,
                    field: "source.format",
                    message: "The configured importer does not support this format."
                )
            )
        }
        if !document.isValid {
            diagnostics.append(
                AssetDiagnostic(
                    severity: .error,
                    code: .invalidInput,
                    source: sourceName,
                    field: "document",
                    message: "The imported document failed normalized-value validation."
                )
            )
        }
        return AssetImportResult(
            document: diagnostics.contains { $0.severity == .error }
                ? nil
                : document,
            diagnostics: diagnostics
        )
    }
}

public final class AssetPipeline {
    public init() {}

    public func convertMesh(
        _ source: AssetMesh,
        policy: AssetConversionPolicy = .identity
    ) -> AssetMeshConversionResult {
        var diagnostics: [AssetDiagnostic] = []
        guard policy.isValid else {
            diagnostics.append(
                error(
                    .invalidInput,
                    source: source.name,
                    field: "policy",
                    message: "The coordinate conversion policy is invalid."
                )
            )
            return AssetMeshConversionResult(
                normalizedMesh: nil,
                mesh: nil,
                diagnostics: diagnostics,
                didReverseWinding: false,
                discardedTangentCount: 0,
                discardedColorCount: 0
            )
        }
        guard source.isValid else {
            diagnostics.append(
                error(
                    .invalidGeometry,
                    source: source.name,
                    field: "mesh",
                    message: "The mesh contains invalid vertices, indices, or metadata."
                )
            )
            return AssetMeshConversionResult(
                normalizedMesh: nil,
                mesh: nil,
                diagnostics: diagnostics,
                didReverseWinding: false,
                discardedTangentCount: 0,
                discardedColorCount: 0
            )
        }

        let reflection =
            policy.sourceCoordinates.handedness
                != policy.targetCoordinates.handedness
        let shouldReverse: Bool
        switch policy.windingPolicy {
        case .automatic:
            shouldReverse = reflection
        case .preserve:
            shouldReverse = false
        case .reverse:
            shouldReverse = true
        }

        var normalized = source
        normalized.vertices = source.vertices.map { vertex in
            var converted = vertex
            converted.position = convertPosition(
                vertex.position,
                source: policy.sourceCoordinates,
                target: policy.targetCoordinates
            )
            converted.normal = normalizedDirection(
                convertDirection(
                    vertex.normal,
                    source: policy.sourceCoordinates,
                    target: policy.targetCoordinates
                )
            )
            if vertex.hasTangent {
                var tangent = convertDirection(
                    AssetVector3(
                        x: vertex.tangent.x,
                        y: vertex.tangent.y,
                        z: vertex.tangent.z
                    ),
                    source: policy.sourceCoordinates,
                    target: policy.targetCoordinates
                )
                if reflection {
                    converted.tangent.w = -vertex.tangent.w
                }
                tangent = normalizedDirection(tangent)
                converted.tangent.x = tangent.x
                converted.tangent.y = tangent.y
                converted.tangent.z = tangent.z
            }
            if policy.sourceUVOrigin != policy.targetUVOrigin {
                converted.texcoord.y = 1 - converted.texcoord.y
            }
            if vertex.hasColor {
                converted.color = AssetColorConverter.convert(
                    vertex.color,
                    from: policy.sourceColorSpace,
                    to: policy.targetColorSpace
                )
            }
            return converted
        }

        if var culling = source.culling {
            culling.center = convertPosition(
                culling.center,
                source: policy.sourceCoordinates,
                target: policy.targetCoordinates
            )
            culling.radius *= abs(
                policy.sourceCoordinates.unitScale
                    / policy.targetCoordinates.unitScale
            )
            normalized.culling = culling
        }
        normalized.meshletDescriptors = source.meshletDescriptors.map {
            var descriptor = $0
            descriptor.boundsCenter = convertPosition(
                descriptor.boundsCenter,
                source: policy.sourceCoordinates,
                target: policy.targetCoordinates
            )
            descriptor.boundsRadius *= abs(
                policy.sourceCoordinates.unitScale
                    / policy.targetCoordinates.unitScale
            )
            return descriptor
        }

        if shouldReverse && normalized.primitiveType == .triangle {
            guard normalized.indices.count % 3 == 0 else {
                diagnostics.append(
                    error(
                        .invalidIndex,
                        source: source.name,
                        field: "indices",
                        message: "Triangle indices must be grouped in triples."
                    )
                )
                return AssetMeshConversionResult(
                    normalizedMesh: nil,
                    mesh: nil,
                    diagnostics: diagnostics,
                    didReverseWinding: false,
                    discardedTangentCount: 0,
                    discardedColorCount: 0
                )
            }
            for index in stride(from: 0, to: normalized.indices.count, by: 3) {
                normalized.indices.swapAt(index + 1, index + 2)
            }
        }

        let mesh = Mesh(
            name: normalized.name,
            vertexStride: Mesh.standardVertexStride,
            primitiveType: normalized.primitiveType.coreValue,
            indexType: .uint32
        )
        for vertex in normalized.vertices {
            guard mesh.appendVertex(
                MeshVertex(
                    position: toCore(vertex.position),
                    normal: toCore(vertex.normal),
                    texcoord: toCore(vertex.texcoord)
                )
            ) else {
                diagnostics.append(
                    error(
                        .invalidGeometry,
                        source: source.name,
                        field: "vertices",
                        message: "A normalized vertex could not be appended."
                    )
                )
                return AssetMeshConversionResult(
                    normalizedMesh: normalized,
                    mesh: nil,
                    diagnostics: diagnostics,
                    didReverseWinding: shouldReverse,
                    discardedTangentCount: 0,
                    discardedColorCount: 0
                )
            }
        }
        for index in normalized.indices {
            guard mesh.appendIndex(index) else {
                diagnostics.append(
                    error(
                        .invalidIndex,
                        source: source.name,
                        field: "indices",
                        message: "An index references outside the normalized vertex array."
                    )
                )
                return AssetMeshConversionResult(
                    normalizedMesh: normalized,
                    mesh: nil,
                    diagnostics: diagnostics,
                    didReverseWinding: shouldReverse,
                    discardedTangentCount: 0,
                    discardedColorCount: 0
                )
            }
        }

        if !normalized.meshletDescriptors.isEmpty {
            let payload = MeshletPayload(
                name: normalized.name,
                descriptors: normalized.meshletDescriptors.map {
                    MeshletDescriptor(
                        vertexOffset: $0.vertexOffset,
                        vertexCount: $0.vertexCount,
                        primitiveOffset: $0.primitiveOffset,
                        primitiveCount: $0.primitiveCount,
                        lodLevel: $0.lodLevel,
                        boundsCenter: toCore($0.boundsCenter),
                        boundsRadius: $0.boundsRadius
                    )
                },
                vertexData: normalized.meshletVertexData,
                primitiveData: normalized.meshletPrimitiveData
            )
            if payload.isValid {
                mesh.setMeshletPayload(payload)
            } else {
                diagnostics.append(
                    warning(
                        .lossyConversion,
                        source: source.name,
                        field: "meshlets",
                        message: "Invalid meshlet payload was retained only as normalized data."
                    )
                )
            }
        }
        if let culling = normalized.culling {
            mesh.setCullingMetadata(
                MeshCullingMetadata(
                    center: toCore(culling.center),
                    radius: culling.radius,
                    visibilityMask: culling.visibilityMask,
                    enabled: culling.enabled,
                    lod: normalized.lodLevels.isEmpty
                        ? nil
                        : MeshLODMetadata(
                            levels: normalized.lodLevels.map {
                                MeshLODLevel(
                                    maxDistance: $0.maxDistance,
                                    meshName: $0.meshName,
                                    level: $0.level
                                )
                            },
                            fallbackMeshName: normalized.fallbackMeshName
                        )
                )
            )
        }

        let tangentCount = normalized.vertices.filter { $0.hasTangent }.count
        let colorCount = normalized.vertices.filter { $0.hasColor }.count
        if tangentCount > 0 && policy.preserveTangents {
            diagnostics.append(
                warning(
                    .lossyConversion,
                    source: source.name,
                    field: "vertices.tangent",
                    message: "Plan 16 MeshVertex has no tangent channel; normalized tangents remain in the value result."
                )
            )
        }
        if colorCount > 0 && policy.preserveVertexColors {
            diagnostics.append(
                warning(
                    .lossyConversion,
                    source: source.name,
                    field: "vertices.color",
                    message: "Plan 16 MeshVertex has no color channel; normalized colors remain in the value result."
                )
            )
        }
        return AssetMeshConversionResult(
            normalizedMesh: normalized,
            mesh: mesh,
            diagnostics: diagnostics,
            didReverseWinding: shouldReverse,
            discardedTangentCount: UInt32(min(tangentCount, Int(UInt32.max))),
            discardedColorCount: UInt32(min(colorCount, Int(UInt32.max)))
        )
    }

    public func convertMaterial(
        _ source: AssetMaterial,
        policy: AssetConversionPolicy = .identity
    ) -> AssetMaterialConversionResult {
        var diagnostics: [AssetDiagnostic] = []
        guard source.isValid, policy.isValid else {
            diagnostics.append(
                error(
                    .invalidInput,
                    source: source.name,
                    field: "material",
                    message: "The material or conversion policy is invalid."
                )
            )
            return AssetMaterialConversionResult(
                material: nil,
                data: nil,
                diagnostics: diagnostics
            )
        }
        var normalized = source
        if requiresColorConversionWarning(
            from: source.colorSpace,
            to: policy.targetColorSpace
        ) {
            diagnostics.append(
                warning(
                    .capability,
                    source: source.name,
                    field: "material.colorSpace",
                    message: "This color-space conversion is metadata-preserving only."
                )
            )
        }
        normalized.baseColor = AssetColorConverter.convert(
            source.baseColor,
            from: source.colorSpace,
            to: policy.targetColorSpace
        )
        normalized.emissiveColor = AssetColorConverter.convert(
            source.emissiveColor,
            from: source.colorSpace,
            to: policy.targetColorSpace
        )
        let metallic = min(max(source.metallic, 0), 1)
        let roughness = min(max(source.roughness, 0), 1)
        let normalScale = max(source.normalScale, 0)
        let occlusionStrength = min(max(source.occlusionStrength, 0), 1)
        if metallic != source.metallic
            || roughness != source.roughness
            || normalScale != source.normalScale
            || occlusionStrength != source.occlusionStrength {
            diagnostics.append(
                warning(
                    .lossyConversion,
                    source: source.name,
                    field: "material.parameters",
                    message: "Out-of-range material values were clamped to the Plan 16 PBR contract."
                )
            )
        }
        normalized.metallic = metallic
        normalized.roughness = roughness
        normalized.normalScale = normalScale
        normalized.occlusionStrength = occlusionStrength
        return AssetMaterialConversionResult(
            material: normalized,
            data: PBRMaterialData(
                baseColor: toCore(normalized.baseColor),
                emissiveColor: toCore(normalized.emissiveColor),
                metallic: metallic,
                roughness: roughness,
                normalScale: normalScale,
                occlusionStrength: occlusionStrength
            ),
            diagnostics: diagnostics
        )
    }

    public func convertTexture(
        _ source: AssetTexture,
        policy: AssetConversionPolicy = .identity
    ) -> AssetTextureConversionResult {
        var diagnostics: [AssetDiagnostic] = []
        guard source.isValid, policy.isValid else {
            diagnostics.append(
                error(
                    .invalidTexture,
                    source: source.name,
                    field: "texture",
                    message: "The texture or conversion policy is invalid."
                )
            )
            return AssetTextureConversionResult(
                texture: nil,
                diagnostics: diagnostics
            )
        }
        let targetFormat: AssetTexturePixelFormat
        switch policy.textureFormatPolicy {
        case .preserve:
            targetFormat = source.pixelFormat
        case .r8Unorm:
            targetFormat = .r8Unorm
        case .rgba8Unorm:
            targetFormat = .rgba8Unorm
        case .bgra8Unorm:
            targetFormat = .bgra8Unorm
        }
        let targetColorSpace =
            policy.targetColorSpace == .unknown
                ? source.colorSpace
                : policy.targetColorSpace
        if requiresColorConversionWarning(
            from: source.colorSpace,
            to: targetColorSpace
        ) {
            diagnostics.append(
                warning(
                    .capability,
                    source: source.name,
                    field: "texture.colorSpace",
                    message: "This color-space conversion is metadata-preserving only."
                )
            )
        }
        let targetOrigin = policy.targetUVOrigin
        let initialLevels = policy.mipPolicy == .generate
            ? Array(source.levels.prefix(1))
            : source.levels
        var convertedLevels: [AssetTextureLevel] = []
        for level in initialLevels {
            guard let converted = convertTextureLevel(
                level,
                sourceFormat: source.pixelFormat,
                targetFormat: targetFormat,
                sourceColorSpace: source.colorSpace,
                targetColorSpace: targetColorSpace,
                sourceOrigin: source.origin,
                targetOrigin: targetOrigin
            ) else {
                diagnostics.append(
                    error(
                        .invalidTexture,
                        source: source.name,
                        field: "levels",
                        message: "A texture level could not be converted."
                    )
                )
                return AssetTextureConversionResult(
                    texture: nil,
                    diagnostics: diagnostics
                )
            }
            convertedLevels.append(converted)
        }
        switch policy.mipPolicy {
        case .baseOnly:
            if source.levels.count > 1 {
                diagnostics.append(
                    warning(
                        .lossyConversion,
                        source: source.name,
                        field: "mips",
                        message: "Additional mip levels were dropped by the base-only policy."
                    )
                )
            }
            convertedLevels = Array(convertedLevels.prefix(1))
        case .preserve:
            break
        case .generate:
            convertedLevels = generateMipLevels(
                base: convertedLevels[0],
                format: targetFormat
            )
            if source.levels.count > 1 {
                diagnostics.append(
                    warning(
                        .lossyConversion,
                        source: source.name,
                        field: "mips",
                        message: "Source mip levels were regenerated from the converted base level."
                    )
                )
            }
        }
        return AssetTextureConversionResult(
            texture: AssetTexture(
                name: source.name,
                pixelFormat: targetFormat,
                colorSpace: targetColorSpace,
                origin: targetOrigin,
                levels: convertedLevels
            ),
            diagnostics: diagnostics
        )
    }

    public func convertDocument(
        _ source: AssetDocument,
        policy: AssetConversionPolicy = .identity
    ) -> AssetDocumentConversionResult {
        var diagnostics: [AssetDiagnostic] = []
        guard source.isValid else {
            diagnostics.append(
                error(
                    .invalidInput,
                    source: source.name,
                    field: "document",
                    message: "The document failed normalized-value validation."
                )
            )
            return AssetDocumentConversionResult(
                scene: nil,
                meshes: [],
                curves: [],
                materials: [],
                textures: [],
                diagnostics: diagnostics
            )
        }

        var meshes: [Mesh] = []
        var curves: [Curve] = []
        var materials: [PBRMaterialData] = []
        var textures: [AssetTexture] = []
        for mesh in source.meshes {
            let result = convertMesh(mesh, policy: policy)
            diagnostics.append(contentsOf: result.diagnostics)
            if let converted = result.mesh {
                meshes.append(converted)
            }
        }
        for curve in source.curves {
            guard let converted = curve.makeCoreCurve(policy: policy) else {
                diagnostics.append(
                    error(
                        .invalidGeometry,
                        source: source.name,
                        field: "curves",
                        message: "A curve could not be converted to the Plan 16 representation."
                    )
                )
                continue
            }
            curves.append(converted)
        }
        for material in source.materials {
            let result = convertMaterial(material, policy: policy)
            diagnostics.append(contentsOf: result.diagnostics)
            if let converted = result.data {
                materials.append(converted)
            }
        }
        for texture in source.textures {
            let result = convertTexture(texture, policy: policy)
            diagnostics.append(contentsOf: result.diagnostics)
            if let converted = result.texture {
                textures.append(converted)
            }
        }
        let scene = Scene()
        let meshNames = Set(source.meshes.map { $0.name })
        for node in source.nodes {
            guard meshNames.contains(node.meshName) else {
                diagnostics.append(
                    error(
                        .invalidInput,
                        source: source.name,
                        field: "nodes.meshName",
                        message: "A scene node references an unknown mesh."
                    )
                )
                continue
            }
            guard scene.addObject(node.makeSceneObject(policy: policy)) else {
                diagnostics.append(
                    error(
                        .invalidInput,
                        source: source.name,
                        field: "nodes",
                        message: "A scene node name was duplicated."
                    )
                )
                continue
            }
        }
        return AssetDocumentConversionResult(
            scene: scene,
            meshes: meshes,
            curves: curves,
            materials: materials,
            textures: textures,
            diagnostics: diagnostics
        )
    }
}

public final class AssetTextureLoader {
    public init() {}

    public func loadDecoded(
        _ texture: AssetTexture,
        source: String = "",
        policy: AssetConversionPolicy = .identity
    ) -> AssetTextureLoadResult {
        let result = AssetPipeline().convertTexture(
            texture,
            policy: policy
        )
        let diagnostics = result.diagnostics.map { diagnostic in
            guard !source.isEmpty else {
                return diagnostic
            }
            var updated = diagnostic
            updated.source = source
            return updated
        }
        return AssetTextureLoadResult(
            texture: result.texture,
            diagnostics: diagnostics
        )
    }

    public func loadPPM(
        bytes: [UInt8],
        source: String = "memory.ppm",
        policy: AssetConversionPolicy = .identity
    ) -> AssetTextureLoadResult {
        var index = 0
        guard let magic = nextToken(bytes, index: &index),
              magic == "P5" || magic == "P6",
              let widthToken = nextToken(bytes, index: &index),
              let heightToken = nextToken(bytes, index: &index),
              let maxValueToken = nextToken(bytes, index: &index),
              let width = UInt32(widthToken),
              let height = UInt32(heightToken),
              let maxValue = UInt32(maxValueToken),
              width > 0,
              height > 0,
              maxValue == 255 else {
            return AssetTextureLoadResult(
                texture: nil,
                diagnostics: [
                    error(
                        .unsupportedFormat,
                        source: source,
                        field: "header",
                        message: "Only binary P5/P6 images with an 8-bit channel are supported."
                    )
                ]
            )
        }
        consumeBinaryDelimiter(bytes, index: &index)
        let channelCount = magic == "P5" ? 1 : 3
        guard let sourceLength = byteCount(
            width: width,
            height: height,
            bytesPerPixel: UInt32(channelCount)
        ),
        sourceLength <= UInt64(Int.max),
              index <= bytes.count,
              bytes.count - index >= Int(sourceLength) else {
            return AssetTextureLoadResult(
                texture: nil,
                diagnostics: [
                    error(
                        .invalidTexture,
                        source: source,
                        field: "pixels",
                        message: "The image payload is truncated."
                    )
                ]
            )
        }
        let payload = Array(
            bytes[index..<(index + Int(sourceLength))]
        )
        let pixelFormat: AssetTexturePixelFormat =
            magic == "P5" ? .r8Unorm : .rgba8Unorm
        var pixels: [UInt8]
        if magic == "P5" {
            pixels = payload
        } else {
            pixels = []
            pixels.reserveCapacity(payload.count / 3 * 4)
            for offset in stride(from: 0, to: payload.count, by: 3) {
                pixels.append(payload[offset])
                pixels.append(payload[offset + 1])
                pixels.append(payload[offset + 2])
                pixels.append(255)
            }
        }
        let texture = AssetTexture(
            name: URL(fileURLWithPath: source).lastPathComponent.isEmpty
                ? source
                : URL(fileURLWithPath: source).lastPathComponent,
            pixelFormat: pixelFormat,
            colorSpace: .unknown,
            origin: .topLeft,
            levels: [
                AssetTextureLevel(
                    width: width,
                    height: height,
                    pixels: pixels
                )
            ]
        )
        let converted = AssetPipeline().convertTexture(
            texture,
            policy: policy
        )
        return AssetTextureLoadResult(
            texture: converted.texture,
            diagnostics: converted.diagnostics
        )
    }

    public func loadPPMFile(
        path: String,
        policy: AssetConversionPolicy = .identity
    ) -> AssetTextureLoadResult {
        do {
            return loadPPM(
                bytes: Array(try Data(contentsOf: URL(fileURLWithPath: path))),
                source: path,
                policy: policy
            )
        } catch {
            return AssetTextureLoadResult(
                texture: nil,
                diagnostics: [
                    error(
                        .invalidInput,
                        source: path,
                        field: "file",
                        message: "The texture file could not be read."
                    )
                ]
            )
        }
    }
}

public final class AssetSerializer {
    public static let currentSchemaMajor: UInt32 = 1
    public static let currentSchemaMinor: UInt32 = 1

    private init() {}

    public static func encode(document: AssetDocument) -> [UInt8]? {
        guard document.isValid,
              document.schemaMajor == currentSchemaMajor,
              document.schemaMinor <= currentSchemaMinor else {
            return nil
        }
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
            return Array(try encoder.encode(document))
        } catch {
            return nil
        }
    }

    public static func decode(
        bytes: [UInt8],
        source: String = "asset.mtasset"
    ) -> AssetSerializationResult {
        guard !bytes.isEmpty else {
            return AssetSerializationResult(
                document: nil,
                diagnostics: [
                    error(
                        .serialization,
                        source: source,
                        field: "bytes",
                        message: "The serialized asset is empty."
                    )
                ],
                migrated: false
            )
        }
        do {
            guard var object = try JSONSerialization.jsonObject(
                with: Data(bytes),
                options: []
            ) as? [String: Any] else {
                throw SerializationError.invalidRoot
            }
            var migrated = false
            let major: UInt32
            let minor: UInt32
            if let majorNumber = object["schemaMajor"] as? NSNumber,
               let minorNumber = object["schemaMinor"] as? NSNumber {
                major = majorNumber.uint32Value
                minor = minorNumber.uint32Value
            } else {
                object["schemaMajor"] = currentSchemaMajor
                object["schemaMinor"] = 0
                major = currentSchemaMajor
                minor = 0
                migrated = true
            }
            guard major == currentSchemaMajor else {
                return AssetSerializationResult(
                    document: nil,
                    diagnostics: [
                        error(
                            .unsupportedVersion,
                            source: source,
                            field: "schemaMajor",
                            message: "The serialized asset uses an unsupported major version."
                        )
                    ],
                    migrated: migrated
                )
            }
            guard minor <= currentSchemaMinor else {
                return AssetSerializationResult(
                    document: nil,
                    diagnostics: [
                        error(
                            .unsupportedVersion,
                            source: source,
                            field: "schemaMinor",
                            message: "The serialized asset is newer than this library."
                        )
                    ],
                    migrated: migrated
                )
            }
            let normalizedData = try JSONSerialization.data(
                withJSONObject: object,
                options: [.sortedKeys]
            )
            var document = try JSONDecoder().decode(
                AssetDocument.self,
                from: normalizedData
            )
            if minor < currentSchemaMinor {
                document.schemaMinor = currentSchemaMinor
                migrated = true
            }
            guard document.isValid else {
                throw SerializationError.invalidDocument
            }
            var diagnostics: [AssetDiagnostic] = []
            if migrated {
                diagnostics.append(
                    AssetDiagnostic(
                        severity: .info,
                        code: .migration,
                        source: source,
                        field: "schemaMinor",
                        message: "The serialized asset was migrated to the current schema."
                    )
                )
            }
            return AssetSerializationResult(
                document: document,
                diagnostics: diagnostics,
                migrated: migrated
            )
        } catch {
            return AssetSerializationResult(
                document: nil,
                diagnostics: [
                    error(
                        .serialization,
                        source: source,
                        field: "document",
                        message: "The serialized asset could not be decoded."
                    )
                ],
                migrated: false
            )
        }
    }
}

public struct AssetSerializationResult {
    public var document: AssetDocument?
    public var diagnostics: [AssetDiagnostic]
    public var migrated: Bool

    public init(
        document: AssetDocument?,
        diagnostics: [AssetDiagnostic],
        migrated: Bool
    ) {
        self.document = document
        self.diagnostics = diagnostics
        self.migrated = migrated
    }

    public var succeeded: Bool {
        document != nil && !diagnostics.contains { $0.severity == .error }
    }
}

public final class AssetColorConverter {
    private init() {}

    public static func convert(
        _ color: AssetVector4,
        from source: AssetColorSpace,
        to target: AssetColorSpace
    ) -> AssetVector4 {
        guard source != target,
              source != .unknown,
              target != .unknown else {
            return color
        }
        return AssetVector4(
            x: convertChannel(color.x, from: source, to: target),
            y: convertChannel(color.y, from: source, to: target),
            z: convertChannel(color.z, from: source, to: target),
            w: color.w
        )
    }
}

private enum SerializationError: Error {
    case invalidRoot
    case invalidDocument
}

private extension AssetPrimitiveType {
    var coreValue: PrimitiveType {
        switch self {
        case .point:
            return .point
        case .line:
            return .line
        case .triangle:
            return .triangle
        }
    }
}

private extension AssetTexturePixelFormat {
    var coreValue: PixelFormat {
        switch self {
        case .r8Unorm:
            return .r8Unorm
        case .rgba8Unorm:
            return .rgba8Unorm
        case .bgra8Unorm:
            return .bgra8Unorm
        }
    }
}

private func isFinite(_ value: AssetVector2) -> Bool {
    value.x.isFinite && value.y.isFinite
}

private func isFinite(_ value: AssetVector3) -> Bool {
    value.x.isFinite && value.y.isFinite && value.z.isFinite
}

private func isFinite(_ value: AssetVector4) -> Bool {
    value.x.isFinite
        && value.y.isFinite
        && value.z.isFinite
        && value.w.isFinite
}

private func toCore(_ value: AssetVector2) -> Vector2 {
    Vector2(x: value.x, y: value.y)
}

private func toCore(_ value: AssetVector3) -> Vector3 {
    Vector3(x: value.x, y: value.y, z: value.z)
}

private func toCore(_ value: AssetVector4) -> Vector4 {
    Vector4(x: value.x, y: value.y, z: value.z, w: value.w)
}

private func convertPosition(
    _ value: AssetVector3,
    source: AssetCoordinateSystem,
    target: AssetCoordinateSystem
) -> AssetVector3 {
    var result = convertDirection(value, source: source, target: target)
    let scale = source.unitScale / target.unitScale
    result.x *= scale
    result.y *= scale
    result.z *= scale
    return result
}

private func convertDirection(
    _ value: AssetVector3,
    source: AssetCoordinateSystem,
    target: AssetCoordinateSystem
) -> AssetVector3 {
    let sourceComponents = [value.x, value.y, value.z]
    let sourceUp = Int(source.upAxis.rawValue)
    let sourceForward = Int(source.forwardAxis.rawValue)
    let targetUp = Int(target.upAxis.rawValue)
    let targetForward = Int(target.forwardAxis.rawValue)
    let sourceRemaining = (0..<3).filter {
        $0 != sourceUp && $0 != sourceForward
    }
    let targetRemaining = (0..<3).filter {
        $0 != targetUp && $0 != targetForward
    }
    var targetComponents = [Float](repeating: 0, count: 3)
    targetComponents[targetUp] = sourceComponents[sourceUp]
    targetComponents[targetForward] = sourceComponents[sourceForward]
    targetComponents[targetRemaining[0]] =
        sourceComponents[sourceRemaining[0]]
    var permutation = [Int](repeating: 0, count: 3)
    permutation[sourceUp] = targetUp
    permutation[sourceForward] = targetForward
    permutation[sourceRemaining[0]] = targetRemaining[0]
    var inversions = 0
    for first in 0..<3 {
        for second in (first + 1)..<3
        where permutation[first] > permutation[second] {
            inversions += 1
        }
    }
    let rawSign = inversions % 2 == 0 ? 1 : -1
    let desiredSign = source.handedness == target.handedness ? 1 : -1
    if rawSign != desiredSign {
        targetComponents[targetForward] = -targetComponents[targetForward]
    }
    return AssetVector3(
        x: targetComponents[0],
        y: targetComponents[1],
        z: targetComponents[2]
    )
}

private func normalizedDirection(_ value: AssetVector3) -> AssetVector3 {
    let length = sqrt(
        value.x * value.x
            + value.y * value.y
            + value.z * value.z
    )
    guard length.isFinite, length > 0 else {
        return value
    }
    return AssetVector3(
        x: value.x / length,
        y: value.y / length,
        z: value.z / length
    )
}

private func convertChannel(
    _ value: Float,
    from source: AssetColorSpace,
    to target: AssetColorSpace
) -> Float {
    guard source != target else {
        return value
    }
    if source == .srgb && target == .linear {
        if value <= 0.04045 {
            return value / 12.92
        }
        return pow((value + 0.055) / 1.055, 2.4)
    }
    if source == .linear && target == .srgb {
        if value <= 0.0031308 {
            return value * 12.92
        }
        return 1.055 * pow(value, 1 / 2.4) - 0.055
    }
    return value
}

private func requiresColorConversionWarning(
    from source: AssetColorSpace,
    to target: AssetColorSpace
) -> Bool {
    guard source != target,
          source != .unknown,
          target != .unknown else {
        return false
    }
    return !(
        (source == .srgb && target == .linear)
            || (source == .linear && target == .srgb)
    )
}

private func error(
    _ code: AssetDiagnosticCode,
    source: String,
    field: String,
    message: String
) -> AssetDiagnostic {
    AssetDiagnostic(
        severity: .error,
        code: code,
        source: source,
        field: field,
        message: message
    )
}

private func warning(
    _ code: AssetDiagnosticCode,
    source: String,
    field: String,
    message: String
) -> AssetDiagnostic {
    AssetDiagnostic(
        severity: .warning,
        code: code,
        source: source,
        field: field,
        message: message
    )
}

private func convertTextureLevel(
    _ level: AssetTextureLevel,
    sourceFormat: AssetTexturePixelFormat,
    targetFormat: AssetTexturePixelFormat,
    sourceColorSpace: AssetColorSpace,
    targetColorSpace: AssetColorSpace,
    sourceOrigin: AssetTextureOrigin,
    targetOrigin: AssetTextureOrigin
) -> AssetTextureLevel? {
    let sourceBytesPerPixel = sourceFormat == .r8Unorm ? 1 : 4
    guard let expected = byteCount(
        width: level.width,
        height: level.height,
        bytesPerPixel: UInt32(sourceBytesPerPixel)
    ),
    expected <= UInt64(Int.max),
    expected == UInt64(level.pixels.count) else {
        return nil
    }
    let targetBytesPerPixel = targetFormat == .r8Unorm ? 1 : 4
    guard let targetByteCount = byteCount(
        width: level.width,
        height: level.height,
        bytesPerPixel: UInt32(targetBytesPerPixel)
    ),
    targetByteCount <= UInt64(Int.max) else {
        return nil
    }
    var output = [UInt8]()
    output.reserveCapacity(Int(targetByteCount))
    for index in 0..<(Int(level.width) * Int(level.height)) {
        let sourceOffset = index * sourceBytesPerPixel
        let red: Float
        let green: Float
        let blue: Float
        let alpha: Float
        switch sourceFormat {
        case .r8Unorm:
            red = Float(level.pixels[sourceOffset]) / 255
            green = red
            blue = red
            alpha = 1
        case .rgba8Unorm:
            red = Float(level.pixels[sourceOffset]) / 255
            green = Float(level.pixels[sourceOffset + 1]) / 255
            blue = Float(level.pixels[sourceOffset + 2]) / 255
            alpha = Float(level.pixels[sourceOffset + 3]) / 255
        case .bgra8Unorm:
            blue = Float(level.pixels[sourceOffset]) / 255
            green = Float(level.pixels[sourceOffset + 1]) / 255
            red = Float(level.pixels[sourceOffset + 2]) / 255
            alpha = Float(level.pixels[sourceOffset + 3]) / 255
        }
        let convertedRed = clampUnit(
            convertChannel(red, from: sourceColorSpace, to: targetColorSpace)
        )
        let convertedGreen = clampUnit(
            convertChannel(
                green,
                from: sourceColorSpace,
                to: targetColorSpace
            )
        )
        let convertedBlue = clampUnit(
            convertChannel(
                blue,
                from: sourceColorSpace,
                to: targetColorSpace
            )
        )
        switch targetFormat {
        case .r8Unorm:
            output.append(byte(from: convertedRed))
        case .rgba8Unorm:
            output.append(byte(from: convertedRed))
            output.append(byte(from: convertedGreen))
            output.append(byte(from: convertedBlue))
            output.append(byte(from: alpha))
        case .bgra8Unorm:
            output.append(byte(from: convertedBlue))
            output.append(byte(from: convertedGreen))
            output.append(byte(from: convertedRed))
            output.append(byte(from: alpha))
        }
    }
    if sourceOrigin != targetOrigin {
        let rowBytes = Int(level.width) * targetBytesPerPixel
        var flipped = [UInt8](repeating: 0, count: output.count)
        for row in 0..<Int(level.height) {
            let sourceStart = row * rowBytes
            let destinationStart =
                (Int(level.height) - row - 1) * rowBytes
            flipped.replaceSubrange(
                destinationStart..<(destinationStart + rowBytes),
                with: output[sourceStart..<(sourceStart + rowBytes)]
            )
        }
        output = flipped
    }
    return AssetTextureLevel(
        width: level.width,
        height: level.height,
        pixels: output
    )
}

private func generateMipLevels(
    base: AssetTextureLevel,
    format: AssetTexturePixelFormat
) -> [AssetTextureLevel] {
    let bytesPerPixel = format == .r8Unorm ? 1 : 4
    var levels = [base]
    while levels.last?.width ?? 0 > 1 || levels.last?.height ?? 0 > 1 {
        guard let previous = levels.last else {
            break
        }
        let width = max(1, previous.width / 2)
        let height = max(1, previous.height / 2)
        guard let levelBytes = byteCount(
            width: width,
            height: height,
            bytesPerPixel: UInt32(bytesPerPixel)
        ),
        levelBytes <= UInt64(Int.max) else {
            break
        }
        var pixels = [UInt8]()
        pixels.reserveCapacity(Int(levelBytes))
        for y in 0..<Int(height) {
            for x in 0..<Int(width) {
                for channel in 0..<bytesPerPixel {
                    var total = 0
                    var count = 0
                    for offsetY in 0..<2 {
                        for offsetX in 0..<2 {
                            let sampleX = min(
                                Int(previous.width) - 1,
                                x * 2 + offsetX
                            )
                            let sampleY = min(
                                Int(previous.height) - 1,
                                y * 2 + offsetY
                            )
                            let sampleIndex =
                                (sampleY * Int(previous.width) + sampleX)
                                    * bytesPerPixel
                                    + channel
                            total += Int(previous.pixels[sampleIndex])
                            count += 1
                        }
                    }
                    pixels.append(UInt8(total / count))
                }
            }
        }
        levels.append(
            AssetTextureLevel(width: width, height: height, pixels: pixels)
        )
    }
    return levels
}

private func byteCount(
    width: UInt32,
    height: UInt32,
    bytesPerPixel: UInt32
) -> UInt64? {
    let (area, areaOverflow) = UInt64(width)
        .multipliedReportingOverflow(by: UInt64(height))
    guard !areaOverflow else {
        return nil
    }
    let (count, countOverflow) = area.multipliedReportingOverflow(
        by: UInt64(bytesPerPixel)
    )
    guard !countOverflow else {
        return nil
    }
    return count
}

private func clampUnit(_ value: Float) -> Float {
    min(max(value, 0), 1)
}

private func byte(from value: Float) -> UInt8 {
    UInt8(min(max(Int((value * 255).rounded()), 0), 255))
}

private func nextToken(
    _ bytes: [UInt8],
    index: inout Int
) -> String? {
    while index < bytes.count {
        while index < bytes.count,
              bytes[index] == 9
                || bytes[index] == 10
                || bytes[index] == 13
                || bytes[index] == 32 {
            index += 1
        }
        if index < bytes.count, bytes[index] == 35 {
            while index < bytes.count, bytes[index] != 10 {
                index += 1
            }
            continue
        }
        break
    }
    guard index < bytes.count else {
        return nil
    }
    let start = index
    while index < bytes.count,
          bytes[index] != 9,
          bytes[index] != 10,
          bytes[index] != 13,
          bytes[index] != 32,
          bytes[index] != 35 {
        index += 1
    }
    return String(bytes: bytes[start..<index], encoding: .ascii)
}

private func consumeBinaryDelimiter(
    _ bytes: [UInt8],
    index: inout Int
) {
    guard index < bytes.count else {
        return
    }
    if bytes[index] == 13 {
        index += 1
        if index < bytes.count, bytes[index] == 10 {
            index += 1
        }
    } else if bytes[index] == 10
                || bytes[index] == 9
                || bytes[index] == 32 {
        index += 1
    }
}
