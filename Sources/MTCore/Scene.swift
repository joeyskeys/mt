import Foundation

public struct Vector2 {
    public var x: Float
    public var y: Float

    public init(x: Float, y: Float) {
        self.x = x
        self.y = y
    }
}

public struct Vector3 {
    public var x: Float
    public var y: Float
    public var z: Float

    public init(x: Float, y: Float, z: Float) {
        self.x = x
        self.y = y
        self.z = z
    }
}

public struct Vector4 {
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

public struct Matrix4x4 {
    // Column-major storage matching Metal's float4x4 memory order.
    public var m00: Float
    public var m01: Float
    public var m02: Float
    public var m03: Float
    public var m10: Float
    public var m11: Float
    public var m12: Float
    public var m13: Float
    public var m20: Float
    public var m21: Float
    public var m22: Float
    public var m23: Float
    public var m30: Float
    public var m31: Float
    public var m32: Float
    public var m33: Float

    public init(
        m00: Float,
        m01: Float,
        m02: Float,
        m03: Float,
        m10: Float,
        m11: Float,
        m12: Float,
        m13: Float,
        m20: Float,
        m21: Float,
        m22: Float,
        m23: Float,
        m30: Float,
        m31: Float,
        m32: Float,
        m33: Float
    ) {
        self.m00 = m00
        self.m01 = m01
        self.m02 = m02
        self.m03 = m03
        self.m10 = m10
        self.m11 = m11
        self.m12 = m12
        self.m13 = m13
        self.m20 = m20
        self.m21 = m21
        self.m22 = m22
        self.m23 = m23
        self.m30 = m30
        self.m31 = m31
        self.m32 = m32
        self.m33 = m33
    }

    public static func identity() -> Matrix4x4 {
        Matrix4x4(
            m00: 1, m01: 0, m02: 0, m03: 0,
            m10: 0, m11: 1, m12: 0, m13: 0,
            m20: 0, m21: 0, m22: 1, m23: 0,
            m30: 0, m31: 0, m32: 0, m33: 1
        )
    }
}

public struct Transform {
    public var position: Vector3
    public var rotation: Vector3
    public var scale: Vector3

    public init(
        position: Vector3,
        rotation: Vector3,
        scale: Vector3
    ) {
        self.position = position
        self.rotation = rotation
        self.scale = scale
    }

    public static func identity() -> Transform {
        Transform(
            position: Vector3(x: 0, y: 0, z: 0),
            rotation: Vector3(x: 0, y: 0, z: 0),
            scale: Vector3(x: 1, y: 1, z: 1)
        )
    }
}

public struct MeshView {
    public var meshName: String
    public var vertexOffset: UInt32
    public var vertexCount: UInt32
    public var indexOffset: UInt32
    public var indexCount: UInt32
    public var baseVertex: Int32

    public init(
        meshName: String,
        vertexOffset: UInt32,
        vertexCount: UInt32,
        indexOffset: UInt32,
        indexCount: UInt32,
        baseVertex: Int32
    ) {
        self.meshName = meshName
        self.vertexOffset = vertexOffset
        self.vertexCount = vertexCount
        self.indexOffset = indexOffset
        self.indexCount = indexCount
        self.baseVertex = baseVertex
    }

    public var isIndexed: Bool {
        indexCount > 0
    }

    public func validate(
        vertexCount: UInt32,
        indexCount: UInt32
    ) -> Bool {
        UInt64(vertexOffset) + UInt64(self.vertexCount)
            <= UInt64(vertexCount)
            && UInt64(indexOffset) + UInt64(self.indexCount)
                <= UInt64(indexCount)
    }
}

public struct MeshInstanceData {
    public var transform: Transform
    public var objectID: UInt64
    public var visibilityMask: UInt32
    public var enabled: Bool

    public init(
        transform: Transform,
        objectID: UInt64,
        visibilityMask: UInt32,
        enabled: Bool
    ) {
        self.transform = transform
        self.objectID = objectID
        self.visibilityMask = visibilityMask
        self.enabled = enabled
    }
}

public final class InstancedMeshFixture {
    public let mesh: Mesh
    private var instanceStorage: [MeshInstanceData] = []

    public init(mesh: Mesh) {
        self.mesh = mesh
    }

    public var instanceCount: UInt32 {
        UInt32(min(instanceStorage.count, Int(UInt32.max)))
    }

    public func appendInstance(_ instance: MeshInstanceData) -> Bool {
        guard instanceStorage.count < Int(UInt32.max) else {
            return false
        }
        instanceStorage.append(instance)
        return true
    }

    public func instanceAt(_ index: UInt32) -> MeshInstanceData? {
        guard index < UInt32(instanceStorage.count) else {
            return nil
        }
        return instanceStorage[Int(index)]
    }

    public static func cubeFixture(
        name: String = "instanced.cube"
    ) -> InstancedMeshFixture {
        let fixture = InstancedMeshFixture(mesh: Mesh.cube(name: name))
        _ = fixture.appendInstance(
            MeshInstanceData(
                transform: Transform.identity(),
                objectID: 0,
                visibilityMask: UInt32.max,
                enabled: true
            )
        )
        _ = fixture.appendInstance(
            MeshInstanceData(
                transform: Transform(
                    position: Vector3(x: 2, y: 0, z: 0),
                    rotation: Vector3(x: 0, y: 0.5, z: 0),
                    scale: Vector3(x: 1, y: 1, z: 1)
                ),
                objectID: 1,
                visibilityMask: UInt32.max,
                enabled: true
            )
        )
        return fixture
    }
}

public enum CurveInterpolation: Int32 {
    case polyline
    case bezier
    case catmullRom
}

public struct CurvePoint {
    public var position: Vector3
    public var width: Float
    public var color: Vector4

    public init(
        position: Vector3,
        width: Float,
        color: Vector4
    ) {
        self.position = position
        self.width = width
        self.color = color
    }
}

public final class Curve {
    public let name: String
    public var interpolation: CurveInterpolation
    private var pointStorage: [CurvePoint] = []

    public init(
        name: String,
        interpolation: CurveInterpolation = .polyline
    ) {
        self.name = name
        self.interpolation = interpolation
    }

    public var pointCount: UInt32 {
        UInt32(min(pointStorage.count, Int(UInt32.max)))
    }

    public func appendPoint(_ point: CurvePoint) -> Bool {
        guard point.width.isFinite, point.width >= 0,
              [
                  point.position.x,
                  point.position.y,
                  point.position.z,
                  point.color.x,
                  point.color.y,
                  point.color.z,
                  point.color.w
              ].allSatisfy({ $0.isFinite }) else {
            return false
        }
        pointStorage.append(point)
        return true
    }

    public func pointAt(_ index: UInt32) -> CurvePoint? {
        guard index < UInt32(pointStorage.count) else {
            return nil
        }
        return pointStorage[Int(index)]
    }

    public func clear() {
        pointStorage.removeAll(keepingCapacity: true)
    }

    public func tessellatedPoints(
        segments: UInt32 = 8
    ) -> [CurvePoint] {
        guard pointStorage.count >= 2 else {
            return pointStorage
        }
        let segmentCount = max(1, min(Int(segments), 1024))
        switch interpolation {
        case .polyline:
            return pointStorage
        case .bezier:
            guard pointStorage.count >= 4 else {
                return pointStorage
            }
            var result: [CurvePoint] = []
            var start = 0
            while start + 3 < pointStorage.count {
                for step in 0...segmentCount {
                    if start > 0, step == 0 {
                        continue
                    }
                    let t = Float(step) / Float(segmentCount)
                    result.append(
                        cubic(
                            pointStorage[start],
                            pointStorage[start + 1],
                            pointStorage[start + 2],
                            pointStorage[start + 3],
                            t: t
                        )
                    )
                }
                start += 3
            }
            return result.isEmpty ? pointStorage : result
        case .catmullRom:
            var result: [CurvePoint] = []
            for index in 0..<(pointStorage.count - 1) {
                let p0 = pointStorage[max(0, index - 1)]
                let p1 = pointStorage[index]
                let p2 = pointStorage[index + 1]
                let p3 = pointStorage[
                    min(pointStorage.count - 1, index + 2)
                ]
                for step in 0...segmentCount {
                    if index > 0, step == 0 {
                        continue
                    }
                    let t = Float(step) / Float(segmentCount)
                    result.append(catmull(p0, p1, p2, p3, t: t))
                }
            }
            return result
        }
    }

    public func tessellateAsLines(
        name: String,
        segments: UInt32 = 8
    ) -> Mesh? {
        let points = tessellatedPoints(segments: segments)
        guard points.count >= 2 else {
            return nil
        }
        let mesh = Mesh(
            name: name,
            vertexStride: Mesh.standardVertexStride,
            primitiveType: .line,
            indexType: .uint32
        )
        for point in points {
            let vertex = MeshVertex(
                position: point.position,
                normal: Vector3(x: 0, y: 0, z: 1),
                texcoord: Vector2(x: point.width, y: 0)
            )
            guard mesh.appendVertex(vertex) else {
                return nil
            }
        }
        return mesh
    }

    private func cubic(
        _ p0: CurvePoint,
        _ p1: CurvePoint,
        _ p2: CurvePoint,
        _ p3: CurvePoint,
        t: Float
    ) -> CurvePoint {
        let u = 1 - t
        let a = u * u * u
        let b = 3 * u * u * t
        let c = 3 * u * t * t
        let d = t * t * t
        return CurvePoint(
            position: Vector3(
                x: a * p0.position.x + b * p1.position.x
                    + c * p2.position.x + d * p3.position.x,
                y: a * p0.position.y + b * p1.position.y
                    + c * p2.position.y + d * p3.position.y,
                z: a * p0.position.z + b * p1.position.z
                    + c * p2.position.z + d * p3.position.z
            ),
            width: a * p0.width + b * p1.width
                + c * p2.width + d * p3.width,
            color: Vector4(
                x: a * p0.color.x + b * p1.color.x
                    + c * p2.color.x + d * p3.color.x,
                y: a * p0.color.y + b * p1.color.y
                    + c * p2.color.y + d * p3.color.y,
                z: a * p0.color.z + b * p1.color.z
                    + c * p2.color.z + d * p3.color.z,
                w: a * p0.color.w + b * p1.color.w
                    + c * p2.color.w + d * p3.color.w
            )
        )
    }

    private func catmull(
        _ p0: CurvePoint,
        _ p1: CurvePoint,
        _ p2: CurvePoint,
        _ p3: CurvePoint,
        t: Float
    ) -> CurvePoint {
        let t2 = t * t
        let t3 = t2 * t
        let coefficient0 = -0.5 * t3 + t2 - 0.5 * t
        let coefficient1 = 1.5 * t3 - 2.5 * t2 + 1
        let coefficient2 = -1.5 * t3 + 2 * t2 + 0.5 * t
        let coefficient3 = 0.5 * t3 - 0.5 * t2
        return CurvePoint(
            position: Vector3(
                x: coefficient0 * p0.position.x
                    + coefficient1 * p1.position.x
                    + coefficient2 * p2.position.x
                    + coefficient3 * p3.position.x,
                y: coefficient0 * p0.position.y
                    + coefficient1 * p1.position.y
                    + coefficient2 * p2.position.y
                    + coefficient3 * p3.position.y,
                z: coefficient0 * p0.position.z
                    + coefficient1 * p1.position.z
                    + coefficient2 * p2.position.z
                    + coefficient3 * p3.position.z
            ),
            width: coefficient1 * p1.width + coefficient2 * p2.width,
            color: Vector4(
                x: coefficient1 * p1.color.x + coefficient2 * p2.color.x,
                y: coefficient1 * p1.color.y + coefficient2 * p2.color.y,
                z: coefficient1 * p1.color.z + coefficient2 * p2.color.z,
                w: coefficient1 * p1.color.w + coefficient2 * p2.color.w
            )
        )
    }
}

public struct MeshLODLevel {
    public var maxDistance: Float
    public var meshName: String
    public var level: UInt32

    public init(
        maxDistance: Float,
        meshName: String,
        level: UInt32
    ) {
        self.maxDistance = maxDistance
        self.meshName = meshName
        self.level = level
    }
}

public struct MeshLODMetadata {
    public var levels: [MeshLODLevel]
    public var fallbackMeshName: String

    public init(
        levels: [MeshLODLevel],
        fallbackMeshName: String
    ) {
        self.levels = levels
        self.fallbackMeshName = fallbackMeshName
    }

    public var isValid: Bool {
        !fallbackMeshName.isEmpty
            && levels.enumerated().allSatisfy { index, level in
                level.maxDistance.isFinite
                    && level.maxDistance >= 0
                    && !level.meshName.isEmpty
                    && (index == 0
                        || level.maxDistance
                            >= levels[index - 1].maxDistance)
            }
    }

