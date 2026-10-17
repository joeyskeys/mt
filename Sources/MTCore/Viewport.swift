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
    case objectPicking
    case vertexPicking
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

    private var attachedStorage = false
    private var extentStorage = Extent(width: 0, height: 0)
    private var attachCountStorage: UInt32 = 0
    private var resizeCountStorage: UInt32 = 0
    private var updateCountStorage: UInt32 = 0
    private var recordCountStorage: UInt32 = 0
    private var lastFrameIndexStorage: UInt64 = 0

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
    }

    fileprivate func resize(to extent: Extent) -> Bool {
        guard attachedStorage else {
            return false
        }
        extentStorage = extent
        resizeCountStorage += 1
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

    public init(
        mode: ViewportPickMode,
        x: UInt32,
        y: UInt32,
        objectID: UInt32
    ) {
        self.mode = mode
        self.x = x
        self.y = y
        self.objectID = objectID
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

    public init(
        mode: ViewportPickMode,
        x: UInt32,
        y: UInt32,
        objectID: UInt32,
        vertexID: UInt32,
        rawID: UInt32,
        hit: Bool
    ) {
        self.mode = mode
        self.x = x
        self.y = y
        self.objectID = objectID
        self.vertexID = vertexID
        self.rawID = rawID
        self.hit = hit
    }
}

public final class Viewport {
    private struct PendingPick {
        let commandBuffer: CommandBuffer
        let texture: Texture
        let request: ViewportPickRequest
    }

    private let device: Device
    private var rendererStorage: Renderer?
    private var features: [UInt64: ViewportFeature] = [:]
    private var featureOrder: [UInt64] = []
    private var nextFeatureID: UInt64 = 1
    private var objectIDs: [String: UInt32] = [:]
    private var objectNames: [UInt32: String] = [:]
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
    private var pendingPickStorage: PendingPick?
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

    public var hasRenderer: Bool {
        rendererStorage != nil
    }

    public var hasPendingPick: Bool {
        pendingPickStorage != nil
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
                  feature.record(.screenOverlay) else {
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
                storeAction: .dontCare,
                clearDepth: 1
            )
            guard descriptor.setDepthAttachment(depth) else {
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
              !commandBuffer.isCommitted,
              !commandBuffer.hasActiveEncoder,
              request.x < extentStorage.width,
              request.y < extentStorage.height,
              let texture = pickingTextureStorage,
              let readbackTexture = pickingReadbackTextureStorage else {
            errorDescriptionStorage =
                "The viewport pick readback request is invalid or busy."
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
        guard blit.endEncoding() else {
            errorDescriptionStorage =
                "The viewport could not end the picking readback encoder."
            return false
        }
        pendingPickStorage = PendingPick(
            commandBuffer: commandBuffer,
            texture: readbackTexture,
            request: request
        )
        errorDescriptionStorage = ""
        return true
    }

    public func pollPickResult() -> ViewportPickResult? {
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
        rendererStorage = nil
        pendingPickStorage = nil
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
           depth.height == extentStorage.height {
            return true
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
            storageMode: .gpuPrivate,
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
        pickingTextureStorage = color
        pickingReadbackTextureStorage = readback
        pickingDepthTextureStorage = depth
        return true
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
        errorDescriptionStorage = ""
        return ViewportPickResult(
            mode: pending.request.mode,
            x: pending.request.x,
            y: pending.request.y,
            objectID: objectID,
            vertexID: vertexID,
            rawID: id.rawValue,
            hit: hit
        )
    }
}

