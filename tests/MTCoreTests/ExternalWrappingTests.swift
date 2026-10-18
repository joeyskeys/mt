import MTCore
import XCTest

final class ExternalWrappingTests: XCTestCase {
    func testApplicationOwnedResourcesCanBeWrappedWithoutTransferringHandles() {
        guard let device = Device.systemDefault(),
              let buffer = device.createBuffer(
                  BufferDescriptor(
                      length: 64,
                      storageMode: .shared,
                      cpuCacheMode: .defaultCache,
                      hazardMode: .defaultMode,
                      usage: UInt32(BufferUsage.storage.rawValue),
                      label: "producer buffer"
                  )
              ),
              let texture = device.createTexture(
                  TextureDescriptor(
                      textureType: .twoD,
                      pixelFormat: .rgba8Unorm,
                      width: 2,
                      height: 2,
                      depth: 1,
                      arrayLength: 1,
                      mipLevelCount: 1,
                      sampleCount: 1,
                      usage: UInt32(TextureUsage.shaderRead.rawValue),
                      storageMode: .shared,
                      cpuCacheMode: .defaultCache,
                      hazardMode: .defaultMode,
                      label: "producer texture"
                  )
              )
        else {
            throw XCTSkip("No Metal device or shared resources are available.")
        }

        XCTAssertNotNil(
            device.wrapBuffer(
                nativeHandle: buffer.nativeHandle(),
                usage: UInt32(BufferUsage.storage.rawValue),
                label: "wrapped buffer"
            )
        )
        XCTAssertNotNil(
            device.wrapTexture(
                nativeHandle: texture.nativeHandle(),
                usage: UInt32(TextureUsage.shaderRead.rawValue),
                label: "wrapped texture"
            )
        )
    }

    func testWrappingAResourceFromAnotherDeviceIsRejected() {
        let devices = Device.enumerate()
        guard devices.count > 1,
              let source = Device.fromRegistryID(devices[0].registryID),
              let destination = Device.fromRegistryID(devices[1].registryID),
              let buffer = source.createBuffer(
                  BufferDescriptor(
                      length: 64,
                      storageMode: .shared,
                      cpuCacheMode: .defaultCache,
                      hazardMode: .defaultMode,
                      usage: UInt32(BufferUsage.storage.rawValue),
                      label: "foreign buffer"
                  )
              )
        else {
            throw XCTSkip("Two Metal devices are required for this test.")
        }

        XCTAssertNil(
            destination.wrapBuffer(
                nativeHandle: buffer.nativeHandle(),
                usage: UInt32(BufferUsage.storage.rawValue),
                label: "rejected foreign buffer"
            )
        )
    }
}