    public func rendererRanges() -> [RendererLODRange] {
        levels.map {
            RendererLODRange(maxDistance: $0.maxDistance, level: $0.level)
        }
    }
}

public struct MeshCullingMetadata {
    public var center: Vector3
    public var radius: Float
    public var visibilityMask: UInt32
    public var enabled: Bool
    public var lod: MeshLODMetadata?

    public init(
        center: Vector3,
        radius: Float,
        visibilityMask: UInt32,
        enabled: Bool,
        lod: MeshLODMetadata?
    ) {
        self.center = center
        self.radius = radius
        self.visibilityMask = visibilityMask
        self.enabled = enabled
        self.lod = lod
    }

    public var isValid: Bool {
        [
            center.x,
            center.y,
            center.z
        ].allSatisfy { $0.isFinite }
            && radius.isFinite
            && radius >= 0
            && (lod?.isValid ?? true)
    }

    public func makeRendererCullingItem(
        id: UInt64,
        distance: Float
    ) -> RendererCullingItem? {
        guard isValid, distance.isFinite, distance >= 0 else {
            return nil
        }
        return RendererCullingItem(
            id: id,
            center: center,
            radius: radius,
            distance: distance,
            visibilityMask: visibilityMask,
            enabled: enabled,
            lodRanges: lod?.rendererRanges() ?? []
        )
    }
}

public final class MeshletPayload {
    public let name: String
    public let descriptors: [MeshletDescriptor]
    public let vertexData: [UInt8]
    public let primitiveData: [UInt8]

    public init(
        name: String,
        descriptors: [MeshletDescriptor],
        vertexData: [UInt8],
        primitiveData: [UInt8]
    ) {
        self.name = name
        self.descriptors = descriptors
        self.vertexData = vertexData
        self.primitiveData = primitiveData
    }

    public var meshletCount: UInt32 {
        UInt32(min(descriptors.count, Int(UInt32.max)))
    }

    public var isValid: Bool {
        !name.isEmpty
            && !descriptors.isEmpty
            && !vertexData.isEmpty
            && !primitiveData.isEmpty
            && descriptors.allSatisfy {
                $0.vertexCount > 0
                    && $0.primitiveCount > 0
                    && [
                        $0.boundsCenter.x,
                        $0.boundsCenter.y,
                        $0.boundsCenter.z
                    ].allSatisfy { $0.isFinite }
                    && $0.boundsRadius.isFinite
                    && $0.boundsRadius >= 0
            }
    }

    public func upload(
        device: Device,
        storageMode: StorageMode,
        label: String
    ) -> MeshletGPU? {
        guard isValid else {
            return nil
        }
        return MeshletGPU.upload(
            device: device,
            name: name,
            descriptors: descriptors,
            vertexData: vertexData,
            primitiveData: primitiveData,
            storageMode: storageMode,
            label: label
        )
    }

    public static func triangleFixture(name: String) -> MeshletPayload {
        let descriptor = MeshletDescriptor(
            vertexOffset: 0,
            vertexCount: 3,
            primitiveOffset: 0,
            primitiveCount: 1,
            lodLevel: 0,
            boundsCenter: Vector3(x: 0, y: 0, z: 0),
            boundsRadius: 1
        )
        return MeshletPayload(
            name: name,
            descriptors: [descriptor],
            vertexData: Array(repeating: 0, count: 36),
            primitiveData: [0, 1, 2]
        )
    }
}

public struct MeshVertex {
    public var position: Vector3
    public var normal: Vector3
    public var texcoord: Vector2

    public init(
        position: Vector3,
        normal: Vector3,
        texcoord: Vector2
    ) {
        self.position = position
        self.normal = normal
        self.texcoord = texcoord
    }
}

public final class Mesh {
    public let name: String
    public let vertexStride: UInt32
    public let primitiveType: PrimitiveType
    public let indexType: IndexType

    private var vertexStorage: [UInt8] = []
    private var indexStorage: [UInt8] = []
    private var meshletPayloadStorage: MeshletPayload?
    private var cullingMetadataStorage: MeshCullingMetadata?
    private var revisionStorage: UInt64 = 1

    public init(
        name: String,
        vertexStride: UInt32,
        primitiveType: PrimitiveType,
        indexType: IndexType
    ) {
        self.name = name
        self.vertexStride = vertexStride
        self.primitiveType = primitiveType
        self.indexType = indexType
    }

    public convenience init(name: String) {
        self.init(
            name: name,
            vertexStride: UInt32(MemoryLayout<MeshVertex>.stride),
            primitiveType: .triangle,
            indexType: .uint32
        )
    }

    public static var standardVertexStride: UInt32 {
        UInt32(MemoryLayout<MeshVertex>.stride)
    }

    public var vertexCount: UInt32 {
        guard vertexStride > 0 else {
            return 0
        }
        return UInt32(vertexStorage.count / Int(vertexStride))
    }

    public var indexCount: UInt32 {
        let stride = indexType == .uint16 ? 2 : 4
        return UInt32(indexStorage.count / stride)
    }

    public var vertexDataLength: UInt64 {
        UInt64(vertexStorage.count)
    }

    public var indexDataLength: UInt64 {
        UInt64(indexStorage.count)
    }

    public var retainsIndexedRepresentation: Bool {
        vertexCount > 0
    }

    public var retainsMeshletRepresentation: Bool {
        meshletPayloadStorage?.isValid == true
    }

    public func vertex(at index: UInt32) -> MeshVertex? {
        guard index < vertexCount,
              UInt64(vertexStride) == UInt64(MemoryLayout<MeshVertex>.stride),
              UInt64(index) * UInt64(vertexStride)
                  <= UInt64(vertexStorage.count),
              (UInt64(index) + 1) * UInt64(vertexStride)
                  <= UInt64(vertexStorage.count) else {
            return nil
        }
        let offset = Int(index) * Int(vertexStride)
        var value = MeshVertex(
            position: Vector3(x: 0, y: 0, z: 0),
            normal: Vector3(x: 0, y: 0, z: 0),
            texcoord: Vector2(x: 0, y: 0)
        )
        let source = vertexStorage[offset..<(offset + Int(vertexStride))]
        withUnsafeMutableBytes(of: &value) { destination in
            source.withUnsafeBytes { bytes in
                destination.copyMemory(from: bytes)
            }
        }
        return value
    }

    public var revision: UInt64 {
        revisionStorage
    }

    public var meshletPayload: MeshletPayload? {
        get {
            meshletPayloadStorage
        }
        set {
            meshletPayloadStorage = newValue
            revisionStorage &+= 1
        }
    }

    public func setMeshletPayload(_ payload: MeshletPayload) {
        meshletPayloadStorage = payload
        revisionStorage &+= 1
    }

    public func clearMeshletPayload() {
        meshletPayloadStorage = nil
        revisionStorage &+= 1
    }

    public var cullingMetadata: MeshCullingMetadata? {
        get {
            cullingMetadataStorage
        }
        set {
            cullingMetadataStorage = newValue
            revisionStorage &+= 1
        }
    }

    public func setCullingMetadata(_ metadata: MeshCullingMetadata) {
        cullingMetadataStorage = metadata
        revisionStorage &+= 1
    }

    public func clearCullingMetadata() {
        cullingMetadataStorage = nil
        revisionStorage &+= 1
    }

    public func makeView(
        vertexOffset: UInt32 = 0,
        vertexCount: UInt32? = nil,
        indexOffset: UInt32 = 0,
        indexCount: UInt32? = nil,
        baseVertex: Int32 = 0
    ) -> MeshView {
        MeshView(
            meshName: name,
            vertexOffset: vertexOffset,
            vertexCount: vertexCount
                ?? (vertexOffset < self.vertexCount
                    ? self.vertexCount - vertexOffset
                    : 0),
            indexOffset: indexOffset,
            indexCount: indexCount
                ?? (indexOffset < self.indexCount
                    ? self.indexCount - indexOffset
                    : 0),
            baseVertex: baseVertex
        )
    }

    public func clear() {
        vertexStorage.removeAll(keepingCapacity: true)
        indexStorage.removeAll(keepingCapacity: true)
        meshletPayloadStorage = nil
        cullingMetadataStorage = nil
        revisionStorage &+= 1
    }

    public func appendVertex(_ vertex: MeshVertex) -> Bool {
        guard vertexStride == Mesh.standardVertexStride else {
            return false
        }
        var value = vertex
        withUnsafeBytes(of: &value) { bytes in
            vertexStorage.append(contentsOf: bytes)
        }
        revisionStorage &+= 1
        return true
    }

    public func appendIndex(_ index: UInt32) -> Bool {
        switch indexType {
        case .uint16:
            guard index <= UInt32(UInt16.max) else {
                return false
            }
            var value = UInt16(index)
            withUnsafeBytes(of: &value) { bytes in
                indexStorage.append(contentsOf: bytes)
            }
        case .uint32:
            var value = index
            withUnsafeBytes(of: &value) { bytes in
                indexStorage.append(contentsOf: bytes)
            }
        }
        revisionStorage &+= 1
        return true
    }

    public func setVertexData(
        _ source: UnsafeRawPointer,
        length: UInt64
    ) -> Bool {
        guard length > 0,
              UInt64(vertexStride) > 0,
              length % UInt64(vertexStride) == 0,
              length <= UInt64(Int.max) else {
            return false
        }
        let bytes = UnsafeRawBufferPointer(
            start: source,
            count: Int(length)
        )
        vertexStorage = bytes.map { $0 }
        revisionStorage &+= 1
        return true
    }

    public func setIndexData(
        _ source: UnsafeRawPointer,
        length: UInt64
    ) -> Bool {
        let stride: UInt64 = indexType == .uint16 ? 2 : 4
        guard length > 0,
              length % stride == 0,
              length <= UInt64(Int.max) else {
            return false
        }
        let bytes = UnsafeRawBufferPointer(
            start: source,
            count: Int(length)
        )
        indexStorage = bytes.map { $0 }
        revisionStorage &+= 1
        return true
    }

    public static func triangle(name: String) -> Mesh {
        let mesh = Mesh(name: name)
        _ = mesh.appendVertex(
            MeshVertex(
                position: Vector3(x: 0, y: 0.5, z: 0),
                normal: Vector3(x: 0, y: 0, z: 1),
                texcoord: Vector2(x: 0.5, y: 1)
            )
        )
        _ = mesh.appendVertex(
            MeshVertex(
                position: Vector3(x: -0.5, y: -0.5, z: 0),
                normal: Vector3(x: 0, y: 0, z: 1),
                texcoord: Vector2(x: 0, y: 0)
            )
        )
        _ = mesh.appendVertex(
            MeshVertex(
                position: Vector3(x: 0.5, y: -0.5, z: 0),
                normal: Vector3(x: 0, y: 0, z: 1),
                texcoord: Vector2(x: 1, y: 0)
            )
        )
        _ = mesh.appendIndex(0)
        _ = mesh.appendIndex(1)
        _ = mesh.appendIndex(2)
        return mesh
    }

    public static func plane(
        name: String,
        size: Float = 1
    ) -> Mesh {
        let mesh = Mesh(name: name)
        let half = max(0, size) * 0.5
        let normal = Vector3(x: 0, y: 1, z: 0)
        let vertices = [
            MeshVertex(
                position: Vector3(x: -half, y: 0, z: -half),
                normal: normal,
                texcoord: Vector2(x: 0, y: 0)
            ),
            MeshVertex(
                position: Vector3(x: half, y: 0, z: -half),
                normal: normal,
                texcoord: Vector2(x: 1, y: 0)
            ),
            MeshVertex(
                position: Vector3(x: half, y: 0, z: half),
                normal: normal,
                texcoord: Vector2(x: 1, y: 1)
            ),
            MeshVertex(
                position: Vector3(x: -half, y: 0, z: half),
                normal: normal,
                texcoord: Vector2(x: 0, y: 1)
            )
        ]
        for vertex in vertices {
            _ = mesh.appendVertex(vertex)
        }
        for index in [0, 1, 2, 0, 2, 3] {
            _ = mesh.appendIndex(UInt32(index))
        }
        return mesh
    }

