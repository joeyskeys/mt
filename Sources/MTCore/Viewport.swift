import Foundation

public enum ViewportState: Int32 {
    case ready
    case shutDown
}

public enum ViewportPhase: Int32 {
    case picking
    case scene
    case screenOverlay
}

public enum ViewportFeatureKind: Int32 {
    case noOp
    case axes
    case grid
    case labels
    case vertexPoints
    case objectPicking
    case vertexPicking
    case custom
}

public enum ViewportAccelerationPath: Int32 {
    case baseline
    case memoryless
    case tile
    case mesh
}

public enum ViewportAccelerationFallbackReason: Int32 {
    case none
    case capabilityUnavailable
    case resourcesUnavailable
    case unsupportedReadback
    case invalidRequest
}

public struct ViewportAccelerationSelection {
    public var requestedPath: ViewportAccelerationPath
    public var selectedPath: ViewportAccelerationPath
    public var fallbackReason: ViewportAccelerationFallbackReason
    public var fallbackAvailable: Bool

    public init(
        requestedPath: ViewportAccelerationPath,
        selectedPath: ViewportAccelerationPath,
        fallbackReason: ViewportAccelerationFallbackReason,
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

public enum ViewportPickingPath: Int32 {
    case baseline
    case aBuffer
}

public enum ViewportPickingFallbackReason: Int32 {
    case none
    case capabilityUnavailable
    case resourcesUnavailable
    case unsupportedReadback
    case invalidRequest
}

public struct ViewportPickingSelection {
    public var requestedPath: ViewportPickingPath
    public var selectedPath: ViewportPickingPath
    public var fallbackReason: ViewportPickingFallbackReason
    public var fallbackAvailable: Bool

    public init(
        requestedPath: ViewportPickingPath,
        selectedPath: ViewportPickingPath,
        fallbackReason: ViewportPickingFallbackReason,
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

public struct ViewportPickingConfiguration {
    public var captureDepth: Bool
    public var captureNormal: Bool
    public var preferMemoryless: Bool
    public var preferTile: Bool
    public var preferMesh: Bool
    public var preferABuffer: Bool
    public var aBufferNodesPerPixel: UInt32
    public var aBufferMaxNodes: UInt32
    public var vertexPointSize: Float

    public init(
        captureDepth: Bool = false,
        captureNormal: Bool = false,
        preferMemoryless: Bool = false,
        preferTile: Bool = false,
        preferMesh: Bool = false,
        preferABuffer: Bool = false,
        aBufferNodesPerPixel: UInt32 = 8,
        aBufferMaxNodes: UInt32 = 1_048_576,
        vertexPointSize: Float = 1
    ) {
        self.captureDepth = captureDepth
        self.captureNormal = captureNormal
        self.preferMemoryless = preferMemoryless
        self.preferTile = preferTile
        self.preferMesh = preferMesh
        self.preferABuffer = preferABuffer
        self.aBufferNodesPerPixel = aBufferNodesPerPixel
        self.aBufferMaxNodes = aBufferMaxNodes
        self.vertexPointSize = vertexPointSize
    }
}

public struct ViewportFeatureVertex {
    public var position: Vector3
    public var color: Vector4

    public init(position: Vector3, color: Vector4) {
        self.position = position
        self.color = color
    }
}

public struct ViewportFeatureFrameData {
    public var modelViewProjection: Matrix4x4
    public var pointSize: Float
    public var reserved0: Float
    public var reserved1: Float
    public var reserved2: Float

    public init(modelViewProjection: Matrix4x4, pointSize: Float) {
        self.modelViewProjection = modelViewProjection
        self.pointSize = pointSize
        self.reserved0 = 0
        self.reserved1 = 0
        self.reserved2 = 0
    }

    public func makeParameterBlock() -> ParameterBlock {
        let block = ParameterBlock(
            length: UInt32(MemoryLayout<ViewportFeatureFrameData>.size),
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

public struct ViewportFeatureExtension {
    public var name: String
    public var phase: ViewportPhase
    public var requiredFeatures: UInt32
    public var fallbackAvailable: Bool
    public var enabled: Bool
    public var visible: Bool

    public init(
        name: String,
        phase: ViewportPhase,
        requiredFeatures: UInt32,
        fallbackAvailable: Bool,
        enabled: Bool = true,
        visible: Bool = true
    ) {
        self.name = name
        self.phase = phase
        self.requiredFeatures = requiredFeatures
        self.fallbackAvailable = fallbackAvailable
        self.enabled = enabled
        self.visible = visible
    }
}

public struct ViewportVertexCandidate {
    public var objectID: UInt32
    public var vertexID: UInt32
    public var screenPosition: Vector2
    public var depth: Float

    public init(
        objectID: UInt32,
        vertexID: UInt32,
        screenPosition: Vector2,
        depth: Float
    ) {
        self.objectID = objectID
        self.vertexID = vertexID
        self.screenPosition = screenPosition
        self.depth = depth
    }
}

public struct ViewportVertexSelectionResult {
    public var objectID: UInt32
    public var vertexID: UInt32
    public var distanceSquared: Float
    public var depth: Float
    public var hit: Bool

    public init(
        objectID: UInt32,
        vertexID: UInt32,
        distanceSquared: Float,
        depth: Float,
        hit: Bool
    ) {
        self.objectID = objectID
        self.vertexID = vertexID
        self.distanceSquared = distanceSquared
        self.depth = depth
        self.hit = hit
    }
}

public enum ViewportPickMode: Int32 {
    case object
    case vertex
}

public struct ViewportCamera {
    public var viewMatrix: Matrix4x4
    public var projectionMatrix: Matrix4x4
    public var position: Vector3
    public var nearPlane: Float
    public var farPlane: Float

    public init(
        viewMatrix: Matrix4x4,
        projectionMatrix: Matrix4x4,
        position: Vector3,
        nearPlane: Float,
        farPlane: Float
    ) {
        self.viewMatrix = viewMatrix
        self.projectionMatrix = projectionMatrix
        self.position = position
        self.nearPlane = nearPlane
        self.farPlane = farPlane
    }

    public static func identity() -> ViewportCamera {
        ViewportCamera(
            viewMatrix: Matrix4x4.identity(),
            projectionMatrix: Matrix4x4.identity(),
            position: Vector3(x: 0, y: 0, z: 0),
            nearPlane: 0.1,
            farPlane: 1000
        )
    }
}

public struct ViewportUpdate {
    public var frameIndex: UInt64
    public var timeSeconds: Double
    public var camera: ViewportCamera

    public init(
        frameIndex: UInt64,
        timeSeconds: Double,
        camera: ViewportCamera
    ) {
        self.frameIndex = frameIndex
        self.timeSeconds = timeSeconds
        self.camera = camera
    }
}

public final class ViewportFeature {
    public let name: String
    public let kind: ViewportFeatureKind
    public let phase: ViewportPhase
    public var enabled: Bool
    public var visible: Bool
    public var cellCount: UInt32
    public var cellSize: Float
    public var drawLabels: Bool
    public var depthTested: Bool
    public var labelText: String
    public var labelScale: Float
    public var labelColor: Vector4
    public var pointSize: Float

    private var attachedStorage = false
    private var extentStorage = Extent(width: 0, height: 0)
    private var attachCountStorage: UInt32 = 0
    private var resizeCountStorage: UInt32 = 0
    private var updateCountStorage: UInt32 = 0
    private var recordCountStorage: UInt32 = 0
    private var lastFrameIndexStorage: UInt64 = 0
    private var vertexPointsStorage: [Vector3] = []
    private var vertexStorage: [ViewportFeatureVertex] = []
    private var vertexBufferStorage: Buffer?
    private var pipelineStorage: [Int32: RenderPipeline] = [:]
    private var depthStateStorage: DepthStencilState?
    private var preparedDeviceIDStorage: UInt64 = 0
    private var preparedGeometrySignatureStorage = ""
    private var preparedColorFormatStorage = PixelFormat.invalid
    private var primitiveTypeStorage = PrimitiveType.line
    private var preparationErrorStorage = ""

    public init(
        name: String,
        kind: ViewportFeatureKind,
        phase: ViewportPhase,
        enabled: Bool
    ) {
        self.name = name
        self.kind = kind
        self.phase = phase
        self.enabled = enabled
        self.visible = true
        self.cellCount = 10
        self.cellSize = 1
        self.drawLabels = false
        self.depthTested = true
        self.labelText = name
        self.labelScale = 0.1
        self.labelColor = Vector4(x: 1, y: 1, z: 1, w: 1)
        self.pointSize = 5
    }

    public static func axes(name: String) -> ViewportFeature {
        ViewportFeature(
            name: name,
            kind: .axes,
            phase: .screenOverlay,
            enabled: true
        )
    }

    public static func grid(name: String) -> ViewportFeature {
        ViewportFeature(
            name: name,
            kind: .grid,
            phase: .screenOverlay,
            enabled: true
        )
    }

    public static func labels(name: String) -> ViewportFeature {
        ViewportFeature(
            name: name,
            kind: .labels,
            phase: .screenOverlay,
            enabled: true
        )
    }

    public static func vertexPoints(name: String) -> ViewportFeature {
        ViewportFeature(
            name: name,
            kind: .vertexPoints,
            phase: .screenOverlay,
            enabled: true
        )
    }

    public static func objectPicking(name: String) -> ViewportFeature {
        ViewportFeature(
            name: name,
            kind: .objectPicking,
            phase: .picking,
            enabled: true
        )
    }

    public static func vertexPicking(name: String) -> ViewportFeature {
        ViewportFeature(
            name: name,
            kind: .vertexPicking,
            phase: .picking,
            enabled: true
        )
    }

    public var isAttached: Bool {
        attachedStorage
    }

    public var extent: Extent {
        extentStorage
    }

    public var attachCount: UInt32 {
        attachCountStorage
    }

    public var resizeCount: UInt32 {
        resizeCountStorage
    }

    public var updateCount: UInt32 {
        updateCountStorage
    }

    public var recordCount: UInt32 {
        recordCountStorage
    }

    public var lastFrameIndex: UInt64 {
        lastFrameIndexStorage
    }

    public var vertexPointCount: UInt32 {
        UInt32(min(vertexPointsStorage.count, Int(UInt32.max)))
    }

    public var vertexCount: UInt32 {
        UInt32(min(vertexStorage.count, Int(UInt32.max)))
    }

    public var primitiveType: PrimitiveType {
        primitiveTypeStorage
    }

    public var selectedPipelineCount: UInt32 {
        UInt32(pipelineStorage.count)
    }

    public var preparationError: String {
        preparationErrorStorage
    }

    public func setLabelText(_ text: String) {
        labelText = text
        preparedGeometrySignatureStorage = ""
    }

    public func setVertexPoints(_ points: [Vector3]) -> Bool {
        guard points.count <= Int(UInt32.max),
              points.allSatisfy({
                  $0.x.isFinite && $0.y.isFinite && $0.z.isFinite
              }) else {
            return false
        }
        vertexPointsStorage = points
        preparedGeometrySignatureStorage = ""
        return true
    }

    fileprivate func attach(to extent: Extent) -> Bool {
        guard !name.isEmpty, !attachedStorage else {
            return false
        }
        attachedStorage = true
        extentStorage = extent
        attachCountStorage += 1
        return true
    }

    fileprivate func detach() {
        attachedStorage = false
        vertexBufferStorage = nil
        pipelineStorage.removeAll()
        depthStateStorage = nil
    }

    fileprivate func resize(to extent: Extent) -> Bool {
        guard attachedStorage else {
            return false
        }
        extentStorage = extent
        resizeCountStorage += 1
        preparedGeometrySignatureStorage = ""
        return true
    }

    fileprivate func update(_ update: ViewportUpdate) -> Bool {
        guard attachedStorage else {
            return false
        }
        guard enabled else {
            return true
        }
        guard update.timeSeconds.isFinite,
              update.camera.nearPlane.isFinite,
              update.camera.farPlane.isFinite,
              update.camera.nearPlane > 0,
              update.camera.farPlane > update.camera.nearPlane else {
            return false
        }
        updateCountStorage += 1
        lastFrameIndexStorage = update.frameIndex
        return true
    }

    fileprivate func record(_ phase: ViewportPhase) -> Bool {
        guard attachedStorage, enabled, visible, self.phase == phase else {
            return true
        }
        recordCountStorage += 1
        return true
    }

    fileprivate func recordGPU(
        _ phase: ViewportPhase,
        encoder: RenderEncoder,
        camera: ViewportCamera,
        colorFormat: PixelFormat,
        device: Device
    ) -> Bool {
        guard attachedStorage, enabled, visible, self.phase == phase else {
            return true
        }
        guard record(phase) else {
            return false
        }
        guard kind == .axes
                || kind == .grid
                || kind == .labels
                || kind == .vertexPoints else {
            return true
        }
        guard prepare(device: device, colorFormat: colorFormat),
              let pipeline = pipelineStorage[colorFormat.rawValue],
              let vertexBuffer = vertexBufferStorage,
              !vertexStorage.isEmpty else {
            return preparationErrorStorage.isEmpty
        }
        let resolvedPointSize = pointSize.isFinite
            ? max(1, pointSize)
            : 1
        let frame = ViewportFeatureFrameData(
            modelViewProjection: viewportCameraMatrix(camera),
            pointSize: resolvedPointSize
        ).makeParameterBlock()
        guard encoder.setRenderPipeline(pipeline),
              encoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0),
              encoder.setVertexBytes(frame, index: 1) else {
            return false
        }
        if depthTested {
            guard let depthStateStorage,
                  encoder.setDepthStencilState(depthStateStorage) else {
                return false
            }
        }
        guard encoder.drawPrimitives(
                  primitiveType: primitiveTypeStorage,
                  vertexStart: 0,
                  vertexCount: UInt32(vertexStorage.count),
                  instanceCount: 1,
                  baseInstance: 0
              ) else {
            return false
        }
        return true
    }

    private func prepare(
        device: Device,
        colorFormat: PixelFormat
    ) -> Bool {
        guard colorFormat != .invalid else {
            preparationErrorStorage = "A valid viewport color format is required."
            return false
        }
        guard [
            labelColor.x,
            labelColor.y,
            labelColor.z,
            labelColor.w
        ].allSatisfy({ $0.isFinite }) else {
            preparationErrorStorage =
                "Viewport feature colors must be finite."
            return false
        }
        rebuildGeometry()
        let deviceID = device.info.registryID
        let signature = geometrySignature()
        if preparedDeviceIDStorage != deviceID
            || preparedGeometrySignatureStorage != signature {
            vertexBufferStorage = nil
            pipelineStorage.removeAll()
            depthStateStorage = nil
            preparedDeviceIDStorage = deviceID
            preparedGeometrySignatureStorage = signature
        }
        if vertexBufferStorage == nil, !vertexStorage.isEmpty {
            let descriptor = BufferDescriptor(
                length: UInt64(
                    MemoryLayout<ViewportFeatureVertex>.stride
                        * vertexStorage.count
                ),
                usage: UInt32(BufferUsage.vertex.rawValue),
                storageMode: .shared,
                cpuCacheMode: .defaultCache,
                hazardMode: .defaultMode,
                label: "mt.viewport." + name + ".vertices"
            )
            guard let buffer = device.createBuffer(descriptor),
                  uploadViewportFeatureVertices(vertexStorage, to: buffer)
            else {
                preparationErrorStorage =
                    "The viewport feature vertex buffer could not be created."
                return false
            }
            vertexBufferStorage = buffer
        }
        if pipelineStorage[colorFormat.rawValue] == nil {
            guard let library = device.createShaderLibraryFromSource(
                source: viewportFeatureShaderSource,
                label: "mt viewport features"
            ),
            let vertex = library.function("mt_viewport_feature_vertex"),
            let fragment = library.function("mt_viewport_feature_fragment")
            else {
                preparationErrorStorage = device.errorDescription
                return false
            }
            let descriptor = RenderPipelineDescriptor()
            descriptor.label = "mt.viewport." + name
            descriptor.setVertexFunction(vertex)
            descriptor.setFragmentFunction(fragment)
            guard descriptor.setColorAttachment(
                ColorAttachmentDescriptor(
                    pixelFormat: colorFormat,
                    blendingEnabled: kind == .labels,
                    sourceRGBBlendFactor: .sourceAlpha,
                    destinationRGBBlendFactor: .oneMinusSourceAlpha,
                    rgbBlendOperation: .add,
                    sourceAlphaBlendFactor: .sourceAlpha,
                    destinationAlphaBlendFactor: .oneMinusSourceAlpha,
                    alphaBlendOperation: .add,
                    writeMask: 15
                ),
                index: 0
            ),
            let pipeline = device.createRenderPipeline(descriptor) else {
                preparationErrorStorage = device.errorDescription
                return false
            }
            pipelineStorage[colorFormat.rawValue] = pipeline
        }
        if depthTested, depthStateStorage == nil {
            depthStateStorage = device.createDepthStencilState(
                DepthStencilDescriptor(
                    depthCompareFunction: .lessEqual,
                    depthWriteEnabled: false,
                    frontFaceStencil: .default,
                    backFaceStencil: .default,
                    label: "mt.viewport." + name + ".depth"
                )
            )
        }
        preparedColorFormatStorage = colorFormat
        preparationErrorStorage = ""
        return true
    }

    private func rebuildGeometry() {
        vertexStorage.removeAll(keepingCapacity: true)
        switch kind {
        case .axes:
            primitiveTypeStorage = .line
            vertexStorage = [
                ViewportFeatureVertex(
                    position: Vector3(x: 0, y: 0, z: 0),
                    color: Vector4(x: 1, y: 0, z: 0, w: 1)
                ),
                ViewportFeatureVertex(
                    position: Vector3(x: 1, y: 0, z: 0),
                    color: Vector4(x: 1, y: 0, z: 0, w: 1)
                ),
                ViewportFeatureVertex(
                    position: Vector3(x: 0, y: 0, z: 0),
                    color: Vector4(x: 0, y: 1, z: 0, w: 1)
                ),
                ViewportFeatureVertex(
                    position: Vector3(x: 0, y: 1, z: 0),
                    color: Vector4(x: 0, y: 1, z: 0, w: 1)
                ),
                ViewportFeatureVertex(
                    position: Vector3(x: 0, y: 0, z: 0),
                    color: Vector4(x: 0, y: 0, z: 1, w: 1)
                ),
                ViewportFeatureVertex(
                    position: Vector3(x: 0, y: 0, z: 1),
                    color: Vector4(x: 0, y: 0, z: 1, w: 1)
                )
            ]
        case .grid:
            primitiveTypeStorage = .line
            let count = min(cellCount, 1024)
            guard count > 0, cellSize.isFinite, cellSize > 0 else {
                return
            }
            let half = Float(count) * cellSize * 0.5
            for index in 0...count {
                let offset = Float(index) * cellSize - half
                let color = Vector4(x: 0.35, y: 0.35, z: 0.35, w: 1)
                vertexStorage.append(
                    ViewportFeatureVertex(
                        position: Vector3(x: -half, y: 0, z: offset),
                        color: color
                    )
                )
                vertexStorage.append(
                    ViewportFeatureVertex(
                        position: Vector3(x: half, y: 0, z: offset),
                        color: color
                    )
                )
                vertexStorage.append(
                    ViewportFeatureVertex(
                        position: Vector3(x: offset, y: 0, z: -half),
                        color: color
                    )
                )
                vertexStorage.append(
                    ViewportFeatureVertex(
                        position: Vector3(x: offset, y: 0, z: half),
                        color: color
                    )
                )
            }
        case .labels:
            primitiveTypeStorage = .triangle
            rebuildLabelGeometry()
        case .vertexPoints:
            primitiveTypeStorage = .point
            vertexStorage = vertexPointsStorage.map {
                ViewportFeatureVertex(position: $0, color: labelColor)
            }
        default:
            primitiveTypeStorage = .line
        }
    }

    private func rebuildLabelGeometry() {
        let scale = labelScale.isFinite && labelScale > 0 ? labelScale : 0.1
        let width = scale * 0.6
        let height = scale
        let advance = scale * 0.8
        for (index, _) in labelText.utf8.enumerated() {
            let x = Float(index) * advance
            let y: Float = 0
            let p0 = Vector3(x: x, y: y, z: 0)
            let p1 = Vector3(x: x + width, y: y, z: 0)
            let p2 = Vector3(x: x + width, y: y + height, z: 0)
            let p3 = Vector3(x: x, y: y + height, z: 0)
            vertexStorage.append(contentsOf: [
                ViewportFeatureVertex(position: p0, color: labelColor),
                ViewportFeatureVertex(position: p1, color: labelColor),
                ViewportFeatureVertex(position: p2, color: labelColor),
                ViewportFeatureVertex(position: p0, color: labelColor),
                ViewportFeatureVertex(position: p2, color: labelColor),
                ViewportFeatureVertex(position: p3, color: labelColor)
            ])
        }
    }

    private func geometrySignature() -> String {
        [
            String(kind.rawValue),
            String(cellCount),
            String(cellSize),
            labelText,
            String(labelScale),
            String(labelColor.x),
            String(labelColor.y),
            String(labelColor.z),
            String(labelColor.w),
            String(pointSize),
            String(vertexPointsStorage.count),
            vertexPointsStorage.map {
                String($0.x) + "," + String($0.y) + "," + String($0.z)
            }.joined(separator: ";")
        ].joined(separator: "|")
    }
}

private let viewportPickingShaderSource = """
#include <metal_stdlib>
using namespace metal;

struct MTViewportPickingFrame {
    float4x4 modelViewProjection;
    uint objectID;
    uint mode;
    float pointSize;
    uint reserved0;
};

struct MTViewportPickingVertex {
    packed_float3 position;
    packed_float3 normal;
    packed_float2 texcoord;
};

struct MTViewportPickingOutput {
    float4 position [[position]];
    float4 encodedID;
    float3 normal;
    uint objectID [[flat]];
    uint vertexID [[flat]];
    float pointSize [[point_size]];
};

struct MTViewportPickingFragmentOutput {
    float4 encodedID [[color(0)]];
    float4 encodedNormal [[color(1)]];
};

float4 mt_viewport_encode_id(uint value) {
    return float4(
        float(value & 0xffu) / 255.0,
        float((value >> 8u) & 0xffu) / 255.0,
        float((value >> 16u) & 0xffu) / 255.0,
        float((value >> 24u) & 0xffu) / 255.0
    );
}

vertex MTViewportPickingOutput mt_viewport_picking_vertex(
    const device MTViewportPickingVertex *vertices [[buffer(0)]],
    constant MTViewportPickingFrame &frame [[buffer(1)]],
    uint vertexID [[vertex_id]]
) {
    MTViewportPickingOutput output;
    output.position = frame.modelViewProjection *
        float4(vertices[vertexID].position, 1.0);
    uint value = frame.mode == 0u ? frame.objectID : vertexID + 1u;
    output.encodedID = mt_viewport_encode_id(value);
    output.normal = normalize(float3(vertices[vertexID].normal));
    output.objectID = frame.objectID;
    output.vertexID = vertexID;
    output.pointSize = frame.pointSize;
    return output;
}

fragment float4 mt_viewport_picking_fragment(
    MTViewportPickingOutput input [[stage_in]]
) {
    return input.encodedID;
}

fragment MTViewportPickingFragmentOutput
mt_viewport_picking_normal_fragment(
    MTViewportPickingOutput input [[stage_in]]
) {
    MTViewportPickingFragmentOutput output;
    output.encodedID = input.encodedID;
    float3 normal = normalize(input.normal);
    output.encodedNormal = float4(normal * 0.5 + 0.5, 1.0);
    return output;
}

struct MTViewportABufferNode {
    uint objectID;
    uint vertexID;
    float depth;
    uint next;
    float3 normal;
};

struct MTViewportABufferParameters {
    uint width;
    uint height;
    uint capacity;
    uint reserved;
};

void mt_viewport_store_abuffer(
    MTViewportPickingOutput input,
    device atomic_uint *heads,
    device atomic_uint *nodeHeader,
    device MTViewportABufferNode *nodes,
    constant MTViewportABufferParameters &parameters
) {
    const uint2 pixel = uint2(input.position.xy);
    if (pixel.x >= parameters.width || pixel.y >= parameters.height) {
        return;
    }

    const uint nodeIndex = atomic_fetch_add_explicit(
        nodeHeader,
        1u,
        memory_order_relaxed
    );
    if (nodeIndex >= parameters.capacity) {
        atomic_store_explicit(nodeHeader + 1, 1u, memory_order_relaxed);
        return;
    }

    nodes[nodeIndex].objectID = input.objectID;
    nodes[nodeIndex].vertexID = input.vertexID;
    nodes[nodeIndex].depth = input.position.z;
    nodes[nodeIndex].normal = input.normal;
    nodes[nodeIndex].next = atomic_exchange_explicit(
        heads + pixel.y * parameters.width + pixel.x,
        nodeIndex,
        memory_order_relaxed
    );
}

fragment float4 mt_viewport_picking_abuffer_fragment(
    MTViewportPickingOutput input [[stage_in]],
    device atomic_uint *heads [[buffer(2)]],
    device MTViewportABufferNode *nodes [[buffer(3)]],
    device atomic_uint *nodeHeader [[buffer(4)]],
    constant MTViewportABufferParameters &parameters [[buffer(5)]]
) {
    mt_viewport_store_abuffer(
        input,
        heads,
        nodeHeader,
        nodes,
        parameters
    );
    return input.encodedID;
}

fragment MTViewportPickingFragmentOutput
mt_viewport_picking_abuffer_normal_fragment(
    MTViewportPickingOutput input [[stage_in]],
    device atomic_uint *heads [[buffer(2)]],
    device MTViewportABufferNode *nodes [[buffer(3)]],
    device atomic_uint *nodeHeader [[buffer(4)]],
    constant MTViewportABufferParameters &parameters [[buffer(5)]]
) {
    mt_viewport_store_abuffer(
        input,
        heads,
        nodeHeader,
        nodes,
        parameters
    );
    MTViewportPickingFragmentOutput output;
    output.encodedID = input.encodedID;
    float3 normal = normalize(input.normal);
    output.encodedNormal = float4(normal * 0.5 + 0.5, 1.0);
    return output;
}
"""

private let viewportFeatureShaderSource = """
#include <metal_stdlib>
using namespace metal;

struct MTViewportFeatureFrame {
    float4x4 modelViewProjection;
    float pointSize;
    packed_float3 reserved;
};

struct MTViewportFeatureVertex {
    packed_float3 position;
    packed_float4 color;
};

struct MTViewportFeatureOutput {
    float4 position [[position]];
    float4 color;
    float pointSize [[point_size]];
};

vertex MTViewportFeatureOutput mt_viewport_feature_vertex(
    const device MTViewportFeatureVertex *vertices [[buffer(0)]],
    constant MTViewportFeatureFrame &frame [[buffer(1)]],
    uint vertexID [[vertex_id]]
) {
    MTViewportFeatureOutput output;
    output.position = frame.modelViewProjection *
        float4(vertices[vertexID].position, 1.0);
    output.color = float4(vertices[vertexID].color);
    output.pointSize = frame.pointSize;
    return output;
}

fragment float4 mt_viewport_feature_fragment(
    MTViewportFeatureOutput input [[stage_in]]
) {
    return input.color;
}
"""

private func uploadViewportFeatureVertices(
    _ vertices: [ViewportFeatureVertex],
    to buffer: Buffer
) -> Bool {
    guard !vertices.isEmpty else {
        return false
    }
    return vertices.withUnsafeBufferPointer { pointer in
        guard let baseAddress = pointer.baseAddress else {
            return false
        }
        return buffer.upload(
            source: UnsafeRawPointer(baseAddress),
            length: UInt64(
                MemoryLayout<ViewportFeatureVertex>.stride * pointer.count
            ),
            offset: 0
        )
    }
}

private func viewportMatrixElements(_ matrix: Matrix4x4) -> [Float] {
    [
        matrix.m00, matrix.m01, matrix.m02, matrix.m03,
        matrix.m10, matrix.m11, matrix.m12, matrix.m13,
        matrix.m20, matrix.m21, matrix.m22, matrix.m23,
        matrix.m30, matrix.m31, matrix.m32, matrix.m33
    ]
}

private func viewportMatrix(_ elements: [Float]) -> Matrix4x4 {
    Matrix4x4(
        m00: elements[0],
        m01: elements[1],
        m02: elements[2],
        m03: elements[3],
        m10: elements[4],
        m11: elements[5],
        m12: elements[6],
        m13: elements[7],
        m20: elements[8],
        m21: elements[9],
        m22: elements[10],
        m23: elements[11],
        m30: elements[12],
        m31: elements[13],
        m32: elements[14],
        m33: elements[15]
    )
}

private func viewportMultiply(
    _ left: Matrix4x4,
    _ right: Matrix4x4
) -> Matrix4x4 {
    let a = viewportMatrixElements(left)
    let b = viewportMatrixElements(right)
    var result = Array(repeating: Float(0), count: 16)
    for column in 0..<4 {
        for row in 0..<4 {
            var value: Float = 0
            for inner in 0..<4 {
                value += a[inner * 4 + row]
                    * b[column * 4 + inner]
            }
            result[column * 4 + row] = value
        }
    }
    return viewportMatrix(result)
}

private func viewportCameraMatrix(_ camera: ViewportCamera) -> Matrix4x4 {
    viewportMultiply(camera.projectionMatrix, camera.viewMatrix)
}

private func viewportTransformMatrix(_ transform: Transform) -> Matrix4x4 {
    let position = transform.position
    let rotation = transform.rotation
    let scale = transform.scale
    let sx = scale.x.isFinite ? scale.x : 1
    let sy = scale.y.isFinite ? scale.y : 1
    let sz = scale.z.isFinite ? scale.z : 1
    let rx = rotation.x.isFinite ? rotation.x : 0
    let ry = rotation.y.isFinite ? rotation.y : 0
    let rz = rotation.z.isFinite ? rotation.z : 0
    let cx = cos(rx)
    let sxr = sin(rx)
    let cy = cos(ry)
    let syr = sin(ry)
    let cz = cos(rz)
    let szr = sin(rz)
    let scaleMatrix = Matrix4x4(
        m00: sx, m01: 0, m02: 0, m03: 0,
        m10: 0, m11: sy, m12: 0, m13: 0,
        m20: 0, m21: 0, m22: sz, m23: 0,
        m30: 0, m31: 0, m32: 0, m33: 1
    )
    let xMatrix = Matrix4x4(
        m00: 1, m01: 0, m02: 0, m03: 0,
        m10: 0, m11: cx, m12: sxr, m13: 0,
        m20: 0, m21: -sxr, m22: cx, m23: 0,
        m30: 0, m31: 0, m32: 0, m33: 1
    )
    let yMatrix = Matrix4x4(
        m00: cy, m01: 0, m02: -syr, m03: 0,
        m10: 0, m11: 1, m12: 0, m13: 0,
        m20: syr, m21: 0, m22: cy, m23: 0,
        m30: 0, m31: 0, m32: 0, m33: 1
    )
    let zMatrix = Matrix4x4(
        m00: cz, m01: szr, m02: 0, m03: 0,
        m10: -szr, m11: cz, m12: 0, m13: 0,
        m20: 0, m21: 0, m22: 1, m23: 0,
        m30: 0, m31: 0, m32: 0, m33: 1
    )
    let rotationMatrix = viewportMultiply(
        viewportMultiply(zMatrix, yMatrix),
        xMatrix
    )
    var result = viewportMultiply(rotationMatrix, scaleMatrix)
    result.m30 = position.x.isFinite ? position.x : 0
    result.m31 = position.y.isFinite ? position.y : 0
    result.m32 = position.z.isFinite ? position.z : 0
    return result
}

private struct ViewportProjectedPoint {
    let position: Vector2
    let depth: Float
}

private func viewportProject(
    _ point: Vector3,
    matrix: Matrix4x4,
    extent: Extent
) -> ViewportProjectedPoint? {
    let x = point.x
    let y = point.y
    let z = point.z
    guard x.isFinite, y.isFinite, z.isFinite,
          extent.width > 0, extent.height > 0 else {
        return nil
    }
    let clipX = matrix.m00 * x + matrix.m10 * y
        + matrix.m20 * z + matrix.m30
    let clipY = matrix.m01 * x + matrix.m11 * y
        + matrix.m21 * z + matrix.m31
    let clipZ = matrix.m02 * x + matrix.m12 * y
        + matrix.m22 * z + matrix.m32
    let clipW = matrix.m03 * x + matrix.m13 * y
        + matrix.m23 * z + matrix.m33
    guard clipW.isFinite, abs(clipW) > Float.ulpOfOne else {
        return nil
    }
    let ndcX = clipX / clipW
    let ndcY = clipY / clipW
    let ndcZ = clipZ / clipW
    guard ndcX.isFinite, ndcY.isFinite, ndcZ.isFinite else {
        return nil
    }
    return ViewportProjectedPoint(
        position: Vector2(
            x: (ndcX + 1) * 0.5 * Float(extent.width),
            y: (1 - ndcY) * 0.5 * Float(extent.height)
        ),
        depth: ndcZ
    )
}

public struct PickingID {
    public let rawValue: UInt32

    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }

    public var isValid: Bool {
        rawValue != 0
    }

    public func normalizedColor() -> Vector4 {
        let scale = Float(UInt8.max)
        return Vector4(
            x: Float(rawValue & 0xff) / scale,
            y: Float((rawValue >> 8) & 0xff) / scale,
            z: Float((rawValue >> 16) & 0xff) / scale,
            w: Float((rawValue >> 24) & 0xff) / scale
        )
    }

    public static func fromBytes(
        red: UInt8,
        green: UInt8,
        blue: UInt8,
        alpha: UInt8
    ) -> PickingID {
        PickingID(
            rawValue: UInt32(red)
                | (UInt32(green) << 8)
                | (UInt32(blue) << 16)
                | (UInt32(alpha) << 24)
        )
    }

    public static func vertex(_ vertexID: UInt32) -> PickingID? {
        guard vertexID < UInt32.max else {
            return nil
        }
        return PickingID(rawValue: vertexID + 1)
    }
}

public struct ViewportPickRequest {
    public var mode: ViewportPickMode
    public var x: UInt32
    public var y: UInt32
    public var objectID: UInt32
    public var includeDepth: Bool
    public var includeNormal: Bool

    public init(
        mode: ViewportPickMode,
        x: UInt32,
        y: UInt32,
        objectID: UInt32,
        includeDepth: Bool = false,
        includeNormal: Bool = false
    ) {
        self.mode = mode
        self.x = x
        self.y = y
        self.objectID = objectID
        self.includeDepth = includeDepth
        self.includeNormal = includeNormal
    }
}

public struct ViewportPickHit {
    public var objectID: UInt32
    public var vertexID: UInt32
    public var rawID: UInt32
    public var depth: Float
    public var normal: Vector3
    public var hasDepth: Bool
    public var hasNormal: Bool

    public init(
        objectID: UInt32,
        vertexID: UInt32,
        rawID: UInt32,
        depth: Float = 0,
        normal: Vector3 = Vector3(x: 0, y: 0, z: 1),
        hasDepth: Bool = false,
        hasNormal: Bool = false
    ) {
        self.objectID = objectID
        self.vertexID = vertexID
        self.rawID = rawID
        self.depth = depth
        self.normal = normal
        self.hasDepth = hasDepth
        self.hasNormal = hasNormal
    }
}

public struct ViewportPickResult {
    public var mode: ViewportPickMode
    public var x: UInt32
    public var y: UInt32
    public var objectID: UInt32
    public var vertexID: UInt32
    public var rawID: UInt32
    public var hit: Bool
    public var depth: Float
    public var normal: Vector3
    public var hasDepth: Bool
    public var hasNormal: Bool
    private var hitStorage: [ViewportPickHit]
    private var overflowedStorage: Bool
    private var usedABufferStorage: Bool

    public init(
        mode: ViewportPickMode,
        x: UInt32,
        y: UInt32,
        objectID: UInt32,
        vertexID: UInt32,
        rawID: UInt32,
        hit: Bool,
        depth: Float = 0,
        normal: Vector3 = Vector3(x: 0, y: 0, z: 1),
        hasDepth: Bool = false,
        hasNormal: Bool = false
    ) {
        self.mode = mode
        self.x = x
        self.y = y
        self.objectID = objectID
        self.vertexID = vertexID
        self.rawID = rawID
        self.hit = hit
        self.depth = depth
        self.normal = normal
        self.hasDepth = hasDepth
        self.hasNormal = hasNormal
        self.hitStorage = []
        self.overflowedStorage = false
        self.usedABufferStorage = false
    }

    public var hitCount: UInt32 {
        if usedABufferStorage {
            return UInt32(min(hitStorage.count, Int(UInt32.max)))
        }
        return hit ? 1 : 0
    }

    public var overflowed: Bool {
        overflowedStorage
    }

    public var usedABuffer: Bool {
        usedABufferStorage
    }

    public func hit(at index: UInt32) -> ViewportPickHit? {
        if usedABufferStorage {
            guard index < UInt32(hitStorage.count) else {
                return nil
            }
            return hitStorage[Int(index)]
        }
        guard index == 0, hit else {
            return nil
        }
        return ViewportPickHit(
            objectID: objectID,
            vertexID: vertexID,
            rawID: rawID,
            depth: depth,
            normal: normal,
            hasDepth: hasDepth,
            hasNormal: hasNormal
        )
    }

    fileprivate mutating func setABufferHits(
        _ hits: [ViewportPickHit],
        overflowed: Bool
    ) {
        hitStorage = hits
        overflowedStorage = overflowed
        usedABufferStorage = true
    }
}

public struct ViewportPickFrameData {
    public var modelViewProjection: Matrix4x4
    public var objectID: UInt32
    public var mode: UInt32
    public var pointSize: Float
    public var reserved0: UInt32

    public init(
        modelViewProjection: Matrix4x4,
        objectID: UInt32,
        mode: ViewportPickMode,
        pointSize: Float = 1
    ) {
        self.modelViewProjection = modelViewProjection
        self.objectID = objectID
        self.mode = UInt32(mode.rawValue)
        self.pointSize = pointSize.isFinite && pointSize > 0
            ? pointSize
            : 1
        self.reserved0 = 0
    }

    public func makeParameterBlock() -> ParameterBlock {
        let block = ParameterBlock(
            length: UInt32(MemoryLayout<ViewportPickFrameData>.size),
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

private let viewportABufferHeaderBytes: UInt64 = 16
private let viewportABufferNodeStride: UInt64 = 32
private let viewportABufferEmptyHead = UInt32.max

public final class Viewport {
    private struct PendingPick {
        let commandBuffer: CommandBuffer
        let sourceTexture: Texture
        let texture: Texture
        let sourceDepthTexture: Texture?
        let depthTexture: Texture?
        let sourceNormalTexture: Texture?
        let normalTexture: Texture?
        let request: ViewportPickRequest
    }

    private struct PendingABufferPick {
        let commandBuffer: CommandBuffer
        let headBuffer: Buffer
        let nodeBuffer: Buffer
        let width: UInt32
        let height: UInt32
        let nodeCapacity: UInt32
        let request: ViewportPickRequest
    }

    private let device: Device
    private var rendererStorage: Renderer?
    private var features: [UInt64: ViewportFeature] = [:]
    private var featureOrder: [UInt64] = []
    private var nextFeatureID: UInt64 = 1
    private var extensions: [String: ViewportFeatureExtension] = [:]
    private var extensionOrder: [String] = []
    private var objectIDs: [String: UInt32] = [:]
    private var objectNames: [UInt32: String] = [:]
    private var sceneObjectIDHistory: [String: UInt32] = [:]
    private var sceneObjectNamesStorage: Set<String> = []
    private var nextObjectIDStorage: UInt32 = 1
    private var stateStorage = ViewportState.ready
    private var extentStorage = Extent(width: 0, height: 0)
    private var resizeGenerationStorage: UInt64 = 0
    private var updateStorage = ViewportUpdate(
        frameIndex: 0,
        timeSeconds: 0,
        camera: ViewportCamera.identity()
    )
    private var pickingTextureStorage: Texture?
    private var pickingReadbackTextureStorage: Texture?
    private var pickingDepthTextureStorage: Texture?
    private var pickingDepthReadbackTextureStorage: Texture?
    private var pickingNormalTextureStorage: Texture?
    private var pickingNormalReadbackTextureStorage: Texture?
    private var pickingConfigurationStorage = ViewportPickingConfiguration()
    private var pickingSelectionStorage = ViewportPickingSelection(
        requestedPath: .baseline,
        selectedPath: .baseline,
        fallbackReason: .none,
        fallbackAvailable: false
    )
    private var pickingABufferHeadStorage: Buffer?
    private var pickingABufferNodeStorage: Buffer?
    private var pickingABufferNodeCapacityStorage: UInt32 = 0
    private var accelerationSelectionStorage =
        ViewportAccelerationSelection(
            requestedPath: .baseline,
            selectedPath: .baseline,
            fallbackReason: .none,
            fallbackAvailable: false
        )
    private var pickingPipelineStorage: [Int32: RenderPipeline] = [:]
    private var pickingDepthStateStorage: DepthStencilState?
    private var pickingABufferDepthStateStorage: DepthStencilState?
    private var pendingPickStorage: PendingPick?
    private var pendingABufferPickStorage: PendingABufferPick?
    private var errorDescriptionStorage = ""
    private var pointerPositionStorage = Vector2(x: 0, y: 0)
    private var scrollDeltaStorage = Vector2(x: 0, y: 0)
    private var lastButtonStorage: Int32 = -1
    private var buttonPressedStorage = false
    private var focusedStorage = false
    private var closedStorage = false

    public init(device: Device) {
        self.device = device
    }

    public var state: ViewportState {
        stateStorage
    }

    public var isActive: Bool {
        stateStorage == .ready
    }

    public var extent: Extent {
        extentStorage
    }

    public var resizeGeneration: UInt64 {
        resizeGenerationStorage
    }

    public var featureCount: UInt32 {
        UInt32(featureOrder.count)
    }

    public var extensionCount: UInt32 {
        UInt32(extensionOrder.count)
    }

    public var hasRenderer: Bool {
        rendererStorage != nil
    }

    public var hasPendingPick: Bool {
        pendingPickStorage != nil || pendingABufferPickStorage != nil
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

    public var currentUpdate: ViewportUpdate {
        updateStorage
    }

    public var pointerPosition: Vector2 {
        pointerPositionStorage
    }

    public var scrollDelta: Vector2 {
        scrollDeltaStorage
    }

    public var lastButton: Int32 {
        lastButtonStorage
    }

    public var isButtonPressed: Bool {
        buttonPressedStorage
    }

    public var isFocused: Bool {
        focusedStorage
    }

    public var isClosed: Bool {
        closedStorage
    }

    public var pickingColorFormat: PixelFormat {
        .rgba8Unorm
    }

    public var pickingTexture: Texture? {
        pickingTextureStorage
    }

    public var pickingConfiguration: ViewportPickingConfiguration {
        pickingConfigurationStorage
    }

    public var pickingSelection: ViewportPickingSelection {
        pickingSelectionStorage
    }

    public var aBufferNodeCapacity: UInt32 {
        pickingABufferNodeCapacityStorage
    }

    public var accelerationSelection: ViewportAccelerationSelection {
        accelerationSelectionStorage
    }

    public var pickingNormalTexture: Texture? {
        pickingNormalTextureStorage
    }

    public var pickingDepthTexture: Texture? {
        pickingDepthTextureStorage
    }

    public var pickingDepthReadbackTexture: Texture? {
        pickingDepthReadbackTextureStorage
    }

    public var pickingNormalReadbackTexture: Texture? {
        pickingNormalReadbackTextureStorage
    }

    public func configurePicking(
        _ configuration: ViewportPickingConfiguration
    ) -> ViewportAccelerationSelection {
        pickingConfigurationStorage = configuration
        accelerationSelectionStorage = selectPickingAcceleration(
            configuration
        )
        pickingSelectionStorage = selectPickingPath(configuration)
        pickingTextureStorage = nil
        pickingReadbackTextureStorage = nil
        pickingDepthTextureStorage = nil
        pickingDepthReadbackTextureStorage = nil
        pickingNormalTextureStorage = nil
        pickingNormalReadbackTextureStorage = nil
        pickingABufferHeadStorage = nil
        pickingABufferNodeStorage = nil
        pickingABufferNodeCapacityStorage = 0
        errorDescriptionStorage = ""
        return accelerationSelectionStorage
    }

    public func attachRenderer(_ renderer: Renderer) -> Bool {
        guard isActive else {
            errorDescriptionStorage = "The viewport is shut down."
            return false
        }
        rendererStorage = renderer
        errorDescriptionStorage = ""
        return true
    }

    public func clearRenderer() {
        rendererStorage = nil
    }

    public func addFeature(_ feature: ViewportFeature) -> UInt64 {
        guard isActive,
              !featureOrder.contains(where: { id in
                  guard let existing = features[id] else {
                      return false
                  }
                  return existing === feature
              }),
              feature.attach(to: extentStorage) else {
            errorDescriptionStorage =
                "The feature is invalid or already attached."
            return 0
        }
        let id = nextFeatureID
        nextFeatureID += 1
        features[id] = feature
        featureOrder.append(id)
        errorDescriptionStorage = ""
        return id
    }

    public func addAxesFeature(_ name: String) -> UInt64 {
        addFeature(ViewportFeature.axes(name: name))
    }

    public func addGridFeature(_ name: String) -> UInt64 {
        addFeature(ViewportFeature.grid(name: name))
    }

    public func addObjectPickingFeature(_ name: String) -> UInt64 {
        addFeature(ViewportFeature.objectPicking(name: name))
    }

    public func addVertexPickingFeature(_ name: String) -> UInt64 {
        addFeature(ViewportFeature.vertexPicking(name: name))
    }

    public func removeFeature(_ id: UInt64) -> Bool {
        guard let feature = features.removeValue(forKey: id) else {
            return false
        }
        feature.detach()
        featureOrder.removeAll { $0 == id }
        return true
    }

    public func clearFeatures() {
        for feature in features.values {
            feature.detach()
        }
        features.removeAll()
        featureOrder.removeAll()
    }

    public func feature(_ id: UInt64) -> ViewportFeature? {
        features[id]
    }

    public func featureAt(_ index: UInt32) -> ViewportFeature? {
        guard index < UInt32(featureOrder.count) else {
            return nil
        }
        return features[featureOrder[Int(index)]]
    }

    public func registerFeatureExtension(
        _ featureExtension: ViewportFeatureExtension
    ) -> Bool {
        guard isActive,
              !featureExtension.name.isEmpty,
              extensions[featureExtension.name] == nil,
              extensionOrder.count < Int(UInt32.max) else {
            errorDescriptionStorage =
                "Viewport extension names must be unique and non-empty."
            return false
        }
        extensions[featureExtension.name] = featureExtension
        extensionOrder.append(featureExtension.name)
        errorDescriptionStorage = ""
        return true
    }

    public func featureExtension(
        _ name: String
    ) -> ViewportFeatureExtension? {
        extensions[name]
    }

    public func featureExtensionAt(
        _ index: UInt32
    ) -> ViewportFeatureExtension? {
        guard index < UInt32(extensionOrder.count) else {
            return nil
        }
        return extensions[extensionOrder[Int(index)]]
    }

    public func updateFeatureExtension(
        _ featureExtension: ViewportFeatureExtension
    ) -> Bool {
        guard !featureExtension.name.isEmpty,
              extensions[featureExtension.name] != nil else {
            return false
        }
        extensions[featureExtension.name] = featureExtension
        return true
    }

    public func removeFeatureExtension(_ name: String) -> Bool {
        guard extensions.removeValue(forKey: name) != nil else {
            return false
        }
        extensionOrder.removeAll { $0 == name }
        return true
    }

    public func featureExtensionIsSupported(_ name: String) -> Bool {
        guard let featureExtension = extensions[name] else {
            return false
        }
        for rawValue in 0..<UInt32(DeviceFeature.fragmentAtomics.rawValue + 1) {
            let mask = UInt32(1) << rawValue
            guard featureExtension.requiredFeatures & mask != 0 else {
                continue
            }
            guard let feature = DeviceFeature(rawValue: Int32(rawValue)),
                  device.capabilities.availability(for: feature).isUsable
            else {
                return false
            }
        }
        return true
    }

    public func resize(width: UInt32, height: UInt32) -> Bool {
        guard isActive, width > 0, height > 0 else {
            errorDescriptionStorage =
                "Viewport resize requires a positive active extent."
            return false
        }

        let oldExtent = extentStorage
        extentStorage = Extent(width: width, height: height)
        if pickingTextureStorage != nil,
           !ensurePickingTargets() {
            extentStorage = oldExtent
            return false
        }

        for id in featureOrder {
            guard let feature = features[id], feature.resize(to: extentStorage)
            else {
                errorDescriptionStorage =
                    "A viewport feature rejected the resize."
                return false
            }
        }
        resizeGenerationStorage += 1
        errorDescriptionStorage = ""
        return true
    }

    public func update(_ update: ViewportUpdate) -> Bool {
        guard isActive,
              update.timeSeconds.isFinite,
              update.camera.nearPlane.isFinite,
              update.camera.farPlane.isFinite,
              update.camera.nearPlane > 0,
              update.camera.farPlane > update.camera.nearPlane else {
            errorDescriptionStorage = "The viewport update is invalid."
            return false
        }
        for id in featureOrder {
            guard let feature = features[id], feature.update(update) else {
                errorDescriptionStorage =
                    "A viewport feature rejected the update."
                return false
            }
        }
        updateStorage = update
        errorDescriptionStorage = ""
        return true
    }

    public func handleInput(_ event: HostInputEvent) -> Bool {
        guard isActive || event.kind == .close else {
            errorDescriptionStorage = "The viewport is shut down."
            return false
        }
        switch event.kind {
        case .pointerMoved:
            guard event.x.isFinite, event.y.isFinite else {
                errorDescriptionStorage =
                    "Pointer coordinates must be finite."
                return false
            }
            pointerPositionStorage = Vector2(
                x: Float(event.x),
                y: Float(event.y)
            )
        case .pointerButton:
            guard event.x.isFinite, event.y.isFinite else {
                errorDescriptionStorage =
                    "Pointer coordinates must be finite."
                return false
            }
            pointerPositionStorage = Vector2(
                x: Float(event.x),
                y: Float(event.y)
            )
            lastButtonStorage = event.button
            buttonPressedStorage = event.pressed
        case .scroll:
            guard event.deltaX.isFinite, event.deltaY.isFinite else {
                errorDescriptionStorage = "Scroll deltas must be finite."
                return false
            }
            scrollDeltaStorage = Vector2(
                x: Float(event.deltaX),
                y: Float(event.deltaY)
            )
        case .key:
            break
        case .resize:
            return resize(width: event.width, height: event.height)
        case .close:
            closedStorage = true
        case .focus:
            focusedStorage = event.focused
        }
        errorDescriptionStorage = ""
        return true
    }

    public func record(
        _ commandBuffer: CommandBuffer,
        renderPass: RenderPassDescriptor,
        view: RenderView
    ) -> Bool {
        guard isActive,
              view.viewport.width > 0,
              view.viewport.height > 0,
              view.timeSeconds.isFinite else {
            errorDescriptionStorage = "The viewport render view is invalid."
            return false
        }

        for id in featureOrder {
            guard let feature = features[id],
                  feature.record(.scene) else {
                errorDescriptionStorage =
                    "A scene viewport feature rejected recording."
                return false
            }
        }
        if let rendererStorage,
           !rendererStorage.record(
               commandBuffer,
               renderPass: renderPass,
               view: view
           ) {
            errorDescriptionStorage = rendererStorage.errorDescription
            return false
        }
        errorDescriptionStorage = ""
        return true
    }

    public func recordOverlay(
        _ commandBuffer: CommandBuffer,
        renderPass: RenderPassDescriptor,
        view: RenderView
    ) -> Bool {
        guard isActive,
              view.viewport.width > 0,
              view.viewport.height > 0,
              view.timeSeconds.isFinite else {
            errorDescriptionStorage = "The viewport overlay view is invalid."
            return false
        }

        let hasOverlay = featureOrder.contains { id in
            guard let feature = features[id] else {
                return false
            }
            return feature.enabled &&
                feature.visible &&
                feature.phase == .screenOverlay
        }
        guard hasOverlay else {
            return true
        }

        renderPass.colorLoadAction = .load
        renderPass.colorStoreAction = .store
        guard let encoder = commandBuffer.makeRenderEncoder(renderPass) else {
            errorDescriptionStorage = commandBuffer.errorDescription
            return false
        }
        guard encoder.setViewport(view.viewport) else {
            _ = encoder.endEncoding()
            errorDescriptionStorage = "Failed to set the viewport overlay extent."
            return false
        }
        for id in featureOrder {
            guard let feature = features[id],
                  feature.recordGPU(
                      .screenOverlay,
                      encoder: encoder,
                      camera: updateStorage.camera,
                      colorFormat: renderPass.colorFormat,
                      device: device
                  ) else {
                _ = encoder.endEncoding()
                errorDescriptionStorage =
                    "An overlay viewport feature rejected recording."
                return false
            }
        }
        guard encoder.endEncoding() else {
            errorDescriptionStorage =
                "Failed to end the viewport overlay encoder."
            return false
        }
        errorDescriptionStorage = ""
        return true
    }

    public var sceneObjectIDCount: UInt32 {
        UInt32(min(sceneObjectNamesStorage.count, Int(UInt32.max)))
    }

    public func synchronizeSceneObjectIDs(_ scene: Scene) -> UInt32 {
        guard isActive else {
            errorDescriptionStorage = "The viewport is shut down."
            return 0
        }
        var currentNames = Set<String>()
        for index in 0..<scene.objectCount {
            guard let object = scene.objectAt(index) else {
                continue
            }
            currentNames.insert(object.name)
            if objectIDs[object.name] == nil {
                if let historicalID = sceneObjectIDHistory[object.name],
                   objectNames[historicalID] == nil {
                    objectIDs[object.name] = historicalID
                    objectNames[historicalID] = object.name
                } else {
                    guard registerObject(object.name) != 0 else {
                        return UInt32(currentNames.count)
                    }
                }
            }
            sceneObjectIDHistory[object.name] = objectIDs[object.name] ?? 0
        }
        for name in sceneObjectNamesStorage.subtracting(currentNames) {
            _ = unregisterObject(name)
        }
        sceneObjectNamesStorage = currentNames
        errorDescriptionStorage = ""
        return UInt32(min(currentNames.count, Int(UInt32.max)))
    }

    public func recordPicking(
        _ commandBuffer: CommandBuffer,
        scene: Scene,
        drawables: DrawableManager,
        renderPass: RenderPassDescriptor? = nil,
        mode: ViewportPickMode = .object,
        camera: ViewportCamera? = nil,
        visibilityMask: UInt32 = UInt32.max
    ) -> Bool {
        guard isActive,
              extentStorage.width > 0,
              extentStorage.height > 0,
              !commandBuffer.isCommitted,
              !commandBuffer.hasActiveEncoder,
              pendingPickStorage == nil,
              pendingABufferPickStorage == nil else {
            errorDescriptionStorage =
                "The viewport picking request is invalid or busy."
            return false
        }
        guard ensurePickingTargets() else {
            return false
        }
        guard synchronizeSceneObjectIDs(scene) > 0 || scene.objectCount == 0
        else {
            return false
        }
        let descriptor: RenderPassDescriptor
        let generatedDescriptor: Bool
        if let renderPass {
            descriptor = renderPass
            generatedDescriptor = false
        } else {
            guard let generated = makePickingRenderPass() else {
                return false
            }
            descriptor = generated
            generatedDescriptor = true
        }
        if let normalFormat = descriptor.colorFormat(at: 1),
           normalFormat != .rgba32Float {
            errorDescriptionStorage =
                "Viewport normal picking requires RGBA32Float attachment 1."
            return false
        }
        if !generatedDescriptor {
            for id in featureOrder {
                guard let feature = features[id],
                      feature.record(.picking) else {
                    errorDescriptionStorage =
                        "A picking viewport feature rejected recording."
                    return false
                }
            }
        }
        var usesABuffer =
            pickingSelectionStorage.selectedPath == .aBuffer
        var pipeline = preparePickingPipeline(
            colorFormat: descriptor.colorFormat,
            hasNormalAttachment: descriptor.colorFormat(at: 1) != nil,
            usesABuffer: usesABuffer
        )
        if pipeline == nil, usesABuffer {
            pickingSelectionStorage = ViewportPickingSelection(
                requestedPath: pickingSelectionStorage.requestedPath,
                selectedPath: .baseline,
                fallbackReason: .resourcesUnavailable,
                fallbackAvailable: true
            )
            usesABuffer = false
            pipeline = preparePickingPipeline(
                colorFormat: descriptor.colorFormat,
                hasNormalAttachment: descriptor.colorFormat(at: 1) != nil,
                usesABuffer: false
            )
        }
        guard let pipeline,
        let encoder = commandBuffer.makeRenderEncoder(descriptor),
        encoder.setViewport(extentStorage) else {
            errorDescriptionStorage = commandBuffer.errorDescription
            return false
        }
        if descriptor.hasDepthAttachment {
            let depthState = usesABuffer
                ? pickingABufferDepthStateStorage
                : pickingDepthStateStorage
            guard let depthState,
                  encoder.setDepthStencilState(depthState) else {
                _ = encoder.endEncoding()
                errorDescriptionStorage =
                    "The viewport picking depth state could not be bound."
                return false
            }
        }
        if usesABuffer {
            guard let headBuffer = pickingABufferHeadStorage,
                  let nodeBuffer = pickingABufferNodeStorage,
                  resetABufferStorage(),
                  let parameters = makeABufferParameters(),
                  commandBuffer.retainResource(headBuffer),
                  commandBuffer.retainResource(nodeBuffer),
                  encoder.setFragmentBuffer(
                      headBuffer,
                      offset: viewportABufferHeaderBytes,
                      index: 2
                  ),
                  encoder.setFragmentBuffer(
                      nodeBuffer,
                      offset: viewportABufferHeaderBytes,
                      index: 3
                  ),
                  encoder.setFragmentBuffer(
                      nodeBuffer,
                      offset: 0,
                      index: 4
                  ),
                  encoder.setFragmentBytes(parameters, index: 5) else {
                _ = encoder.endEncoding()
                errorDescriptionStorage =
                    "The viewport A-buffer bindings could not be encoded."
                return false
            }
        }
        let activeCamera = camera ?? updateStorage.camera
        let cameraMatrix = viewportCameraMatrix(activeCamera)
        for index in 0..<scene.objectCount {
            guard let object = scene.objectAt(index),
                  object.enabled,
                  object.visibilityMask & visibilityMask != 0 else {
                continue
            }
            let objectID = objectIDs[object.name] ?? 0
            guard objectID != 0,
                  let mesh = drawables.mesh(object.meshName),
                  let meshGPU = drawables.uploadMesh(
                      object.meshName,
                      device: device,
                      storageMode: .shared,
                      label: "mt.viewport.picking"
                  ) else {
                _ = encoder.endEncoding()
                errorDescriptionStorage =
                    "A visible scene object has no synchronized mesh."
                return false
            }
            let view = object.meshView ?? mesh.makeView()
            guard view.validate(
                vertexCount: meshGPU.vertexCount,
                indexCount: meshGPU.indexCount
            ) else {
                _ = encoder.endEncoding()
                errorDescriptionStorage =
                    "A scene mesh view is outside the synchronized mesh."
                return false
            }
            let frame = ViewportPickFrameData(
                modelViewProjection: viewportMultiply(
                    cameraMatrix,
                    viewportTransformMatrix(object.transform)
                ),
                objectID: objectID,
                mode: mode,
                pointSize: pickingConfigurationStorage.vertexPointSize
            ).makeParameterBlock()
            guard encoder.setRenderPipeline(pipeline),
                  encoder.setVertexBuffer(
                      meshGPU.vertexBuffer,
                      offset: 0,
                      index: 0
                  ),
                  encoder.setVertexBytes(frame, index: 1) else {
                _ = encoder.endEncoding()
                errorDescriptionStorage =
                    "The viewport picking bindings could not be encoded."
                return false
            }
            let didDraw: Bool
            if mode == .vertex {
                didDraw = encoder.drawPrimitives(
                    primitiveType: .point,
                    vertexStart: view.vertexOffset,
                    vertexCount: view.vertexCount,
                    instanceCount: 1,
                    baseInstance: 0
                )
            } else if let indexBuffer = meshGPU.indexBuffer,
                      view.indexCount > 0 {
                let indexStride: UInt64 =
                    meshGPU.indexType == .uint16 ? 2 : 4
                didDraw = encoder.drawIndexedPrimitives(
                    primitiveType: meshGPU.primitiveType,
                    indexType: meshGPU.indexType,
                    indexBuffer: indexBuffer,
                    indexBufferOffset: UInt64(view.indexOffset)
                        * indexStride,
                    indexCount: view.indexCount,
                    instanceCount: 1,
                    baseVertex: view.baseVertex,
                    baseInstance: 0
                )
            } else {
                didDraw = encoder.drawPrimitives(
                    primitiveType: meshGPU.primitiveType,
                    vertexStart: view.vertexOffset,
                    vertexCount: view.vertexCount,
                    instanceCount: 1,
                    baseInstance: 0
                )
            }
            guard didDraw else {
                _ = encoder.endEncoding()
                errorDescriptionStorage =
                    "The viewport picking draw could not be encoded."
                return false
            }
        }
        guard encoder.endEncoding() else {
            errorDescriptionStorage =
                "The viewport picking encoder could not end."
            return false
        }
        errorDescriptionStorage = ""
        return true
    }

    public func makeVertexCandidates(
        scene: Scene,
        drawables: DrawableManager,
        camera: ViewportCamera? = nil,
        visibilityMask: UInt32 = UInt32.max
    ) -> [ViewportVertexCandidate] {
        guard isActive, extentStorage.width > 0, extentStorage.height > 0
        else {
            return []
        }
        _ = synchronizeSceneObjectIDs(scene)
        let activeCamera = camera ?? updateStorage.camera
        let cameraMatrix = viewportCameraMatrix(activeCamera)
        var candidates: [ViewportVertexCandidate] = []
        for index in 0..<scene.objectCount {
            guard let object = scene.objectAt(index),
                  object.enabled,
                  object.visibilityMask & visibilityMask != 0,
                  let objectID = objectIDs[object.name],
                  let mesh = drawables.mesh(object.meshName) else {
                continue
            }
            let view = object.meshView ?? mesh.makeView()
            let model = viewportTransformMatrix(object.transform)
            let matrix = viewportMultiply(cameraMatrix, model)
            let end = min(
                mesh.vertexCount,
                view.vertexOffset &+ view.vertexCount
            )
            guard view.vertexOffset < end else {
                continue
            }
            for vertexIndex in view.vertexOffset..<end {
                guard let vertex = mesh.vertex(at: vertexIndex),
                      let projected = viewportProject(
                          vertex.position,
                          matrix: matrix,
                          extent: extentStorage
                      ) else {
                    continue
                }
                candidates.append(
                    ViewportVertexCandidate(
                        objectID: objectID,
                        vertexID: vertexIndex,
                        screenPosition: projected.position,
                        depth: projected.depth
                    )
                )
            }
        }
        return candidates
    }

    public func selectNearestVertex(
        candidates: [ViewportVertexCandidate],
        x: Float,
        y: Float,
        maxDistance: Float
    ) -> ViewportVertexSelectionResult {
        let limit = maxDistance.isFinite && maxDistance >= 0
            ? maxDistance * maxDistance
            : Float.greatestFiniteMagnitude
        var best: ViewportVertexCandidate?
        var bestDistance = Float.greatestFiniteMagnitude
        for candidate in candidates {
            guard candidate.screenPosition.x.isFinite,
                  candidate.screenPosition.y.isFinite,
                  candidate.depth.isFinite,
                  x.isFinite,
                  y.isFinite else {
                continue
            }
            let dx = candidate.screenPosition.x - x
            let dy = candidate.screenPosition.y - y
            let distance = dx * dx + dy * dy
            guard distance <= limit else {
                continue
            }
            let isBetter: Bool
            if distance < bestDistance {
                isBetter = true
            } else if distance > bestDistance, best != nil {
                isBetter = false
            } else if let current = best {
                isBetter =
                    candidate.depth < current.depth
                    || (
                        candidate.depth == current.depth
                        && (
                            candidate.objectID < current.objectID
                            || (
                                candidate.objectID == current.objectID
                                && candidate.vertexID < current.vertexID
                            )
                        )
                    )
            } else {
                isBetter = true
            }
            if isBetter {
                best = candidate
                bestDistance = distance
            }
        }
        guard let best else {
            return ViewportVertexSelectionResult(
                objectID: 0,
                vertexID: 0,
                distanceSquared: 0,
                depth: 0,
                hit: false
            )
        }
        return ViewportVertexSelectionResult(
            objectID: best.objectID,
            vertexID: best.vertexID,
            distanceSquared: bestDistance,
            depth: best.depth,
            hit: true
        )
    }

    public func registerObject(_ name: String) -> UInt32 {
        guard isActive, !name.isEmpty, objectIDs[name] == nil else {
            errorDescriptionStorage =
                "Object names must be non-empty and unique."
            return 0
        }
        guard nextObjectIDStorage != 0 else {
            errorDescriptionStorage = "The viewport object ID space is full."
            return 0
        }
        let id = nextObjectIDStorage
        if id == UInt32.max {
            nextObjectIDStorage = 0
        } else {
            nextObjectIDStorage += 1
        }
        objectIDs[name] = id
        objectNames[id] = name
        errorDescriptionStorage = ""
        return id
    }

    public func unregisterObject(_ name: String) -> Bool {
        guard let id = objectIDs.removeValue(forKey: name) else {
            return false
        }
        objectNames[id] = nil
        return true
    }

    public func objectID(_ name: String) -> UInt32 {
        objectIDs[name] ?? 0
    }

    public func objectName(_ id: UInt32) -> String {
        objectNames[id] ?? ""
    }

    public func makePickingRenderPass() -> RenderPassDescriptor? {
        guard isActive, extentStorage.width > 0, extentStorage.height > 0,
              ensurePickingTargets(),
              let colorTexture = pickingTextureStorage else {
            if errorDescriptionStorage.isEmpty {
                errorDescriptionStorage =
                    "Picking requires a positive viewport extent."
            }
            return nil
        }

        let descriptor = RenderPassDescriptor(colorTexture: colorTexture)
        descriptor.label = "mt viewport picking"
        descriptor.clearColor = ClearColor(
            red: 0,
            green: 0,
            blue: 0,
            alpha: 0
        )
        descriptor.colorLoadAction = .clear
        descriptor.colorStoreAction = .store
        if let depthTexture = pickingDepthTextureStorage {
            let depth = DepthAttachment(
                texture: depthTexture,
                loadAction: .clear,
                storeAction: pickingConfigurationStorage.captureDepth
                    ? .store
                    : .dontCare,
                clearDepth: 1
            )
            guard descriptor.setDepthAttachment(depth) else {
                errorDescriptionStorage = descriptor.validationError
                return nil
            }
        }
        if let normalTexture = pickingNormalTextureStorage {
            guard descriptor.setColorAttachment(
                normalTexture,
                index: 1
            ),
            descriptor.configureColorAttachment(
                index: 1,
                loadAction: .clear,
                storeAction: .store,
                clearColor: ClearColor(
                    red: 0,
                    green: 0,
                    blue: 1,
                    alpha: 1
                )
            ) else {
                errorDescriptionStorage = descriptor.validationError
                return nil
            }
        }
        for id in featureOrder {
            guard let feature = features[id],
                  feature.record(.picking) else {
                errorDescriptionStorage =
                    "A picking viewport feature rejected recording."
                return nil
            }
        }
        errorDescriptionStorage = ""
        return descriptor
    }

    public func schedulePickReadback(
        _ commandBuffer: CommandBuffer,
        request: ViewportPickRequest
    ) -> Bool {
        guard isActive,
              pendingPickStorage == nil,
              pendingABufferPickStorage == nil,
              !commandBuffer.isCommitted,
              !commandBuffer.hasActiveEncoder,
              request.x < extentStorage.width,
              request.y < extentStorage.height else {
            errorDescriptionStorage =
                "The viewport pick readback request is invalid or busy."
            return false
        }
        guard ensurePickingTargets() else {
            return false
        }
        if request.mode == .vertex {
            guard request.objectID != 0,
                  objectNames[request.objectID] != nil else {
                errorDescriptionStorage =
                    "Vertex picking requires a registered object ID."
                return false
            }
        }
        if pickingSelectionStorage.selectedPath == .aBuffer {
            guard let headBuffer = pickingABufferHeadStorage,
                  let nodeBuffer = pickingABufferNodeStorage,
                  commandBuffer.retainResource(headBuffer),
                  commandBuffer.retainResource(nodeBuffer) else {
                errorDescriptionStorage =
                    "The viewport A-buffer readback is unavailable."
                return false
            }
            pendingABufferPickStorage = PendingABufferPick(
                commandBuffer: commandBuffer,
                headBuffer: headBuffer,
                nodeBuffer: nodeBuffer,
                width: extentStorage.width,
                height: extentStorage.height,
                nodeCapacity: pickingABufferNodeCapacityStorage,
                request: request
            )
            errorDescriptionStorage = ""
            return true
        }
        guard let texture = pickingTextureStorage,
              let readbackTexture = pickingReadbackTextureStorage else {
            errorDescriptionStorage =
                "The viewport pick readback targets are unavailable."
            return false
        }
        guard !request.includeDepth
                || (pickingConfigurationStorage.captureDepth
                    && pickingDepthTextureStorage != nil
                    && pickingDepthReadbackTextureStorage != nil),
              !request.includeNormal
                || (pickingConfigurationStorage.captureNormal
                    && pickingNormalTextureStorage != nil
                    && pickingNormalReadbackTextureStorage != nil) else {
            errorDescriptionStorage =
                "The requested picking attachment was not configured."
            return false
        }
        guard let blit = commandBuffer.makeBlitEncoder() else {
            errorDescriptionStorage = commandBuffer.errorDescription
            return false
        }
        guard blit.copyTexture(
            source: texture,
            destination: readbackTexture
        ) else {
            _ = blit.endEncoding()
            errorDescriptionStorage =
                "The viewport could not schedule the picking texture copy."
            return false
        }
        if request.includeDepth,
           let depthTexture = pickingDepthTextureStorage,
           let depthReadback = pickingDepthReadbackTextureStorage,
           !blit.copyTexture(
               source: depthTexture,
               destination: depthReadback
           ) {
            _ = blit.endEncoding()
            errorDescriptionStorage =
                "The viewport could not schedule the depth copy."
            return false
        }
        if request.includeNormal,
           let normalTexture = pickingNormalTextureStorage,
           let normalReadback = pickingNormalReadbackTextureStorage,
           !blit.copyTexture(
               source: normalTexture,
               destination: normalReadback
           ) {
            _ = blit.endEncoding()
            errorDescriptionStorage =
                "The viewport could not schedule the normal copy."
            return false
        }
        guard blit.endEncoding() else {
            errorDescriptionStorage =
                "The viewport could not end the picking readback encoder."
            return false
        }
        pendingPickStorage = PendingPick(
            commandBuffer: commandBuffer,
            sourceTexture: texture,
            texture: readbackTexture,
            sourceDepthTexture: request.includeDepth
                ? pickingDepthTextureStorage
                : nil,
            depthTexture: request.includeDepth
                ? pickingDepthReadbackTextureStorage
                : nil,
            sourceNormalTexture: request.includeNormal
                ? pickingNormalTextureStorage
                : nil,
            normalTexture: request.includeNormal
                ? pickingNormalReadbackTextureStorage
                : nil,
            request: request
        )
        errorDescriptionStorage = ""
        return true
    }

    public func pollPickResult() -> ViewportPickResult? {
        if let pending = pendingABufferPickStorage {
            switch pending.commandBuffer.status {
            case .error:
                errorDescriptionStorage = pending.commandBuffer.errorDescription
                pendingABufferPickStorage = nil
                return nil
            case .completed:
                break
            default:
                return nil
            }
            let result = readABufferPickResult(pending)
            pendingABufferPickStorage = nil
            return result
        }
        guard let pending = pendingPickStorage else {
            return nil
        }
        switch pending.commandBuffer.status {
        case .error:
            errorDescriptionStorage = pending.commandBuffer.errorDescription
            pendingPickStorage = nil
            return nil
        case .completed:
            break
        default:
            return nil
        }

        let result = readPickResult(pending)
        pendingPickStorage = nil
        return result
    }

    public func shutdown() {
        clearFeatures()
        extensions.removeAll()
        extensionOrder.removeAll()
        sceneObjectNamesStorage.removeAll()
        sceneObjectIDHistory.removeAll()
        rendererStorage = nil
        pendingPickStorage = nil
        pendingABufferPickStorage = nil
        stateStorage = .shutDown
    }

    private func ensurePickingTargets() -> Bool {
        guard extentStorage.width > 0, extentStorage.height > 0 else {
            errorDescriptionStorage =
                "Picking targets require a positive viewport extent."
            return false
        }
        if let color = pickingTextureStorage,
           color.width == extentStorage.width,
           color.height == extentStorage.height,
           let readback = pickingReadbackTextureStorage,
           readback.width == extentStorage.width,
           readback.height == extentStorage.height,
           let depth = pickingDepthTextureStorage,
           depth.width == extentStorage.width,
           depth.height == extentStorage.height,
           (!pickingConfigurationStorage.captureDepth
                || (pickingDepthReadbackTextureStorage?.width
                    == extentStorage.width
                    && pickingDepthReadbackTextureStorage?.height
                    == extentStorage.height)),
           (!pickingConfigurationStorage.captureNormal
                || (pickingNormalTextureStorage?.width
                    == extentStorage.width
                    && pickingNormalTextureStorage?.height
                    == extentStorage.height
                    && pickingNormalReadbackTextureStorage?.width
                    == extentStorage.width
                    && pickingNormalReadbackTextureStorage?.height
                    == extentStorage.height)) {
            if pickingSelectionStorage.selectedPath != .aBuffer
                || hasABufferStorageForCurrentExtent() {
                return true
            }
        }

        let colorDescriptor = TextureDescriptor(
            textureType: .twoD,
            pixelFormat: .rgba8Unorm,
            width: extentStorage.width,
            height: extentStorage.height,
            depth: 1,
            arrayLength: 1,
            mipLevelCount: 1,
            sampleCount: 1,
            usage: UInt32(TextureUsage.renderTarget.rawValue),
            storageMode: .gpuPrivate,
            cpuCacheMode: .defaultCache,
            hazardMode: .defaultMode,
            label: "mt viewport picking IDs"
        )
        let readbackDescriptor = TextureDescriptor(
            textureType: .twoD,
            pixelFormat: .rgba8Unorm,
            width: extentStorage.width,
            height: extentStorage.height,
            depth: 1,
            arrayLength: 1,
            mipLevelCount: 1,
            sampleCount: 1,
            usage: UInt32(TextureUsage.shaderRead.rawValue),
            storageMode: .shared,
            cpuCacheMode: .defaultCache,
            hazardMode: .defaultMode,
            label: "mt viewport picking readback"
        )
        let depthDescriptor = TextureDescriptor(
            textureType: .twoD,
            pixelFormat: .depth32Float,
            width: extentStorage.width,
            height: extentStorage.height,
            depth: 1,
            arrayLength: 1,
            mipLevelCount: 1,
            sampleCount: 1,
            usage: UInt32(TextureUsage.renderTarget.rawValue),
            storageMode: accelerationSelectionStorage.selectedPath
                    == .memoryless
                ? .memoryless
                : .gpuPrivate,
            cpuCacheMode: .defaultCache,
            hazardMode: .defaultMode,
            label: "mt viewport picking depth"
        )
        guard let color = device.createTexture(colorDescriptor),
              let readback = device.createTexture(readbackDescriptor),
              let depth = device.createTexture(depthDescriptor) else {
            errorDescriptionStorage = "Metal could not allocate picking targets."
            return false
        }
        var depthReadback: Texture?
        if pickingConfigurationStorage.captureDepth {
            let descriptor = TextureDescriptor(
                textureType: .twoD,
                pixelFormat: .depth32Float,
                width: extentStorage.width,
                height: extentStorage.height,
                depth: 1,
                arrayLength: 1,
                mipLevelCount: 1,
                sampleCount: 1,
                usage: UInt32(TextureUsage.shaderRead.rawValue),
                storageMode: .shared,
                cpuCacheMode: .defaultCache,
                hazardMode: .defaultMode,
                label: "mt viewport picking depth readback"
            )
            guard let created = device.createTexture(descriptor) else {
                errorDescriptionStorage =
                    "Metal could not allocate the picking depth readback."
                return false
            }
            depthReadback = created
        }
        var normal: Texture?
        var normalReadback: Texture?
        if pickingConfigurationStorage.captureNormal {
            let descriptor = TextureDescriptor(
                textureType: .twoD,
                pixelFormat: .rgba32Float,
                width: extentStorage.width,
                height: extentStorage.height,
                depth: 1,
                arrayLength: 1,
                mipLevelCount: 1,
                sampleCount: 1,
                usage: UInt32(TextureUsage.renderTarget.rawValue),
                storageMode: .gpuPrivate,
                cpuCacheMode: .defaultCache,
                hazardMode: .defaultMode,
                label: "mt viewport picking normals"
            )
            let readbackDescriptor = TextureDescriptor(
                textureType: .twoD,
                pixelFormat: .rgba32Float,
                width: extentStorage.width,
                height: extentStorage.height,
                depth: 1,
                arrayLength: 1,
                mipLevelCount: 1,
                sampleCount: 1,
                usage: UInt32(TextureUsage.shaderRead.rawValue),
                storageMode: .shared,
                cpuCacheMode: .defaultCache,
                hazardMode: .defaultMode,
                label: "mt viewport picking normal readback"
            )
            guard let created = device.createTexture(descriptor),
                  let createdReadback =
                    device.createTexture(readbackDescriptor) else {
                errorDescriptionStorage =
                    "Metal could not allocate picking normal attachments."
                return false
            }
            normal = created
            normalReadback = createdReadback
        }
        pickingTextureStorage = color
        pickingReadbackTextureStorage = readback
        pickingDepthTextureStorage = depth
        pickingDepthReadbackTextureStorage = depthReadback
        pickingNormalTextureStorage = normal
        pickingNormalReadbackTextureStorage = normalReadback
        if pickingSelectionStorage.selectedPath == .aBuffer,
           !ensureABufferStorage() {
            pickingSelectionStorage = ViewportPickingSelection(
                requestedPath: pickingSelectionStorage.requestedPath,
                selectedPath: .baseline,
                fallbackReason: .resourcesUnavailable,
                fallbackAvailable: true
            )
            pickingABufferHeadStorage = nil
            pickingABufferNodeStorage = nil
            pickingABufferNodeCapacityStorage = 0
        }
        return true
    }

    private func requestedABufferCapacity() -> UInt32? {
        let nodesPerPixel = UInt64(
            pickingConfigurationStorage.aBufferNodesPerPixel
        )
        let maxNodes = UInt64(
            pickingConfigurationStorage.aBufferMaxNodes
        )
        guard nodesPerPixel > 0, maxNodes > 0 else {
            return nil
        }
        let pixelCount = UInt64(extentStorage.width)
            * UInt64(extentStorage.height)
        guard pixelCount > 0,
              pixelCount <= UInt64.max / nodesPerPixel else {
            return nil
        }
        let capacity = pixelCount * nodesPerPixel
        guard capacity <= maxNodes,
              capacity <= UInt64(UInt32.max) else {
            return nil
        }
        return UInt32(capacity)
    }

    private func hasABufferStorageForCurrentExtent() -> Bool {
        guard let capacity = requestedABufferCapacity(),
              let headBuffer = pickingABufferHeadStorage,
              let nodeBuffer = pickingABufferNodeStorage else {
            return false
        }
        let pixelCount = UInt64(extentStorage.width)
            * UInt64(extentStorage.height)
        guard pixelCount <= (UInt64.max - viewportABufferHeaderBytes) / 4,
              capacity <= UInt32.max else {
            return false
        }
        let headBytes = viewportABufferHeaderBytes + pixelCount * 4
        guard capacity <= UInt32.max / UInt32(viewportABufferNodeStride)
        else {
            return false
        }
        let nodeBytes = viewportABufferHeaderBytes
            + UInt64(capacity) * viewportABufferNodeStride
        return pickingABufferNodeCapacityStorage == capacity
            && headBuffer.length == headBytes
            && nodeBuffer.length == nodeBytes
    }

    private func ensureABufferStorage() -> Bool {
        guard let capacity = requestedABufferCapacity() else {
            errorDescriptionStorage =
                "The viewport A-buffer capacity is invalid or exceeds its "
                + "configured limit."
            return false
        }
        let pixelCount = UInt64(extentStorage.width)
            * UInt64(extentStorage.height)
        guard pixelCount <= (UInt64.max - viewportABufferHeaderBytes) / 4,
              UInt64(capacity)
                    <= (UInt64.max - viewportABufferHeaderBytes)
                        / viewportABufferNodeStride else {
            errorDescriptionStorage =
                "The viewport A-buffer extent is too large."
            return false
        }
        let headBytes = viewportABufferHeaderBytes + pixelCount * 4
        let nodeBytes = viewportABufferHeaderBytes
            + UInt64(capacity) * viewportABufferNodeStride
        guard headBytes <= UInt64(Int.max),
              nodeBytes <= UInt64(Int.max),
              headBytes <= device.capabilities.maxBufferLength,
              nodeBytes <= device.capabilities.maxBufferLength else {
            errorDescriptionStorage =
                "The viewport A-buffer exceeds the device buffer limit."
            return false
        }
        if hasABufferStorageForCurrentExtent() {
            return resetABufferStorage()
        }

        let usage = UInt32(
            BufferUsage.storage.rawValue | BufferUsage.readback.rawValue
        )
        let descriptor = BufferDescriptor(
            length: headBytes,
            usage: usage,
            storageMode: .shared,
            cpuCacheMode: .defaultCache,
            hazardMode: .defaultMode,
            label: "mt viewport A-buffer heads"
        )
        let nodeDescriptor = BufferDescriptor(
            length: nodeBytes,
            usage: usage,
            storageMode: .shared,
            cpuCacheMode: .defaultCache,
            hazardMode: .defaultMode,
            label: "mt viewport A-buffer nodes"
        )
        guard let headBuffer = device.createBuffer(descriptor),
              let nodeBuffer = device.createBuffer(nodeDescriptor) else {
            errorDescriptionStorage =
                "Metal could not allocate the viewport A-buffer."
            return false
        }
        pickingABufferHeadStorage = headBuffer
        pickingABufferNodeStorage = nodeBuffer
        pickingABufferNodeCapacityStorage = capacity
        return resetABufferStorage()
    }

    private func resetABufferStorage() -> Bool {
        guard let headBuffer = pickingABufferHeadStorage,
              let nodeBuffer = pickingABufferNodeStorage,
              let capacity = requestedABufferCapacity() else {
            return false
        }
        let pixelCount = UInt64(extentStorage.width)
            * UInt64(extentStorage.height)
        guard pixelCount <= UInt64(Int.max) - 4,
              UInt64(capacity) <= UInt64(Int.max) / 8 else {
            return false
        }
        var headWords = [UInt32](
            repeating: viewportABufferEmptyHead,
            count: Int(pixelCount) + 4
        )
        headWords[0] = extentStorage.width
        headWords[1] = extentStorage.height
        headWords[2] = 0
        headWords[3] = 0
        let didResetHeads = headWords.withUnsafeBytes { rawBytes in
            guard let baseAddress = rawBytes.baseAddress else {
                return false
            }
            return headBuffer.upload(
                source: baseAddress,
                length: UInt64(rawBytes.count),
                offset: 0
            )
        }
        guard didResetHeads else {
            return false
        }
        var nodeHeader = [UInt32](
            repeating: 0,
            count: 4
        )
        nodeHeader[2] = capacity
        return nodeHeader.withUnsafeBytes { rawBytes in
            guard let baseAddress = rawBytes.baseAddress else {
                return false
            }
            return nodeBuffer.upload(
                source: baseAddress,
                length: UInt64(rawBytes.count),
                offset: 0
            )
        }
    }

    private func makeABufferParameters() -> ParameterBlock? {
        let parameters = ParameterBlock(length: 16, alignment: 16)
        guard parameters.setUInt32(0, value: extentStorage.width),
              parameters.setUInt32(4, value: extentStorage.height),
              parameters.setUInt32(
                  8,
                  value: pickingABufferNodeCapacityStorage
              ),
              parameters.setUInt32(12, value: 0) else {
            return nil
        }
        return parameters
    }

    private func selectPickingPath(
        _ configuration: ViewportPickingConfiguration
    ) -> ViewportPickingSelection {
        guard configuration.preferABuffer else {
            return ViewportPickingSelection(
                requestedPath: .baseline,
                selectedPath: .baseline,
                fallbackReason: .none,
                fallbackAvailable: false
            )
        }
        guard configuration.aBufferNodesPerPixel > 0,
              configuration.aBufferMaxNodes > 0,
              configuration.vertexPointSize.isFinite,
              configuration.vertexPointSize > 0 else {
            return ViewportPickingSelection(
                requestedPath: .aBuffer,
                selectedPath: .baseline,
                fallbackReason: .invalidRequest,
                fallbackAvailable: true
            )
        }
        guard device.capabilities.availability(
            for: .fragmentAtomics
        ).isUsable else {
            return ViewportPickingSelection(
                requestedPath: .aBuffer,
                selectedPath: .baseline,
                fallbackReason: .capabilityUnavailable,
                fallbackAvailable: true
            )
        }
        return ViewportPickingSelection(
            requestedPath: .aBuffer,
            selectedPath: .aBuffer,
            fallbackReason: .none,
            fallbackAvailable: true
        )
    }

    private func selectPickingAcceleration(
        _ configuration: ViewportPickingConfiguration
    ) -> ViewportAccelerationSelection {
        let requested: ViewportAccelerationPath
        if configuration.preferMesh {
            requested = .mesh
        } else if configuration.preferTile {
            requested = .tile
        } else if configuration.preferMemoryless {
            requested = .memoryless
        } else {
            requested = .baseline
        }
        guard requested != .baseline else {
            return ViewportAccelerationSelection(
                requestedPath: requested,
                selectedPath: .baseline,
                fallbackReason: .none,
                fallbackAvailable: false
            )
        }
        let feature: DeviceFeature
        switch requested {
        case .memoryless:
            feature = .memorylessAttachments
        case .tile:
            feature = .tileShaders
        case .mesh:
            feature = .meshShaders
        case .baseline:
            return ViewportAccelerationSelection(
                requestedPath: requested,
                selectedPath: .baseline,
                fallbackReason: .none,
                fallbackAvailable: false
            )
        }
        if requested == .memoryless,
           (configuration.captureDepth || configuration.captureNormal) {
            return ViewportAccelerationSelection(
                requestedPath: requested,
                selectedPath: .baseline,
                fallbackReason: .unsupportedReadback,
                fallbackAvailable: true
            )
        }
        if !device.capabilities.availability(for: feature).isUsable {
            return ViewportAccelerationSelection(
                requestedPath: requested,
                selectedPath: .baseline,
                fallbackReason: .capabilityUnavailable,
                fallbackAvailable: true
            )
        }
        if requested == .tile || requested == .mesh {
            return ViewportAccelerationSelection(
                requestedPath: requested,
                selectedPath: .baseline,
                fallbackReason: .resourcesUnavailable,
                fallbackAvailable: true
            )
        }
        return ViewportAccelerationSelection(
            requestedPath: requested,
            selectedPath: requested,
            fallbackReason: .none,
            fallbackAvailable: true
        )
    }

    private func preparePickingPipeline(
        colorFormat: PixelFormat,
        hasNormalAttachment: Bool,
        usesABuffer: Bool
    ) -> RenderPipeline? {
        guard colorFormat != .invalid else {
            errorDescriptionStorage =
                "Picking requires a color attachment format."
            return nil
        }
        let cacheKey = colorFormat.rawValue
            + (hasNormalAttachment ? 1000 : 0)
            + (usesABuffer ? 2000 : 0)
        if let pipeline = pickingPipelineStorage[cacheKey] {
            return pipeline
        }
        let fragmentName: String
        if usesABuffer {
            fragmentName = hasNormalAttachment
                ? "mt_viewport_picking_abuffer_normal_fragment"
                : "mt_viewport_picking_abuffer_fragment"
        } else {
            fragmentName = hasNormalAttachment
                ? "mt_viewport_picking_normal_fragment"
                : "mt_viewport_picking_fragment"
        }
        guard let library = device.createShaderLibraryFromSource(
            source: viewportPickingShaderSource,
            label: "mt viewport picking"
        ),
        let vertex = library.function("mt_viewport_picking_vertex"),
        let fragment = library.function(fragmentName)
        else {
            errorDescriptionStorage = device.errorDescription
            return nil
        }
        let descriptor = RenderPipelineDescriptor()
        descriptor.label = "mt.viewport.picking"
        descriptor.setVertexFunction(vertex)
        descriptor.setFragmentFunction(fragment)
        guard descriptor.setColorAttachment(
            ColorAttachmentDescriptor(
                pixelFormat: colorFormat,
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
        ),
        (!hasNormalAttachment
            || descriptor.setColorAttachment(
                ColorAttachmentDescriptor(
                    pixelFormat: .rgba32Float,
                    blendingEnabled: false,
                    sourceRGBBlendFactor: .one,
                    destinationRGBBlendFactor: .zero,
                    rgbBlendOperation: .add,
                    sourceAlphaBlendFactor: .one,
                    destinationAlphaBlendFactor: .zero,
                    alphaBlendOperation: .add,
                    writeMask: 15
                ),
                index: 1
            )),
        let pipeline = device.createRenderPipeline(descriptor) else {
            errorDescriptionStorage = device.errorDescription
            return nil
        }
        if pickingDepthStateStorage == nil {
            pickingDepthStateStorage = device.createDepthStencilState(
                DepthStencilDescriptor(
                    depthCompareFunction: .lessEqual,
                    depthWriteEnabled: true,
                    frontFaceStencil: .default,
                    backFaceStencil: .default,
                    label: "mt.viewport.picking.depth"
                )
            )
        }
        if usesABuffer, pickingABufferDepthStateStorage == nil {
            pickingABufferDepthStateStorage = device.createDepthStencilState(
                DepthStencilDescriptor(
                    depthCompareFunction: .always,
                    depthWriteEnabled: false,
                    frontFaceStencil: .default,
                    backFaceStencil: .default,
                    label: "mt.viewport.picking.abuffer.depth"
                )
            )
        }
        guard !usesABuffer || pickingABufferDepthStateStorage != nil else {
            errorDescriptionStorage =
                "The viewport A-buffer depth state could not be created."
            return nil
        }
        pickingPipelineStorage[cacheKey] = pipeline
        errorDescriptionStorage = ""
        return pipeline
    }

    private func readABufferPickResult(
        _ pending: PendingABufferPick
    ) -> ViewportPickResult? {
        let pixelCount = UInt64(pending.width)
            * UInt64(pending.height)
        guard pixelCount <= (UInt64.max - viewportABufferHeaderBytes) / 4,
              UInt64(pending.nodeCapacity)
                    <= (UInt64.max - viewportABufferHeaderBytes)
                        / viewportABufferNodeStride else {
            errorDescriptionStorage = "The viewport A-buffer extent is invalid."
            return nil
        }
        let headByteCount = viewportABufferHeaderBytes + pixelCount * 4
        let nodeByteCount = viewportABufferHeaderBytes
            + UInt64(pending.nodeCapacity) * viewportABufferNodeStride
        guard headByteCount <= UInt64(Int.max),
              nodeByteCount <= UInt64(Int.max) else {
            errorDescriptionStorage =
                "The viewport A-buffer readback is too large."
            return nil
        }

        var headBytes = [UInt8](repeating: 0, count: Int(headByteCount))
        let didReadHeads = headBytes.withUnsafeMutableBytes { rawBytes in
            guard let baseAddress = rawBytes.baseAddress else {
                return false
            }
            return pending.headBuffer.read(
                destination: baseAddress,
                length: headByteCount,
                offset: 0
            )
        }
        guard didReadHeads else {
            errorDescriptionStorage =
                "The viewport A-buffer head readback failed."
            return nil
        }

        var nodeBytes = [UInt8](repeating: 0, count: Int(nodeByteCount))
        let didReadNodes = nodeBytes.withUnsafeMutableBytes { rawBytes in
            guard let baseAddress = rawBytes.baseAddress else {
                return false
            }
            return pending.nodeBuffer.read(
                destination: baseAddress,
                length: nodeByteCount,
                offset: 0
            )
        }
        guard didReadNodes else {
            errorDescriptionStorage =
                "The viewport A-buffer node readback failed."
            return nil
        }

        func readUInt32(_ bytes: [UInt8], _ offset: Int) -> UInt32 {
            UInt32(bytes[offset])
                | (UInt32(bytes[offset + 1]) << 8)
                | (UInt32(bytes[offset + 2]) << 16)
                | (UInt32(bytes[offset + 3]) << 24)
        }

        func readFloat(_ bytes: [UInt8], _ offset: Int) -> Float {
            Float(bitPattern: readUInt32(bytes, offset))
        }

        let headerWidth = readUInt32(headBytes, 0)
        let headerHeight = readUInt32(headBytes, 4)
        guard headerWidth == pending.width,
              headerHeight == pending.height else {
            errorDescriptionStorage =
                "The viewport A-buffer dimensions changed before readback."
            return nil
        }
        var overflowed = readUInt32(nodeBytes, 4) != 0
        let capacity = min(
            readUInt32(nodeBytes, 8),
            pending.nodeCapacity
        )
        let pixelIndex = UInt64(pending.request.y)
            * UInt64(headerWidth)
            + UInt64(pending.request.x)
        let headOffset = Int(viewportABufferHeaderBytes + pixelIndex * 4)
        var nodeIndex = readUInt32(headBytes, headOffset)
        var traversed: UInt32 = 0
        var hits: [ViewportPickHit] = []

        while nodeIndex != viewportABufferEmptyHead,
              traversed < capacity {
            guard nodeIndex < capacity else {
                errorDescriptionStorage =
                    "The viewport A-buffer contained an invalid node link."
                return nil
            }
            let nodeOffset = Int(viewportABufferHeaderBytes)
                + Int(nodeIndex) * Int(viewportABufferNodeStride)
            guard nodeOffset >= 0,
                  nodeOffset <= nodeBytes.count - Int(viewportABufferNodeStride)
            else {
                errorDescriptionStorage =
                    "The viewport A-buffer node offset is invalid."
                return nil
            }
            let objectID = readUInt32(nodeBytes, nodeOffset)
            let vertexID = readUInt32(nodeBytes, nodeOffset + 4)
            let depth = readFloat(nodeBytes, nodeOffset + 8)
            let next = readUInt32(nodeBytes, nodeOffset + 12)
            let normal = Vector3(
                x: readFloat(nodeBytes, nodeOffset + 16),
                y: readFloat(nodeBytes, nodeOffset + 20),
                z: readFloat(nodeBytes, nodeOffset + 24)
            )
            let hasNormal = normal.x.isFinite
                && normal.y.isFinite
                && normal.z.isFinite
            if pending.request.mode == .object
                || objectID == pending.request.objectID {
                let rawID = pending.request.mode == .object
                    ? objectID
                    : PickingID.vertex(vertexID)?.rawValue ?? 0
                hits.append(
                    ViewportPickHit(
                        objectID: objectID,
                        vertexID: pending.request.mode == .object
                            ? 0
                            : vertexID,
                        rawID: rawID,
                        depth: depth,
                        normal: normal,
                        hasDepth: depth.isFinite,
                        hasNormal: hasNormal
                    )
                )
            }
            nodeIndex = next
            traversed += 1
        }
        if nodeIndex != viewportABufferEmptyHead {
            overflowed = true
        }
        hits.sort { lhs, rhs in
            let lhsDepth = lhs.depth.isFinite
                ? lhs.depth
                : Float.greatestFiniteMagnitude
            let rhsDepth = rhs.depth.isFinite
                ? rhs.depth
                : Float.greatestFiniteMagnitude
            if lhsDepth != rhsDepth {
                return lhsDepth < rhsDepth
            }
            if lhs.objectID != rhs.objectID {
                return lhs.objectID < rhs.objectID
            }
            return lhs.vertexID < rhs.vertexID
        }

        let first = hits.first
        let objectID: UInt32
        if pending.request.mode == .vertex {
            objectID = pending.request.objectID
        } else {
            objectID = first?.objectID ?? 0
        }
        var result = ViewportPickResult(
            mode: pending.request.mode,
            x: pending.request.x,
            y: pending.request.y,
            objectID: objectID,
            vertexID: first?.vertexID ?? 0,
            rawID: first?.rawID ?? 0,
            hit: !hits.isEmpty,
            depth: first?.depth ?? 0,
            normal: first?.normal ?? Vector3(x: 0, y: 0, z: 1),
            hasDepth: first?.hasDepth ?? false,
            hasNormal: first?.hasNormal ?? false
        )
        result.setABufferHits(hits, overflowed: overflowed)
        errorDescriptionStorage = ""
        return result
    }

    private func readPickResult(
        _ pending: PendingPick
    ) -> ViewportPickResult? {
        let width = pending.texture.width
        let height = pending.texture.height
        guard pending.request.x < width,
              pending.request.y < height,
              UInt64(width) <= UInt64(Int.max) / 4 else {
            errorDescriptionStorage = "The picking texture extent is invalid."
            return nil
        }

        let bytesPerRow = UInt64(width) * 4
        guard UInt64(height) <= UInt64(Int.max) / bytesPerRow else {
            errorDescriptionStorage = "The picking readback is too large."
            return nil
        }
        let byteCount = bytesPerRow * UInt64(height)
        var bytes = [UInt8](repeating: 0, count: Int(byteCount))
        let didRead = bytes.withUnsafeMutableBytes { rawBytes in
            guard let baseAddress = rawBytes.baseAddress else {
                return false
            }
            return pending.texture.readBaseLevel2D(
                destination: baseAddress,
                bytesPerRow: bytesPerRow,
                bytesPerImage: byteCount
            )
        }
        guard didRead else {
            errorDescriptionStorage = "The picking texture readback failed."
            return nil
        }

        let pixelOffset =
            (UInt64(pending.request.y) * UInt64(width)
                + UInt64(pending.request.x)) * 4
        let index = Int(pixelOffset)
        let id = PickingID.fromBytes(
            red: bytes[index],
            green: bytes[index + 1],
            blue: bytes[index + 2],
            alpha: bytes[index + 3]
        )
        let objectID: UInt32
        let vertexID: UInt32
        let hit: Bool
        switch pending.request.mode {
        case .object:
            objectID = id.rawValue
            vertexID = 0
            hit = id.isValid && objectNames[id.rawValue] != nil
        case .vertex:
            objectID = pending.request.objectID
            vertexID = id.isValid ? id.rawValue - 1 : 0
            hit = id.isValid
        }
        var depth: Float = 0
        var hasDepth = false
        if let depthTexture = pending.depthTexture {
            guard UInt64(depthTexture.width) <= UInt64(Int.max) / 4,
                  UInt64(depthTexture.height)
                    <= UInt64(Int.max)
                        / (UInt64(depthTexture.width) * 4) else {
                errorDescriptionStorage =
                    "The depth picking readback is too large."
                return nil
            }
            let depthBytesPerRow = UInt64(depthTexture.width) * 4
            let depthByteCount = depthBytesPerRow
                * UInt64(depthTexture.height)
            var depthBytes = [UInt8](
                repeating: 0,
                count: Int(depthByteCount)
            )
            let didReadDepth = depthBytes.withUnsafeMutableBytes { rawBytes in
                guard let baseAddress = rawBytes.baseAddress else {
                    return false
                }
                return depthTexture.readBaseLevel2D(
                    destination: baseAddress,
                    bytesPerRow: depthBytesPerRow,
                    bytesPerImage: depthByteCount
                )
            }
            if didReadDepth {
                let depthOffset =
                    (UInt64(pending.request.y)
                        * UInt64(depthTexture.width)
                        + UInt64(pending.request.x)) * 4
                let depthIndex = Int(depthOffset)
                let bits = UInt32(depthBytes[depthIndex])
                    | (UInt32(depthBytes[depthIndex + 1]) << 8)
                    | (UInt32(depthBytes[depthIndex + 2]) << 16)
                    | (UInt32(depthBytes[depthIndex + 3]) << 24)
                depth = Float(bitPattern: bits)
                hasDepth = depth.isFinite
            }
        }
        var normal = Vector3(x: 0, y: 0, z: 1)
        var hasNormal = false
        if let normalTexture = pending.normalTexture {
            guard UInt64(normalTexture.width) <= UInt64(Int.max) / 16,
                  UInt64(normalTexture.height)
                    <= UInt64(Int.max)
                        / (UInt64(normalTexture.width) * 16) else {
                errorDescriptionStorage =
                    "The normal picking readback is too large."
                return nil
            }
            let normalBytesPerRow = UInt64(normalTexture.width) * 16
            let normalByteCount = normalBytesPerRow
                * UInt64(normalTexture.height)
            var normalBytes = [UInt8](
                repeating: 0,
                count: Int(normalByteCount)
            )
            let didReadNormal = normalBytes.withUnsafeMutableBytes { rawBytes in
                guard let baseAddress = rawBytes.baseAddress else {
                    return false
                }
                return normalTexture.readBaseLevel2D(
                    destination: baseAddress,
                    bytesPerRow: normalBytesPerRow,
                    bytesPerImage: normalByteCount
                )
            }
            if didReadNormal {
                let normalOffset =
                    (UInt64(pending.request.y)
                        * UInt64(normalTexture.width)
                        + UInt64(pending.request.x)) * 16
                let normalIndex = Int(normalOffset)
                func component(_ offset: Int) -> Float {
                    let index = normalIndex + offset
                    let bits = UInt32(normalBytes[index])
                        | (UInt32(normalBytes[index + 1]) << 8)
                        | (UInt32(normalBytes[index + 2]) << 16)
                        | (UInt32(normalBytes[index + 3]) << 24)
                    return Float(bitPattern: bits)
                }
                let encoded = Vector3(
                    x: component(0),
                    y: component(4),
                    z: component(8)
                )
                normal = Vector3(
                    x: encoded.x * 2 - 1,
                    y: encoded.y * 2 - 1,
                    z: encoded.z * 2 - 1
                )
                hasNormal = normal.x.isFinite
                    && normal.y.isFinite
                    && normal.z.isFinite
            }
        }
        errorDescriptionStorage = ""
        return ViewportPickResult(
            mode: pending.request.mode,
            x: pending.request.x,
            y: pending.request.y,
            objectID: objectID,
            vertexID: vertexID,
            rawID: id.rawValue,
            hit: hit,
            depth: depth,
            normal: normal,
            hasDepth: hasDepth,
            hasNormal: hasNormal
        )
    }
}

public final class ViewportFixture {
    public let viewport: Viewport
    public let scene: Scene
    public let drawables: DrawableManager
    public let axesFeatureID: UInt64
    public let gridFeatureID: UInt64
    public let labelsFeatureID: UInt64
    public let vertexPointsFeatureID: UInt64
    public let objectPickingFeatureID: UInt64
    public let vertexPickingFeatureID: UInt64
    public let sceneObjectID: UInt32

    public init?(
        device: Device,
        width: UInt32 = 640,
        height: UInt32 = 480
    ) {
        guard width > 0, height > 0 else {
            return nil
        }
        let viewport = Viewport(device: device)
        guard viewport.resize(width: width, height: height) else {
            return nil
        }
        let axesID = viewport.addAxesFeature("fixture.axes")
        let gridID = viewport.addGridFeature("fixture.grid")
        let labelsID = viewport.addFeature(
            ViewportFeature.labels(name: "fixture.labels")
        )
        let vertexPointsID = viewport.addFeature(
            ViewportFeature.vertexPoints(name: "fixture.vertexPoints")
        )
        let objectPickingID = viewport.addObjectPickingFeature(
            "fixture.objectPicking"
        )
        let vertexPickingID = viewport.addVertexPickingFeature(
            "fixture.vertexPicking"
        )
        guard axesID != 0,
              gridID != 0,
              labelsID != 0,
              vertexPointsID != 0,
              objectPickingID != 0,
              vertexPickingID != 0 else {
            return nil
        }
        let scene = Scene()
        let drawables = DrawableManager()
        let mesh = Mesh.triangle(name: "fixture.triangle")
        guard drawables.addMesh(mesh) else {
            return nil
        }
        guard scene.addObject(
            SceneObject(
                name: "fixture.triangle",
                meshName: mesh.name,
                transform: Transform.identity(),
                materialID: 0,
                visibilityMask: UInt32.max,
                enabled: true
            )
        ) else {
            return nil
        }
        let objectCount = viewport.synchronizeSceneObjectIDs(scene)
        guard objectCount == 1,
              viewport.objectID("fixture.triangle") != 0 else {
            return nil
        }
        if let labels = viewport.feature(labelsID) {
            labels.setLabelText("fixture")
            labels.labelColor = Vector4(x: 1, y: 1, z: 0, w: 1)
        }
        if let points = viewport.feature(vertexPointsID) {
            _ = points.setVertexPoints([
                Vector3(x: 0, y: 0.5, z: 0),
                Vector3(x: -0.5, y: -0.5, z: 0),
                Vector3(x: 0.5, y: -0.5, z: 0)
            ])
            points.labelColor = Vector4(x: 1, y: 1, z: 1, w: 1)
        }
        self.viewport = viewport
        self.scene = scene
        self.drawables = drawables
        self.axesFeatureID = axesID
        self.gridFeatureID = gridID
        self.labelsFeatureID = labelsID
        self.vertexPointsFeatureID = vertexPointsID
        self.objectPickingFeatureID = objectPickingID
        self.vertexPickingFeatureID = vertexPickingID
        self.sceneObjectID = viewport.objectID("fixture.triangle")
    }

    public func makePickingRenderPass() -> RenderPassDescriptor? {
        viewport.makePickingRenderPass()
    }

    public func makeVertexCandidates() -> [ViewportVertexCandidate] {
        viewport.makeVertexCandidates(
            scene: scene,
            drawables: drawables
        )
    }
}

