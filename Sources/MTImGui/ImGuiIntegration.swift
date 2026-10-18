import Foundation
import MTCore

public enum ImGuiBackendState: Int32 {
    case idle
    case frameOpen
    case drawDataSubmitted
    case shutDown
}

public enum ImGuiInputKind: Int32 {
    case pointerMoved
    case pointerButton
    case scroll
    case key
    case resize
    case focus
}

public struct ImGuiVersion: Equatable {
    public var major: UInt32
    public var minor: UInt32
    public var patch: UInt32

    public init(major: UInt32, minor: UInt32, patch: UInt32) {
        self.major = major
        self.minor = minor
        self.patch = patch
    }
}

public struct ImGuiBackendConfiguration {
    public var compiledVersion: ImGuiVersion
    public var allowMinorVersionSkew: Bool
    public var enableDocking: Bool
    public var enableViewports: Bool
    public var requireNativeContext: Bool

    public init(
        compiledVersion: ImGuiVersion,
        allowMinorVersionSkew: Bool,
        enableDocking: Bool,
        enableViewports: Bool,
        requireNativeContext: Bool
    ) {
        self.compiledVersion = compiledVersion
        self.allowMinorVersionSkew = allowMinorVersionSkew
        self.enableDocking = enableDocking
        self.enableViewports = enableViewports
        self.requireNativeContext = requireNativeContext
    }

    public var isValid: Bool {
        compiledVersion.major > 0
    }

    public func accepts(runtimeVersion: ImGuiVersion) -> Bool {
        guard runtimeVersion.major == compiledVersion.major else {
            return false
        }
        if allowMinorVersionSkew {
            return runtimeVersion.minor >= compiledVersion.minor
        }
        return runtimeVersion.minor == compiledVersion.minor
            && runtimeVersion.patch == compiledVersion.patch
    }
}

public struct ImGuiFrameInfo {
    public var frameIndex: UInt64
    public var deltaTime: Double
    public var displaySize: Extent
    public var framebufferScale: Vector2

    public init(
        frameIndex: UInt64,
        deltaTime: Double,
        displaySize: Extent,
        framebufferScale: Vector2
    ) {
        self.frameIndex = frameIndex
        self.deltaTime = deltaTime
        self.displaySize = displaySize
        self.framebufferScale = framebufferScale
    }

    public var isValid: Bool {
        deltaTime.isFinite
            && deltaTime >= 0
            && displaySize.width > 0
            && displaySize.height > 0
            && framebufferScale.x.isFinite
            && framebufferScale.y.isFinite
            && framebufferScale.x > 0
            && framebufferScale.y > 0
    }
}

public struct ImGuiDrawDataSummary {
    public var vertexCount: UInt32
    public var indexCount: UInt32
    public var commandCount: UInt32
    public var textureCount: UInt32
    public var displaySize: Extent

    public init(
        vertexCount: UInt32,
        indexCount: UInt32,
        commandCount: UInt32,
        textureCount: UInt32,
        displaySize: Extent
    ) {
        self.vertexCount = vertexCount
        self.indexCount = indexCount
        self.commandCount = commandCount
        self.textureCount = textureCount
        self.displaySize = displaySize
    }

    public var isValid: Bool {
        displaySize.width > 0 && displaySize.height > 0
    }
}

public struct ImGuiInputEvent {
    public var kind: ImGuiInputKind
    public var x: Double
    public var y: Double
    public var deltaX: Double
    public var deltaY: Double
    public var button: Int32
    public var pressed: Bool
    public var keyCode: UInt32
    public var modifiers: InputModifiers
    public var width: UInt32
    public var height: UInt32
    public var focused: Bool

    public init(
        kind: ImGuiInputKind,
        x: Double,
        y: Double,
        deltaX: Double,
        deltaY: Double,
        button: Int32,
        pressed: Bool,
        keyCode: UInt32,
        modifiers: InputModifiers,
        width: UInt32,
        height: UInt32,
        focused: Bool
    ) {
        self.kind = kind
        self.x = x
        self.y = y
        self.deltaX = deltaX
        self.deltaY = deltaY
        self.button = button
        self.pressed = pressed
        self.keyCode = keyCode
        self.modifiers = modifiers
        self.width = width
        self.height = height
        self.focused = focused
    }
}

public final class ImGuiInputTranslator {
    private init() {}