    public static func cube(
        name: String,
        size: Float = 1
    ) -> Mesh {
        let mesh = Mesh(name: name)
        let half = max(0, size) * 0.5
        let faces: [(Vector3, [Vector3])] = [
            (
                Vector3(x: 0, y: 0, z: 1),
                [
                    Vector3(x: -half, y: -half, z: half),
                    Vector3(x: half, y: -half, z: half),
                    Vector3(x: half, y: half, z: half),
                    Vector3(x: -half, y: half, z: half)
                ]
            ),
            (
                Vector3(x: 0, y: 0, z: -1),
                [
                    Vector3(x: half, y: -half, z: -half),
                    Vector3(x: -half, y: -half, z: -half),
                    Vector3(x: -half, y: half, z: -half),
                    Vector3(x: half, y: half, z: -half)
                ]
            ),
            (
                Vector3(x: 0, y: 1, z: 0),
                [
                    Vector3(x: -half, y: half, z: -half),
                    Vector3(x: -half, y: half, z: half),
                    Vector3(x: half, y: half, z: half),
                    Vector3(x: half, y: half, z: -half)
                ]
            ),
            (
                Vector3(x: 0, y: -1, z: 0),
                [
                    Vector3(x: -half, y: -half, z: half),
                    Vector3(x: -half, y: -half, z: -half),
                    Vector3(x: half, y: -half, z: -half),
                    Vector3(x: half, y: -half, z: half)
                ]
            ),
            (
                Vector3(x: 1, y: 0, z: 0),
                [
                    Vector3(x: half, y: -half, z: half),
                    Vector3(x: half, y: -half, z: -half),
                    Vector3(x: half, y: half, z: -half),
                    Vector3(x: half, y: half, z: half)
                ]
            ),
            (
                Vector3(x: -1, y: 0, z: 0),
                [
                    Vector3(x: -half, y: -half, z: -half),
                    Vector3(x: -half, y: -half, z: half),
                    Vector3(x: -half, y: half, z: half),
                    Vector3(x: -half, y: half, z: -half)
                ]
            )
        ]
        let texcoords = [
            Vector2(x: 0, y: 0),
            Vector2(x: 1, y: 0),
            Vector2(x: 1, y: 1),
            Vector2(x: 0, y: 1)
        ]
        for (faceIndex, face) in faces.enumerated() {
            for vertexIndex in 0..<4 {
                _ = mesh.appendVertex(
                    MeshVertex(
                        position: face.1[vertexIndex],
                        normal: face.0,
                        texcoord: texcoords[vertexIndex]
                    )
                )
            }
            let base = UInt32(faceIndex * 4)
            for index in [0, 1, 2, 0, 2, 3] {
                _ = mesh.appendIndex(base + UInt32(index))
            }
        }
        return mesh
    }

    public static func grid(
        name: String,
        columns: UInt32,
        rows: UInt32,
        size: Float = 1
    ) -> Mesh {
        let mesh = Mesh(name: name)
        guard columns > 0, rows > 0, columns <= 1024, rows <= 1024 else {
            return mesh
        }
        let half = max(0, size) * 0.5
        let columnCount = columns + 1
        for row in 0...rows {
            let y = Float(row) / Float(rows)
            for column in 0...columns {
                let x = Float(column) / Float(columns)
                _ = mesh.appendVertex(
                    MeshVertex(
                        position: Vector3(
                            x: x * size - half,
                            y: 0,
                            z: y * size - half
                        ),
                        normal: Vector3(x: 0, y: 1, z: 0),
                        texcoord: Vector2(x: x, y: y)
                    )
                )
            }
        }
        for row in 0..<rows {
            for column in 0..<columns {
                let base = row * columnCount + column
                let next = base + columnCount
                for index in [
                    base, next, next + 1,
                    base, next + 1, base + 1
                ] {
                    _ = mesh.appendIndex(index)
                }
            }
        }
        return mesh
    }

    public static func textFixture(
        name: String,
        text: String,
        glyphWidth: Float = 1,
        glyphHeight: Float = 1,
        advance: Float = 1.1
    ) -> Mesh {
        let mesh = Mesh(name: name)
        let width = glyphWidth.isFinite && glyphWidth > 0
            ? glyphWidth
            : 1
        let height = glyphHeight.isFinite && glyphHeight > 0
            ? glyphHeight
            : 1
        let step = advance.isFinite && advance > 0 ? advance : 1.1
        for (index, _) in text.utf8.enumerated() {
            let x = Float(index) * step
            let base = UInt32(mesh.vertexCount)
            let vertices = [
                MeshVertex(
                    position: Vector3(x: x, y: 0, z: 0),
                    normal: Vector3(x: 0, y: 0, z: 1),
                    texcoord: Vector2(x: 0, y: 0)
                ),
                MeshVertex(
                    position: Vector3(x: x + width, y: 0, z: 0),
                    normal: Vector3(x: 0, y: 0, z: 1),
                    texcoord: Vector2(x: 1, y: 0)
                ),
                MeshVertex(
                    position: Vector3(x: x + width, y: height, z: 0),
                    normal: Vector3(x: 0, y: 0, z: 1),
                    texcoord: Vector2(x: 1, y: 1)
                ),
                MeshVertex(
                    position: Vector3(x: x, y: height, z: 0),
                    normal: Vector3(x: 0, y: 0, z: 1),
                    texcoord: Vector2(x: 0, y: 1)
                )
            ]
            for vertex in vertices {
                _ = mesh.appendVertex(vertex)
            }
            for index in [0, 1, 2, 0, 2, 3] {
                _ = mesh.appendIndex(base + UInt32(index))
            }
        }
        return mesh
    }

    fileprivate func upload(
        device: Device,
        storageMode: StorageMode,
        label: String
    ) -> MeshGPU? {
        guard vertexDataLength > 0, vertexCount > 0,
              storageMode == .shared || storageMode == .managed else {
            return nil
        }
        let vertexDescriptor = BufferDescriptor(
            length: vertexDataLength,
            usage: UInt32(BufferUsage.vertex.rawValue),
            storageMode: storageMode,
            cpuCacheMode: .defaultCache,
            hazardMode: .defaultMode,
            label: label.isEmpty ? name + ".vertices" : label + ".vertices"
        )
        guard let vertexBuffer = device.createBuffer(vertexDescriptor),
              uploadBytes(vertexStorage, to: vertexBuffer) else {
            return nil
        }

        var indexBuffer: Buffer?
        if indexDataLength > 0 {
            let indexDescriptor = BufferDescriptor(
                length: indexDataLength,
                usage: UInt32(BufferUsage.index.rawValue),
                storageMode: storageMode,
                cpuCacheMode: .defaultCache,
                hazardMode: .defaultMode,
                label: label.isEmpty ? name + ".indices" : label + ".indices"
            )
            guard let created = device.createBuffer(indexDescriptor),
                  uploadBytes(indexStorage, to: created) else {
                return nil
            }
            indexBuffer = created
        }

        let meshletGPU = meshletPayloadStorage?.upload(
            device: device,
            storageMode: storageMode,
            label: label.isEmpty ? name : label
        )
        return MeshGPU(
            name: name,
            vertexBuffer: vertexBuffer,
            indexBuffer: indexBuffer,
            primitiveType: primitiveType,
            indexType: indexType,
            vertexCount: vertexCount,
            indexCount: indexCount,
            sourceRevision: revisionStorage,
            meshlet: meshletGPU
        )
    }
}

fileprivate func uploadBytes(_ bytes: [UInt8], to buffer: Buffer) -> Bool {
    guard !bytes.isEmpty else {
        return false
    }
    return bytes.withUnsafeBufferPointer { pointer in
        guard let baseAddress = pointer.baseAddress else {
            return false
        }
        return buffer.upload(
            source: UnsafeRawPointer(baseAddress),
            length: UInt64(pointer.count),
            offset: 0
        )
    }
}

public final class MeshGPU {
    public let name: String
    public let vertexBuffer: Buffer
    public let indexBuffer: Buffer?
    public let primitiveType: PrimitiveType
    public let indexType: IndexType
    public let vertexCount: UInt32
    public let indexCount: UInt32
    public let sourceRevision: UInt64
    public let meshlet: MeshletGPU?

    public var hasIndexedRepresentation: Bool {
        vertexCount > 0
    }

    public var hasMeshletRepresentation: Bool {
        meshlet != nil
    }

    fileprivate init(
        name: String,
        vertexBuffer: Buffer,
        indexBuffer: Buffer?,
        primitiveType: PrimitiveType,
        indexType: IndexType,
        vertexCount: UInt32,
        indexCount: UInt32,
        sourceRevision: UInt64,
        meshlet: MeshletGPU?
    ) {
        self.name = name
        self.vertexBuffer = vertexBuffer
        self.indexBuffer = indexBuffer
        self.primitiveType = primitiveType
        self.indexType = indexType
        self.vertexCount = vertexCount
        self.indexCount = indexCount
        self.sourceRevision = sourceRevision
        self.meshlet = meshlet
    }

    public func makeRenderBatch(
        pipeline: RenderPipeline,
        transparent: Bool,
        label: String
    ) -> RenderBatch? {
        let batch = RenderBatch(
            pipeline: pipeline,
            vertexBuffer: vertexBuffer,
            primitiveType: primitiveType,
            vertexStart: 0,
            vertexCount: vertexCount,
            instanceCount: 1,
            baseInstance: 0,
            transparent: transparent,
            label: label
        )
        if let indexBuffer {
            guard batch.setIndexBuffer(
                indexBuffer,
                indexType: indexType,
                offset: 0,
                count: indexCount,
                baseVertex: 0
            ) else {
                return nil
            }
        }
        return batch
    }

    public func makeMeshletRenderBatch(
        pipeline: RenderPipeline,
        dispatch: MeshDispatchDescriptor,
        transparent: Bool,
        label: String
    ) -> RenderBatch? {
        meshlet?.makeRenderBatch(
            pipeline: pipeline,
            dispatch: dispatch,
            transparent: transparent,
            label: label
        )
    }
}

public final class DrawableManager {
    private var meshes: [String: Mesh] = [:]
    private var meshOrder: [String] = []
    private var gpuMeshes: [String: MeshGPU] = [:]
    private var syncVersionStorage: UInt64 = 0
    private let retirementQueueStorage = ResourceRetirementQueue()
    private var errorDescriptionStorage = ""

    public init() {}

    public var meshCount: UInt32 {
        UInt32(meshOrder.count)
    }

    public var gpuMeshCount: UInt32 {
        UInt32(gpuMeshes.count)
    }

    public var errorDescription: String {
        errorDescriptionStorage
    }

    public var syncVersion: UInt64 {
        syncVersionStorage
    }

    public var retirementQueue: ResourceRetirementQueue {
        retirementQueueStorage
    }

    public func addMesh(_ mesh: Mesh) -> Bool {
        guard !mesh.name.isEmpty, meshes[mesh.name] == nil else {
            errorDescriptionStorage =
                "A mesh with this name already exists or the name is empty."
            return false
        }
        meshes[mesh.name] = mesh
        meshOrder.append(mesh.name)
        errorDescriptionStorage = ""
        return true
    }

    public func replaceMesh(_ mesh: Mesh) -> Bool {
        guard !mesh.name.isEmpty else {
            errorDescriptionStorage = "Mesh names cannot be empty."
            return false
        }
        if meshes[mesh.name] == nil {
            meshOrder.append(mesh.name)
        }
        meshes[mesh.name] = mesh
        gpuMeshes[mesh.name] = nil
        syncVersionStorage &+= 1
        errorDescriptionStorage = ""
        return true
    }

    public func replaceMesh(
        _ mesh: Mesh,
        after token: CompletionToken
    ) -> Bool {
        guard !mesh.name.isEmpty else {
            errorDescriptionStorage = "Mesh names cannot be empty."
            return false
        }
        if meshes[mesh.name] == nil {
            meshOrder.append(mesh.name)
        }
        if let previous = gpuMeshes[mesh.name] {
            retire(previous, after: token)
        }
        meshes[mesh.name] = mesh
        gpuMeshes[mesh.name] = nil
        syncVersionStorage &+= 1
        errorDescriptionStorage = ""
        return true
    }

    public func removeMesh(_ name: String) -> Bool {
        guard meshes.removeValue(forKey: name) != nil else {
            return false
        }
        meshOrder.removeAll { $0 == name }
        gpuMeshes[name] = nil
        syncVersionStorage &+= 1
        return true
    }

    public func removeMesh(
        _ name: String,
        after token: CompletionToken
    ) -> Bool {
        guard meshes.removeValue(forKey: name) != nil else {
            return false
        }
        meshOrder.removeAll { $0 == name }
        if let previous = gpuMeshes.removeValue(forKey: name) {
            retire(previous, after: token)
        }
        syncVersionStorage &+= 1
        return true
    }

    public func clear() {
        meshes.removeAll()
        meshOrder.removeAll()
        gpuMeshes.removeAll()
        syncVersionStorage &+= 1
    }

    public func clear(after token: CompletionToken) {
        for mesh in gpuMeshes.values {
            retire(mesh, after: token)
        }
        meshes.removeAll()
        meshOrder.removeAll()
        gpuMeshes.removeAll()
        syncVersionStorage &+= 1
    }

