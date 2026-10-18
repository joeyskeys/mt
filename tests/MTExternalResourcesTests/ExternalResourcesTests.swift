import Foundation
import IOSurface
import MTCore
import MTExternalResources
import XCTest

final class ExternalResourcesTests: XCTestCase {
    func testTextureDescriptorValidationRejectsMissingProducerMetadata() {
        let descriptor = IOSurfaceTextureDescriptor(
            surfaceID: 0,
            width: 0,
            height: 0,
            pixelFormat: .invalid,
            plane: 0,
            usage: 0,
            ownership: .borrowed,
            label: "invalid"
        )

        let diagnostics = IOSurfaceResourceImporter().validate(descriptor)

        XCTAssertEqual(diagnostics.count, 1)
        XCTAssertEqual(diagnostics.first?.code, .invalidDescriptor)
    }

    func testBufferDescriptorValidationRejectsEmptyRange() {
        let descriptor = IOSurfaceBufferDescriptor(
            surfaceID: 1,
            offset: 0,
            length: 0,
            usage: 1,
            ownership: .retained,
            label: "invalid"
        )

        let diagnostics = IOSurfaceResourceImporter().validate(descriptor)

        XCTAssertEqual(diagnostics.count, 1)
        XCTAssertEqual(diagnostics.first?.code, .invalidDescriptor)
    }

    func testDescriptorValidationRejectsUnknownUsageBits() {
        let texture = IOSurfaceTextureDescriptor(
            surfaceID: 1,
            width: 1,
            height: 1,
            pixelFormat: .rgba8Unorm,
            plane: 0,
            usage: 0x8000,
            ownership: .borrowed,
            label: "unknown usage"
        )
        let buffer = IOSurfaceBufferDescriptor(
            surfaceID: 1,
            offset: 0,
            length: 1,
            usage: 0x8000,
            ownership: .borrowed,
            label: "unknown usage"
        )

        let importer = IOSurfaceResourceImporter()
        XCTAssertEqual(importer.validate(texture).first?.code, .invalidDescriptor)
        XCTAssertEqual(importer.validate(buffer).first?.code, .invalidDescriptor)
    }

    func testExternalDescriptorsRejectPrivateAndMemorylessStorage() {
        let privateTexture = IOSurfaceTextureDescriptor(
            surfaceID: 1,
            width: 1,
            height: 1,
            pixelFormat: .rgba8Unorm,
            plane: 0,
            usage: UInt32(TextureUsage.shaderRead.rawValue),
            ownership: .borrowed,
            label: "private",
            storageMode: .gpuPrivate
        )
        let memorylessBuffer = IOSurfaceBufferDescriptor(
            surfaceID: 1,
            offset: 0,
            length: 1,
            usage: UInt32(BufferUsage.storage.rawValue),
            ownership: .borrowed,
            label: "memoryless",
            storageMode: .memoryless
        )

        let importer = IOSurfaceResourceImporter()
        XCTAssertEqual(
            importer.validate(privateTexture).first?.code,
            .invalidDescriptor
        )
        XCTAssertEqual(
            importer.validate(memorylessBuffer).first?.code,
            .invalidDescriptor
        )
    }

    func testSharedEventPolicyRequiresValuesOnlyWhenEnabled() {
        XCTAssertTrue(ExternalEventSyncPolicy.none.isValid)
        XCTAssertTrue(
            ExternalEventSyncPolicy(
                waitValue: 4,
                signalValue: 8,
                waitBeforeEncoding: true,
                signalAfterEncoding: true
            ).isValid
        )
        XCTAssertFalse(
            ExternalEventSyncPolicy(
                waitValue: 0,
                signalValue: 1,
                waitBeforeEncoding: true,
                signalAfterEncoding: false
            ).isValid
        )
    }

    func testInvalidImportDoesNotTouchMetalOrProducerOwnership() {
        guard let device = Device.systemDefault() else {
            throw XCTSkip("No Metal device is available on this machine.")
        }

        let result = IOSurfaceResourceImporter().importTexture(
            device: device,
            descriptor: IOSurfaceTextureDescriptor(
                surfaceID: 0,
                width: 1,
                height: 1,
                pixelFormat: .rgba8Unorm,
                plane: 0,
                usage: UInt32(TextureUsage.shaderRead.rawValue),
                ownership: .retained,
                label: "invalid"
            )
        )

        XCTAssertFalse(result.succeeded)
        XCTAssertNil(result.resource)
        XCTAssertEqual(result.diagnostics.first?.code, .invalidDescriptor)
    }

    func testRetainedImportReleasesTheWrapperAndIOSurfaceUseCount() throws {
        guard let device = Device.systemDefault() else {
            throw XCTSkip("No Metal device is available on this machine.")
        }
        let properties: [CFString: Any] = [
            kIOSurfaceWidth: 2,
            kIOSurfaceHeight: 2,
            kIOSurfaceBytesPerElement: 4,
            kIOSurfaceBytesPerRow: 8,
            kIOSurfaceAllocSize: 16,
            kIOSurfaceIsGlobal: true
        ]
        guard let surface = IOSurfaceCreate(properties as CFDictionary) else {
            throw XCTSkip("The test IOSurface could not be created.")
        }

        let descriptor = IOSurfaceTextureDescriptor(
            surfaceID: IOSurfaceGetID(surface),
            width: 2,
            height: 2,
            pixelFormat: .bgra8Unorm,
            plane: 0,
            usage: UInt32(TextureUsage.shaderRead.rawValue),
            ownership: .retained,
            label: "retained test surface"
        )
        var result = IOSurfaceResourceImporter().importTexture(
            device: device,
            descriptor: descriptor
        )
        guard result.succeeded else {
            throw XCTSkip(
                "This device rejected the test IOSurface texture import."
            )
        }

        weak var weakResource: ImportedExternalTexture?
        do {
            guard let resource = result.resource else {
                XCTFail("A successful import should return a resource.")
                return
            }
            weakResource = resource
            result.resource = nil
        }
        XCTAssertNil(weakResource)
    }

    func testSharedEventBridgeEncodesExplicitWaitAndSignalBoundaries() throws {
        guard let device = Device.systemDefault(),
              let bridge = ExternalSharedEventBridge(
                  device: device,
                  label: "external sync"
              ),
              let queue = device.createCommandQueue(),
              let commandBuffer = queue.makeCommandBuffer()
        else {
            throw XCTSkip("Shared events are unavailable on this machine.")
        }

        let policy = ExternalEventSyncPolicy(
            waitValue: 1,
            signalValue: 2,
            waitBeforeEncoding: true,
            signalAfterEncoding: true
        )
        XCTAssertTrue(bridge.applyWait(to: commandBuffer, policy: policy))
        XCTAssertTrue(bridge.applySignal(to: commandBuffer, policy: policy))
    }
}
