import XCTest
@testable import MTCore

final class ValidationTests: XCTestCase {
    func testDeviceEnumerationAndNoDevicePathAreConsistent() {
        let devices = Device.enumerate()
        if devices.isEmpty {
            XCTAssertNil(Device.systemDefault())
        } else {
            XCTAssertNotNil(Device.systemDefault())
            XCTAssertTrue(devices.allSatisfy { !$0.name.isEmpty })
        }
    }

    func testCapabilitiesExposeRuntimeLimitsAndFeatureRelationships() {
        guard let device = Device.systemDefault() else {
            return
        }
        let capabilities = device.capabilities
        XCTAssertGreaterThan(capabilities.maxThreadsPerThreadgroup, 0)
        XCTAssertGreaterThan(capabilities.maxBufferLength, 0)
        XCTAssertFalse(capabilities.maxTextureDimension2DLimit.known)
        XCTAssertTrue(capabilities.supportedSampleCounts.contains(1))
        XCTAssertEqual(
            capabilities.supports(.argumentBuffers),
            capabilities.argumentBufferCapabilities.supported
        )
        XCTAssertEqual(
            capabilities.supports(.meshShaders),
            capabilities.meshShaderCapabilities.supported
        )
        XCTAssertEqual(
            capabilities.supports(.tileShaders),
            capabilities.tileShaderCapabilities.supported
        )
        XCTAssertEqual(
            capabilities.supports(.rayTracing),
            capabilities.rayTracingCapabilities.supported
        )
    }

    func testInvalidDescriptorsFailWithoutCreatingPartialResources() {
        guard let device = Device.systemDefault() else {
            return
        }

        XCTAssertNil(
            device.createBuffer(
                BufferDescriptor(
                    length: 0,
                    usage: UInt32(BufferUsage.storage.rawValue),
                    storageMode: .shared,
                    cpuCacheMode: .defaultCache,
                    hazardMode: .defaultMode,
                    label: "invalid"
                )
            )
        )
        XCTAssertNil(
            device.createTexture(
                TextureDescriptor(
                    textureType: .twoD,
                    pixelFormat: .rgba8Unorm,
                    width: 0,
                    height: 16,
                    depth: 1,
                    arrayLength: 1,
                    mipLevelCount: 1,
                    sampleCount: 1,
                    usage: UInt32(TextureUsage.renderTarget.rawValue),
                    storageMode: .gpuPrivate,
                    cpuCacheMode: .defaultCache,
                    hazardMode: .defaultMode,
                    label: "invalid"
                )
            )
        )
        XCTAssertNil(
            Surface.offscreen(
                device: device,
                width: 0,
                height: 16,
                format: .bgra8Unorm
            )
        )

        let renderer = Renderer.forward(device: device)
        XCTAssertFalse(renderer.resize(width: 0, height: 16))
        XCTAssertEqual(renderer.batchCount, 0)

        let viewport = Viewport(device: device)
        XCTAssertNil(viewport.makePickingRenderPass())
        XCTAssertEqual(viewport.featureCount, 0)
    }

    func testFailurePathsRemainActionableAfterShutdown() {
        guard let device = Device.systemDefault() else {
            return
        }
        let renderer = Renderer.forward(device: device)
        renderer.shutdown()
        XCTAssertFalse(renderer.resize(width: 16, height: 16))
        XCTAssertFalse(renderer.errorDescription.isEmpty)

        let viewport = Viewport(device: device)
        viewport.shutdown()
        XCTAssertFalse(viewport.resize(width: 16, height: 16))
        XCTAssertFalse(viewport.errorDescription.isEmpty)
    }
}