    public func mesh(_ name: String) -> Mesh? {
        meshes[name]
    }

    public func meshAt(_ index: UInt32) -> Mesh? {
        guard index < UInt32(meshOrder.count) else {
            return nil
        }
        return meshes[meshOrder[Int(index)]]
    }

    public func gpuMesh(_ name: String) -> MeshGPU? {
        gpuMeshes[name]
    }

    public func gpuMeshVersion(_ name: String) -> UInt64 {
        gpuMeshes[name]?.sourceRevision ?? 0
    }

    public func uploadMesh(
        _ name: String,
        device: Device,
        storageMode: StorageMode,
        label: String
    ) -> MeshGPU? {
        guard let mesh = meshes[name] else {
            errorDescriptionStorage = "Mesh not found: " + name
            return nil
        }
        if let existing = gpuMeshes[name],
           existing.sourceRevision == mesh.revision {
            errorDescriptionStorage = ""
            return existing
        }
        guard let gpuMesh = mesh.upload(
            device: device,
            storageMode: storageMode,
            label: label
        ) else {
            errorDescriptionStorage =
                "Mesh upload requires valid data and CPU-visible storage."
            return nil
        }
        gpuMeshes[name] = gpuMesh
        syncVersionStorage &+= 1
        errorDescriptionStorage = ""
        return gpuMesh
    }

    public func uploadAll(
        device: Device,
        storageMode: StorageMode,
        label: String
    ) -> UInt32 {
        var uploaded: UInt32 = 0
        for name in meshOrder {
            if uploadMesh(
                name,
                device: device,
                storageMode: storageMode,
                label: label
            ) != nil {
                uploaded += 1
            }
        }
        return uploaded
    }

    public func syncToGPU(
        device: Device,
        storageMode: StorageMode,
        label: String
    ) -> DrawableSyncResult {
        var uploaded: UInt32 = 0
        var failed: UInt32 = 0
        for name in meshOrder {
            guard let mesh = meshes[name] else {
                continue
            }
            let previousRevision = gpuMeshes[name]?.sourceRevision ?? 0
            if uploadMesh(
                name,
                device: device,
                storageMode: storageMode,
                label: label
            ) == nil {
                failed &+= 1
            } else if previousRevision != mesh.revision {
                uploaded &+= 1
            }
        }
        if failed > 0 {
            errorDescriptionStorage =
                "One or more meshes could not be synchronized."
        }
        return DrawableSyncResult(
            syncVersion: syncVersionStorage,
            uploadedCount: uploaded,
            failedCount: failed,
            gpuMeshCount: UInt32(gpuMeshes.count)
        )
    }

    public func syncToGPU(
        device: Device,
        storageMode: StorageMode,
        label: String,
        after token: CompletionToken
    ) -> DrawableSyncResult {
        var uploaded: UInt32 = 0
        var failed: UInt32 = 0
        for name in meshOrder {
            guard let mesh = meshes[name] else {
                continue
            }
            if let existing = gpuMeshes[name],
               existing.sourceRevision == mesh.revision {
                continue
            }
            guard let gpuMesh = mesh.upload(
                device: device,
                storageMode: storageMode,
                label: label
            ) else {
                failed &+= 1
                continue
            }
            if let previous = gpuMeshes[name] {
                retire(previous, after: token)
            }
            gpuMeshes[name] = gpuMesh
            uploaded &+= 1
        }
        syncVersionStorage &+= 1
        if failed > 0 {
            errorDescriptionStorage =
                "One or more meshes could not be synchronized."
        } else {
            errorDescriptionStorage = ""
        }
        return DrawableSyncResult(
            syncVersion: syncVersionStorage,
            uploadedCount: uploaded,
            failedCount: failed,
            gpuMeshCount: UInt32(gpuMeshes.count)
        )
    }

    public func collectRetiredResources() -> UInt32 {
        retirementQueueStorage.collectCompleted()
    }

    private func retire(
        _ mesh: MeshGPU,
        after token: CompletionToken
    ) {
        _ = retirementQueueStorage.retireBuffer(
            mesh.vertexBuffer,
            after: token
        )
        if let indexBuffer = mesh.indexBuffer {
            _ = retirementQueueStorage.retireBuffer(
                indexBuffer,
                after: token
            )
        }
        if let meshlet = mesh.meshlet {
            _ = retirementQueueStorage.retireBuffer(
                meshlet.meshletBuffer,
                after: token
            )
            _ = retirementQueueStorage.retireBuffer(
                meshlet.vertexBuffer,
                after: token
            )
            _ = retirementQueueStorage.retireBuffer(
                meshlet.primitiveBuffer,
                after: token
            )
        }
    }
}

public struct DrawableSyncResult {
    public var syncVersion: UInt64
    public var uploadedCount: UInt32
    public var failedCount: UInt32
    public var gpuMeshCount: UInt32

    public init(
        syncVersion: UInt64,
        uploadedCount: UInt32,
        failedCount: UInt32,
        gpuMeshCount: UInt32
    ) {
        self.syncVersion = syncVersion
        self.uploadedCount = uploadedCount
        self.failedCount = failedCount
        self.gpuMeshCount = gpuMeshCount
    }
}

public final class Lines {
    private let storage: Mesh

    public init(name: String) {
        storage = Mesh(
            name: name,
            vertexStride: Mesh.standardVertexStride,
            primitiveType: .line,
            indexType: .uint32
        )
    }

    public func append(_ start: MeshVertex, _ end: MeshVertex) -> Bool {
        storage.appendVertex(start) && storage.appendVertex(end)
    }

    public var mesh: Mesh {
        storage
    }
}

public final class Points {
    private let storage: Mesh

    public init(name: String) {
        storage = Mesh(
            name: name,
            vertexStride: Mesh.standardVertexStride,
            primitiveType: .point,
            indexType: .uint32
        )
    }

    public func append(_ point: MeshVertex) -> Bool {
        storage.appendVertex(point)
    }

    public var mesh: Mesh {
        storage
    }
}

public struct SceneObject {
    public var name: String
    public var meshName: String
    public var transform: Transform
    public var materialID: UInt64
    public var visibilityMask: UInt32
    public var enabled: Bool
    public var meshView: MeshView?
    public var culling: MeshCullingMetadata?

    public init(
        name: String,
        meshName: String,
        transform: Transform,
        materialID: UInt64,
        visibilityMask: UInt32,
        enabled: Bool,
        meshView: MeshView? = nil,
        culling: MeshCullingMetadata? = nil
    ) {
        self.name = name
        self.meshName = meshName
        self.transform = transform
        self.materialID = materialID
        self.visibilityMask = visibilityMask
        self.enabled = enabled
        self.meshView = meshView
        self.culling = culling
    }

    public func makeRendererCullingItem(
        id: UInt64,
        distance: Float
    ) -> RendererCullingItem? {
        culling?.makeRendererCullingItem(id: id, distance: distance)
    }
}

public struct SceneObjectGPUData {
    public var positionX: Float
    public var positionY: Float
    public var positionZ: Float
    public var rotationX: Float
    public var rotationY: Float
    public var rotationZ: Float
    public var scaleX: Float
    public var scaleY: Float
    public var scaleZ: Float
    public var materialIDLow: UInt32
    public var materialIDHigh: UInt32
    public var visibilityMask: UInt32
    public var enabled: UInt32
    public var reserved0: UInt32
    public var reserved1: UInt32
    public var reserved2: UInt32

    public init(object: SceneObject) {
        positionX = object.transform.position.x
        positionY = object.transform.position.y
        positionZ = object.transform.position.z
        rotationX = object.transform.rotation.x
        rotationY = object.transform.rotation.y
        rotationZ = object.transform.rotation.z
        scaleX = object.transform.scale.x
        scaleY = object.transform.scale.y
        scaleZ = object.transform.scale.z
        materialIDLow = UInt32(truncatingIfNeeded: object.materialID)
        materialIDHigh = UInt32(
            truncatingIfNeeded: object.materialID >> 32
        )
        visibilityMask = object.visibilityMask
        enabled = object.enabled ? 1 : 0
        reserved0 = 0
        reserved1 = 0
        reserved2 = 0
    }
}

public struct SceneSyncResult {
    public var sceneVersion: UInt64
    public var gpuVersion: UInt64
    public var objectCount: UInt32
    public var didUpload: Bool

    public init(
        sceneVersion: UInt64,
        gpuVersion: UInt64,
        objectCount: UInt32,
        didUpload: Bool
    ) {
        self.sceneVersion = sceneVersion
        self.gpuVersion = gpuVersion
        self.objectCount = objectCount
        self.didUpload = didUpload
    }
}

public final class SceneGPU {
    public let objectBuffer: Buffer
    public let objectCount: UInt32
    public let sourceRevision: UInt64
    public let version: UInt64

    private init(
        objectBuffer: Buffer,
        objectCount: UInt32,
        sourceRevision: UInt64,
        version: UInt64
    ) {
        self.objectBuffer = objectBuffer
        self.objectCount = objectCount
        self.sourceRevision = sourceRevision
        self.version = version
    }

    fileprivate static func upload(
        device: Device,
        objects: [SceneObject],
        sourceRevision: UInt64,
        version: UInt64,
        storageMode: StorageMode,
        label: String
    ) -> SceneGPU? {
        guard storageMode == .shared || storageMode == .managed else {
            return nil
        }
        let data = objects.map { SceneObjectGPUData(object: $0) }
        let bytesLength = max(
            MemoryLayout<SceneObjectGPUData>.stride * data.count,
            MemoryLayout<SceneObjectGPUData>.stride
        )
        let descriptor = BufferDescriptor(
            length: UInt64(bytesLength),
            usage: UInt32(BufferUsage.storage.rawValue),
            storageMode: storageMode,
            cpuCacheMode: .defaultCache,
            hazardMode: .defaultMode,
            label: label.isEmpty ? "mt.scene.objects" : label
        )
        guard let buffer = device.createBuffer(descriptor) else {
            return nil
        }
        if !data.isEmpty {
            let uploaded = data.withUnsafeBufferPointer { pointer in
                guard let baseAddress = pointer.baseAddress else {
                    return false
                }
                return buffer.upload(
                    source: UnsafeRawPointer(baseAddress),
                    length: UInt64(
                        MemoryLayout<SceneObjectGPUData>.stride
                            * pointer.count
                    ),
                    offset: 0
                )
            }
            guard uploaded else {
                return nil
            }
        }
        return SceneGPU(
            objectBuffer: buffer,
            objectCount: UInt32(min(objects.count, Int(UInt32.max))),
            sourceRevision: sourceRevision,
            version: version
        )
    }
}

public final class Scene {
    private var objects: [String: SceneObject] = [:]
    private var objectOrder: [String] = []
    private var revisionStorage: UInt64 = 1
    private var gpuVersionStorage: UInt64 = 0
    private var gpuSceneStorage: SceneGPU?
    private let retirementQueueStorage = ResourceRetirementQueue()
    private var lastSyncResultStorage = SceneSyncResult(
        sceneVersion: 1,
        gpuVersion: 0,
        objectCount: 0,
        didUpload: false
    )
    private var errorDescriptionStorage = ""

    public init() {}

    public var objectCount: UInt32 {
        UInt32(objectOrder.count)
    }

    public var revision: UInt64 {
        revisionStorage
    }

    public var gpuVersion: UInt64 {
        gpuVersionStorage
    }

    public var gpuObjectCount: UInt32 {
        gpuSceneStorage?.objectCount ?? 0
    }

    public var gpuScene: SceneGPU? {
        gpuSceneStorage
    }

    public var lastSyncResult: SceneSyncResult {
        lastSyncResultStorage
    }

    public var retirementQueue: ResourceRetirementQueue {
        retirementQueueStorage
    }

    public var errorDescription: String {
        errorDescriptionStorage
    }

    public func addObject(_ object: SceneObject) -> Bool {
        guard !object.name.isEmpty, objects[object.name] == nil else {
            return false
        }
        objects[object.name] = object
        objectOrder.append(object.name)
        revisionStorage &+= 1
        return true
    }

    public func updateObject(_ object: SceneObject) -> Bool {
        guard !object.name.isEmpty, objects[object.name] != nil else {
            return false
        }
        objects[object.name] = object
        revisionStorage &+= 1
        return true
    }

    public func removeObject(_ name: String) -> Bool {
        guard objects.removeValue(forKey: name) != nil else {
            return false
        }
        objectOrder.removeAll { $0 == name }
        revisionStorage &+= 1
        return true
    }

    public func clear() {
        objects.removeAll()
        objectOrder.removeAll()
        revisionStorage &+= 1
    }

