import Foundation

public enum RendererKind: Int32 {
    case forward
    case forwardPlus
}

public enum RendererState: Int32 {
    case ready
    case shutDown
}

public enum SubmissionPath: Int32 {
    case indexed
    case mesh
    case indirect
}

public enum RendererPass: Int32, Hashable, CaseIterable {
    case depthPrepass
    case shadow
    case opaque
    case transparent
    case overlay
}

public enum RendererBatchKind: Int32 {
    case triangles
    case lines
    case points
    case billboard
}

public enum RendererFallbackReason: Int32 {
    case none
    case capabilityUnavailable
    case resourcesUnavailable
    case missingFallback
    case invalidRequest
}

public struct SubmissionSelection {
    public var requestedPath: SubmissionPath
    public var selectedPath: SubmissionPath
    public var fallbackReason: RendererFallbackReason
    public var fallbackAvailable: Bool

    public init(
        requestedPath: SubmissionPath,
        selectedPath: SubmissionPath,
        fallbackReason: RendererFallbackReason,
        fallbackAvailable: Bool
    ) {
        self.requestedPath = requestedPath
        self.selectedPath = selectedPath
        self.fallbackReason = fallbackReason
        self.fallbackAvailable = fallbackAvailable
    }

    public var usedFallback: Bool {
        requestedPath != selectedPath
    }
}

public struct RendererPassSchedule {
    public var pass: RendererPass
    public var batchIDs: [UInt64]

    public init(pass: RendererPass, batchIDs: [UInt64]) {
        self.pass = pass
        self.batchIDs = batchIDs
    }

    public var batchCount: UInt32 {
        UInt32(min(batchIDs.count, Int(UInt32.max)))
    }
}

public struct RendererPassInput {
    public var pass: RendererPass
    public let renderPass: RenderPassDescriptor

    public init(pass: RendererPass, renderPass: RenderPassDescriptor) {
        self.pass = pass
        self.renderPass = renderPass
    }
}

public struct RenderView {
    public var viewport: Extent
    public var frameIndex: UInt64
    public var timeSeconds: Double
    public var clearColor: ClearColor

    public init(
        viewport: Extent,
        frameIndex: UInt64,
        timeSeconds: Double,
        clearColor: ClearColor
    ) {
        self.viewport = viewport
        self.frameIndex = frameIndex
        self.timeSeconds = timeSeconds
        self.clearColor = clearColor
    }
}

public struct ForwardPlusConfiguration {
    public var tileWidth: UInt32
    public var tileHeight: UInt32
    public var depthSlices: UInt32
    public var maxLightsPerCluster: UInt32

    public init(
        tileWidth: UInt32,
        tileHeight: UInt32,
        depthSlices: UInt32,
        maxLightsPerCluster: UInt32
    ) {
        self.tileWidth = tileWidth
        self.tileHeight = tileHeight
        self.depthSlices = depthSlices
        self.maxLightsPerCluster = maxLightsPerCluster
    }
}

public struct RendererStatistics {
    public var frameIndex: UInt64
    public var drawCallCount: UInt32
    public var submittedInstanceCount: UInt32
    public var meshDispatchCount: UInt32
    public var indirectCommandCount: UInt32
    public var pipelineSwitchCount: UInt32
    public var transparentBatchCount: UInt32
    public var fallbackCount: UInt32
    public var clusterOverflowCount: UInt32
    public var visibleObjectCount: UInt32
    public var culledObjectCount: UInt32
    public var cullingOverflowCount: UInt32
    public var clusterPreparationDispatchCount: UInt32
    public var lineBatchCount: UInt32
    public var pointBatchCount: UInt32
    public var billboardBatchCount: UInt32
    public var passCount: UInt32
    public var gpuStartTime: Double
    public var gpuEndTime: Double
    public var gpuExecutionTime: Double

    public init(frameIndex: UInt64 = 0) {
        self.frameIndex = frameIndex
        self.drawCallCount = 0
        self.submittedInstanceCount = 0
        self.meshDispatchCount = 0
        self.indirectCommandCount = 0
        self.pipelineSwitchCount = 0
        self.transparentBatchCount = 0
        self.fallbackCount = 0
        self.clusterOverflowCount = 0
        self.visibleObjectCount = 0
        self.culledObjectCount = 0
        self.cullingOverflowCount = 0
        self.clusterPreparationDispatchCount = 0
        self.lineBatchCount = 0
        self.pointBatchCount = 0
        self.billboardBatchCount = 0
        self.passCount = 0
        self.gpuStartTime = 0
        self.gpuEndTime = 0
        self.gpuExecutionTime = 0
    }
}

public struct RendererPersistentStatistics {
    public var framesRecorded: UInt64
    public var framesCompleted: UInt64
    public var drawCallCount: UInt64
    public var submittedInstanceCount: UInt64
    public var meshDispatchCount: UInt64
    public var indirectCommandCount: UInt64
    public var fallbackCount: UInt64
    public var clusterOverflowCount: UInt64
    public var visibleObjectCount: UInt64
    public var culledObjectCount: UInt64
    public var cullingOverflowCount: UInt64
    public var totalGPUExecutionTime: Double

    public init() {
        self.framesRecorded = 0
        self.framesCompleted = 0
        self.drawCallCount = 0
        self.submittedInstanceCount = 0
        self.meshDispatchCount = 0
        self.indirectCommandCount = 0
        self.fallbackCount = 0
        self.clusterOverflowCount = 0
        self.visibleObjectCount = 0
        self.culledObjectCount = 0
        self.cullingOverflowCount = 0
        self.totalGPUExecutionTime = 0
    }
}

public struct ForwardPlusLightCoverage {
    public var lightIndex: UInt32
    public var firstCluster: UInt32
    public var clusterCount: UInt32

    public init(
        lightIndex: UInt32,
        firstCluster: UInt32,
        clusterCount: UInt32
    ) {
        self.lightIndex = lightIndex
        self.firstCluster = firstCluster
        self.clusterCount = clusterCount
    }
}

public struct ForwardPlusClusterBounds {
    public var minX: Float
    public var minY: Float
    public var minZ: Float
    public var maxX: Float
    public var maxY: Float
    public var maxZ: Float

    public init(
        minX: Float,
        minY: Float,
        minZ: Float,
        maxX: Float,
        maxY: Float,
        maxZ: Float
    ) {
        self.minX = minX
        self.minY = minY
        self.minZ = minZ
        self.maxX = maxX
        self.maxY = maxY
        self.maxZ = maxZ
    }
}

public struct ForwardPlusClusterAssignment {
    public var lightOffset: UInt32
    public var lightCount: UInt32
    public var overflow: Bool

    public init(
        lightOffset: UInt32,
        lightCount: UInt32,
        overflow: Bool
    ) {
        self.lightOffset = lightOffset
        self.lightCount = lightCount
        self.overflow = overflow
    }
}

public struct ForwardPlusClusterPlan {
    public var columns: UInt32
    public var rows: UInt32
    public var slices: UInt32
    public var clusterCount: UInt64
    public var maxLightsPerCluster: UInt32
    public var overflowCount: UInt32
    public var bounds: [ForwardPlusClusterBounds]
    public var assignments: [ForwardPlusClusterAssignment]
    public var lightIndices: [UInt32]

    public init(
        columns: UInt32,
        rows: UInt32,
        slices: UInt32,
        clusterCount: UInt64,
        maxLightsPerCluster: UInt32,
        overflowCount: UInt32,
        bounds: [ForwardPlusClusterBounds],
        assignments: [ForwardPlusClusterAssignment],
        lightIndices: [UInt32]
    ) {
        self.columns = columns
        self.rows = rows
        self.slices = slices
        self.clusterCount = clusterCount
        self.maxLightsPerCluster = maxLightsPerCluster
        self.overflowCount = overflowCount
        self.bounds = bounds
        self.assignments = assignments
        self.lightIndices = lightIndices
    }
}

public struct ForwardPlusComputeDispatch {
    public var threadgroups: Extent3D
    public var threadsPerThreadgroup: Extent3D
    public var lightBufferIndex: UInt32
    public var clusterBoundsBufferIndex: UInt32
    public var lightIndexBufferIndex: UInt32
    public var clusterCountBufferIndex: UInt32

