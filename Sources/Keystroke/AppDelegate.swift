import AppKit
import SwiftUI

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    var overlayWindow: NSWindow?
    var controlPanelWindow: NSWindow?
    let mouseTracker = MouseTracker()
    var mouseMovedMonitor: Any?
    var mouseClickMonitor: Any?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        setupOverlayWindow()
        setupMouseMonitors()
        setupControlPanel()
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

    private func setupControlPanel() {
        let panelView = ControlPanelView(tracker: mouseTracker)
        let hostingView = NSHostingView(rootView: panelView)
        hostingView.frame = NSRect(x: 0, y: 0, width: 200, height: 200)

        let window = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 200, height: 200),
            styleMask: [.titled, .closable, .utilityWindow, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        window.title = "Keystroke"
        window.level = .floating
        window.isOpaque = false
        window.backgroundColor = NSColor.windowBackgroundColor
        window.contentView = hostingView
        window.isMovableByWindowBackground = true
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]

        // Position at top-right corner of screen
        if let screen = NSScreen.main {
            let x = screen.visibleFrame.maxX - 220
            let y = screen.visibleFrame.maxY - 220
            window.setFrameOrigin(NSPoint(x: x, y: y))
        }

        window.orderFrontRegardless()
        controlPanelWindow = window
    }

    func applicationWillTerminate(_ notification: Notification) {
        if let monitor = mouseMovedMonitor { NSEvent.removeMonitor(monitor) }
        if let monitor = mouseClickMonitor { NSEvent.removeMonitor(monitor) }
    }
}
