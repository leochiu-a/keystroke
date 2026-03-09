import AppKit
import SwiftUI

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    var overlayWindows: [NSWindow] = []
    var mainWindow: NSWindow?
    let mouseTracker = MouseTracker()
    var mouseMovedMonitor: Any?
    var mouseClickMonitor: Any?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        setupOverlayWindows()
        setupMouseMonitors()
        setupMainWindow()
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

    private func setupMainWindow() {
        let mainView = MainWindowView(tracker: mouseTracker)
        let hostingView = NSHostingView(rootView: mainView)

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 700, height: 480),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.title = "Keystroke"
        window.contentView = hostingView
        window.contentMinSize = NSSize(width: 550, height: 400)
        window.appearance = NSAppearance(named: .aqua)
        window.center()
        window.makeKeyAndOrderFront(nil)

        mainWindow = window
    }

    func applicationWillTerminate(_ notification: Notification) {
        if let monitor = mouseMovedMonitor { NSEvent.removeMonitor(monitor) }
        if let monitor = mouseClickMonitor { NSEvent.removeMonitor(monitor) }
    }
}