    public func object(_ name: String) -> SceneObject? {
        objects[name]
    }

    public func objectAt(_ index: UInt32) -> SceneObject? {
        guard index < UInt32(objectOrder.count) else {
            return nil
        }
        return objects[objectOrder[Int(index)]]
    }

    public func syncToGPU(
        device: Device,
        storageMode: StorageMode,
        label: String
    ) -> SceneGPU? {
        if let current = gpuSceneStorage,
           current.sourceRevision == revisionStorage {
            lastSyncResultStorage = SceneSyncResult(
                sceneVersion: revisionStorage,
                gpuVersion: gpuVersionStorage,
                objectCount: current.objectCount,
                didUpload: false
            )
            return current
        }
        let nextVersion = gpuVersionStorage &+ 1
        guard let gpuScene = SceneGPU.upload(
            device: device,
            objects: objectOrder.compactMap { objects[$0] },
            sourceRevision: revisionStorage,
            version: nextVersion,
            storageMode: storageMode,
            label: label
        ) else {
            errorDescriptionStorage =
                "Scene synchronization requires CPU-visible storage."
            return nil
        }
        gpuSceneStorage = gpuScene
        gpuVersionStorage = nextVersion
        lastSyncResultStorage = SceneSyncResult(
            sceneVersion: revisionStorage,
            gpuVersion: nextVersion,
            objectCount: gpuScene.objectCount,
            didUpload: true
        )
        errorDescriptionStorage = ""
        return gpuScene
    }

    public func syncToGPU(
        device: Device,
        storageMode: StorageMode,
        label: String,
        after token: CompletionToken,
        retirementQueue: ResourceRetirementQueue
    ) -> SceneGPU? {
        if let current = gpuSceneStorage,
           current.sourceRevision == revisionStorage {
            lastSyncResultStorage = SceneSyncResult(
                sceneVersion: revisionStorage,
                gpuVersion: gpuVersionStorage,
                objectCount: current.objectCount,
                didUpload: false
            )
            return current
        }
        let nextVersion = gpuVersionStorage &+ 1
        guard let gpuScene = SceneGPU.upload(
            device: device,
            objects: objectOrder.compactMap { objects[$0] },
            sourceRevision: revisionStorage,
            version: nextVersion,
            storageMode: storageMode,
            label: label
        ) else {
            errorDescriptionStorage =
                "Scene synchronization requires CPU-visible storage."
            return nil
        }
        if let previous = gpuSceneStorage {
            _ = retirementQueue.retireBuffer(
                previous.objectBuffer,
                after: token
            )
        }
        gpuSceneStorage = gpuScene
        gpuVersionStorage = nextVersion
        lastSyncResultStorage = SceneSyncResult(
            sceneVersion: revisionStorage,
            gpuVersion: nextVersion,
            objectCount: gpuScene.objectCount,
            didUpload: true
        )
        errorDescriptionStorage = ""
        return gpuScene
    }

    public func syncToGPU(
        device: Device,
        storageMode: StorageMode,
        label: String,
        after token: CompletionToken
    ) -> SceneGPU? {
        syncToGPU(
            device: device,
            storageMode: storageMode,
            label: label,
            after: token,
            retirementQueue: retirementQueueStorage
        )
    }

    public func collectRetiredResources(
        from retirementQueue: ResourceRetirementQueue
    ) -> UInt32 {
        retirementQueue.collectCompleted()
    }

    public func collectRetiredResources() -> UInt32 {
        retirementQueueStorage.collectCompleted()
    }
}

public enum MaterialBindingPath: Int32 {
    case directSlots
    case argumentBuffer
    case argumentBufferTable
}

public enum SamplerFallbackPolicy: Int32 {
    case none
    case linearClamp
    case nearestClamp
    case shadowCompare
}

public struct MaterialPipelineMetadata {
    public var shaderSignature: String
    public var layoutSignature: String
    public var descriptorSignature: String
    public var cacheIdentifier: String

    public init(
        shaderSignature: String,
        layoutSignature: String,
        descriptorSignature: String,
        cacheIdentifier: String
    ) {
        self.shaderSignature = shaderSignature
        self.layoutSignature = layoutSignature
        self.descriptorSignature = descriptorSignature
        self.cacheIdentifier = cacheIdentifier
    }
}

public final class MaterialTextureTable {
    private var entries: [UInt32: Texture] = [:]

    public init() {}

    public var count: UInt32 {
        UInt32(entries.count)
    }

    public var indices: [UInt32] {
        entries.keys.sorted()
    }

    public func set(_ texture: Texture, index: UInt32) {
        entries[index] = texture
    }

    public func texture(_ index: UInt32) -> Texture? {
        entries[index]
    }

    public func remove(_ index: UInt32) -> Bool {
        entries.removeValue(forKey: index) != nil
    }

    public func removeAll() {
        entries.removeAll(keepingCapacity: true)
    }
}

public final class MaterialSamplerTable {
    private var entries: [UInt32: Sampler] = [:]

    public init() {}

    public var count: UInt32 {
        UInt32(entries.count)
    }

    public var indices: [UInt32] {
        entries.keys.sorted()
    }

    public func set(_ sampler: Sampler, index: UInt32) {
        entries[index] = sampler
    }

    public func sampler(_ index: UInt32) -> Sampler? {
        entries[index]
    }

    public func remove(_ index: UInt32) -> Bool {
        entries.removeValue(forKey: index) != nil
    }

    public func removeAll() {
        entries.removeAll(keepingCapacity: true)
    }
}

public struct PhongMaterialData {
    public var baseColor: Vector4
    public var specularColor: Vector4
    public var shininess: Float
    public var reserved0: Float
    public var reserved1: Float
    public var reserved2: Float

    public init(
        baseColor: Vector4,
        specularColor: Vector4,
        shininess: Float
    ) {
        self.baseColor = baseColor
        self.specularColor = specularColor
        self.shininess = shininess
        reserved0 = 0
        reserved1 = 0
        reserved2 = 0
    }

    public func makeParameterBlock() -> ParameterBlock {
        makeSceneParameterBlock(self)
    }
}

public struct PBRMaterialData {
    public var baseColor: Vector4
    public var emissiveColor: Vector4
    public var metallic: Float
    public var roughness: Float
    public var normalScale: Float
    public var occlusionStrength: Float

    public init(
        baseColor: Vector4,
        emissiveColor: Vector4,
        metallic: Float,
        roughness: Float,
        normalScale: Float,
        occlusionStrength: Float
    ) {
        self.baseColor = baseColor
        self.emissiveColor = emissiveColor
        self.metallic = metallic
        self.roughness = roughness
        self.normalScale = normalScale
        self.occlusionStrength = occlusionStrength
    }

    public func makeParameterBlock() -> ParameterBlock {
        makeSceneParameterBlock(self)
    }
}

public struct DirectionalShadowMaterialData {
    public var lightViewProjection: Matrix4x4
    public var depthBias: Float
    public var normalBias: Float
    public var reserved0: Float
    public var reserved1: Float

    public init(
        lightViewProjection: Matrix4x4,
        depthBias: Float,
        normalBias: Float
    ) {
        self.lightViewProjection = lightViewProjection
        self.depthBias = depthBias
        self.normalBias = normalBias
        reserved0 = 0
        reserved1 = 0
    }

    public func makeParameterBlock() -> ParameterBlock {
        makeSceneParameterBlock(self)
    }
}

public struct BillboardMaterialData {
    public var color: Vector4
    public var size: Vector2
    public var pivot: Vector2

    public init(color: Vector4, size: Vector2, pivot: Vector2) {
        self.color = color
        self.size = size
        self.pivot = pivot
    }

    public func makeParameterBlock() -> ParameterBlock {
        makeSceneParameterBlock(self)
    }
}

public struct TextMaterialData {
    public var color: Vector4
    public var outlineColor: Vector4
    public var outlineWidth: Float
    public var edgeSoftness: Float
    public var reserved0: Float
    public var reserved1: Float

    public init(
        color: Vector4,
        outlineColor: Vector4,
        outlineWidth: Float,
        edgeSoftness: Float
    ) {
        self.color = color
        self.outlineColor = outlineColor
        self.outlineWidth = outlineWidth
        self.edgeSoftness = edgeSoftness
        reserved0 = 0
        reserved1 = 0
    }

    public func makeParameterBlock() -> ParameterBlock {
        makeSceneParameterBlock(self)
    }
}

public struct MeshVisualizationMaterialData {
    public var color: Vector4
    public var mode: UInt32
    public var lineWidth: Float
    public var opacity: Float
    public var reserved: Float

    public init(
        color: Vector4,
        mode: UInt32,
        lineWidth: Float,
        opacity: Float
    ) {
        self.color = color
        self.mode = mode
        self.lineWidth = lineWidth
        self.opacity = opacity
        reserved = 0
    }

    public func makeParameterBlock() -> ParameterBlock {
        makeSceneParameterBlock(self)
    }
}

private func makeSceneParameterBlock<T>(
    _ value: T,
    alignment: UInt32 = 16
) -> ParameterBlock {
    let block = ParameterBlock(
        length: UInt32(MemoryLayout<T>.size),
        alignment: alignment
    )
    var value = value
    withUnsafeBytes(of: &value) { bytes in
        guard let baseAddress = bytes.baseAddress else {
            return
        }
        _ = block.writeBytes(
            baseAddress,
            length: UInt32(bytes.count),
            offset: 0
        )
    }
    return block
}

public final class Material {
    public let name: String
    public let pipeline: RenderPipeline
    public var transparent: Bool
    public var requiresMeshShaders: Bool
    public var requiresArgumentBuffers: Bool
    public var requiresIndirectCommandBuffers: Bool

    private var vertexParametersStorage: ParameterBlock?
    private var fragmentParametersStorage: ParameterBlock?
    private var vertexParameterIndexStorage: UInt32 = 0
    private var fragmentParameterIndexStorage: UInt32 = 0
    private let vertexTextureTableStorage = MaterialTextureTable()
    private let fragmentTextureTableStorage = MaterialTextureTable()
    private let vertexSamplerTableStorage = MaterialSamplerTable()
    private let fragmentSamplerTableStorage = MaterialSamplerTable()
    private var vertexArgumentBufferStorage: ArgumentBuffer?
    private var fragmentArgumentBufferStorage: ArgumentBuffer?
    private var vertexArgumentTableStorage: ArgumentBufferTable?
    private var fragmentArgumentTableStorage: ArgumentBufferTable?
    private var bindingPathStorage: MaterialBindingPath = .directSlots
    private var samplerFallbackPolicyStorage: SamplerFallbackPolicy = .none
    private var pipelineMetadataStorage: MaterialPipelineMetadata?
    private var pipelineCacheStorage: PipelineCache?

    public init(name: String, pipeline: RenderPipeline) {
        self.name = name
        self.pipeline = pipeline
        self.transparent = false
        self.requiresMeshShaders = false
        self.requiresArgumentBuffers = false
        self.requiresIndirectCommandBuffers = false
    }

    public var bindingPath: MaterialBindingPath {
        bindingPathStorage
    }

    public var usedBindingFallback: Bool {
        requiresArgumentBuffers && bindingPathStorage == .directSlots
    }

    public var samplerFallbackPolicy: SamplerFallbackPolicy {
        get {
            samplerFallbackPolicyStorage
        }
        set {
            samplerFallbackPolicyStorage = newValue
        }
    }

    public var vertexTextures: MaterialTextureTable {
        vertexTextureTableStorage
    }

    public var fragmentTextures: MaterialTextureTable {
        fragmentTextureTableStorage
    }

    public var vertexSamplers: MaterialSamplerTable {
        vertexSamplerTableStorage
    }

    public var fragmentSamplers: MaterialSamplerTable {
        fragmentSamplerTableStorage
    }

    public var pipelineMetadata: MaterialPipelineMetadata? {
        pipelineMetadataStorage
    }

    public var pipelineCache: PipelineCache? {
        pipelineCacheStorage
    }

    public var pipelineCacheEntryCount: UInt32 {
        pipelineCacheStorage?.entryCount ?? 0
    }

    public var pipelineCacheHits: UInt64 {
        pipelineCacheStorage?.hits ?? 0
    }

    public var pipelineCacheMisses: UInt64 {
        pipelineCacheStorage?.misses ?? 0
    }

    public func setPipelineMetadata(
        _ metadata: MaterialPipelineMetadata
    ) {
        pipelineMetadataStorage = metadata
    }

    public func setPipelineCache(_ cache: PipelineCache) {
        pipelineCacheStorage = cache
    }

    public func clearPipelineCache() {
        pipelineCacheStorage = nil
    }

