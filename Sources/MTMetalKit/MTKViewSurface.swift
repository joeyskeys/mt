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

    public init(
        pixelFormat: PixelFormat,
        framebufferOnly: Bool,
        paused: Bool,
        enableSetNeedsDisplay: Bool,
        preferredFramesPerSecond: Int32
    ) {
        self.pixelFormat = pixelFormat
        self.framebufferOnly = framebufferOnly
        self.paused = paused
        self.enableSetNeedsDisplay = enableSetNeedsDisplay
        self.preferredFramesPerSecond = preferredFramesPerSecond
    }
}

public final class MTKViewSurfaceAdapter {
    private weak var viewStorage: MTKView?
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

    public func resize(width: UInt32, height: UInt32) -> Bool {
        surface.resize(width: width, height: height)
    }

    public func nextDrawable() -> Drawable? {
        surface.nextDrawable()
    }

    public func makeRenderPassDescriptor(
        _ drawable: Drawable
    ) -> RenderPassDescriptor? {
        surface.makeRenderPassDescriptor(drawable)
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

