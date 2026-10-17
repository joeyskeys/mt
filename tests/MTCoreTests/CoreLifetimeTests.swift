import XCTest
@testable import MTCore

final class CoreLifetimeTests: XCTestCase {
    private func sharedBufferDescriptor(
        length: UInt64,
        label: String
    ) -> BufferDescriptor {
        BufferDescriptor(
            length: length,
            usage: UInt32(
                BufferUsage.storage.rawValue
                    | BufferUsage.readback.rawValue
            ),
            storageMode: .shared,
            cpuCacheMode: .defaultCache,
            hazardMode: .defaultMode,
            label: label
        )
    }

    private func textureDescriptor(
        storageMode: StorageMode,
        label: String
    ) -> TextureDescriptor {
        TextureDescriptor(
            textureType: .twoD,
            pixelFormat: .rgba8Unorm,
            width: 8,
            height: 8,
            depth: 1,
            arrayLength: 1,
            mipLevelCount: 2,
            sampleCount: 1,
            usage: UInt32(
                TextureUsage.shaderRead.rawValue
                    | TextureUsage.shaderWrite.rawValue
                    | TextureUsage.renderTarget.rawValue
            ),
            storageMode: storageMode,
            cpuCacheMode: .defaultCache,
            hazardMode: .defaultMode,
            label: label
        )
    }

    func testTypedRegistryHasNoMetalDeviceDependency() {
        let registry = ResourceRegistry()
        XCTAssertFalse(registry.isThreadSafe)
        XCTAssertEqual(registry.bufferCount, 0)
        XCTAssertEqual(registry.textureCount, 0)
        registry.removeAll()
    }

    func testSubresourceDescriptorsValidateRangesAndPitches() {
        guard let device = Device.systemDefault(),
              let texture = device.createTexture(
                  textureDescriptor(
                      storageMode: .shared,
                      label: "mt subresource texture"
                  )
              )
        else {
            return
        }

        let validRegion = TextureRegion(
            mipLevel: 1,
            slice: 0,
            origin: Extent3D(width: 0, height: 0, depth: 0),
            size: Extent3D(width: 4, height: 4, depth: 1)
        )
        let validTransfer = TextureTransferDescriptor(
            region: validRegion,
            bytesPerRow: 16,
            bytesPerImage: 64
        )
        XCTAssertTrue(texture.validateRegion(validRegion))
        XCTAssertTrue(texture.validateTransfer(validTransfer))

        let outsideRegion = TextureRegion(
            mipLevel: 0,
            slice: 0,
            origin: Extent3D(width: 7, height: 7, depth: 0),
            size: Extent3D(width: 2, height: 2, depth: 1)
        )
        XCTAssertFalse(texture.validateRegion(outsideRegion))

        let shortRowTransfer = TextureTransferDescriptor(
            region: validRegion,
            bytesPerRow: 4,
            bytesPerImage: 16
        )
        XCTAssertFalse(texture.validateTransfer(shortRowTransfer))
    }

    func testPrivateBufferUsesExplicitStagingAndReadback() {
        guard let device = Device.systemDefault(),
              let upload = device.createStagingBuffer(
                  length: 64,
                  usage: UInt32(BufferUsage.storage.rawValue),
                  label: "mt upload staging"
              ),
              let privateBuffer = device.createBuffer(
                  BufferDescriptor(
                      length: 64,
                      usage: UInt32(BufferUsage.storage.rawValue),
                      storageMode: .gpuPrivate,
                      cpuCacheMode: .defaultCache,
                      hazardMode: .defaultMode,
                      label: "mt private transfer"
                  )
              ),
              let readback = device.createStagingBuffer(
                  length: 64,
                  usage: UInt32(BufferUsage.readback.rawValue),
                  label: "mt readback staging"
              ),
              let queue = device.createCommandQueue(),
              let commandBuffer = queue.makeCommandBuffer(),
              let blit = commandBuffer.makeBlitEncoder()
        else {
            return
        }

        let source = Array(repeating: UInt8(9), count: 32)
        source.withUnsafeBytes { bytes in
            XCTAssertTrue(
                upload.uploadRange(
                    source: bytes.baseAddress!,
                    range: BufferRange(offset: 8, length: 32)
                )
            )
        }
        XCTAssertTrue(commandBuffer.retainResource(upload))
        XCTAssertTrue(commandBuffer.retainResource(privateBuffer))
        XCTAssertTrue(commandBuffer.retainResource(readback))
        XCTAssertTrue(
            blit.copyBufferRange(
                source: upload,
                sourceRange: BufferRange(offset: 8, length: 32),
                destination: privateBuffer,
                destinationOffset: 16
            )
        )
        XCTAssertTrue(
            blit.copyBufferRange(
                source: privateBuffer,
                sourceRange: BufferRange(offset: 16, length: 32),
                destination: readback,
                destinationOffset: 0
            )
        )
        XCTAssertTrue(blit.endEncoding())
        XCTAssertTrue(commandBuffer.commit())
        XCTAssertTrue(commandBuffer.waitUntilCompletedSuccessfully())

        var destination = Array(repeating: UInt8(0), count: 32)
        destination.withUnsafeMutableBytes { bytes in
            XCTAssertTrue(
                readback.readRange(
                    destination: bytes.baseAddress!,
                    range: BufferRange(offset: 0, length: 32)
                )
            )
        }
        XCTAssertEqual(destination, source)
    }

