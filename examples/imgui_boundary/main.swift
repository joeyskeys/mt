import AppKit
import Foundation
import MTAppKit
import MTCore
import MTImGui

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var queue: CommandQueue?
    private var host: AppKitWindowHost?
    private var backend: ImGuiBackend?
    private var timer: Timer?

    func applicationDidFinishLaunching(_ notification: Notification) {
        guard let device = Device.systemDefault(),
              let host = AppKitWindowHost(
                  device: device,
                  configuration: AppKitWindowConfiguration(
                      widthPoints: 960,
                      heightPoints: 640,
                      title: "mt ImGui boundary",
                      pixelFormat: .bgra8Unorm,
                      framebufferOnly: true,
                      presentsWithTransaction: false,
                      displaySyncEnabled: true
                  )
              ),
              let queue = device.createCommandQueue(
                  label: "mt ImGui boundary queue"
              ),
              let backend = ImGuiBackend(
                  configuration: ImGuiBackendConfiguration(
                      compiledVersion: ImGuiVersion(
                          major: 1,
                          minor: 90,
                          patch: 0
                      ),
                      allowMinorVersionSkew: true,
                      enableDocking: false,
                      enableViewports: false,
                      requireNativeContext: false
                  )
              ),
              backend.initialize(
                  runtimeVersion: ImGuiVersion(
                      major: 1,
                      minor: 90,
                      patch: 0
                  )
              )
        else {
            NSApp.terminate(nil)
            return
        }

        self.queue = queue
        self.host = host
        self.backend = backend
        host.show()
        timer = Timer.scheduledTimer(
            timeInterval: 1.0 / 60.0,
            target: self,
            selector: #selector(drawFrame),
            userInfo: nil,
            repeats: true
        )
    }

    func applicationShouldTerminateAfterLastWindowClosed(
        _ sender: NSApplication
    ) -> Bool {
        true
    }

    func applicationWillTerminate(_ notification: Notification) {
        timer?.invalidate()
        timer = nil
        _ = backend?.shutdown()
    }

    @objc private func drawFrame() {
        guard let host,
              let queue,
              let backend,
              let drawable = host.adapter.nextDrawable(),
              let pass = host.adapter.makeRenderPassDescriptor(drawable),
              let commandBuffer = queue.makeCommandBuffer(),
              let encoder = commandBuffer.makeRenderEncoder(pass)
        else {
            return
        }

        let extent = host.adapter.drawableSize
        let frame = ImGuiFrameInfo(
            frameIndex: 0,
            deltaTime: 1.0 / 60.0,
            displaySize: extent,
            framebufferScale: Vector2(
                x: Float(host.adapter.scaleFactor),
                y: Float(host.adapter.scaleFactor)
            )
        )
        guard backend.beginFrame(frame) else {
            return
        }
        pass.clearColor = ClearColor(
            red: 0.12,
            green: 0.08,
            blue: 0.18,
            alpha: 1
        )
        _ = backend.submitDrawData(
            ImGuiDrawDataSummary(
                vertexCount: 0,
                indexCount: 0,
                commandCount: 0,
                textureCount: 0,
                displaySize: extent
            ),
            to: commandBuffer
        )
        _ = encoder.endEncoding()
        _ = backend.endFrame()
        guard host.adapter.present(drawable, on: commandBuffer) else {
            return
        }
        _ = commandBuffer.commit()
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.regular)
app.activate(ignoringOtherApps: true)
app.run()