    public init(
        threadgroups: Extent3D,
        threadsPerThreadgroup: Extent3D,
        lightBufferIndex: UInt32,
        clusterBoundsBufferIndex: UInt32,
        lightIndexBufferIndex: UInt32,
        clusterCountBufferIndex: UInt32
    ) {
        self.threadgroups = threadgroups
        self.threadsPerThreadgroup = threadsPerThreadgroup
        self.lightBufferIndex = lightBufferIndex
        self.clusterBoundsBufferIndex = clusterBoundsBufferIndex
        self.lightIndexBufferIndex = lightIndexBufferIndex
        self.clusterCountBufferIndex = clusterCountBufferIndex
    }
}

public final class ForwardPlusComputeResources {
    public let lightBuffer: Buffer
    public let clusterBoundsBuffer: Buffer
    public let lightIndexBuffer: Buffer
    public let clusterCountBuffer: Buffer

    public init(
        lightBuffer: Buffer,
        clusterBoundsBuffer: Buffer,
        lightIndexBuffer: Buffer,
        clusterCountBuffer: Buffer
    ) {
        self.lightBuffer = lightBuffer
        self.clusterBoundsBuffer = clusterBoundsBuffer
        self.lightIndexBuffer = lightIndexBuffer
        self.clusterCountBuffer = clusterCountBuffer
    }
}

public final class ForwardPlusRenderBindings {
    public let lightBuffer: Buffer
    public let lightIndexBuffer: Buffer
    public let clusterCountBuffer: Buffer
    public let lightBufferIndex: UInt32
    public let lightIndexBufferIndex: UInt32
    public let clusterCountBufferIndex: UInt32

    public init(
        lightBuffer: Buffer,
        lightIndexBuffer: Buffer,
        clusterCountBuffer: Buffer,
        lightBufferIndex: UInt32,
        lightIndexBufferIndex: UInt32,
        clusterCountBufferIndex: UInt32
    ) {
        self.lightBuffer = lightBuffer
        self.lightIndexBuffer = lightIndexBuffer
        self.clusterCountBuffer = clusterCountBuffer
        self.lightBufferIndex = lightBufferIndex
        self.lightIndexBufferIndex = lightIndexBufferIndex
        self.clusterCountBufferIndex = clusterCountBufferIndex
    }
}

public struct RendererLODRange {
    public var maxDistance: Float
    public var level: UInt32

    public init(maxDistance: Float, level: UInt32) {
        self.maxDistance = maxDistance
        self.level = level
    }
}

public struct RendererCullingItem {
    public var id: UInt64
    public var center: Vector3
    public var radius: Float
    public var distance: Float
    public var visibilityMask: UInt32
    public var enabled: Bool
    public var lodRanges: [RendererLODRange]

    public init(
        id: UInt64,
        center: Vector3,
        radius: Float,
        distance: Float,
        visibilityMask: UInt32,
        enabled: Bool,
        lodRanges: [RendererLODRange]
    ) {
        self.id = id
        self.center = center
        self.radius = radius
        self.distance = distance
        self.visibilityMask = visibilityMask
        self.enabled = enabled
        self.lodRanges = lodRanges
    }
}

public struct RendererCullingResult {
    public var visibleIDs: [UInt64]
    public var visibleLODLevels: [UInt32]
    public var culledCount: UInt32
    public var invalidCount: UInt32
    public var overflowCount: UInt32

    public init(
        visibleIDs: [UInt64],
        visibleLODLevels: [UInt32],
        culledCount: UInt32,
        invalidCount: UInt32,
        overflowCount: UInt32
    ) {
        self.visibleIDs = visibleIDs
        self.visibleLODLevels = visibleLODLevels
        self.culledCount = culledCount
        self.invalidCount = invalidCount
        self.overflowCount = overflowCount
    }
}

public struct GPUCullingDispatch {
    public var pipeline: ComputePipeline
    public var inputBuffer: Buffer
    public var visibilityBuffer: Buffer
    public var countBuffer: Buffer
    public var itemCount: UInt32
    public var inputStride: UInt32
    public var visibilityStride: UInt32
    public var threadgroupSize: UInt32
    public var inputBufferIndex: UInt32
    public var visibilityBufferIndex: UInt32
    public var countBufferIndex: UInt32

    public init(
        pipeline: ComputePipeline,
        inputBuffer: Buffer,
        visibilityBuffer: Buffer,
        countBuffer: Buffer,
        itemCount: UInt32,
        inputStride: UInt32,
        visibilityStride: UInt32,
        threadgroupSize: UInt32,
        inputBufferIndex: UInt32,
        visibilityBufferIndex: UInt32,
        countBufferIndex: UInt32
    ) {
        self.pipeline = pipeline
        self.inputBuffer = inputBuffer
        self.visibilityBuffer = visibilityBuffer
        self.countBuffer = countBuffer
        self.itemCount = itemCount
        self.inputStride = inputStride
        self.visibilityStride = visibilityStride
        self.threadgroupSize = threadgroupSize
        self.inputBufferIndex = inputBufferIndex
        self.visibilityBufferIndex = visibilityBufferIndex
        self.countBufferIndex = countBufferIndex
    }
}

public struct MeshletDescriptor {
    public var vertexOffset: UInt32
    public var vertexCount: UInt32
    public var primitiveOffset: UInt32
    public var primitiveCount: UInt32
    public var lodLevel: UInt32
    public var boundsCenter: Vector3
    public var boundsRadius: Float