    public static func translate(
        _ event: HostInputEvent
    ) -> ImGuiInputEvent? {
        let kind: ImGuiInputKind
        switch event.kind {
        case .pointerMoved:
            kind = .pointerMoved
        case .pointerButton:
            kind = .pointerButton
        case .scroll:
            kind = .scroll
        case .key:
            kind = .key
        case .resize:
            kind = .resize
        case .focus:
            kind = .focus
        case .close:
            return nil
        }
        return ImGuiInputEvent(
            kind: kind,
            x: event.x,
            y: event.y,
            deltaX: event.deltaX,
            deltaY: event.deltaY,
            button: event.button,
            pressed: event.pressed,
            keyCode: event.keyCode,
            modifiers: event.modifiers,
            width: event.width,
            height: event.height,
            focused: event.focused
        )
    }
}

/// Coordinates an external ImGui backend without linking ImGui into MTCore.
///
/// The native context pointer is borrowed. This type does not create,
/// destroy, or own an ImGui context, widget tree, renderer, queue, or frame
/// loop. `submitDrawData` records the integration boundary and a Metal debug
/// group; the external ImGui renderer remains responsible for actual draw
/// list encoding.
public final class ImGuiBackend {
    private let configurationStorage: ImGuiBackendConfiguration
    private let nativeContextStorage: UnsafeMutableRawPointer?
    private var initializedStorage = false
    private var stateStorage = ImGuiBackendState.idle
    private var frameStorage: ImGuiFrameInfo?
    private var drawDataStorage: ImGuiDrawDataSummary?
    private var lastErrorStorage = ""

    public init?(
        configuration: ImGuiBackendConfiguration,
        nativeContext: UnsafeMutableRawPointer? = nil
    ) {
        guard configuration.isValid,
              !configuration.requireNativeContext || nativeContext != nil
        else {
            return nil
        }
        self.configurationStorage = configuration
        self.nativeContextStorage = nativeContext
    }

    public var configuration: ImGuiBackendConfiguration {
        configurationStorage
    }

    public var nativeContextHandle: UnsafeMutableRawPointer? {
        nativeContextStorage
    }

    public var state: ImGuiBackendState {
        stateStorage
    }

    public var isInitialized: Bool {
        initializedStorage
    }

    public var frame: ImGuiFrameInfo? {
        frameStorage
    }

    public var lastDrawData: ImGuiDrawDataSummary? {
        drawDataStorage
    }

    public var errorDescription: String {
        lastErrorStorage
    }

    public func initialize(runtimeVersion: ImGuiVersion) -> Bool {
        guard !initializedStorage else {
            lastErrorStorage = "The ImGui backend is already initialized."
            return false
        }
        guard configurationStorage.accepts(runtimeVersion: runtimeVersion)
        else {
            lastErrorStorage =
                "The ImGui runtime version is incompatible with the backend."
            return false
        }
        initializedStorage = true
        stateStorage = .idle
        lastErrorStorage = ""
        return true
    }

    public func beginFrame(_ frame: ImGuiFrameInfo) -> Bool {
        guard initializedStorage else {
            lastErrorStorage = "The ImGui backend is not initialized."
            return false
        }
        guard stateStorage == .idle else {
            lastErrorStorage = "ImGui frame begin requires an idle backend."
            return false
        }
        guard frame.isValid else {
            lastErrorStorage = "The ImGui frame information is invalid."
            return false
        }
        frameStorage = frame
        drawDataStorage = nil
        stateStorage = .frameOpen
        lastErrorStorage = ""
        return true
    }

    public func submitDrawData(
        _ drawData: ImGuiDrawDataSummary,
        to commandBuffer: CommandBuffer
    ) -> Bool {
        guard stateStorage == .frameOpen else {
            lastErrorStorage =
                "ImGui draw data requires an open backend frame."
            return false
        }
        guard drawData.isValid else {
            lastErrorStorage = "The ImGui draw-data summary is invalid."
            return false
        }
        guard commandBuffer.pushDebugGroup("mt-imgui draw data") else {
            lastErrorStorage = commandBuffer.errorDescription
            return false
        }
        guard commandBuffer.popDebugGroup() else {
            lastErrorStorage = commandBuffer.errorDescription
            return false
        }
        drawDataStorage = drawData
        stateStorage = .drawDataSubmitted
        lastErrorStorage = ""
        return true
    }

    public func endFrame() -> Bool {
        guard stateStorage == .frameOpen
                || stateStorage == .drawDataSubmitted else {
            lastErrorStorage =
                "ImGui frame end requires an open or submitted frame."
            return false
        }
        stateStorage = .idle
        lastErrorStorage = ""
        return true
    }

    public func shutdown() -> Bool {
        guard stateStorage != .shutDown else {
            return false
        }
        frameStorage = nil
        drawDataStorage = nil
        initializedStorage = false
        stateStorage = .shutDown
        lastErrorStorage = ""
        return true
    }
}