    func testManagedBufferSynchronizationDirectionIsExplicit() {
        guard let device = Device.systemDefault(),
              let managed = device.createBuffer(
                  BufferDescriptor(
                      length: 64,
                      usage: UInt32(BufferUsage.storage.rawValue),
                      storageMode: .managed,
                      cpuCacheMode: .defaultCache,
                      hazardMode: .defaultMode,
                      label: "mt managed synchronization"
                  )
              ),
              let queue = device.createCommandQueue(),
              let commandBuffer = queue.makeCommandBuffer(),
              let blit = commandBuffer.makeBlitEncoder()
        else {
            return
        }

        XCTAssertTrue(
            managed.synchronizeForCPUToGPU(
                range: BufferRange(offset: 0, length: 64)
            )
        )
        XCTAssertTrue(
            blit.synchronize(
                managed,
                direction: .gpuToCPU
            )
        )
        XCTAssertTrue(blit.endEncoding())
        XCTAssertTrue(commandBuffer.commit())
        XCTAssertTrue(commandBuffer.waitUntilCompletedSuccessfully())
    }

    func testTextureRegionUploadReadbackAndPrivateCopy() {
        guard let device = Device.systemDefault(),
              let sourceTexture = device.createTexture(
                  textureDescriptor(
                      storageMode: .shared,
                      label: "mt source texture"
                  )
              ),
              let privateTexture = device.createTexture(
                  textureDescriptor(
                      storageMode: .gpuPrivate,
                      label: "mt private texture"
                  )
              ),
              let readbackTexture = device.createTexture(
                  textureDescriptor(
                      storageMode: .shared,
                      label: "mt readback texture"
                  )
              ),
              let queue = device.createCommandQueue(),
              let commandBuffer = queue.makeCommandBuffer()
        else {
            return
        }

        let region = TextureRegion(
            mipLevel: 0,
            slice: 0,
            origin: Extent3D(width: 2, height: 1, depth: 0),
            size: Extent3D(width: 4, height: 3, depth: 1)
        )
        let transfer = TextureTransferDescriptor(
            region: region,
            bytesPerRow: 16,
            bytesPerImage: 48
        )
        let source = Array(repeating: UInt8(5), count: 48)
        source.withUnsafeBytes { bytes in
            XCTAssertTrue(
                sourceTexture.uploadRegion(
                    source: bytes.baseAddress!,
                    transfer: transfer
                )
            )
        }

        guard let blit = commandBuffer.makeBlitEncoder() else {
            XCTFail("A blit encoder should be available.")
            return
        }
        XCTAssertTrue(commandBuffer.retainResource(sourceTexture))
        XCTAssertTrue(commandBuffer.retainResource(privateTexture))
        XCTAssertTrue(commandBuffer.retainResource(readbackTexture))
        XCTAssertTrue(
            blit.copyTextureRegion(
                source: sourceTexture,
                sourceRegion: region,
                destination: privateTexture,
                destinationRegion: region
            )
        )
        XCTAssertTrue(
            blit.copyTextureRegion(
                source: privateTexture,
                sourceRegion: region,
                destination: readbackTexture,
                destinationRegion: region
            )
        )
        XCTAssertTrue(blit.endEncoding())
        XCTAssertTrue(commandBuffer.commit())
        XCTAssertTrue(commandBuffer.waitUntilCompletedSuccessfully())

        var destination = Array(repeating: UInt8(0), count: 48)
        destination.withUnsafeMutableBytes { bytes in
            XCTAssertTrue(
                readbackTexture.readRegion(
                    destination: bytes.baseAddress!,
                    transfer: transfer
                )
            )
        }
        XCTAssertEqual(destination, source)
    }