    @discardableResult
    public func selectBindingPath(device: Device) -> MaterialBindingPath {
        if (vertexArgumentTableStorage != nil
            || fragmentArgumentTableStorage != nil)
            && device.capabilities.argumentBufferCapabilities.supported {
            bindingPathStorage = .argumentBufferTable
        } else if vertexArgumentBufferStorage != nil
            || fragmentArgumentBufferStorage != nil {
            if device.capabilities.argumentBufferCapabilities.supported {
                bindingPathStorage = .argumentBuffer
            } else {
                bindingPathStorage = .directSlots
            }
        } else {
            bindingPathStorage = .directSlots
        }
        return bindingPathStorage
    }

    public func ensureSamplerFallbacks(
        device: Device,
        label: String
    ) -> Bool {
        guard samplerFallbackPolicyStorage != .none else {
            return true
        }
        let filter: SamplerFilter =
            samplerFallbackPolicyStorage == .nearestClamp
                ? .nearest
                : .linear
        let compare: CompareFunction =
            samplerFallbackPolicyStorage == .shadowCompare
                ? .lessEqual
                : .always
        let descriptor = SamplerDescriptor(
            minFilter: filter,
            magFilter: filter,
            mipFilter: .linear,
            addressModeS: .clampToEdge,
            addressModeT: .clampToEdge,
            addressModeR: .clampToEdge,
            compareFunction: compare,
            maxAnisotropy: 1,
            lodMinClamp: 0,
            lodMaxClamp: 16,
            label: label.isEmpty ? name + ".fallback" : label
        )
        guard let sampler = device.createSampler(descriptor) else {
            return false
        }
        for index in vertexTextureTableStorage.indices
            where vertexSamplerTableStorage.sampler(index) == nil {
            vertexSamplerTableStorage.set(sampler, index: index)
        }
        for index in fragmentTextureTableStorage.indices
            where fragmentSamplerTableStorage.sampler(index) == nil {
            fragmentSamplerTableStorage.set(sampler, index: index)
        }
        return true
    }

    public func isSupported(device: Device) -> Bool {
        if requiresMeshShaders && !device.capabilities.meshShaders {
            return false
        }
        if requiresArgumentBuffers &&
            !device.capabilities.argumentBufferCapabilities.supported {
            return false
        }
        if requiresIndirectCommandBuffers &&
            !device.capabilities.indirectCommandBuffers {
            return false
        }
        return true
    }

    public func setVertexParameters(
        _ parameters: ParameterBlock,
        index: UInt32
    ) {
        vertexParametersStorage = parameters
        vertexParameterIndexStorage = index
    }

    public func setFragmentParameters(
        _ parameters: ParameterBlock,
        index: UInt32
    ) {
        fragmentParametersStorage = parameters
        fragmentParameterIndexStorage = index
    }

    public func clearVertexParameters() {
        vertexParametersStorage = nil
    }

    public func clearFragmentParameters() {
        fragmentParametersStorage = nil
    }

    public func setVertexTexture(_ texture: Texture, index: UInt32) {
        vertexTextureTableStorage.set(texture, index: index)
    }

    public func setFragmentTexture(_ texture: Texture, index: UInt32) {
        fragmentTextureTableStorage.set(texture, index: index)
    }

    public func setVertexSampler(_ sampler: Sampler, index: UInt32) {
        vertexSamplerTableStorage.set(sampler, index: index)
    }

    public func setFragmentSampler(_ sampler: Sampler, index: UInt32) {
        fragmentSamplerTableStorage.set(sampler, index: index)
    }

    public func setVertexArgumentBuffer(_ argumentBuffer: ArgumentBuffer) {
        vertexArgumentBufferStorage = argumentBuffer
        if bindingPathStorage == .directSlots {
            bindingPathStorage = .argumentBuffer
        }
    }

    public func clearVertexArgumentBuffer() {
        vertexArgumentBufferStorage = nil
        if vertexArgumentTableStorage == nil
            && fragmentArgumentTableStorage == nil
            && fragmentArgumentBufferStorage == nil {
            bindingPathStorage = .directSlots
        }
    }

    public func setFragmentArgumentBuffer(_ argumentBuffer: ArgumentBuffer) {
        fragmentArgumentBufferStorage = argumentBuffer
        if bindingPathStorage == .directSlots {
            bindingPathStorage = .argumentBuffer
        }
    }

    public func clearFragmentArgumentBuffer() {
        fragmentArgumentBufferStorage = nil
        if vertexArgumentTableStorage == nil
            && fragmentArgumentTableStorage == nil
            && vertexArgumentBufferStorage == nil {
            bindingPathStorage = .directSlots
        }
    }

    public func setVertexArgumentTable(_ table: ArgumentBufferTable) {
        vertexArgumentTableStorage = table
        bindingPathStorage = .argumentBufferTable
    }

    public func clearVertexArgumentTable() {
        vertexArgumentTableStorage = nil
        if fragmentArgumentTableStorage == nil
            && vertexArgumentBufferStorage == nil
            && fragmentArgumentBufferStorage == nil {
            bindingPathStorage = .directSlots
        }
    }

    public func setFragmentArgumentTable(_ table: ArgumentBufferTable) {
        fragmentArgumentTableStorage = table
        bindingPathStorage = .argumentBufferTable
    }

    public func clearFragmentArgumentTable() {
        fragmentArgumentTableStorage = nil
        if vertexArgumentTableStorage == nil
            && vertexArgumentBufferStorage == nil
            && fragmentArgumentBufferStorage == nil {
            bindingPathStorage = .directSlots
        }
    }

    public func bind(_ encoder: RenderEncoder) -> Bool {
        if let parameters = vertexParametersStorage,
           !encoder.setVertexBytes(
               parameters,
               index: vertexParameterIndexStorage
           ) {
            return false
        }
        if let parameters = fragmentParametersStorage,
           !encoder.setFragmentBytes(
               parameters,
               index: fragmentParameterIndexStorage
           ) {
            return false
        }
        if bindingPathStorage != .directSlots {
            if let argumentBuffer = vertexArgumentBufferStorage,
               !encoder.setVertexArgumentBuffer(argumentBuffer, index: 0) {
                return false
            }
            if let argumentBuffer = fragmentArgumentBufferStorage,
               !encoder.setFragmentArgumentBuffer(argumentBuffer, index: 0) {
                return false
            }
            if let table = vertexArgumentTableStorage,
               !table.bindVertex(to: encoder) {
                return false
            }
            if let table = fragmentArgumentTableStorage,
               !table.bindFragment(to: encoder) {
                return false
            }
        }
        for index in vertexTextureTableStorage.indices {
            guard let texture = vertexTextureTableStorage.texture(index),
                  encoder.setVertexTexture(texture, index: index) else {
                return false
            }
        }
        for index in fragmentTextureTableStorage.indices {
            guard let texture = fragmentTextureTableStorage.texture(index),
                  encoder.setFragmentTexture(texture, index: index) else {
                return false
            }
        }
        for index in vertexSamplerTableStorage.indices {
            guard let sampler = vertexSamplerTableStorage.sampler(index),
                  encoder.setVertexSampler(sampler, index: index) else {
                return false
            }
        }
        for index in fragmentSamplerTableStorage.indices {
            guard let sampler = fragmentSamplerTableStorage.sampler(index),
                  encoder.setFragmentSampler(sampler, index: index) else {
                return false
            }
        }
        return true
    }
}

public final class MaterialManager {
    private var materials: [String: Material] = [:]
    private var materialOrder: [String] = []

    public init() {}

    public var materialCount: UInt32 {
        UInt32(materialOrder.count)
    }

    public func addMaterial(_ material: Material) -> Bool {
        guard !material.name.isEmpty, materials[material.name] == nil else {
            return false
        }
        materials[material.name] = material
        materialOrder.append(material.name)
        return true
    }

    public func replaceMaterial(_ material: Material) -> Bool {
        guard !material.name.isEmpty else {
            return false
        }
        if materials[material.name] == nil {
            materialOrder.append(material.name)
        }
        materials[material.name] = material
        return true
    }

    public func removeMaterial(_ name: String) -> Bool {
        guard materials.removeValue(forKey: name) != nil else {
            return false
        }
        materialOrder.removeAll { $0 == name }
        return true
    }

    public func material(_ name: String) -> Material? {
        materials[name]
    }

    public func materialAt(_ index: UInt32) -> Material? {
        guard index < UInt32(materialOrder.count) else {
            return nil
        }
        return materials[materialOrder[Int(index)]]
    }
}

public struct LightClusterData {
    public var columns: UInt32
    public var rows: UInt32
    public var slices: UInt32
    public var maxLightsPerCluster: UInt32
    public var overflowCount: UInt32
    public var assignments: [ForwardPlusClusterAssignment]
    public var lightIndices: [UInt32]

    public init(plan: ForwardPlusClusterPlan) {
        columns = plan.columns
        rows = plan.rows
        slices = plan.slices
        maxLightsPerCluster = plan.maxLightsPerCluster
        overflowCount = plan.overflowCount
        assignments = plan.assignments
        lightIndices = plan.lightIndices
    }

    public var clusterCount: UInt64 {
        UInt64(columns) * UInt64(rows) * UInt64(slices)
    }
}

public struct LightClusterBoundsGPUData {
    public var minX: Float
    public var minY: Float
    public var minZ: Float
    public var maxX: Float
    public var maxY: Float
    public var maxZ: Float

    public init(bounds: ForwardPlusClusterBounds) {
        minX = bounds.minX
        minY = bounds.minY
        minZ = bounds.minZ
        maxX = bounds.maxX
        maxY = bounds.maxY
        maxZ = bounds.maxZ
    }
}

public struct LightClusterAssignmentGPUData {
    public var lightOffset: UInt32
    public var lightCount: UInt32
    public var overflow: UInt32
    public var reserved: UInt32

    public init(assignment: ForwardPlusClusterAssignment) {
        lightOffset = assignment.lightOffset
        lightCount = assignment.lightCount
        overflow = assignment.overflow ? 1 : 0
        reserved = 0
    }
}

public final class LightClusterResources {
    public let clusterBoundsBuffer: Buffer
    public let lightIndexBuffer: Buffer
    public let clusterCountBuffer: Buffer
    public let data: LightClusterData

    private init(
        clusterBoundsBuffer: Buffer,
        lightIndexBuffer: Buffer,
        clusterCountBuffer: Buffer,
        data: LightClusterData
    ) {
        self.clusterBoundsBuffer = clusterBoundsBuffer
        self.lightIndexBuffer = lightIndexBuffer
        self.clusterCountBuffer = clusterCountBuffer
        self.data = data
    }

    public static func upload(
        device: Device,
        plan: ForwardPlusClusterPlan,
        storageMode: StorageMode,
        label: String
    ) -> LightClusterResources? {
        guard storageMode == .shared || storageMode == .managed,
              plan.clusterCount <= UInt64(Int.max) else {
            return nil
        }
        let data = LightClusterData(plan: plan)
        var bounds = plan.bounds.map {
            LightClusterBoundsGPUData(bounds: $0)
        }
        var assignments = plan.assignments.map {
            LightClusterAssignmentGPUData(assignment: $0)
        }
        var indices = plan.lightIndices
        if bounds.isEmpty {
            bounds = [
                LightClusterBoundsGPUData(
                    bounds: ForwardPlusClusterBounds(
                        minX: 0,
                        minY: 0,
                        minZ: 0,
                        maxX: 0,
                        maxY: 0,
                        maxZ: 0
                    )
                )
            ]
        }
        if assignments.isEmpty {
            assignments = [
                LightClusterAssignmentGPUData(
                    assignment: ForwardPlusClusterAssignment(
                        lightOffset: 0,
                        lightCount: 0,
                        overflow: false
                    )
                )
            ]
        }
        if indices.isEmpty {
            indices = [0]
        }
        let boundsDescriptor = BufferDescriptor(
            length: UInt64(
                MemoryLayout<LightClusterBoundsGPUData>.stride * bounds.count
            ),
            usage: UInt32(BufferUsage.storage.rawValue),
            storageMode: storageMode,
            cpuCacheMode: .defaultCache,
            hazardMode: .defaultMode,
            label: label.isEmpty ? "mt.light.cluster.bounds" : label + ".bounds"
        )
        let indexDescriptor = BufferDescriptor(
            length: UInt64(MemoryLayout<UInt32>.stride * indices.count),
            usage: UInt32(BufferUsage.storage.rawValue),
            storageMode: storageMode,
            cpuCacheMode: .defaultCache,
            hazardMode: .defaultMode,
            label: label.isEmpty ? "mt.light.cluster.indices" : label + ".indices"
        )
        let countDescriptor = BufferDescriptor(
            length: UInt64(
                MemoryLayout<LightClusterAssignmentGPUData>.stride
                    * assignments.count
            ),
            usage: UInt32(BufferUsage.storage.rawValue),
            storageMode: storageMode,
            cpuCacheMode: .defaultCache,
            hazardMode: .defaultMode,
            label: label.isEmpty ? "mt.light.cluster.assignments" : label + ".assignments"
        )
        guard let boundsBuffer = device.createBuffer(boundsDescriptor),
              let indexBuffer = device.createBuffer(indexDescriptor),
              let countBuffer = device.createBuffer(countDescriptor) else {
            return nil
        }
        guard uploadSceneArray(bounds, to: boundsBuffer),
              uploadSceneArray(indices, to: indexBuffer),
              uploadSceneArray(assignments, to: countBuffer) else {
            return nil
        }
        return LightClusterResources(
            clusterBoundsBuffer: boundsBuffer,
            lightIndexBuffer: indexBuffer,
            clusterCountBuffer: countBuffer,
            data: data
        )
    }

