import AppKit
import Metal
import QuartzCore
import MTCore

public struct AppKitSurfaceConfiguration {
    public var pixelFormat: PixelFormat
    public var drawableSize: Extent
    public var framebufferOnly: Bool
    public var presentsWithTransaction: Bool
    public var displaySyncEnabled: Bool

    public init(
        pixelFormat: PixelFormat,
        drawableSize: Extent,
        framebufferOnly: Bool,
        presentsWithTransaction: Bool,
        displaySyncEnabled: Bool
    ) {
        self.pixelFormat = pixelFormat
        self.drawableSize = drawableSize
        self.framebufferOnly = framebufferOnly
        self.presentsWithTransaction = presentsWithTransaction
        self.displaySyncEnabled = displaySyncEnabled
    }

    public var isValid: Bool {
        pixelFormat != .invalid
            && drawableSize.width > 0
            && drawableSize.height > 0
    }
}

public final class AppKitSurfaceAdapter {
    private weak var viewStorage: NSView?
    private let layerStorage: CAMetalLayer
    private var lastDrawableAvailableStorage = false
    public let surface: Surface

    public init?(
        nativeView: UnsafeMutableRawPointer,
        device: Device,
        configuration: AppKitSurfaceConfiguration
    ) {
        let view = Unmanaged<NSView>
            .fromOpaque(nativeView)
            .takeUnretainedValue()
        let layer = CAMetalLayer()
        guard Self.configure(
            layer,
            device: device,
            drawableSize: configuration.drawableSize,
            pixelFormat: configuration.pixelFormat,
            framebufferOnly: configuration.framebufferOnly,
            presentsWithTransaction: configuration.presentsWithTransaction,
            displaySyncEnabled: configuration.displaySyncEnabled,
            scaleFactor: Self.scaleFactor(for: view)
        ) else {
            return nil
        }
        view.wantsLayer = true
        layer.frame = view.bounds
        view.layer = layer
        guard let surface = Surface.layerBacked(
            nativeLayer: Unmanaged.passUnretained(layer).toOpaque()
        ) else {
            return nil
        }
        self.viewStorage = view
        self.layerStorage = layer
        self.surface = surface
    }

    public init?(
        nativeLayer: UnsafeMutableRawPointer,
        device: Device,
        configuration: AppKitSurfaceConfiguration
    ) {
        let layer = Unmanaged<CAMetalLayer>
            .fromOpaque(nativeLayer)
            .takeUnretainedValue()
        guard Self.configure(
            layer,
            device: device,
            drawableSize: configuration.drawableSize,
            pixelFormat: configuration.pixelFormat,
            framebufferOnly: configuration.framebufferOnly,
            presentsWithTransaction: configuration.presentsWithTransaction,
            displaySyncEnabled: configuration.displaySyncEnabled,
            scaleFactor: layer.contentsScale
        ),
        let surface = Surface.layerBacked(
            nativeLayer: Unmanaged.passUnretained(layer).toOpaque()
        ) else {
            return nil
        }
        self.viewStorage = nil
        self.layerStorage = layer
        self.surface = surface
    }

    public var drawableSize: Extent {
        surface.drawableSize
    }

    public var colorFormat: PixelFormat {
        surface.colorFormat
    }

    public var scaleFactor: Double {
        if let view = viewStorage {
            return Self.scaleFactor(for: view)
        }
        return Double(layerStorage.contentsScale)
    }

    public var isAttached: Bool {
        viewStorage != nil || layerStorage.device != nil
    }

    public var lastDrawableAvailable: Bool {
        lastDrawableAvailableStorage
    }

    public var framebufferOnly: Bool {
        get { layerStorage.framebufferOnly }
        set { layerStorage.framebufferOnly = newValue }
    }

    public var presentsWithTransaction: Bool {
        get { layerStorage.presentsWithTransaction }
        set { layerStorage.presentsWithTransaction = newValue }
    }

    public var displaySyncEnabled: Bool {
        get { layerStorage.displaySyncEnabled }
        set { layerStorage.displaySyncEnabled = newValue }
    }

    public func resize(width: UInt32, height: UInt32) -> Bool {
        let didResize = surface.resize(width: width, height: height)
        if didResize {
            lastDrawableAvailableStorage = false
        }
        return didResize
    }

    public func resizeToView() -> Bool {
        guard let view = viewStorage else {
            return false
        }
        layerStorage.frame = view.bounds
        let backingBounds = view.convertToBacking(view.bounds)
        let width = UInt32(max(0, Int(backingBounds.width)))
        let height = UInt32(max(0, Int(backingBounds.height)))
        guard width > 0, height > 0 else {
            return false
        }
        return resize(width: width, height: height)
    }

    public func nextDrawable() -> Drawable? {
        let drawable = surface.nextDrawable()
        lastDrawableAvailableStorage = drawable != nil
        return drawable
    }

    public func makeRenderPassDescriptor(
        _ drawable: Drawable
    ) -> RenderPassDescriptor? {
        surface.makeRenderPassDescriptor(drawable)
    }

    public func present(
        _ drawable: Drawable,
        on commandBuffer: CommandBuffer
    ) -> Bool {
        commandBuffer.present(drawable)
    }

    public func nativeLayerHandle() -> UnsafeMutableRawPointer {
        Unmanaged.passUnretained(layerStorage).toOpaque()
    }

    private static func scaleFactor(for view: NSView) -> Double {
        if let window = view.window {
            return max(1, window.backingScaleFactor)
        }
        return max(1, NSScreen.main?.backingScaleFactor ?? 1)
    }

