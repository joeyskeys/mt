import XCTest
@testable import MTCore

final class MTCoreTests: XCTestCase {
    func testCapabilityFeatureQueries() {
        let capabilities = DeviceCapabilities(
            macFamily: .mac2,
            appleFamily: .unknown,
            argumentBufferTier: .tier2,
            unifiedMemory: false,
            indirectCommandBuffers: true,
            meshShaders: true,
            tileShaders: true,
            memorylessAttachments: true,
            rayTracing: true,
            dynamicLibraries: true,
            counterSampling: true,
            maxThreadsPerThreadgroup: 1024,
            maxBufferLength: 1024 * 1024,
            maxArgumentBufferSamplerCount: 16,
            maxTextureDimension2D: 16384,
            supportedSampleCounts: [1, 2, 4, 8]
        )

        XCTAssertTrue(capabilities.supports(.argumentBuffers))
        XCTAssertTrue(capabilities.supports(.argumentBufferTier2))
        XCTAssertTrue(capabilities.supports(.meshShaders))
        XCTAssertTrue(capabilities.supports(.rayTracing))
    }

    func testDeviceEnumerationHasSafeNoDevicePath() {
        let devices = Device.enumerate()
        if devices.isEmpty {
            XCTAssertNil(Device.systemDefault())
        } else {
            XCTAssertNotNil(Device.systemDefault())
        }
    }

    func testDeviceCreatesQueueAndCommandBuffer() {
        guard let device = Device.systemDefault() else {
            return
        }

        let queue = device.createCommandQueue(label: "mt test queue")
        XCTAssertNotNil(queue)
        XCTAssertEqual(queue?.label, "mt test queue")

        let commandBuffer = queue?.makeCommandBuffer()
        XCTAssertNotNil(commandBuffer)
        XCTAssertEqual(commandBuffer?.status, .notEnqueued)
    }
}

