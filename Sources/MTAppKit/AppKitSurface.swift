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
}

public final class AppKitSurfaceAdapter {
    private weak var viewStorage: NSView?
    private let layerStorage: CAMetalLayer
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

    public func resize(width: UInt32, height: UInt32) -> Bool {
        surface.resize(width: width, height: height)
    }

    public func resizeToView() -> Bool {
        guard let view = viewStorage else {
            return false
        }
        let backingBounds = view.convertToBacking(view.bounds)
        let width = UInt32(max(0, Int(backingBounds.width)))
        let height = UInt32(max(0, Int(backingBounds.height)))
        guard width > 0, height > 0 else {
            return false
        }
        return resize(width: width, height: height)
    }

    public func nextDrawable() -> Drawable? {
        surface.nextDrawable()
    }

    public func makeRenderPassDescriptor(
        _ drawable: Drawable
    ) -> RenderPassDescriptor? {
        surface.makeRenderPassDescriptor(drawable)
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

