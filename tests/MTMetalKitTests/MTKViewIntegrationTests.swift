import MTCore
import MTMetalKit
import XCTest

final class MTKViewIntegrationTests: XCTestCase {
    func testSurfaceConfigurationKeepsHostLoopOptionsExplicit() {
        let configuration = MTKViewSurfaceConfiguration(
            pixelFormat: .bgra8Unorm,
            framebufferOnly: true,
            paused: true,
            enableSetNeedsDisplay: false,
            preferredFramesPerSecond: 60,
            drawableSize: Extent(width: 1280, height: 720)
        )
        XCTAssertTrue(configuration.isValid)
        XCTAssertTrue(configuration.framebufferOnly)
        XCTAssertTrue(configuration.paused)
        XCTAssertFalse(configuration.enableSetNeedsDisplay)
        XCTAssertEqual(configuration.preferredFramesPerSecond, 60)
        XCTAssertEqual(configuration.drawableSize.width, 1280)
    }

    func testWindowConfigurationRejectsInvalidSurfaceConfiguration() {
        let surface = MTKViewSurfaceConfiguration(
            pixelFormat: .invalid,
            framebufferOnly: true,
            paused: true,
            enableSetNeedsDisplay: false,
            preferredFramesPerSecond: 60
        )
        let configuration = MTKViewWindowConfiguration(
            widthPoints: 960,
            heightPoints: 640,
            title: "invalid",
            surface: surface
        )
        XCTAssertFalse(configuration.isValid)
    }

    func testWindowedLifecycleWhenExplicitlyEnabled() throws {
        guard ProcessInfo.processInfo.environment[
            "MT_RUN_WINDOWED_HOST_TESTS"
        ] == "1" else {
            throw XCTSkip("Windowed host tests are opt-in.")
        }
        guard let device = Device.systemDefault() else {
            throw XCTSkip("No Metal device is available on this machine.")
        }
        guard let host = MTKViewWindowHost(
            device: device,
            configuration: MTKViewWindowConfiguration(
                widthPoints: 320,
                heightPoints: 240,
                title: "mt MTKView test",
                surface: MTKViewSurfaceConfiguration(
                    pixelFormat: .bgra8Unorm,
                    framebufferOnly: true,
                    paused: true,
                    enableSetNeedsDisplay: false,
                    preferredFramesPerSecond: 60
                )
            )
        ) else {
            XCTFail("The MTKView host could not be created.")
            return
        }
        defer { host.hide() }

        host.show()
        XCTAssertTrue(host.syncDrawableSize())
        guard let drawable = host.adapter.nextDrawable(),
              let pass = host.adapter.makeRenderPassDescriptor(drawable),
              let queue = device.createCommandQueue(),
              let commandBuffer = queue.makeCommandBuffer(),
              let encoder = commandBuffer.makeRenderEncoder(pass)
        else {
            throw XCTSkip("The test view did not provide a drawable.")
        }
        _ = encoder.endEncoding()
        XCTAssertTrue(host.adapter.present(drawable, on: commandBuffer))
        XCTAssertTrue(commandBuffer.commit())
        commandBuffer.waitUntilCompleted()
        XCTAssertTrue(commandBuffer.didSucceed)
    }
}