    public func makeComputeResources(
        lightBuffer: Buffer
    ) -> ForwardPlusComputeResources {
        ForwardPlusComputeResources(
            lightBuffer: lightBuffer,
            clusterBoundsBuffer: clusterBoundsBuffer,
            lightIndexBuffer: lightIndexBuffer,
            clusterCountBuffer: clusterCountBuffer
        )
    }
}

private func uploadSceneArray<T>(
    _ values: [T],
    to buffer: Buffer
) -> Bool {
    guard !values.isEmpty else {
        return false
    }
    return values.withUnsafeBufferPointer { pointer in
        guard let baseAddress = pointer.baseAddress else {
            return false
        }
        return buffer.upload(
            source: UnsafeRawPointer(baseAddress),
            length: UInt64(MemoryLayout<T>.stride * pointer.count),
            offset: 0
        )
    }
}

public struct ShadowMapDescriptor {
    public var width: UInt32
    public var height: UInt32
    public var cascades: UInt32
    public var pixelFormat: PixelFormat
    public var storageMode: StorageMode
    public var label: String

    public init(
        width: UInt32,
        height: UInt32,
        cascades: UInt32,
        pixelFormat: PixelFormat,
        storageMode: StorageMode,
        label: String
    ) {
        self.width = width
        self.height = height
        self.cascades = cascades
        self.pixelFormat = pixelFormat
        self.storageMode = storageMode
        self.label = label
    }

    public var isValid: Bool {
        width > 0
            && height > 0
            && cascades > 0
            && (
                pixelFormat == .depth16Unorm
                    || pixelFormat == .depth32Float
                    || pixelFormat == .depth24UnormStencil8
                    || pixelFormat == .depth32FloatStencil8
            )
            && storageMode != .memoryless
    }

    public static func directionalFixture(
        label: String = "mt.shadow.fixture"
    ) -> ShadowMapDescriptor {
        ShadowMapDescriptor(
            width: 1024,
            height: 1024,
            cascades: 4,
            pixelFormat: .depth32Float,
            storageMode: .gpuPrivate,
            label: label
        )
    }
}

public final class ShadowMap {
    public let descriptor: ShadowMapDescriptor
    public let texture: Texture

    private init(descriptor: ShadowMapDescriptor, texture: Texture) {
        self.descriptor = descriptor
        self.texture = texture
    }

    public static func create(
        device: Device,
        descriptor: ShadowMapDescriptor
    ) -> ShadowMap? {
        guard descriptor.isValid else {
            return nil
        }
        let textureDescriptor = TextureDescriptor(
            textureType: descriptor.cascades > 1 ? .twoDArray : .twoD,
            pixelFormat: descriptor.pixelFormat,
            width: descriptor.width,
            height: descriptor.height,
            depth: 1,
            arrayLength: descriptor.cascades,
            mipLevelCount: 1,
            sampleCount: 1,
            usage: UInt32(
                TextureUsage.renderTarget.rawValue
                    | TextureUsage.shaderRead.rawValue
            ),
            storageMode: descriptor.storageMode,
            cpuCacheMode: .defaultCache,
            hazardMode: .defaultMode,
            label: descriptor.label
        )
        guard let texture = device.createTexture(textureDescriptor) else {
            return nil
        }
        return ShadowMap(descriptor: descriptor, texture: texture)
    }
}

public enum LightKind: Int32 {
    case directional
    case point
    case spot
}

public struct Light {
    public var name: String
    public var kind: LightKind
    public var position: Vector3
    public var direction: Vector3
    public var color: Vector3
    public var intensity: Float
    public var range: Float
    public var innerConeAngle: Float
    public var outerConeAngle: Float
    public var castsShadow: Bool
    public var enabled: Bool
    public var shadowMap: ShadowMapDescriptor?

    public init(
        name: String,
        kind: LightKind,
        position: Vector3,
        direction: Vector3,
        color: Vector3,
        intensity: Float,
        range: Float,
        innerConeAngle: Float,
        outerConeAngle: Float,
        castsShadow: Bool,
        enabled: Bool,
        shadowMap: ShadowMapDescriptor? = nil
    ) {
        self.name = name
        self.kind = kind
        self.position = position
        self.direction = direction
        self.color = color
        self.intensity = intensity
        self.range = range
        self.innerConeAngle = innerConeAngle
        self.outerConeAngle = outerConeAngle
        self.castsShadow = castsShadow
        self.enabled = enabled
        self.shadowMap = shadowMap
    }

    public var isValid: Bool {
        [
            position.x,
            position.y,
            position.z,
            direction.x,
            direction.y,
            direction.z,
            color.x,
            color.y,
            color.z,
            intensity,
            range,
            innerConeAngle,
            outerConeAngle
        ].allSatisfy { $0.isFinite }
            && intensity >= 0
            && range >= 0
            && innerConeAngle >= 0
            && outerConeAngle >= innerConeAngle
            && (shadowMap?.isValid ?? true)
    }

    public static func fixture(
        name: String = "key"
    ) -> Light {
        Light(
            name: name,
            kind: .directional,
            position: Vector3(x: 0, y: 4, z: 2),
            direction: Vector3(x: -0.25, y: -1, z: -0.4),
            color: Vector3(x: 1, y: 0.95, z: 0.85),
            intensity: 3,
            range: 100,
            innerConeAngle: 0,
            outerConeAngle: 0,
            castsShadow: true,
            enabled: true,
            shadowMap: ShadowMapDescriptor.directionalFixture()
        )
    }
}

public struct LightGPUData {
    public var positionX: Float
    public var positionY: Float
    public var positionZ: Float
    public var range: Float
    public var directionX: Float
    public var directionY: Float
    public var directionZ: Float
    public var innerConeAngle: Float
    public var colorR: Float
    public var colorG: Float
    public var colorB: Float
    public var intensity: Float
    public var kind: Int32
    public var flags: UInt32
    public var outerConeAngle: Float
    public var reserved: Float

    public init(
        positionX: Float,
        positionY: Float,
        positionZ: Float,
        range: Float,
        directionX: Float,
        directionY: Float,
        directionZ: Float,
        innerConeAngle: Float,
        colorR: Float,
        colorG: Float,
        colorB: Float,
        intensity: Float,
        kind: Int32,
        flags: UInt32,
        outerConeAngle: Float,
        reserved: Float
    ) {
        self.positionX = positionX
        self.positionY = positionY
        self.positionZ = positionZ
        self.range = range
        self.directionX = directionX
        self.directionY = directionY
        self.directionZ = directionZ
        self.innerConeAngle = innerConeAngle
        self.colorR = colorR
        self.colorG = colorG
        self.colorB = colorB
        self.intensity = intensity
        self.kind = kind
        self.flags = flags
        self.outerConeAngle = outerConeAngle
        self.reserved = reserved
    }

    fileprivate init(light: Light) {
        self.init(
            positionX: light.position.x,
            positionY: light.position.y,
            positionZ: light.position.z,
            range: light.range,
            directionX: light.direction.x,
            directionY: light.direction.y,
            directionZ: light.direction.z,
            innerConeAngle: light.innerConeAngle,
            colorR: light.color.x,
            colorG: light.color.y,
            colorB: light.color.z,
            intensity: light.intensity,
            kind: light.kind.rawValue,
            flags: light.castsShadow ? 1 : 0,
            outerConeAngle: light.outerConeAngle,
            reserved: light.enabled ? 1 : 0
        )
    }
}

public struct BuiltInFrameData {
    public var modelViewProjection: Matrix4x4

    public init(modelViewProjection: Matrix4x4) {
        self.modelViewProjection = modelViewProjection
    }

    public func makeParameterBlock() -> ParameterBlock {
        let block = ParameterBlock(
            length: UInt32(MemoryLayout<BuiltInFrameData>.size),
            alignment: 16
        )
        var value = self
        withUnsafeBytes(of: &value) { bytes in
            guard let baseAddress = bytes.baseAddress else {
                return
            }
            _ = block.writeBytes(
                baseAddress,
                length: UInt32(bytes.count),
                offset: 0
            )
        }
        return block
    }
}

public struct FixedColorMaterialData {
    public var color: Vector4

    public init(color: Vector4) {
        self.color = color
    }

    public func makeParameterBlock() -> ParameterBlock {
        let block = ParameterBlock(
            length: UInt32(MemoryLayout<FixedColorMaterialData>.size),
            alignment: 16
        )
        var value = self
        withUnsafeBytes(of: &value) { bytes in
            guard let baseAddress = bytes.baseAddress else {
                return
            }
            _ = block.writeBytes(
                baseAddress,
                length: UInt32(bytes.count),
                offset: 0
            )
        }
        return block
    }
}

public final class LightManager {
    private var lights: [String: Light] = [:]
    private var lightOrder: [String] = []
    private var errorDescriptionStorage = ""

    public init() {}

    public static func fixture() -> LightManager {
        let manager = LightManager()
        _ = manager.addLight(Light.fixture(name: "key"))
        _ = manager.addLight(
            Light(
                name: "fill",
                kind: .point,
                position: Vector3(x: 2, y: 2, z: 1),
                direction: Vector3(x: 0, y: -1, z: 0),
                color: Vector3(x: 0.4, y: 0.6, z: 1),
                intensity: 2,
                range: 12,
                innerConeAngle: 0,
                outerConeAngle: 0,
                castsShadow: false,
                enabled: true
            )
        )
        return manager
    }

    public var lightCount: UInt32 {
        UInt32(lightOrder.count)
    }

    public var errorDescription: String {
        errorDescriptionStorage
    }

    public func addLight(_ light: Light) -> Bool {
        guard !light.name.isEmpty,
              light.isValid,
              lights[light.name] == nil else {
            errorDescriptionStorage =
                "A light with this name already exists or the name is empty."
            return false
        }
        lights[light.name] = light
        lightOrder.append(light.name)
        errorDescriptionStorage = ""
        return true
    }

    public func updateLight(_ light: Light) -> Bool {
        guard !light.name.isEmpty,
              light.isValid,
              lights[light.name] != nil else {
            return false
        }
        lights[light.name] = light
        return true
    }

    public func removeLight(_ name: String) -> Bool {
        guard lights.removeValue(forKey: name) != nil else {
            return false
        }
        lightOrder.removeAll { $0 == name }
        return true
    }

    public func light(_ name: String) -> Light? {
        lights[name]
    }

    public func lightAt(_ index: UInt32) -> Light? {
        guard index < UInt32(lightOrder.count) else {
            return nil
        }
        return lights[lightOrder[Int(index)]]
    }

    public func upload(
        device: Device,
        storageMode: StorageMode,
        label: String
    ) -> Buffer? {
        guard !lightOrder.isEmpty,
              storageMode == .shared || storageMode == .managed else {
            errorDescriptionStorage =
                "Light uploads require non-empty CPU-visible storage."
            return nil
        }
        var bytes: [UInt8] = []
        for name in lightOrder {
            guard let light = lights[name] else {
                continue
            }
            var gpuData = LightGPUData(light: light)
            withUnsafeBytes(of: &gpuData) { bytes.append(contentsOf: $0) }
        }
        guard !bytes.isEmpty else {
            errorDescriptionStorage = "No light data is available to upload."
            return nil
        }
        let descriptor = BufferDescriptor(
            length: UInt64(bytes.count),
            usage: UInt32(BufferUsage.storage.rawValue),
            storageMode: storageMode,
            cpuCacheMode: .defaultCache,
            hazardMode: .defaultMode,
            label: label
        )
        guard let buffer = device.createBuffer(descriptor),
              uploadBytes(bytes, to: buffer) else {
            errorDescriptionStorage = "Metal could not allocate light storage."
            return nil
        }
        errorDescriptionStorage = ""
        return buffer
    }
}

public enum BuiltInShaderFamily: Int32 {
    case fixedColor
    case phong
    case forwardPlus
    case physicallyBased
    case directionalShadow
    case meshVisualization
    case billboard
    case text
    case lightClustering
}

public struct BuiltInShaderLayout {
    public var family: BuiltInShaderFamily
    public var sourceName: String
    public var vertexEntryPoint: String
    public var fragmentEntryPoint: String
    public var computeEntryPoint: String
    public var vertexStride: UInt32
    public var vertexBufferIndex: UInt32
    public var frameBufferIndex: UInt32
    public var materialBufferIndex: UInt32
    public var lightBufferIndex: UInt32
    public var auxiliaryBufferIndex0: UInt32
    public var auxiliaryBufferIndex1: UInt32
    public var requiredFeatures: UInt32
    public var supportsIndexedFallback: Bool
    public var indexedVertexEntryPoint: String
    public var indexedFragmentEntryPoint: String
    public var cpuDataSize: UInt32
    public var cpuDataAlignment: UInt32
    public var mslDataSize: UInt32
    public var mslDataAlignment: UInt32

