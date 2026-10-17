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

    public func clear() {
        vertexStorage.removeAll(keepingCapacity: true)
        indexStorage.removeAll(keepingCapacity: true)
    }

    public func appendVertex(_ vertex: MeshVertex) -> Bool {
        guard vertexStride == Mesh.standardVertexStride else {
            return false
        }
        var value = vertex
        withUnsafeBytes(of: &value) { bytes in
            vertexStorage.append(contentsOf: bytes)
        }
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

        return MeshGPU(
            name: name,
            vertexBuffer: vertexBuffer,
            indexBuffer: indexBuffer,
            primitiveType: primitiveType,
            indexType: indexType,
            vertexCount: vertexCount,
            indexCount: indexCount
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

    fileprivate init(
        name: String,
        vertexBuffer: Buffer,
        indexBuffer: Buffer?,
        primitiveType: PrimitiveType,
        indexType: IndexType,
        vertexCount: UInt32,
        indexCount: UInt32
    ) {
        self.name = name
        self.vertexBuffer = vertexBuffer
        self.indexBuffer = indexBuffer
        self.primitiveType = primitiveType
        self.indexType = indexType
        self.vertexCount = vertexCount
        self.indexCount = indexCount
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
}

public final class DrawableManager {
    private var meshes: [String: Mesh] = [:]
    private var meshOrder: [String] = []
    private var gpuMeshes: [String: MeshGPU] = [:]
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
        errorDescriptionStorage = ""
        return true
    }

    public func removeMesh(_ name: String) -> Bool {
        guard meshes.removeValue(forKey: name) != nil else {
            return false
        }
        meshOrder.removeAll { $0 == name }
        gpuMeshes[name] = nil
        return true
    }

    public func clear() {
        meshes.removeAll()
        meshOrder.removeAll()
        gpuMeshes.removeAll()
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

    public init(
        name: String,
        meshName: String,
        transform: Transform,
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
}

public final class Scene {
    private var objects: [String: SceneObject] = [:]
    private var objectOrder: [String] = []

    public init() {}

    public var objectCount: UInt32 {
        UInt32(objectOrder.count)
    }

    public func addObject(_ object: SceneObject) -> Bool {
        guard !object.name.isEmpty, objects[object.name] == nil else {
            return false
        }
        objects[object.name] = object
        objectOrder.append(object.name)
        return true
    }

    public func updateObject(_ object: SceneObject) -> Bool {
        guard !object.name.isEmpty, objects[object.name] != nil else {
            return false
        }
        objects[object.name] = object
        return true
    }

    public func removeObject(_ name: String) -> Bool {
        guard objects.removeValue(forKey: name) != nil else {
            return false
        }
        objectOrder.removeAll { $0 == name }
        return true
    }

    public func clear() {
        objects.removeAll()
        objectOrder.removeAll()
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
    private var vertexTextures: [UInt32: Texture] = [:]
    private var fragmentTextures: [UInt32: Texture] = [:]
    private var vertexSamplers: [UInt32: Sampler] = [:]
    private var fragmentSamplers: [UInt32: Sampler] = [:]
    private var vertexArgumentBufferStorage: ArgumentBuffer?
    private var fragmentArgumentBufferStorage: ArgumentBuffer?
    private var vertexArgumentTableStorage: ArgumentBufferTable?
    private var fragmentArgumentTableStorage: ArgumentBufferTable?

    public init(name: String, pipeline: RenderPipeline) {
        self.name = name
        self.pipeline = pipeline
        self.transparent = false
        self.requiresMeshShaders = false
        self.requiresArgumentBuffers = false
        self.requiresIndirectCommandBuffers = false
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
        vertexTextures[index] = texture
    }

    public func setFragmentTexture(_ texture: Texture, index: UInt32) {
        fragmentTextures[index] = texture
    }

    public func setVertexSampler(_ sampler: Sampler, index: UInt32) {
        vertexSamplers[index] = sampler
    }

    public func setFragmentSampler(_ sampler: Sampler, index: UInt32) {
        fragmentSamplers[index] = sampler
    }

    public func setVertexArgumentBuffer(_ argumentBuffer: ArgumentBuffer) {
        vertexArgumentBufferStorage = argumentBuffer
    }

    public func clearVertexArgumentBuffer() {
        vertexArgumentBufferStorage = nil
    }

    public func setFragmentArgumentBuffer(_ argumentBuffer: ArgumentBuffer) {
        fragmentArgumentBufferStorage = argumentBuffer
    }

    public func clearFragmentArgumentBuffer() {
        fragmentArgumentBufferStorage = nil
    }

    public func setVertexArgumentTable(_ table: ArgumentBufferTable) {
        vertexArgumentTableStorage = table
    }

    public func clearVertexArgumentTable() {
        vertexArgumentTableStorage = nil
    }

    public func setFragmentArgumentTable(_ table: ArgumentBufferTable) {
        fragmentArgumentTableStorage = table
    }

    public func clearFragmentArgumentTable() {
        fragmentArgumentTableStorage = nil
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
        for (index, texture) in vertexTextures {
            guard encoder.setVertexTexture(texture, index: index) else {
                return false
            }
        }
        for (index, texture) in fragmentTextures {
            guard encoder.setFragmentTexture(texture, index: index) else {
                return false
            }
        }
        for (index, sampler) in vertexSamplers {
            guard encoder.setVertexSampler(sampler, index: index) else {
                return false
            }
        }
        for (index, sampler) in fragmentSamplers {
            guard encoder.setFragmentSampler(sampler, index: index) else {
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
        enabled: Bool
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

    public var lightCount: UInt32 {
        UInt32(lightOrder.count)
    }

    public var errorDescription: String {
        errorDescriptionStorage
    }

    public func addLight(_ light: Light) -> Bool {
        guard !light.name.isEmpty, lights[light.name] == nil else {
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
        guard !light.name.isEmpty, lights[light.name] != nil else {
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
    public var vertexEntryPoint: String
    public var fragmentEntryPoint: String
    public var computeEntryPoint: String
    public var vertexStride: UInt32
    public var vertexBufferIndex: UInt32
    public var frameBufferIndex: UInt32
    public var materialBufferIndex: UInt32
    public var lightBufferIndex: UInt32
    public var requiredFeatures: UInt32

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
        requiredFeatures: UInt32
    ) {
        self.family = family
        self.vertexEntryPoint = vertexEntryPoint
        self.fragmentEntryPoint = fragmentEntryPoint
        self.computeEntryPoint = computeEntryPoint
        self.vertexStride = vertexStride
        self.vertexBufferIndex = vertexBufferIndex
        self.frameBufferIndex = frameBufferIndex
        self.materialBufferIndex = materialBufferIndex
        self.lightBufferIndex = lightBufferIndex
        self.requiredFeatures = requiredFeatures
    }

    public static func fixedColor() -> BuiltInShaderLayout {
        BuiltInShaderLayout(
            family: .fixedColor,
            vertexEntryPoint: "mt_fixed_color_vertex",
            fragmentEntryPoint: "mt_fixed_color_fragment",
            computeEntryPoint: "",
            vertexStride: Mesh.standardVertexStride,
            vertexBufferIndex: 0,
            frameBufferIndex: 1,
            materialBufferIndex: 2,
            lightBufferIndex: 3,
            requiredFeatures: 0
        )
    }

    public static func lightClustering() -> BuiltInShaderLayout {
        BuiltInShaderLayout(
            family: .lightClustering,
            vertexEntryPoint: "",
            fragmentEntryPoint: "",
            computeEntryPoint: "mt_light_cluster_kernel",
            vertexStride: 0,
            vertexBufferIndex: 0,
            frameBufferIndex: 0,
            materialBufferIndex: 1,
            lightBufferIndex: 2,
            requiredFeatures: 0
        )
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

