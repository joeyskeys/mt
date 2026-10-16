import XCTest
@testable import MTCore

final class CommandsTests: XCTestCase {
    func testCommandBufferRequiresEncodersToEndBeforeCommit() {
        guard let device = Device.systemDefault(),
              let queue = device.createCommandQueue(),
              let commandBuffer = queue.makeCommandBuffer(),
              let surface = Surface.offscreen(
                  device: device,
                  width: 32,
                  height: 32,
                  format: .bgra8Unorm
              ),
              let drawable = surface.nextDrawable(),
              let descriptor = surface.makeRenderPassDescriptor(drawable),
              let encoder = commandBuffer.makeRenderEncoder(descriptor)
        else {
            return
        }

        XCTAssertTrue(commandBuffer.hasActiveEncoder)
        XCTAssertFalse(commandBuffer.commit())
        XCTAssertTrue(encoder.endEncoding())
        XCTAssertFalse(commandBuffer.hasActiveEncoder)
        XCTAssertTrue(commandBuffer.commit())
        XCTAssertFalse(commandBuffer.commit())
    }

    func testCommandBufferCreatesFocusedEncoderTypes() {
        guard let device = Device.systemDefault(),
              let queue = device.createCommandQueue(),
              let commandBuffer = queue.makeCommandBuffer()
        else {
            return
        }

        guard let compute = commandBuffer.makeComputeEncoder() else {
            return
        }
        XCTAssertTrue(compute.endEncoding())

        guard let blit = commandBuffer.makeBlitEncoder() else {
            return
        }
        XCTAssertTrue(blit.endEncoding())
        XCTAssertTrue(commandBuffer.commit())
    }

    func testOffscreenSurfaceAndRenderPassValidation() {
        guard let device = Device.systemDefault(),
              let surface = Surface.offscreen(
                  device: device,
                  width: 64,
                  height: 48,
                  format: .bgra8Unorm
              )
        else {
            return
        }

        XCTAssertEqual(surface.drawableSize.width, 64)
        XCTAssertEqual(surface.drawableSize.height, 48)
        XCTAssertEqual(surface.colorFormat, .bgra8Unorm)
        XCTAssertFalse(surface.isLayerBacked)

        guard let drawable = surface.nextDrawable(),
              let descriptor = surface.makeRenderPassDescriptor(drawable)
        else {
            XCTFail("An offscreen surface should provide a drawable.")
            return
        }

        XCTAssertFalse(drawable.isPresentable)
        XCTAssertTrue(descriptor.validate())
        XCTAssertEqual(descriptor.sampleCount, 1)
        XCTAssertEqual(descriptor.colorFormat, .bgra8Unorm)
        XCTAssertEqual(descriptor.colorLoadAction, .clear)
        XCTAssertEqual(descriptor.colorStoreAction, .store)

        descriptor.colorStoreAction = .multisampleResolve
        XCTAssertFalse(descriptor.validate())
        descriptor.colorStoreAction = .store

        descriptor.clearColor = ClearColor(
            red: 0.1,
            green: 0.2,
            blue: 0.3,
            alpha: 1.0
        )
        XCTAssertTrue(descriptor.validate())
        XCTAssertTrue(surface.resize(width: 80, height: 60))
        XCTAssertEqual(surface.drawableSize.width, 80)
        XCTAssertEqual(surface.drawableSize.height, 60)
    }

    func testFrameSchedulerCommitsAnOffscreenFrameWithoutPresentation() {
        guard let device = Device.systemDefault(),
              let queue = device.createCommandQueue(),
              let surface = Surface.offscreen(
                  device: device,
                  width: 16,
                  height: 16,
                  format: .bgra8Unorm
              )
        else {
            return
        }

        let scheduler = FrameScheduler(queue: queue)
        guard let frame = scheduler.beginFrame(surface) else {
            XCTFail("A frame should be created for an offscreen surface.")
            return
        }

        XCTAssertEqual(frame.frameIndex, 0)
        XCTAssertTrue(frame.hasDrawable)
        XCTAssertNotNil(frame.renderPassDescriptor)
        XCTAssertTrue(scheduler.endFrame(frame, present: false))
        XCTAssertTrue(frame.isEnded)
    }
}