    public init(
        family: BuiltInShaderFamily,
        vertexEntryPoint: String,
        fragmentEntryPoint: String,
        computeEntryPoint: String,
        vertexStride: UInt32,
        vertexBufferIndex: UInt32,
        frameBufferIndex: UInt32,
        materialBufferIndex: UInt32,
        lightBufferIndex: UInt32,
        requiredFeatures: UInt32,
        sourceName: String = "",
        supportsIndexedFallback: Bool = true,
        indexedVertexEntryPoint: String = "",
        indexedFragmentEntryPoint: String = "",
        cpuDataSize: UInt32 = 0,
        cpuDataAlignment: UInt32 = 16,
        mslDataSize: UInt32 = 0,
        mslDataAlignment: UInt32 = 16,
        auxiliaryBufferIndex0: UInt32 = UInt32.max,
        auxiliaryBufferIndex1: UInt32 = UInt32.max
    ) {
        self.family = family
        self.sourceName = sourceName
        self.vertexEntryPoint = vertexEntryPoint
        self.fragmentEntryPoint = fragmentEntryPoint
        self.computeEntryPoint = computeEntryPoint
        self.vertexStride = vertexStride
        self.vertexBufferIndex = vertexBufferIndex
        self.frameBufferIndex = frameBufferIndex
        self.materialBufferIndex = materialBufferIndex
        self.lightBufferIndex = lightBufferIndex
        self.auxiliaryBufferIndex0 = auxiliaryBufferIndex0
        self.auxiliaryBufferIndex1 = auxiliaryBufferIndex1
        self.requiredFeatures = requiredFeatures
        self.supportsIndexedFallback = supportsIndexedFallback
        self.indexedVertexEntryPoint = indexedVertexEntryPoint
        self.indexedFragmentEntryPoint = indexedFragmentEntryPoint
        self.cpuDataSize = cpuDataSize
        self.cpuDataAlignment = cpuDataAlignment
        self.mslDataSize = mslDataSize
        self.mslDataAlignment = mslDataAlignment
    }

    public var hasComputeEntryPoint: Bool {
        !computeEntryPoint.isEmpty
    }

    public func hasValidDataContract() -> Bool {
        cpuDataAlignment > 0
            && mslDataAlignment > 0
            && cpuDataSize == mslDataSize
            && (cpuDataSize == 0 || cpuDataSize % cpuDataAlignment == 0)
    }

    public static func fixedColor() -> BuiltInShaderLayout {
        BuiltInShaderLayout(
            family: .fixedColor,
            sourceName: "fixed_color.metal",
            vertexEntryPoint: "mt_fixed_color_vertex",
            fragmentEntryPoint: "mt_fixed_color_fragment",
            computeEntryPoint: "",
            vertexStride: Mesh.standardVertexStride,
            vertexBufferIndex: 0,
            frameBufferIndex: 1,
            materialBufferIndex: 2,
            lightBufferIndex: 3,
            requiredFeatures: 0,
            indexedVertexEntryPoint: "mt_fixed_color_vertex",
            indexedFragmentEntryPoint: "mt_fixed_color_fragment",
            cpuDataSize: UInt32(MemoryLayout<FixedColorMaterialData>.size),
            mslDataSize: 16
        )
    }

    public static func phong() -> BuiltInShaderLayout {
        BuiltInShaderLayout(
            family: .phong,
            sourceName: "phong.metal",
            vertexEntryPoint: "mt_phong_vertex",
            fragmentEntryPoint: "mt_phong_fragment",
            computeEntryPoint: "",
            vertexStride: Mesh.standardVertexStride,
            vertexBufferIndex: 0,
            frameBufferIndex: 1,
            materialBufferIndex: 2,
            lightBufferIndex: 3,
            requiredFeatures: 0,
            indexedVertexEntryPoint: "mt_phong_vertex",
            indexedFragmentEntryPoint: "mt_phong_fragment",
            cpuDataSize: UInt32(MemoryLayout<PhongMaterialData>.size),
            mslDataSize: 48
        )
    }

    public static func forwardPlus() -> BuiltInShaderLayout {
        BuiltInShaderLayout(
            family: .forwardPlus,
            sourceName: "forward_plus.metal",
            vertexEntryPoint: "mt_forward_plus_vertex",
            fragmentEntryPoint: "mt_forward_plus_fragment",
            computeEntryPoint: "",
            vertexStride: Mesh.standardVertexStride,
            vertexBufferIndex: 0,
            frameBufferIndex: 1,
            materialBufferIndex: 2,
            lightBufferIndex: 3,
            requiredFeatures: 0,
            auxiliaryBufferIndex0: 4,
            auxiliaryBufferIndex1: 5,
            indexedVertexEntryPoint: "mt_forward_plus_vertex",
            indexedFragmentEntryPoint: "mt_forward_plus_fragment",
            cpuDataSize: UInt32(MemoryLayout<PhongMaterialData>.size),
            mslDataSize: 48
        )
    }

    public static func physicallyBased() -> BuiltInShaderLayout {
        BuiltInShaderLayout(
            family: .physicallyBased,
            sourceName: "physically_based.metal",
            vertexEntryPoint: "mt_pbr_vertex",
            fragmentEntryPoint: "mt_pbr_fragment",
            computeEntryPoint: "",
            vertexStride: Mesh.standardVertexStride,
            vertexBufferIndex: 0,
            frameBufferIndex: 1,
            materialBufferIndex: 2,
            lightBufferIndex: 3,
            requiredFeatures: 0,
            indexedVertexEntryPoint: "mt_pbr_vertex",
            indexedFragmentEntryPoint: "mt_pbr_fragment",
            cpuDataSize: UInt32(MemoryLayout<PBRMaterialData>.size),
            mslDataSize: 48
        )
    }

    public static func directionalShadow() -> BuiltInShaderLayout {
        BuiltInShaderLayout(
            family: .directionalShadow,
            sourceName: "directional_shadow.metal",
            vertexEntryPoint: "mt_directional_shadow_vertex",
            fragmentEntryPoint: "mt_directional_shadow_fragment",
            computeEntryPoint: "",
            vertexStride: Mesh.standardVertexStride,
            vertexBufferIndex: 0,
            frameBufferIndex: 1,
            materialBufferIndex: 2,
            lightBufferIndex: 3,
            requiredFeatures: 0,
            indexedVertexEntryPoint: "mt_directional_shadow_vertex",
            indexedFragmentEntryPoint: "mt_directional_shadow_fragment",
            cpuDataSize: UInt32(
                MemoryLayout<DirectionalShadowMaterialData>.size
            ),
            mslDataSize: 80
        )
    }

    public static func meshVisualization() -> BuiltInShaderLayout {
        BuiltInShaderLayout(
            family: .meshVisualization,
            sourceName: "mesh_visualization.metal",
            vertexEntryPoint: "mt_mesh_visualization_vertex",
            fragmentEntryPoint: "mt_mesh_visualization_fragment",
            computeEntryPoint: "",
            vertexStride: Mesh.standardVertexStride,
            vertexBufferIndex: 0,
            frameBufferIndex: 1,
            materialBufferIndex: 2,
            lightBufferIndex: 3,
            requiredFeatures: 0,
            indexedVertexEntryPoint: "mt_mesh_visualization_vertex",
            indexedFragmentEntryPoint: "mt_mesh_visualization_fragment",
            cpuDataSize: UInt32(
                MemoryLayout<MeshVisualizationMaterialData>.size
            ),
            mslDataSize: 32
        )
    }

    public static func billboard() -> BuiltInShaderLayout {
        BuiltInShaderLayout(
            family: .billboard,
            sourceName: "billboard.metal",
            vertexEntryPoint: "mt_billboard_vertex",
            fragmentEntryPoint: "mt_billboard_fragment",
            computeEntryPoint: "",
            vertexStride: Mesh.standardVertexStride,
            vertexBufferIndex: 0,
            frameBufferIndex: 1,
            materialBufferIndex: 2,
            lightBufferIndex: 3,
            requiredFeatures: 0,
            indexedVertexEntryPoint: "mt_billboard_vertex",
            indexedFragmentEntryPoint: "mt_billboard_fragment",
            cpuDataSize: UInt32(MemoryLayout<BillboardMaterialData>.size),
            mslDataSize: 32
        )
    }

    public static func text() -> BuiltInShaderLayout {
        BuiltInShaderLayout(
            family: .text,
            sourceName: "text.metal",
            vertexEntryPoint: "mt_text_vertex",
            fragmentEntryPoint: "mt_text_fragment",
            computeEntryPoint: "",
            vertexStride: Mesh.standardVertexStride,
            vertexBufferIndex: 0,
            frameBufferIndex: 1,
            materialBufferIndex: 2,
            lightBufferIndex: 3,
            requiredFeatures: 0,
            indexedVertexEntryPoint: "mt_text_vertex",
            indexedFragmentEntryPoint: "mt_text_fragment",
            cpuDataSize: UInt32(MemoryLayout<TextMaterialData>.size),
            mslDataSize: 48
        )
    }

    public static func lightClustering() -> BuiltInShaderLayout {
        BuiltInShaderLayout(
            family: .lightClustering,
            sourceName: "light_clustering.metal",
            vertexEntryPoint: "",
            fragmentEntryPoint: "",
            computeEntryPoint: "mt_light_cluster_kernel",
            vertexStride: 0,
            vertexBufferIndex: 0,
            frameBufferIndex: 0,
            materialBufferIndex: 2,
            lightBufferIndex: 1,
            requiredFeatures: 0,
            auxiliaryBufferIndex0: 0,
            auxiliaryBufferIndex1: 3,
            supportsIndexedFallback: false,
            cpuDataSize: UInt32(
                MemoryLayout<LightClusterAssignmentGPUData>.size
            ),
            mslDataSize: 16
        )
    }

    public static var all: [BuiltInShaderLayout] {
        [
            fixedColor(),
            phong(),
            forwardPlus(),
            physicallyBased(),
            directionalShadow(),
            meshVisualization(),
            billboard(),
            text(),
            lightClustering()
        ]
    }

    public static func forFamily(
        _ family: BuiltInShaderFamily
    ) -> BuiltInShaderLayout {
        switch family {
        case .fixedColor:
            return fixedColor()
        case .phong:
            return phong()
        case .forwardPlus:
            return forwardPlus()
        case .physicallyBased:
            return physicallyBased()
        case .directionalShadow:
            return directionalShadow()
        case .meshVisualization:
            return meshVisualization()
        case .billboard:
            return billboard()
        case .text:
            return text()
        case .lightClustering:
            return lightClustering()
        }
    }
}

public struct MeshObjectShaderLayout {
    public var objectEntryPoint: String
    public var meshEntryPoint: String
    public var fragmentEntryPoint: String
    public var requiredFeatures: UInt32

    public init(
        objectEntryPoint: String,
        meshEntryPoint: String,
        fragmentEntryPoint: String,
        requiredFeatures: UInt32
    ) {
        self.objectEntryPoint = objectEntryPoint
        self.meshEntryPoint = meshEntryPoint
        self.fragmentEntryPoint = fragmentEntryPoint
        self.requiredFeatures = requiredFeatures
    }

    public static func standard() -> MeshObjectShaderLayout {
        MeshObjectShaderLayout(
            objectEntryPoint: "mt_mesh_object",
            meshEntryPoint: "mt_mesh_mesh",
            fragmentEntryPoint: "mt_mesh_fragment",
            requiredFeatures: UInt32(
                1 << Int(DeviceFeature.meshShaders.rawValue)
            )
        )
    }
}

