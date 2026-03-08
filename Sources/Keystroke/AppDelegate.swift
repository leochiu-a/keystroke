import AppKit
import SwiftUI

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    var overlayWindow: NSWindow?
    let mouseTracker = MouseTracker()
    var mouseMovedMonitor: Any?
    var mouseClickMonitor: Any?

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupOverlayWindow()
        setupMouseMonitors()
    }

    private func setupOverlayWindow() {
        guard let screen = NSScreen.main else { return }

        let window = NSWindow(
            contentRect: screen.frame,
            styleMask: .borderless,
            backing: .buffered,
            defer: false
        )
        window.level = .screenSaver
        window.isOpaque = false
        window.backgroundColor = .clear
        window.ignoresMouseEvents = true
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        window.contentView = NSHostingView(rootView: OverlayView(tracker: mouseTracker))
        window.orderFrontRegardless()

        overlayWindow = window
    }

    private func setupMouseMonitors() {
        let tracker = mouseTracker

        mouseMovedMonitor = NSEvent.addGlobalMonitorForEvents(matching: .mouseMoved) { event in
            guard let screen = NSScreen.main else { return }
            let point = CGPoint(
                x: event.locationInWindow.x,
                y: screen.frame.height - event.locationInWindow.y
            )
            Task { @MainActor in
                tracker.updatePosition(point)
            }
        }

        mouseClickMonitor = NSEvent.addGlobalMonitorForEvents(
            matching: [.leftMouseDown, .rightMouseDown]
        ) { event in
            guard let screen = NSScreen.main else { return }
            let point = CGPoint(
                x: event.locationInWindow.x,
                y: screen.frame.height - event.locationInWindow.y
            )
            Task { @MainActor in
                tracker.addClick(at: point)
            }
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        if let monitor = mouseMovedMonitor { NSEvent.removeMonitor(monitor) }
        if let monitor = mouseClickMonitor { NSEvent.removeMonitor(monitor) }
    }
}
