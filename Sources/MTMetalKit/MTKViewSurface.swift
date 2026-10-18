import AppKit
import Metal
import MetalKit
import QuartzCore
import MTCore

public struct MTKViewSurfaceConfiguration {
    public var pixelFormat: PixelFormat
    public var framebufferOnly: Bool
    public var paused: Bool
    public var enableSetNeedsDisplay: Bool
    public var preferredFramesPerSecond: Int32
    public var drawableSize: Extent

    public init(
        pixelFormat: PixelFormat,
        framebufferOnly: Bool,
        paused: Bool,
        enableSetNeedsDisplay: Bool,
        preferredFramesPerSecond: Int32,
        drawableSize: Extent = Extent(width: 0, height: 0)
    ) {
        self.pixelFormat = pixelFormat
        self.framebufferOnly = framebufferOnly
        self.paused = paused
        self.enableSetNeedsDisplay = enableSetNeedsDisplay
        self.preferredFramesPerSecond = preferredFramesPerSecond
        self.drawableSize = drawableSize
    }

    public var isValid: Bool {
        pixelFormat != .invalid
            && preferredFramesPerSecond >= 0
    }
}

public final class MTKViewSurfaceAdapter {
    private weak var viewStorage: MTKView?
    private var lastDrawableAvailableStorage = false
    public let surface: Surface

    public init?(
        nativeView: UnsafeMutableRawPointer,
        device: Device,
        configuration: MTKViewSurfaceConfiguration
    ) {
        let view = Unmanaged<MTKView>
            .fromOpaque(nativeView)
            .takeUnretainedValue()
        guard let metalDevice = Self.metalDevice(from: device),
              let metalPixelFormat = Self.metalPixelFormat(
                  configuration.pixelFormat
              ) else {
            return nil
        }
        view.device = metalDevice
        view.colorPixelFormat = metalPixelFormat
        view.framebufferOnly = configuration.framebufferOnly
        view.isPaused = configuration.paused
        view.enableSetNeedsDisplay = configuration.enableSetNeedsDisplay
        if configuration.drawableSize.width > 0,
           configuration.drawableSize.height > 0 {
            view.drawableSize = CGSize(
                width: CGFloat(configuration.drawableSize.width),
                height: CGFloat(configuration.drawableSize.height)
            )
        }
        if configuration.preferredFramesPerSecond > 0 {
            view.preferredFramesPerSecond = Int(
                configuration.preferredFramesPerSecond
            )
        }
        guard let layer = view.layer as? CAMetalLayer,
              let surface = Surface.layerBacked(
                  nativeLayer: Unmanaged.passUnretained(layer).toOpaque()
              ) else {
            return nil
        }
        self.viewStorage = view
        self.surface = surface
    }

    public var drawableSize: Extent {
        surface.drawableSize
    }

    public var colorFormat: PixelFormat {
        surface.colorFormat
    }

    public var scaleFactor: Double {
        if let window = viewStorage?.window {
            return max(1, window.backingScaleFactor)
        }
        return max(1, Double(viewStorage?.layer?.contentsScale ?? 1))
    }

    public var isAttached: Bool {
        viewStorage != nil
    }

    public var lastDrawableAvailable: Bool {
        lastDrawableAvailableStorage
    }

    public var framebufferOnly: Bool {
        get { viewStorage?.framebufferOnly ?? false }
        set { viewStorage?.framebufferOnly = newValue }
    }

    public var paused: Bool {
        get { viewStorage?.isPaused ?? true }
        set { viewStorage?.isPaused = newValue }
    }

    public var enableSetNeedsDisplay: Bool {
        get { viewStorage?.enableSetNeedsDisplay ?? false }
        set { viewStorage?.enableSetNeedsDisplay = newValue }
    }

    public var preferredFramesPerSecond: Int32 {
        get { Int32(viewStorage?.preferredFramesPerSecond ?? 0) }
        set {
            guard newValue > 0 else {
                return
            }
            viewStorage?.preferredFramesPerSecond = Int(newValue)
        }
    }

    public func resize(width: UInt32, height: UInt32) -> Bool {
        guard width > 0, height > 0 else {
            return false
        }
        viewStorage?.drawableSize = CGSize(
            width: CGFloat(width),
            height: CGFloat(height)
        )
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
        let size = view.drawableSize
        guard size.width > 0, size.height > 0 else {
            return false
        }
        return resize(
            width: UInt32(max(1, Int(size.width))),
            height: UInt32(max(1, Int(size.height)))
        )
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

    public func nativeViewHandle() -> UnsafeMutableRawPointer? {
        guard let view = viewStorage else {
            return nil
        }
        return Unmanaged.passUnretained(view).toOpaque()
    }

    private static func metalDevice(from device: Device) -> MTLDevice? {
        let object = Unmanaged<AnyObject>
            .fromOpaque(device.nativeHandle())
            .takeUnretainedValue()
        return object as? MTLDevice
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

public struct MTKViewWindowConfiguration {
    public var widthPoints: Double
    public var heightPoints: Double
    public var title: String
    public var surface: MTKViewSurfaceConfiguration

    public init(
        widthPoints: Double,
        heightPoints: Double,
        title: String,
        surface: MTKViewSurfaceConfiguration
    ) {
        self.widthPoints = widthPoints
        self.heightPoints = heightPoints
        self.title = title
        self.surface = surface
    }

    public var isValid: Bool {
        widthPoints.isFinite
            && heightPoints.isFinite
            && widthPoints > 0
            && heightPoints > 0
            && surface.isValid
    }
}

/// A native MTKView consumer fixture. It owns the window and view only.
/// The application remains responsible for the device, queue, and frame loop.
public final class MTKViewWindowHost {
    private let windowStorage: NSWindow
    private let viewStorage: MTKView
    public let adapter: MTKViewSurfaceAdapter

    public init?(
        device: Device,
        configuration: MTKViewWindowConfiguration
    ) {
        guard configuration.isValid,
              let metalDevice = Self.metalDevice(from: device)
        else {
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

        let view = MTKView(
            frame: NSRect(
                x: 0,
                y: 0,
                width: configuration.widthPoints,
                height: configuration.heightPoints
            ),
            device: metalDevice
        )
        window.contentView = view
        guard let adapter = MTKViewSurfaceAdapter(
            nativeView: Unmanaged.passUnretained(view).toOpaque(),
            device: device,
            configuration: configuration.surface
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

    private static func metalDevice(from device: Device) -> MTLDevice? {
        let object = Unmanaged<AnyObject>
            .fromOpaque(device.nativeHandle())
            .takeUnretainedValue()
        return object as? MTLDevice
    }
}

