import AppKit
import MetalKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var window: NSWindow!
    private var renderer: Renderer!

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)

        guard let device = MTLCreateSystemDefaultDevice() else {
            showError("Metal is not supported on this Mac.")
            return
        }

        guard device.supportsFamily(.apple7) else {
            showError(
                """
                Mesh shaders require an Apple Silicon GPU (M1 or later).

                This Mac's CPU architecture is \(hostArchitecture()). \
                The app must be built and run on Apple Silicon to use the mesh shader pipeline.
                """
            )
            return
        }

        let view = MTKView(frame: NSRect(x: 0, y: 0, width: 800, height: 600), device: device)
        view.colorPixelFormat = .bgra8Unorm
        view.clearColor = MTLClearColor(red: 0.08, green: 0.08, blue: 0.12, alpha: 1.0)

        do {
            renderer = try Renderer(device: device, view: view)
        } catch {
            showError(error.localizedDescription)
            return
        }
        view.delegate = renderer

        window = NSWindow(
            contentRect: view.frame,
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.title = "MT — Metal"
        window.contentView = view
        window.center()
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }

    private func hostArchitecture() -> String {
        #if arch(arm64)
        return "arm64"
        #elseif arch(x86_64)
        return "x86_64 (Intel)"
        #else
        return "unknown"
        #endif
    }

    private func showError(_ message: String) {
        NSApp.activate(ignoringOtherApps: true)
        let alert = NSAlert()
        alert.messageText = "MT — Metal"
        alert.informativeText = message
        alert.alertStyle = .critical
        alert.runModal()
        NSApp.terminate(nil)
    }
}