    private static func configure(
        _ layer: CAMetalLayer,
        device: Device,
        drawableSize: Extent,
        pixelFormat: PixelFormat,
        framebufferOnly: Bool,
        presentsWithTransaction: Bool,
        displaySyncEnabled: Bool,
        scaleFactor: Double
    ) -> Bool {
        guard let metalPixelFormat = metalPixelFormat(pixelFormat) else {
            return false
        }
        let object = Unmanaged<AnyObject>
            .fromOpaque(device.nativeHandle())
            .takeUnretainedValue()
        guard let metalDevice = object as? MTLDevice else {
            return false
        }
        layer.device = metalDevice
        layer.pixelFormat = metalPixelFormat
        layer.framebufferOnly = framebufferOnly
        layer.presentsWithTransaction = presentsWithTransaction
        layer.displaySyncEnabled = displaySyncEnabled
        layer.contentsScale = CGFloat(max(1, scaleFactor))
        if drawableSize.width > 0, drawableSize.height > 0 {
            layer.drawableSize = CGSize(
                width: CGFloat(drawableSize.width),
                height: CGFloat(drawableSize.height)
            )
        }
        return true
    }

    private static func metalPixelFormat(
        _ format: PixelFormat
    ) -> MTLPixelFormat? {
        switch format {
        case .rgba8Unorm:
            return .rgba8Unorm
        case .rgba8UnormSrgb:
            return .rgba8Unorm_sRGB
        case .bgra8Unorm:
            return .bgra8Unorm
        case .bgra8UnormSrgb:
            return .bgra8Unorm_sRGB
        default:
            return nil
        }
    }
}

public struct AppKitWindowConfiguration {
    public var widthPoints: Double
    public var heightPoints: Double
    public var title: String
    public var pixelFormat: PixelFormat
    public var framebufferOnly: Bool
    public var presentsWithTransaction: Bool
    public var displaySyncEnabled: Bool

    public init(
        widthPoints: Double,
        heightPoints: Double,
        title: String,
        pixelFormat: PixelFormat,
        framebufferOnly: Bool,
        presentsWithTransaction: Bool,
        displaySyncEnabled: Bool
    ) {
        self.widthPoints = widthPoints
        self.heightPoints = heightPoints
        self.title = title
        self.pixelFormat = pixelFormat
        self.framebufferOnly = framebufferOnly
        self.presentsWithTransaction = presentsWithTransaction
        self.displaySyncEnabled = displaySyncEnabled
    }

    public var isValid: Bool {
        widthPoints.isFinite
            && heightPoints.isFinite
            && widthPoints > 0
            && heightPoints > 0
            && pixelFormat != .invalid
    }
}

/// A small native consumer fixture. It owns only the window and view.
/// Devices, queues, frame scheduling, and rendering remain application-owned.
public final class AppKitWindowHost {
    private let windowStorage: NSWindow
    private let viewStorage: NSView
    public let adapter: AppKitSurfaceAdapter

    public init?(
        device: Device,
        configuration: AppKitWindowConfiguration
    ) {
        guard configuration.isValid else {
            return nil
        }

        let window = NSWindow(
            contentRect: NSRect(
                x: 0,
                y: 0,
                width: configuration.widthPoints,
                height: configuration.heightPoints
            ),
            styleMask: [
                .titled,
                .closable,
                .miniaturizable,
                .resizable
            ],
            backing: .buffered,
            defer: false
        )
        window.title = configuration.title
        window.isReleasedWhenClosed = false

        let view = NSView(
            frame: NSRect(
                x: 0,
                y: 0,
                width: configuration.widthPoints,
                height: configuration.heightPoints
            )
        )
        window.contentView = view

        let scaleFactor = max(1, window.backingScaleFactor)
        let drawableSize = Extent(
            width: UInt32(
                max(1, Int(configuration.widthPoints * scaleFactor))
            ),
            height: UInt32(
                max(1, Int(configuration.heightPoints * scaleFactor))
            )
        )
        let surfaceConfiguration = AppKitSurfaceConfiguration(
            pixelFormat: configuration.pixelFormat,
            drawableSize: drawableSize,
            framebufferOnly: configuration.framebufferOnly,
            presentsWithTransaction: configuration.presentsWithTransaction,
            displaySyncEnabled: configuration.displaySyncEnabled
        )
        guard let adapter = AppKitSurfaceAdapter(
            nativeView: Unmanaged.passUnretained(view).toOpaque(),
            device: device,
            configuration: surfaceConfiguration
        ) else {
            return nil
        }

        self.windowStorage = window
        self.viewStorage = view
        self.adapter = adapter
    }

    public var windowHandle: UnsafeMutableRawPointer {
        Unmanaged.passUnretained(windowStorage).toOpaque()
    }

    public var viewHandle: UnsafeMutableRawPointer {
        Unmanaged.passUnretained(viewStorage).toOpaque()
    }

    public var isVisible: Bool {
        windowStorage.isVisible
    }

    public var backingScaleFactor: Double {
        max(1, windowStorage.backingScaleFactor)
    }

    public func show() {
        windowStorage.makeKeyAndOrderFront(nil)
    }

    public func hide() {
        windowStorage.orderOut(nil)
    }

    public func resize(widthPoints: Double, heightPoints: Double) -> Bool {
        guard widthPoints.isFinite,
              heightPoints.isFinite,
              widthPoints > 0,
              heightPoints > 0
        else {
            return false
        }
        windowStorage.setContentSize(
            NSSize(width: widthPoints, height: heightPoints)
        )
        viewStorage.layoutSubtreeIfNeeded()
        return adapter.resizeToView()
    }

    public func syncDrawableSize() -> Bool {
        viewStorage.layoutSubtreeIfNeeded()
        return adapter.resizeToView()
    }
}

