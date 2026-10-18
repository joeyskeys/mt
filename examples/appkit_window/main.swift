import AppKit
import Foundation
import MTAppKit
import MTCore

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var device: Device?
    private var queue: CommandQueue?
    private var host: AppKitWindowHost?
    private var timer: Timer?

    func applicationDidFinishLaunching(_ notification: Notification) {
        guard let device = Device.systemDefault(),
              let host = AppKitWindowHost(
                  device: device,
                  configuration: AppKitWindowConfiguration(
                      widthPoints: 960,
                      heightPoints: 640,
                      title: "mt AppKit host",
                      pixelFormat: .bgra8Unorm,
                      framebufferOnly: true,
                      presentsWithTransaction: false,
                      displaySyncEnabled: true
                  )
              ),
              let queue = device.createCommandQueue(
                  label: "mt AppKit example queue"
              )
        else {
            NSApp.terminate(nil)
            return
        }

        self.device = device
        self.queue = queue
        self.host = host
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
    }

    @objc private func drawFrame() {
        guard let host,
              let queue,
              let drawable = host.adapter.nextDrawable(),
              let pass = host.adapter.makeRenderPassDescriptor(drawable),
              let commandBuffer = queue.makeCommandBuffer(),
              let encoder = commandBuffer.makeRenderEncoder(pass)
        else {
            return
        }

        pass.clearColor = ClearColor(
            red: 0.08,
            green: 0.16,
            blue: 0.30,
            alpha: 1
        )
        _ = encoder.endEncoding()
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