    func testOffscreenDrawableReadbackUsesExplicitStaging() {
        guard let device = Device.systemDefault(),
              let surface = Surface.offscreen(
                  device: device,
                  width: 8,
                  height: 8,
                  format: .bgra8Unorm
              ),
              let drawable = surface.nextDrawable(),
              let staging = device.createStagingBuffer(
                  length: 8 * 8 * 4,
                  usage: UInt32(BufferUsage.readback.rawValue),
                  label: "mt drawable readback"
              ),
              let queue = device.createCommandQueue(),
              let commandBuffer = queue.makeCommandBuffer(),
              let blit = commandBuffer.makeBlitEncoder()
        else {
            return
        }

        let transfer = TextureTransferDescriptor(
            region: TextureRegion(
                mipLevel: 0,
                slice: 0,
                origin: Extent3D(width: 0, height: 0, depth: 0),
                size: Extent3D(width: 8, height: 8, depth: 1)
            ),
            bytesPerRow: 8 * 4,
            bytesPerImage: 8 * 8 * 4
        )
        XCTAssertTrue(drawable.validateRegion(transfer.region))
        XCTAssertTrue(commandBuffer.retainResource(drawable))
        XCTAssertTrue(commandBuffer.retainResource(staging))
        XCTAssertTrue(
            blit.copyDrawableToBuffer(
                source: drawable,
                transfer: transfer,
                destination: staging,
                destinationOffset: 0
            )
        )
        XCTAssertTrue(blit.endEncoding())
        XCTAssertTrue(commandBuffer.commit())
        XCTAssertTrue(commandBuffer.waitUntilCompletedSuccessfully())
    }

    func testCompletionRetirementVersioningAndRegistryContracts() {
        guard let device = Device.systemDefault(),
              let queue = device.createCommandQueue(),
              let commandBuffer = queue.makeCommandBuffer(),
              let firstBuffer = device.createBuffer(
                  sharedBufferDescriptor(
                      length: 128,
                      label: "mt first version"
                  )
              ),
              let secondBuffer = device.createBuffer(
                  sharedBufferDescriptor(
                      length: 128,
                      label: "mt second version"
                  )
              )
        else {
            return
        }

        let token = commandBuffer.makeCompletionToken()
        XCTAssertFalse(token.isComplete)
        XCTAssertEqual(token.state, .pending)
        XCTAssertTrue(commandBuffer.retainResource(firstBuffer))
        XCTAssertEqual(commandBuffer.retainedResourceCount, 1)

        let retirement = ResourceRetirementQueue()
        XCTAssertTrue(retirement.retireBuffer(firstBuffer, after: token))
        XCTAssertEqual(retirement.count, 1)

        let slot = BufferResourceSlot()
        XCTAssertEqual(slot.install(firstBuffer), 1)
        XCTAssertEqual(
            slot.installAndRetire(
                secondBuffer,
                queue: retirement,
                after: token
            ),
            2
        )
        XCTAssertEqual(slot.buffer?.label, "mt second version")
        XCTAssertEqual(slot.versionInfo.value, 2)
        XCTAssertEqual(slot.versionInfo.label, "mt second version")
        XCTAssertEqual(retirement.count, 2)

        let registry = device.createResourceRegistry()
        XCTAssertFalse(registry.isThreadSafe)
        XCTAssertTrue(
            registry.registerBuffer(
                name: "second",
                buffer: secondBuffer
            )
        )
        XCTAssertFalse(
            registry.registerBuffer(
                name: "second",
                buffer: secondBuffer
            )
        )
        XCTAssertEqual(registry.buffer(named: "second")?.length, 128)
        XCTAssertTrue(registry.removeBuffer(named: "second"))
        XCTAssertEqual(registry.bufferCount, 0)

        guard let allocator = device.createDynamicBuffer(
            capacity: 256,
            alignment: 64,
            label: "mt completion allocator"
        ) else {
            XCTFail("A dynamic buffer allocator should be creatable.")
            return
        }
        XCTAssertNotNil(allocator.allocate(length: 32))
        XCTAssertTrue(allocator.seal(for: commandBuffer))
        XCTAssertFalse(allocator.resetIfIdle())

        XCTAssertTrue(commandBuffer.commit())
        XCTAssertTrue(commandBuffer.waitUntilCompletedSuccessfully())
        XCTAssertTrue(token.isComplete)
        XCTAssertEqual(token.state, .completed)
        XCTAssertEqual(retirement.collectCompleted(), 2)
        XCTAssertEqual(retirement.count, 0)
        XCTAssertEqual(allocator.reclaimCompleted(), 1)
        XCTAssertTrue(allocator.resetIfIdle())
    }
}
