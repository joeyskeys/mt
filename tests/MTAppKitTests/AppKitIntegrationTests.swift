import AppKit
import MTAppKit
import MTCore
import XCTest

final class AppKitIntegrationTests: XCTestCase {
    func testSurfaceConfigurationValidatesPixelAndDrawableSize() {
        let valid = AppKitSurfaceConfiguration(
            pixelFormat: .bgra8Unorm,
            drawableSize: Extent(width: 1280, height: 720),
            framebufferOnly: true,
            presentsWithTransaction: false,
            displaySyncEnabled: true
        )
        XCTAssertTrue(valid.isValid)

        let invalid = AppKitSurfaceConfiguration(
            pixelFormat: .invalid,
            drawableSize: Extent(width: 1280, height: 720),
            framebufferOnly: true,
            presentsWithTransaction: false,
            displaySyncEnabled: true
        )
        XCTAssertFalse(invalid.isValid)
    }

    func testWindowConfigurationRejectsNonPositiveSize() {
        let configuration = AppKitWindowConfiguration(
            widthPoints: 0,
            heightPoints: 640,
            title: "invalid",
            pixelFormat: .bgra8Unorm,
            framebufferOnly: true,
            presentsWithTransaction: false,
            displaySyncEnabled: true
        )
        XCTAssertFalse(configuration.isValid)
    }

    func testModifierTranslationPreservesAllSupportedFlags() {
        let flags: NSEvent.ModifierFlags = [
            .shift,
            .control,
            .option,
            .command,
            .capsLock
        ]
        let translated = AppKitInputTranslator.modifiers(
            rawValue: UInt64(flags.rawValue)
        )
        XCTAssertTrue(translated.shift)
        XCTAssertTrue(translated.control)
        XCTAssertTrue(translated.option)
        XCTAssertTrue(translated.command)
        XCTAssertTrue(translated.capsLock)
    }

    func testLifecycleEventsUseToolkitNeutralValues() {
        let resize = AppKitInputTranslator.resize(width: 800, height: 600)
        XCTAssertEqual(resize.kind, .resize)
        XCTAssertEqual(resize.width, 800)
        XCTAssertEqual(resize.height, 600)

        let close = AppKitInputTranslator.close()
        XCTAssertEqual(close.kind, .close)

        let focus = AppKitInputTranslator.focus(true)
        XCTAssertEqual(focus.kind, .focus)
        XCTAssertTrue(focus.focused)
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
        guard let host = AppKitWindowHost(
            device: device,
            configuration: AppKitWindowConfiguration(
                widthPoints: 320,
                heightPoints: 240,
                title: "mt AppKit test",
                pixelFormat: .bgra8Unorm,
                framebufferOnly: true,
                presentsWithTransaction: false,
                displaySyncEnabled: true
            )
        ) else {
            XCTFail("The AppKit host could not be created.")
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
            throw XCTSkip("The test window did not provide a drawable.")
        }
        _ = encoder.endEncoding()
        XCTAssertTrue(host.adapter.present(drawable, on: commandBuffer))
        XCTAssertTrue(commandBuffer.commit())
        commandBuffer.waitUntilCompleted()
        XCTAssertTrue(commandBuffer.didSucceed)
    }
}
