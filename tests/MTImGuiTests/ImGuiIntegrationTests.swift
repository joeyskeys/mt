import MTCore
import MTImGui
import XCTest

final class ImGuiIntegrationTests: XCTestCase {
    private let version = ImGuiVersion(major: 1, minor: 90, patch: 0)

    func testVersionPolicyRequiresMajorAndSupportsConfiguredMinorSkew() {
        let strict = ImGuiBackendConfiguration(
            compiledVersion: version,
            allowMinorVersionSkew: false,
            enableDocking: false,
            enableViewports: false,
            requireNativeContext: false
        )
        XCTAssertTrue(strict.accepts(runtimeVersion: version))
        XCTAssertFalse(
            strict.accepts(
                runtimeVersion: ImGuiVersion(major: 2, minor: 90, patch: 0)
            )
        )
        XCTAssertFalse(
            strict.accepts(
                runtimeVersion: ImGuiVersion(major: 1, minor: 91, patch: 0)
            )
        )

        let compatible = ImGuiBackendConfiguration(
            compiledVersion: version,
            allowMinorVersionSkew: true,
            enableDocking: true,
            enableViewports: true,
            requireNativeContext: false
        )
        XCTAssertTrue(
            compatible.accepts(
                runtimeVersion: ImGuiVersion(major: 1, minor: 91, patch: 1)
            )
        )
    }

    func testInputTranslationIsValueOnly() {
        let input = HostInputEvent.pointerMoved(
            x: 12,
            y: 24,
            modifiers: InputModifiers.none()
        )
        guard let translated = ImGuiInputTranslator.translate(input) else {
            XCTFail("Pointer input should translate.")
            return
        }
        XCTAssertEqual(translated.kind, .pointerMoved)
        XCTAssertEqual(translated.x, 12)
        XCTAssertEqual(translated.y, 24)
    }

    func testCoordinatorOwnsPhasesButNotNativeContext() {
        let backend = ImGuiBackend(
            configuration: ImGuiBackendConfiguration(
                compiledVersion: version,
                allowMinorVersionSkew: false,
                enableDocking: false,
                enableViewports: false,
                requireNativeContext: false
            )
        )
        XCTAssertNotNil(backend)
        XCTAssertFalse(backend?.isInitialized ?? true)
        XCTAssertTrue(backend?.initialize(runtimeVersion: version) ?? false)
        XCTAssertTrue(
            backend?.beginFrame(
                ImGuiFrameInfo(
                    frameIndex: 1,
                    deltaTime: 1.0 / 60.0,
                    displaySize: Extent(width: 640, height: 480),
                    framebufferScale: Vector2(x: 1, y: 1)
                )
            ) ?? false
        )
        XCTAssertEqual(backend?.state, .frameOpen)
        XCTAssertTrue(backend?.endFrame() ?? false)
        XCTAssertEqual(backend?.state, .idle)
        XCTAssertTrue(backend?.shutdown() ?? false)
        XCTAssertEqual(backend?.state, .shutDown)
    }

    func testCoordinatorCanAnnotateAnApplicationCommandBuffer() throws {
        guard let device = Device.systemDefault() else {
            throw XCTSkip("No Metal device is available on this machine.")
        }
        guard let backend = ImGuiBackend(
            configuration: ImGuiBackendConfiguration(
                compiledVersion: version,
                allowMinorVersionSkew: false,
                enableDocking: false,
                enableViewports: false,
                requireNativeContext: false
            )
        ),
        backend.initialize(runtimeVersion: version),
        backend.beginFrame(
            ImGuiFrameInfo(
                frameIndex: 2,
                deltaTime: 1.0 / 60.0,
                displaySize: Extent(width: 640, height: 480),
                framebufferScale: Vector2(x: 1, y: 1)
            )
        ),
        let queue = device.createCommandQueue(),
        let commandBuffer = queue.makeCommandBuffer()
        else {
            XCTFail("The ImGui command-buffer fixture could not be created.")
            return
        }
        XCTAssertTrue(
            backend.submitDrawData(
                ImGuiDrawDataSummary(
                    vertexCount: 0,
                    indexCount: 0,
                    commandCount: 0,
                    textureCount: 0,
                    displaySize: Extent(width: 640, height: 480)
                ),
                to: commandBuffer
            )
        )
        XCTAssertTrue(backend.endFrame())
        XCTAssertTrue(commandBuffer.commit())
        commandBuffer.waitUntilCompleted()
        XCTAssertTrue(commandBuffer.didSucceed)
    }
}