    public init(
        vertexOffset: UInt32,
        vertexCount: UInt32,
        primitiveOffset: UInt32,
        primitiveCount: UInt32,
        lodLevel: UInt32,
        boundsCenter: Vector3,
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

public final class RenderBatch {
    public let pipeline: RenderPipeline
    public let vertexBuffer: Buffer
    public var primitiveType: PrimitiveType
    public var vertexStart: UInt32
    public var vertexCount: UInt32
    public var instanceCount: UInt32
    public var baseInstance: UInt32
    public var transparent: Bool
    public var preferredPath: SubmissionPath
    public var pass: RendererPass
    public var kind: RendererBatchKind
    public var sortKey: UInt64
    public var participatesInDepthPrepass: Bool
    public var castsShadow: Bool
    public var label: String

    private var indexBufferStorage: Buffer?
    private var indexTypeStorage = IndexType.uint32
    private var indexBufferOffsetStorage: UInt64 = 0
    private var indexCountStorage: UInt32 = 0
    private var baseVertexStorage: Int32 = 0
    private var fallbackPipelineStorage: RenderPipeline?
    private var meshDispatchStorage: MeshDispatchDescriptor?
    private var indirectCommandsStorage: IndirectCommandBuffer?
    private var indirectRangeStartStorage: UInt32 = 0
    private var indirectCountStorage: UInt32 = 0
    private var passPipelineStorage: [RendererPass: RenderPipeline] = [:]
    private var materialStorage: Material?
    private var vertexArgumentBufferStorage: ArgumentBuffer?
    private var fragmentArgumentBufferStorage: ArgumentBuffer?
    private var vertexArgumentTableStorage: ArgumentBufferTable?
    private var fragmentArgumentTableStorage: ArgumentBufferTable?
    private var meshletStorage: MeshletGPU?

    public init(
        pipeline: RenderPipeline,
        vertexBuffer: Buffer,
        primitiveType: PrimitiveType,
        vertexStart: UInt32,
        vertexCount: UInt32,
        instanceCount: UInt32,
        baseInstance: UInt32,
        transparent: Bool,
        label: String
    ) {
        self.pipeline = pipeline
        self.vertexBuffer = vertexBuffer
        self.primitiveType = primitiveType
        self.vertexStart = vertexStart
        self.vertexCount = vertexCount
        self.instanceCount = instanceCount
        self.baseInstance = baseInstance
        self.transparent = transparent
        self.preferredPath = .indexed
        self.pass = transparent ? .transparent : .opaque
        switch primitiveType {
        case .triangle:
            self.kind = .triangles
        case .line:
            self.kind = .lines
        case .point:
            self.kind = .points
        }
        self.sortKey = 0
        self.participatesInDepthPrepass = false
        self.castsShadow = false
        self.label = label
    }

    public var hasIndexBuffer: Bool {
        indexBufferStorage != nil
    }

    public var hasFallbackPipeline: Bool {
        fallbackPipelineStorage != nil
    }

    public var hasMeshDispatch: Bool {
        meshDispatchStorage != nil
    }

    public var hasIndirectCommands: Bool {
        indirectCommandsStorage != nil
    }

    public var hasMeshlet: Bool {
        meshletStorage != nil
    }

    public var material: Material? {
        materialStorage
    }

    public func setIndexBuffer(
        _ buffer: Buffer,
        indexType: IndexType,
        offset: UInt64,
        count: UInt32,
        baseVertex: Int32
    ) -> Bool {
        guard count > 0 else {
            return false
        }
        let stride: UInt64 = indexType == .uint16 ? 2 : 4
        guard UInt64(count) <= UInt64.max / stride,
              rangeFitsForRenderer(
                  length: buffer.length,
                  offset: offset,
                  count: UInt64(count) * stride
              ) else {
            return false
        }
        indexBufferStorage = buffer
        indexTypeStorage = indexType
        indexBufferOffsetStorage = offset
        indexCountStorage = count
        baseVertexStorage = baseVertex
        return true
    }

    public func clearIndexBuffer() {
        indexBufferStorage = nil
        indexCountStorage = 0
    }

    public func setFallbackPipeline(_ pipeline: RenderPipeline) {
        fallbackPipelineStorage = pipeline
    }

    public func clearFallbackPipeline() {
        fallbackPipelineStorage = nil
    }

    public func setMeshDispatch(_ descriptor: MeshDispatchDescriptor) {
        meshDispatchStorage = descriptor
    }

    public func clearMeshDispatch() {
        meshDispatchStorage = nil
    }

    public func setIndirectCommands(
        _ commands: IndirectCommandBuffer,
        rangeStart: UInt32,
        count: UInt32
    ) -> Bool {
        guard UInt64(rangeStart) + UInt64(count)
            <= UInt64(commands.maxCommandCount) else {
            return false
        }
        indirectCommandsStorage = commands
        indirectRangeStartStorage = rangeStart
        indirectCountStorage = count
        return true
    }

    public func clearIndirectCommands() {
        indirectCommandsStorage = nil
        indirectRangeStartStorage = 0
        indirectCountStorage = 0
    }

    public func setPipeline(
        _ pipeline: RenderPipeline,
        for pass: RendererPass
    ) {
        passPipelineStorage[pass] = pipeline
    }

    public func clearPipeline(for pass: RendererPass) {
        passPipelineStorage.removeValue(forKey: pass)
    }

    public func setMaterial(_ material: Material) {
        materialStorage = material
        if material.transparent {
            transparent = true
            if pass == .opaque {
                pass = .transparent
            }
        }
    }

    public func clearMaterial() {
        materialStorage = nil
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

    public func setMeshlet(_ meshlet: MeshletGPU) {
        meshletStorage = meshlet
    }

    public func clearMeshlet() {
        meshletStorage = nil
    }

    fileprivate var indexBuffer: Buffer? {
        indexBufferStorage
    }

    fileprivate var indexType: IndexType {
        indexTypeStorage
    }

    fileprivate var indexBufferOffset: UInt64 {
        indexBufferOffsetStorage
    }

    fileprivate var indexCount: UInt32 {
        indexCountStorage
    }

    fileprivate var baseVertex: Int32 {
        baseVertexStorage
    }

    fileprivate var fallbackPipeline: RenderPipeline? {
        fallbackPipelineStorage
    }

    fileprivate var meshDispatch: MeshDispatchDescriptor? {
        meshDispatchStorage
    }

    fileprivate var indirectCommands: IndirectCommandBuffer? {
        indirectCommandsStorage
    }

    fileprivate var indirectRangeStart: UInt32 {
        indirectRangeStartStorage
    }

    fileprivate var indirectCount: UInt32 {
        indirectCountStorage
    }

    fileprivate func pipeline(for pass: RendererPass) -> RenderPipeline {
        passPipelineStorage[pass] ?? pipeline
    }

    fileprivate var vertexArgumentBuffer: ArgumentBuffer? {
        vertexArgumentBufferStorage
    }

    fileprivate var fragmentArgumentBuffer: ArgumentBuffer? {
        fragmentArgumentBufferStorage
    }

    fileprivate var vertexArgumentTable: ArgumentBufferTable? {
        vertexArgumentTableStorage
    }

    fileprivate var fragmentArgumentTable: ArgumentBufferTable? {
        fragmentArgumentTableStorage
    }

    fileprivate var meshlet: MeshletGPU? {
        meshletStorage
    }
}

fileprivate struct RendererBatchEntry {
    var id: UInt64
    var batch: RenderBatch
}

public final class MeshletGPU {
    public let name: String
    public let meshletBuffer: Buffer
    public let vertexBuffer: Buffer
    public let primitiveBuffer: Buffer
    public let descriptors: [MeshletDescriptor]

    private init(
        name: String,
        meshletBuffer: Buffer,
        vertexBuffer: Buffer,
        primitiveBuffer: Buffer,
        descriptors: [MeshletDescriptor]
    ) {
        self.name = name
        self.meshletBuffer = meshletBuffer
        self.vertexBuffer = vertexBuffer
        self.primitiveBuffer = primitiveBuffer
        self.descriptors = descriptors
    }

    public var meshletCount: UInt32 {
        UInt32(min(descriptors.count, Int(UInt32.max)))
    }

    public static func upload(
        device: Device,
        name: String,
        descriptors: [MeshletDescriptor],
        vertexData: [UInt8],
        primitiveData: [UInt8],
        storageMode: StorageMode,
        label: String
    ) -> MeshletGPU? {
        guard !name.isEmpty,
              !descriptors.isEmpty,
              !vertexData.isEmpty,
              !primitiveData.isEmpty,
              storageMode == .shared || storageMode == .managed else {
            return nil
        }

        var descriptorBytes: [UInt8] = []
        descriptorBytes.reserveCapacity(descriptors.count * 40)
        for descriptor in descriptors {
            appendRendererUInt32(
                descriptor.vertexOffset,
                to: &descriptorBytes
            )
            appendRendererUInt32(
                descriptor.vertexCount,
                to: &descriptorBytes
            )
            appendRendererUInt32(
                descriptor.primitiveOffset,
                to: &descriptorBytes
            )
            appendRendererUInt32(
                descriptor.primitiveCount,
                to: &descriptorBytes
            )
            appendRendererUInt32(
                descriptor.lodLevel,
                to: &descriptorBytes
            )
            appendRendererFloat(
                descriptor.boundsCenter.x,
                to: &descriptorBytes
            )
            appendRendererFloat(
                descriptor.boundsCenter.y,
                to: &descriptorBytes
            )
            appendRendererFloat(
                descriptor.boundsCenter.z,
                to: &descriptorBytes
            )
            appendRendererFloat(
                descriptor.boundsRadius,
                to: &descriptorBytes
            )
            appendRendererUInt32(0, to: &descriptorBytes)
        }

        let meshletBufferDescriptor = BufferDescriptor(
            length: UInt64(descriptorBytes.count),
            usage: UInt32(BufferUsage.storage.rawValue),
            storageMode: storageMode,
            cpuCacheMode: .defaultCache,
            hazardMode: .defaultMode,
            label: label.isEmpty ? name + ".meshlets" : label + ".meshlets"
        )
        let vertexBufferDescriptor = BufferDescriptor(
            length: UInt64(vertexData.count),
            usage: UInt32(
                BufferUsage.vertex.rawValue | BufferUsage.storage.rawValue
            ),
            storageMode: storageMode,
            cpuCacheMode: .defaultCache,
            hazardMode: .defaultMode,
            label: label.isEmpty ? name + ".vertices" : label + ".vertices"
        )
        let primitiveBufferDescriptor = BufferDescriptor(
            length: UInt64(primitiveData.count),
            usage: UInt32(BufferUsage.storage.rawValue),
            storageMode: storageMode,
            cpuCacheMode: .defaultCache,
            hazardMode: .defaultMode,
            label: label.isEmpty ? name + ".primitives" : label + ".primitives"
        )
        guard let meshletBuffer = device.createBuffer(meshletBufferDescriptor),
              let vertexBuffer = device.createBuffer(vertexBufferDescriptor),
              let primitiveBuffer = device.createBuffer(
                  primitiveBufferDescriptor
              ),
              uploadRendererBytes(descriptorBytes, to: meshletBuffer),
              uploadRendererBytes(vertexData, to: vertexBuffer),
              uploadRendererBytes(primitiveData, to: primitiveBuffer) else {
            return nil
        }

        return MeshletGPU(
            name: name,
            meshletBuffer: meshletBuffer,
            vertexBuffer: vertexBuffer,
            primitiveBuffer: primitiveBuffer,
            descriptors: descriptors
        )
    }

    public func makeRenderBatch(
        pipeline: RenderPipeline,
        dispatch: MeshDispatchDescriptor,
        transparent: Bool,
        label: String
    ) -> RenderBatch {
        let batch = RenderBatch(
            pipeline: pipeline,
            vertexBuffer: vertexBuffer,
            primitiveType: .triangle,
            vertexStart: 0,
            vertexCount: 0,
            instanceCount: 1,
            baseInstance: 0,
            transparent: transparent,
            label: label
        )
        batch.preferredPath = .mesh
        batch.setMeshDispatch(dispatch)
        batch.setMeshlet(self)
        return batch
    }
}

private func appendRendererUInt32(_ value: UInt32, to bytes: inout [UInt8]) {
    var value = value
    withUnsafeBytes(of: &value) {
        bytes.append(contentsOf: $0)
    }
}

private func appendRendererFloat(_ value: Float, to bytes: inout [UInt8]) {
    var value = value
    withUnsafeBytes(of: &value) {
        bytes.append(contentsOf: $0)
    }
}

private func uploadRendererBytes(_ bytes: [UInt8], to buffer: Buffer) -> Bool {
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

private func rendererThreadgroupFits(
    _ extent: Extent3D,
    deviceLimit: UInt32,
    pipelineLimit: UInt32
) -> Bool {
    guard extent.width > 0,
          extent.height > 0,
          extent.depth > 0,
          UInt64(extent.width) <= UInt64.max / UInt64(extent.height),
          UInt64(extent.width) * UInt64(extent.height)
              <= UInt64.max / UInt64(extent.depth) else {
        return false
    }
    let product = UInt64(extent.width)
        * UInt64(extent.height)
        * UInt64(extent.depth)
    return product <= UInt64(deviceLimit)
        && product <= UInt64(pipelineLimit)
}

fileprivate func rangeFitsForRenderer(
    length: UInt64,
    offset: UInt64,
    count: UInt64
) -> Bool {
    offset <= length &&
        count <= length - offset &&
        offset <= UInt64(Int.max) &&
        count <= UInt64(Int.max)
}

public final class Renderer {
    private let device: Device
    private let pipelineCacheStorage: PipelineCache?
    private var batches: [RendererBatchEntry] = []
    private var nextBatchID: UInt64 = 1
    private var stateStorage = RendererState.ready
    private var drawableSizeStorage = Extent(width: 0, height: 0)
    private var resizeGenerationStorage: UInt64 = 0
    private var forwardPlusConfigurationStorage = ForwardPlusConfiguration(
        tileWidth: 16,
        tileHeight: 16,
        depthSlices: 24,
        maxLightsPerCluster: 64
    )
    private var forwardPlusBindingsStorage: ForwardPlusRenderBindings?
    private var statisticsStorage = RendererStatistics()
    private var persistentStatisticsStorage = RendererPersistentStatistics()
    private var frameStartedStorage: UInt64?
    private var committedCPUFrameStorage: UInt64?
    private weak var lastObservedCommandBufferStorage: CommandBuffer?
    private var lastSubmissionSelectionStorage = SubmissionSelection(
        requestedPath: .indexed,
        selectedPath: .indexed,
        fallbackReason: .none,
        fallbackAvailable: false
    )
    private var errorDescriptionStorage = ""

    public let kind: RendererKind

    public init(device: Device, kind: RendererKind) {
        self.pipelineCacheStorage = nil
        self.device = device
        self.kind = kind
    }

    public init(
        device: Device,
        kind: RendererKind,
        pipelineCache: PipelineCache
    ) {
        self.pipelineCacheStorage = pipelineCache
        self.device = device
        self.kind = kind
    }

    public static func forward(device: Device) -> Renderer {
        Renderer(device: device, kind: .forward)
    }

    public static func forward(
        device: Device,
        pipelineCache: PipelineCache
    ) -> Renderer {
        Renderer(
            device: device,
            kind: .forward,
            pipelineCache: pipelineCache
        )
    }

    public static func forwardPlus(device: Device) -> Renderer {
        Renderer(device: device, kind: .forwardPlus)
    }

    public static func forwardPlus(
        device: Device,
        pipelineCache: PipelineCache
    ) -> Renderer {
        Renderer(
            device: device,
            kind: .forwardPlus,
            pipelineCache: pipelineCache
        )
    }

    public var state: RendererState {
        stateStorage
    }

    public var isActive: Bool {
        stateStorage == .ready
    }

    public var batchCount: UInt32 {
        UInt32(min(batches.count, Int(UInt32.max)))
    }

    public var drawableSize: Extent {
        drawableSizeStorage
    }

    public var resizeGeneration: UInt64 {
        resizeGenerationStorage
    }

    public var statistics: RendererStatistics {
        statisticsStorage
    }

    public var persistentStatistics: RendererPersistentStatistics {
        persistentStatisticsStorage
    }

    public var errorDescription: String {
        errorDescriptionStorage
    }

    public func capabilityAvailability(
        _ feature: DeviceFeature
    ) -> MetalCapabilityAvailability {
        device.capabilities.availability(for: feature)
    }

    public var lastCapabilityDiagnostic: MetalCapabilityDiagnostic {
        device.lastCapabilityDiagnostic
    }

    public var lastSubmissionSelection: SubmissionSelection {
        lastSubmissionSelectionStorage
    }

    public var hasPipelineCache: Bool {
        pipelineCacheStorage != nil
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

    public var forwardPlusConfiguration: ForwardPlusConfiguration {
        forwardPlusConfigurationStorage
    }

    public var hasForwardPlusBindings: Bool {
        forwardPlusBindingsStorage != nil
    }

    public func setForwardPlusBindings(
        _ bindings: ForwardPlusRenderBindings
    ) {
        forwardPlusBindingsStorage = bindings
    }

    public func clearForwardPlusBindings() {
        forwardPlusBindingsStorage = nil
    }

    public var clusterCount: UInt64 {
        guard kind == .forwardPlus,
              forwardPlusConfigurationStorage.tileWidth > 0,
              forwardPlusConfigurationStorage.tileHeight > 0,
              forwardPlusConfigurationStorage.depthSlices > 0 else {
            return 0
        }
        let columns =
            (UInt64(drawableSizeStorage.width)
                + UInt64(forwardPlusConfigurationStorage.tileWidth) - 1)
            / UInt64(forwardPlusConfigurationStorage.tileWidth)
        let rows =
            (UInt64(drawableSizeStorage.height)
                + UInt64(forwardPlusConfigurationStorage.tileHeight) - 1)
            / UInt64(forwardPlusConfigurationStorage.tileHeight)
        let slices = UInt64(forwardPlusConfigurationStorage.depthSlices)
        guard columns <= UInt64.max / max(1, rows),
              columns * rows <= UInt64.max / max(1, slices) else {
            return UInt64.max
        }
        return columns * rows * slices
    }

    public var passSchedules: [RendererPassSchedule] {
        RendererPass.allCases.compactMap { pass in
            let ids = orderedEntries(for: pass).map(\.id)
            guard !ids.isEmpty else {
                return nil
            }
            return RendererPassSchedule(pass: pass, batchIDs: ids)
        }
    }

    public func configureForwardPlus(
        _ configuration: ForwardPlusConfiguration
    ) -> Bool {
        guard kind == .forwardPlus,
              configuration.tileWidth > 0,
              configuration.tileHeight > 0,
              configuration.depthSlices > 0,
              configuration.maxLightsPerCluster > 0 else {
            errorDescriptionStorage =
                "Forward+ configuration is invalid for this renderer."
            return false
        }
        forwardPlusConfigurationStorage = configuration
        errorDescriptionStorage = ""
        return true
    }

    public func makeForwardPlusClusterPlan(
        _ coverages: [ForwardPlusLightCoverage]
    ) -> ForwardPlusClusterPlan? {
        guard kind == .forwardPlus,
              let dimensions = clusterDimensions(),
              dimensions.3 <= UInt64(Int.max) else {
            errorDescriptionStorage =
                "Forward+ cluster dimensions are unavailable or too large."
            return nil
        }

        let columns = dimensions.0
        let rows = dimensions.1
        let slices = dimensions.2
        let clusterCount = dimensions.3
        let maxLights = forwardPlusConfigurationStorage.maxLightsPerCluster
        let count = Int(clusterCount)
        var perCluster = Array(
            repeating: [UInt32](),
            count: count
        )
        var perClusterOverflow = Array(
            repeating: false,
            count: count
        )
        var overflowCount: UInt32 = 0

        for coverage in coverages {
            guard coverage.clusterCount > 0 else {
                continue
            }
            let first = UInt64(coverage.firstCluster)
            guard first < clusterCount else {
                continue
            }
            let requestedEnd = first + UInt64(coverage.clusterCount)
            let end = min(clusterCount, requestedEnd)
            for cluster in first..<end {
                let clusterIndex = Int(cluster)
                if perCluster[clusterIndex].count < Int(maxLights) {
                    perCluster[clusterIndex].append(coverage.lightIndex)
                } else {
                    overflowCount &+= 1
                    perClusterOverflow[clusterIndex] = true
                }
            }
        }

        var bounds: [ForwardPlusClusterBounds] = []
        bounds.reserveCapacity(count)
        for index in 0..<count {
            let column = UInt64(index) % UInt64(columns)
            let row = (UInt64(index) / UInt64(columns)) % UInt64(rows)
            let slice = UInt64(index) / (UInt64(columns) * UInt64(rows))
            let minX = Float(column) / Float(columns) * 2 - 1
            let maxX = Float(column + 1) / Float(columns) * 2 - 1
            let minY = Float(row) / Float(rows) * 2 - 1
            let maxY = Float(row + 1) / Float(rows) * 2 - 1
            let minZ = Float(slice) / Float(slices)
            let maxZ = Float(slice + 1) / Float(slices)
            bounds.append(
                ForwardPlusClusterBounds(
                    minX: minX,
                    minY: minY,
                    minZ: minZ,
                    maxX: maxX,
                    maxY: maxY,
                    maxZ: maxZ
                )
            )
        }

        var assignments: [ForwardPlusClusterAssignment] = []
        var lightIndices: [UInt32] = []
        assignments.reserveCapacity(count)
        for (index, bucket) in perCluster.enumerated() {
            guard lightIndices.count <= Int(UInt32.max),
                  bucket.count <= Int(UInt32.max) else {
                errorDescriptionStorage =
                    "Forward+ light-index data exceeds the C++ ABI range."
                return nil
            }
            assignments.append(
                ForwardPlusClusterAssignment(
                    lightOffset: UInt32(lightIndices.count),
                    lightCount: UInt32(bucket.count),
                    overflow: perClusterOverflow[index]
                )
            )
            lightIndices.append(contentsOf: bucket)
        }

        statisticsStorage.clusterOverflowCount &+= overflowCount
        errorDescriptionStorage = ""
        return ForwardPlusClusterPlan(
            columns: columns,
            rows: rows,
            slices: slices,
            clusterCount: clusterCount,
            maxLightsPerCluster: maxLights,
            overflowCount: overflowCount,
            bounds: bounds,
            assignments: assignments,
            lightIndices: lightIndices
        )
    }

    public func resize(width: UInt32, height: UInt32) -> Bool {
        guard isActive, width > 0, height > 0 else {
            errorDescriptionStorage =
                "Renderer resize requires a positive active extent."
            return false
        }
        drawableSizeStorage = Extent(width: width, height: height)
        resizeGenerationStorage += 1
        errorDescriptionStorage = ""
        return true
    }

    public func update(frameIndex: UInt64, timeSeconds: Double) -> Bool {
        guard isActive, timeSeconds.isFinite else {
            errorDescriptionStorage =
                "Renderer update requires an active renderer and finite time."
            return false
        }
        statisticsStorage.frameIndex = frameIndex
        errorDescriptionStorage = ""
        return true
    }

    public func makeRenderPipeline(
        _ descriptor: RenderPipelineDescriptor
    ) -> RenderPipeline? {
        device.createRenderPipeline(
            descriptor,
            cache: pipelineCacheStorage
        )
    }

    public func makeComputePipeline(
        _ descriptor: ComputePipelineDescriptor
    ) -> ComputePipeline? {
        device.createComputePipeline(
            descriptor,
            cache: pipelineCacheStorage
        )
    }

    public func invalidatePipelineCache() {
        pipelineCacheStorage?.invalidateAll()
    }

    public func addBatch(_ batch: RenderBatch) -> UInt64 {
        guard isActive else {
            errorDescriptionStorage =
                "Cannot add a batch after renderer shutdown."
            return 0
        }
        let id = nextBatchID
        nextBatchID += 1
        batches.append(RendererBatchEntry(id: id, batch: batch))
        return id
    }

    public func removeBatch(_ id: UInt64) -> Bool {
        guard let index = batches.firstIndex(where: { $0.id == id }) else {
            return false
        }
        batches.remove(at: index)
        return true
    }

    public func clearBatches() {
        batches.removeAll(keepingCapacity: true)
    }

    public func schedule(for pass: RendererPass) -> RendererPassSchedule {
        RendererPassSchedule(
            pass: pass,
            batchIDs: orderedEntries(for: pass).map(\.id)
        )
    }

    public func submissionSelection(
        for batch: RenderBatch
    ) -> SubmissionSelection {
        let selection: SubmissionSelection
        switch batch.preferredPath {
        case .indexed:
            selection = SubmissionSelection(
                requestedPath: .indexed,
                selectedPath: .indexed,
                fallbackReason: .none,
                fallbackAvailable: false
            )
        case .mesh:
            let reason: RendererFallbackReason
            if !device.capabilities.meshShaders {
                reason = .capabilityUnavailable
            } else if !batch.hasMeshDispatch {
                reason = .resourcesUnavailable
            } else {
                reason = .none
            }
            if reason == .none {
                selection = SubmissionSelection(
                    requestedPath: .mesh,
                    selectedPath: .mesh,
                    fallbackReason: .none,
                    fallbackAvailable: batch.hasFallbackPipeline
                )
            } else if batch.hasFallbackPipeline {
                selection = SubmissionSelection(
                    requestedPath: .mesh,
                    selectedPath: .indexed,
                    fallbackReason: reason,
                    fallbackAvailable: true
                )
            } else {
                selection = SubmissionSelection(
                    requestedPath: .mesh,
                    selectedPath: .mesh,
                    fallbackReason: .missingFallback,
                    fallbackAvailable: false
                )
            }
        case .indirect:
            let reason: RendererFallbackReason
            if !device.capabilities.indirectCommandBuffers {
                reason = .capabilityUnavailable
            } else if !batch.hasIndirectCommands {
                reason = .resourcesUnavailable
            } else {
                reason = .none
            }
            if reason == .none {
                selection = SubmissionSelection(
                    requestedPath: .indirect,
                    selectedPath: .indirect,
                    fallbackReason: .none,
                    fallbackAvailable: batch.hasFallbackPipeline
                )
            } else if batch.hasFallbackPipeline {
                selection = SubmissionSelection(
                    requestedPath: .indirect,
                    selectedPath: .indexed,
                    fallbackReason: reason,
                    fallbackAvailable: true
                )
            } else {
                selection = SubmissionSelection(
                    requestedPath: .indirect,
                    selectedPath: .indirect,
                    fallbackReason: .missingFallback,
                    fallbackAvailable: false
                )
            }
        }
        lastSubmissionSelectionStorage = selection
        return selection
    }

    public func selectedPath(for batch: RenderBatch) -> SubmissionPath {
        submissionSelection(for: batch).selectedPath
    }

    public func record(
        _ commandBuffer: CommandBuffer,
        renderPass: RenderPassDescriptor,
        view: RenderView
    ) -> Bool {
        guard !batches.contains(where: {
            $0.batch.participatesInDepthPrepass || $0.batch.castsShadow
        }) else {
            errorDescriptionStorage =
                "Depth and shadow batches require recordFrame or recordPass."
            return false
        }
        return recordEntries(
            commandBuffer,
            renderPass: renderPass,
            view: view,
            entries: orderedAllEntries(),
            phase: nil,
            commitStatistics: true
        )
    }

    public func recordPass(
        _ commandBuffer: CommandBuffer,
        renderPass: RenderPassDescriptor,
        pass: RendererPass,
        view: RenderView
    ) -> Bool {
        recordEntries(
            commandBuffer,
            renderPass: renderPass,
            view: view,
            entries: orderedEntries(for: pass),
            phase: pass,
            commitStatistics: true
        )
    }

    public func recordFrame(
        _ commandBuffer: CommandBuffer,
        passes: [RendererPassInput],
        view: RenderView
    ) -> Bool {
        guard !passes.isEmpty else {
            errorDescriptionStorage =
                "A renderer frame requires at least one render pass."
            return false
        }
        var previousPass: RendererPass?
        for input in passes {
            if let previousPass,
               input.pass.rawValue < previousPass.rawValue {
                errorDescriptionStorage =
                    "Renderer passes must be supplied in native schedule order."
                return false
            }
            guard recordEntries(
                commandBuffer,
                renderPass: input.renderPass,
                view: view,
                entries: orderedEntries(for: input.pass),
                phase: input.pass,
                commitStatistics: false
            ) else {
                return false
            }
            previousPass = input.pass
        }
        commitCurrentCPUStatisticsIfNeeded()
        errorDescriptionStorage = ""
        return true
    }

    public func encodeForwardPlusClusters(
        _ commandBuffer: CommandBuffer,
        pipeline: ComputePipeline,
        resources: ForwardPlusComputeResources,
        dispatch: ForwardPlusComputeDispatch
    ) -> Bool {
        guard isActive, kind == .forwardPlus else {
            errorDescriptionStorage =
                "Forward+ cluster encoding requires an active Forward+ "
                + "renderer."
            return false
        }
        guard rendererThreadgroupFits(
            dispatch.threadsPerThreadgroup,
            deviceLimit: device.capabilities.maxThreadsPerThreadgroup,
            pipelineLimit: pipeline.maxThreadsPerThreadgroup
        ) else {
            errorDescriptionStorage =
                "The Forward+ threadgroup exceeds the device or pipeline "
                + "limit."
            return false
        }
        guard let encoder = commandBuffer.makeComputeEncoder() else {
            errorDescriptionStorage = commandBuffer.errorDescription.isEmpty
                ? "Failed to create the Forward+ cluster preparation pass."
                : commandBuffer.errorDescription
            return false
        }
        guard encoder.setComputePipeline(pipeline),
              encoder.setBuffer(
                  resources.lightBuffer,
                  offset: 0,
                  index: dispatch.lightBufferIndex
              ),
              encoder.setBuffer(
                  resources.clusterBoundsBuffer,
                  offset: 0,
                  index: dispatch.clusterBoundsBufferIndex
              ),
              encoder.setBuffer(
                  resources.lightIndexBuffer,
                  offset: 0,
                  index: dispatch.lightIndexBufferIndex
              ),
              encoder.setBuffer(
                  resources.clusterCountBuffer,
                  offset: 0,
                  index: dispatch.clusterCountBufferIndex
              ),
              encoder.dispatchThreadgroups(
                  dispatch.threadgroups,
                  threadsPerThreadgroup: dispatch.threadsPerThreadgroup
              ) else {
            _ = encoder.endEncoding()
            errorDescriptionStorage = commandBuffer.errorDescription.isEmpty
                ? "Failed to encode the Forward+ cluster preparation pass."
                : commandBuffer.errorDescription
            return false
        }
        guard encoder.endEncoding() else {
            errorDescriptionStorage =
                "Failed to end the Forward+ cluster preparation pass."
            return false
        }
        _ = commandBuffer.retainResource(resources.lightBuffer)
        _ = commandBuffer.retainResource(resources.clusterBoundsBuffer)
        _ = commandBuffer.retainResource(resources.lightIndexBuffer)
        _ = commandBuffer.retainResource(resources.clusterCountBuffer)
        statisticsStorage.clusterPreparationDispatchCount &+= 1
        errorDescriptionStorage = ""
        return true
    }

    public func encodeGPUCulling(
        _ commandBuffer: CommandBuffer,
        dispatch: GPUCullingDispatch
    ) -> Bool {
        guard isActive else {
            errorDescriptionStorage = "The renderer is shut down."
            return false
        }
        guard dispatch.threadgroupSize > 0,
              UInt64(dispatch.threadgroupSize)
                  <= UInt64(device.capabilities.maxThreadsPerThreadgroup),
              UInt64(dispatch.threadgroupSize)
                  <= UInt64(dispatch.pipeline.maxThreadsPerThreadgroup),
              dispatch.inputStride > 0,
              dispatch.visibilityStride > 0,
              UInt64(dispatch.itemCount)
                  <= UInt64.max / UInt64(dispatch.inputStride),
              UInt64(dispatch.itemCount)
                  <= UInt64.max / UInt64(dispatch.visibilityStride),
              rangeFitsForRenderer(
                  length: dispatch.inputBuffer.length,
                  offset: 0,
                  count: UInt64(dispatch.itemCount)
                      * UInt64(dispatch.inputStride)
              ),
              rangeFitsForRenderer(
                  length: dispatch.visibilityBuffer.length,
                  offset: 0,
                  count: UInt64(dispatch.itemCount)
                      * UInt64(dispatch.visibilityStride)
              ),
              dispatch.countBuffer.length >= 4 else {
            errorDescriptionStorage =
                "The GPU culling dispatch or buffer ranges are invalid."
            return false
        }
        guard dispatch.itemCount > 0 else {
            errorDescriptionStorage = ""
            return true
        }
        let groupCount = (
            UInt64(dispatch.itemCount)
                + UInt64(dispatch.threadgroupSize) - 1
        ) / UInt64(dispatch.threadgroupSize)
        guard groupCount <= UInt64(UInt32.max) else {
            errorDescriptionStorage =
                "The GPU culling dispatch exceeds the threadgroup range."
            return false
        }
        guard let encoder = commandBuffer.makeComputeEncoder() else {
            errorDescriptionStorage = commandBuffer.errorDescription.isEmpty
                ? "Failed to create the GPU culling pass."
                : commandBuffer.errorDescription
            return false
        }
        guard encoder.setComputePipeline(dispatch.pipeline),
              encoder.setBuffer(
                  dispatch.inputBuffer,
                  offset: 0,
                  index: dispatch.inputBufferIndex
              ),
              encoder.setBuffer(
                  dispatch.visibilityBuffer,
                  offset: 0,
                  index: dispatch.visibilityBufferIndex
              ),
              encoder.setBuffer(
                  dispatch.countBuffer,
                  offset: 0,
                  index: dispatch.countBufferIndex
              ),
              encoder.dispatchThreadgroups(
                  Extent3D(
                      width: UInt32(groupCount),
                      height: 1,
                      depth: 1
                  ),
                  threadsPerThreadgroup: Extent3D(
                      width: dispatch.threadgroupSize,
                      height: 1,
                      depth: 1
                  )
              ) else {
            _ = encoder.endEncoding()
            errorDescriptionStorage = commandBuffer.errorDescription.isEmpty
                ? "Failed to encode the GPU culling pass."
                : commandBuffer.errorDescription
            return false
        }
        guard encoder.endEncoding() else {
            errorDescriptionStorage =
                "Failed to end the GPU culling pass."
            return false
        }
        _ = commandBuffer.retainResource(dispatch.inputBuffer)
        _ = commandBuffer.retainResource(dispatch.visibilityBuffer)
        _ = commandBuffer.retainResource(dispatch.countBuffer)
        errorDescriptionStorage = ""
        return true
    }

    public func cull(
        _ items: [RendererCullingItem],
        visibilityMask: UInt32,
        maxDistance: Float,
        maxVisibleCount: UInt32
    ) -> RendererCullingResult {
        let distanceLimit =
            maxDistance.isNaN || maxDistance < 0
                ? Float.infinity
                : maxDistance
        var visibleIDs: [UInt64] = []
        var visibleLODLevels: [UInt32] = []
        var culledCount: UInt32 = 0
        var invalidCount: UInt32 = 0
        var overflowCount: UInt32 = 0

        for item in items {
            let scalarValues = [
                item.center.x,
                item.center.y,
                item.center.z,
                item.radius,
                item.distance
            ]
            guard item.enabled,
                  scalarValues.allSatisfy({ $0.isFinite }),
                  item.radius >= 0,
                  item.distance >= 0 else {
                invalidCount &+= 1
                continue
            }
            guard visibilityMask != 0,
                  item.visibilityMask & visibilityMask != 0,
                  item.distance <= distanceLimit else {
                culledCount &+= 1
                continue
            }
            if maxVisibleCount > 0,
               visibleIDs.count >= Int(maxVisibleCount) {
                overflowCount &+= 1
                continue
            }
            let lod = item.lodRanges
                .filter { !$0.maxDistance.isNaN && $0.maxDistance >= 0 }
                .sorted { lhs, rhs in
                    lhs.maxDistance < rhs.maxDistance
                }
            let selectedLOD = lod.first(where: {
                item.distance <= $0.maxDistance
            })?.level ?? lod.last?.level ?? 0
            visibleIDs.append(item.id)
            visibleLODLevels.append(selectedLOD)
        }

        statisticsStorage.visibleObjectCount =
            UInt32(min(visibleIDs.count, Int(UInt32.max)))
        statisticsStorage.culledObjectCount &+= culledCount
        statisticsStorage.cullingOverflowCount &+= overflowCount
        errorDescriptionStorage = ""
        return RendererCullingResult(
            visibleIDs: visibleIDs,
            visibleLODLevels: visibleLODLevels,
            culledCount: culledCount,
            invalidCount: invalidCount,
            overflowCount: overflowCount
        )
    }

    public func collectGPUStatistics(
        from commandBuffer: CommandBuffer
    ) -> Bool {
        guard commandBuffer.isComplete else {
            errorDescriptionStorage =
                "GPU statistics require a completed command buffer."
            return false
        }
        guard lastObservedCommandBufferStorage !== commandBuffer else {
            return true
        }
        commitCurrentCPUStatisticsIfNeeded()
        let start = commandBuffer.gpuStartTime
        let end = commandBuffer.gpuEndTime
        let duration = start > 0 && end >= start ? end - start : 0
        statisticsStorage.gpuStartTime = start
        statisticsStorage.gpuEndTime = end
        statisticsStorage.gpuExecutionTime = duration
        persistentStatisticsStorage.framesCompleted &+= 1
        persistentStatisticsStorage.totalGPUExecutionTime += duration
        lastObservedCommandBufferStorage = commandBuffer
        errorDescriptionStorage = ""
        return true
    }

    public func resetStatistics() {
        commitCurrentCPUStatisticsIfNeeded()
        statisticsStorage = RendererStatistics(
            frameIndex: statisticsStorage.frameIndex
        )
        frameStartedStorage = nil
        committedCPUFrameStorage = nil
    }

    public func shutdown() {
        commitCurrentCPUStatisticsIfNeeded()
        batches.removeAll()
        stateStorage = .shutDown
    }

    private func clusterDimensions()
        -> (UInt32, UInt32, UInt32, UInt64)? {
        guard kind == .forwardPlus,
              forwardPlusConfigurationStorage.tileWidth > 0,
              forwardPlusConfigurationStorage.tileHeight > 0,
              forwardPlusConfigurationStorage.depthSlices > 0 else {
            return nil
        }
        let columns64 =
            (UInt64(drawableSizeStorage.width)
                + UInt64(forwardPlusConfigurationStorage.tileWidth) - 1)
            / UInt64(forwardPlusConfigurationStorage.tileWidth)
        let rows64 =
            (UInt64(drawableSizeStorage.height)
                + UInt64(forwardPlusConfigurationStorage.tileHeight) - 1)
            / UInt64(forwardPlusConfigurationStorage.tileHeight)
        let slices64 = UInt64(forwardPlusConfigurationStorage.depthSlices)
        guard columns64 > 0,
              rows64 > 0,
              columns64 <= UInt64(UInt32.max),
              rows64 <= UInt64(UInt32.max),
              columns64 <= UInt64.max / rows64,
              columns64 * rows64 <= UInt64.max / slices64 else {
            return nil
        }
        return (
            UInt32(columns64),
            UInt32(rows64),
            UInt32(slices64),
            columns64 * rows64 * slices64
        )
    }

    private func orderedEntries(
        for pass: RendererPass
    ) -> [RendererBatchEntry] {
        batches
            .filter { entry in
                switch pass {
                case .depthPrepass:
                    return entry.batch.participatesInDepthPrepass
                case .shadow:
                    return entry.batch.castsShadow
                case .opaque, .transparent, .overlay:
                    return entry.batch.pass == pass
                }
            }
            .sorted { lhs, rhs in
                if pass == .transparent {
                    if lhs.batch.sortKey != rhs.batch.sortKey {
                        return lhs.batch.sortKey > rhs.batch.sortKey
                    }
                } else if lhs.batch.sortKey != rhs.batch.sortKey {
                    return lhs.batch.sortKey < rhs.batch.sortKey
                }
                return lhs.id < rhs.id
            }
    }

    private func orderedAllEntries() -> [RendererBatchEntry] {
        [
            RendererPass.opaque,
            RendererPass.transparent,
            RendererPass.overlay
        ].flatMap { orderedEntries(for: $0) }
    }

    private func beginFrame(_ frameIndex: UInt64) {
        guard frameStartedStorage != frameIndex else {
            statisticsStorage.frameIndex = frameIndex
            return
        }
        statisticsStorage = RendererStatistics(frameIndex: frameIndex)
        frameStartedStorage = frameIndex
        committedCPUFrameStorage = nil
        persistentStatisticsStorage.framesRecorded &+= 1
    }

    private func commitCurrentCPUStatisticsIfNeeded() {
        guard let frameIndex = frameStartedStorage,
              committedCPUFrameStorage != frameIndex else {
            return
        }
        persistentStatisticsStorage.drawCallCount &+=
            UInt64(statisticsStorage.drawCallCount)
        persistentStatisticsStorage.submittedInstanceCount &+=
            UInt64(statisticsStorage.submittedInstanceCount)
        persistentStatisticsStorage.meshDispatchCount &+=
            UInt64(statisticsStorage.meshDispatchCount)
        persistentStatisticsStorage.indirectCommandCount &+=
            UInt64(statisticsStorage.indirectCommandCount)
        persistentStatisticsStorage.fallbackCount &+=
            UInt64(statisticsStorage.fallbackCount)
        persistentStatisticsStorage.clusterOverflowCount &+=
            UInt64(statisticsStorage.clusterOverflowCount)
        persistentStatisticsStorage.visibleObjectCount &+=
            UInt64(statisticsStorage.visibleObjectCount)
        persistentStatisticsStorage.culledObjectCount &+=
            UInt64(statisticsStorage.culledObjectCount)
        persistentStatisticsStorage.cullingOverflowCount &+=
            UInt64(statisticsStorage.cullingOverflowCount)
        committedCPUFrameStorage = frameIndex
    }

    private func recordEntries(
        _ commandBuffer: CommandBuffer,
        renderPass: RenderPassDescriptor,
        view: RenderView,
        entries: [RendererBatchEntry],
        phase: RendererPass?,
        commitStatistics: Bool
    ) -> Bool {
        guard isActive else {
            errorDescriptionStorage = "The renderer is shut down."
            return false
        }
        guard view.viewport.width > 0, view.viewport.height > 0,
              view.timeSeconds.isFinite else {
            errorDescriptionStorage = "The render view is invalid."
            return false
        }
        beginFrame(view.frameIndex)
        if renderPass.colorLoadAction == .clear {
            renderPass.clearColor = view.clearColor
        }
        if entries.isEmpty {
            if commitStatistics {
                commitCurrentCPUStatisticsIfNeeded()
            }
            errorDescriptionStorage = ""
            return true
        }
        guard let encoder = commandBuffer.makeRenderEncoder(renderPass) else {
            errorDescriptionStorage = commandBuffer.errorDescription
            return false
        }
        guard encoder.setViewport(view.viewport) else {
            _ = encoder.endEncoding()
            errorDescriptionStorage = "Failed to set the renderer viewport."
            return false
        }

        var lastPipeline: RenderPipeline?
        var success = true

        for entry in entries {
            let batch = entry.batch
            if let phase, phase != .depthPrepass,
               phase != .shadow,
               batch.pass != phase {
                continue
            }
            let batchPhase = phase ?? batch.pass
            let selection = submissionSelection(for: batch)
            let selected = selection.selectedPath
            if selection.fallbackReason == .missingFallback {
                errorDescriptionStorage =
                    "No fallback is available for the requested native path "
                    + "for batch "
                    + String(entry.id)
                success = false
                break
            }
            let pipeline: RenderPipeline

            if selection.usedFallback {
                statisticsStorage.fallbackCount += 1
                guard let fallback = batch.fallbackPipeline else {
                    errorDescriptionStorage =
                        "No fallback pipeline is available for batch "
                        + String(entry.id)
                    success = false
                    break
                }
                pipeline = fallback
            } else {
                pipeline = batch.pipeline(for: batchPhase)
            }

            if lastPipeline !== pipeline {
                statisticsStorage.pipelineSwitchCount += 1
                lastPipeline = pipeline
            }
            guard encoder.setRenderPipeline(pipeline) else {
                errorDescriptionStorage =
                    "Failed to bind the pipeline for batch "
                    + String(entry.id)
                success = false
                break
            }

            if let material = batch.material {
                guard material.isSupported(device: device),
                      material.bind(encoder) else {
                    errorDescriptionStorage =
                        "The material for batch "
                        + String(entry.id)
                        + " cannot be bound for this device."
                    success = false
                    break
                }
            }
            if let argumentBuffer = batch.vertexArgumentBuffer,
               !encoder.setVertexArgumentBuffer(
                   argumentBuffer,
                   index: 0
               ) {
                errorDescriptionStorage =
                    "The vertex argument buffer for batch "
                    + String(entry.id)
                    + " cannot be bound."
                success = false
                break
            }
            if let argumentBuffer = batch.fragmentArgumentBuffer,
               !encoder.setFragmentArgumentBuffer(
                   argumentBuffer,
                   index: 0
               ) {
                errorDescriptionStorage =
                    "The fragment argument buffer for batch "
                    + String(entry.id)
                    + " cannot be bound."
                success = false
                break
            }
            if let table = batch.vertexArgumentTable,
               !table.bindVertex(to: encoder) {
                errorDescriptionStorage =
                    "The vertex argument table for batch "
                    + String(entry.id)
                    + " cannot be bound."
                success = false
                break
            }
            if let table = batch.fragmentArgumentTable,
               !table.bindFragment(to: encoder) {
                errorDescriptionStorage =
                    "The fragment argument table for batch "
                    + String(entry.id)
                    + " cannot be bound."
                success = false
                break
            }
            if kind == .forwardPlus,
               (batchPhase == .opaque || batchPhase == .transparent),
               let bindings = forwardPlusBindingsStorage {
                guard encoder.setFragmentBuffer(
                    bindings.lightBuffer,
                    offset: 0,
                    index: bindings.lightBufferIndex
                ),
                encoder.setFragmentBuffer(
                    bindings.lightIndexBuffer,
                    offset: 0,
                    index: bindings.lightIndexBufferIndex
                ),
                encoder.setFragmentBuffer(
                    bindings.clusterCountBuffer,
                    offset: 0,
                    index: bindings.clusterCountBufferIndex
                ) else {
                    errorDescriptionStorage =
                        "The Forward+ cluster bindings for batch "
                        + String(entry.id)
                        + " cannot be bound."
                    success = false
                    break
                }
            }

            switch selected {
            case .indexed:
                guard encoder.setVertexBuffer(
                    batch.vertexBuffer,
                    offset: 0,
                    index: 0
                ) else {
                    errorDescriptionStorage =
                        "Failed to bind the vertex buffer for batch "
                        + String(entry.id)
                    success = false
                    break
                }
                let drawSucceeded: Bool
                if let indexBuffer = batch.indexBuffer {
                    drawSucceeded = encoder.drawIndexedPrimitives(
                        primitiveType: batch.primitiveType,
                        indexType: batch.indexType,
                        indexBuffer: indexBuffer,
                        indexBufferOffset: batch.indexBufferOffset,
                        indexCount: batch.indexCount,
                        instanceCount: batch.instanceCount,
                        baseVertex: batch.baseVertex,
                        baseInstance: batch.baseInstance
                    )
                } else {
                    drawSucceeded = encoder.drawPrimitives(
                        primitiveType: batch.primitiveType,
                        vertexStart: batch.vertexStart,
                        vertexCount: batch.vertexCount,
                        instanceCount: batch.instanceCount,
                        baseInstance: batch.baseInstance
                    )
                }
                guard drawSucceeded else {
                    errorDescriptionStorage =
                        "Failed to encode indexed/vertex draw for batch "
                        + String(entry.id)
                    success = false
                    break
                }
                statisticsStorage.drawCallCount += 1
                statisticsStorage.submittedInstanceCount +=
                    batch.instanceCount

            case .mesh:
                if let meshlet = batch.meshlet {
                    guard encoder.setObjectBuffer(
                        meshlet.meshletBuffer,
                        offset: 0,
                        index: 0
                    ),
                    encoder.setMeshBuffer(
                        meshlet.vertexBuffer,
                        offset: 0,
                        index: 1
                    ),
                    encoder.setMeshBuffer(
                        meshlet.primitiveBuffer,
                        offset: 0,
                        index: 2
                    ) else {
                        errorDescriptionStorage =
                            "Failed to bind meshlet resources for batch "
                            + String(entry.id)
                        success = false
                        break
                    }
                }
                guard let dispatch = batch.meshDispatch,
                      encoder.drawMeshThreadgroups(dispatch) else {
                    errorDescriptionStorage =
                        "Failed to encode mesh dispatch for batch "
                        + String(entry.id)
                    success = false
                    break
                }
                statisticsStorage.meshDispatchCount += 1

            case .indirect:
                guard let commands = batch.indirectCommands,
                      encoder.executeIndirectCommands(
                          commands,
                          rangeStart: batch.indirectRangeStart,
                          count: batch.indirectCount
                      ) else {
                    errorDescriptionStorage =
                        "Failed to execute indirect commands for batch "
                        + String(entry.id)
                    success = false
                    break
                }
                statisticsStorage.indirectCommandCount +=
                    batch.indirectCount
            }

            if batch.transparent {
                statisticsStorage.transparentBatchCount += 1
            }
            switch batch.kind {
            case .triangles:
                break
            case .lines:
                statisticsStorage.lineBatchCount += 1
            case .points:
                statisticsStorage.pointBatchCount += 1
            case .billboard:
                statisticsStorage.billboardBatchCount += 1
            }
        }

        guard encoder.endEncoding() else {
            errorDescriptionStorage =
                "Failed to end the renderer's render encoder."
            return false
        }
        if success {
            statisticsStorage.passCount += 1
            if commitStatistics {
                commitCurrentCPUStatisticsIfNeeded()
            }
        }
        if success {
            errorDescriptionStorage = ""
        }
        return success
    }
}

