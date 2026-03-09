import AppKit
import SwiftUI

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    var overlayWindows: [NSWindow] = []
    var controlPanelWindow: NSWindow?
    let mouseTracker = MouseTracker()
    var mouseMovedMonitor: Any?
    var mouseClickMonitor: Any?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        setupOverlayWindows()
        setupMouseMonitors()
        setupControlPanel()
    }

    private func setupOverlayWindows() {
        for screen in NSScreen.screens {
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
            window.contentView = NSHostingView(
                rootView: OverlayView(tracker: mouseTracker, screenFrame: screen.frame)
            )
            window.setFrame(screen.frame, display: true)
            window.orderFrontRegardless()
            overlayWindows.append(window)
        }
    }

    private func setupMouseMonitors() {
        let tracker = mouseTracker

        mouseMovedMonitor = NSEvent.addGlobalMonitorForEvents(
            matching: [.mouseMoved, .leftMouseDragged, .rightMouseDragged, .otherMouseDragged]
        ) { _ in
            let mouseLocation = NSEvent.mouseLocation
            Task { @MainActor in
                tracker.updatePosition(mouseLocation)
            }
        }

        mouseClickMonitor = NSEvent.addGlobalMonitorForEvents(
            matching: [.leftMouseDown, .rightMouseDown]
        ) { _ in
            let mouseLocation = NSEvent.mouseLocation
            Task { @MainActor in
                tracker.addClick(at: mouseLocation)
            }
        }
    }

    private func setupControlPanel() {
        let panelView = ControlPanelView(tracker: mouseTracker)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        let hostingView = NSHostingView(rootView: panelView)

        let window = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 220, height: 320),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        window.level = .floating
        window.isOpaque = false
        window.backgroundColor = .clear
        window.hasShadow = true
        window.contentView = hostingView
        window.isMovableByWindowBackground = true
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]

        // Position at top-right corner of screen
        if let screen = NSScreen.main {
            let x = screen.visibleFrame.maxX - 240
            let y = screen.visibleFrame.maxY - 340
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
