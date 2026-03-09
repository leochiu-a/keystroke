import AppKit
import SwiftUI

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    var overlayWindows: [NSWindow] = []
    var mainWindow: NSWindow?
    let mouseTracker = MouseTracker()
    let keyPressTracker = KeyPressTracker()
    var globalMouseMovedMonitor: Any?
    var localMouseMovedMonitor: Any?
    var globalMouseClickMonitor: Any?
    var localMouseClickMonitor: Any?
    var globalMouseUpMonitor: Any?
    var localMouseUpMonitor: Any?
    var globalKeyDownMonitor: Any?
    var localKeyDownMonitor: Any?
    var globalFlagsChangedMonitor: Any?
    var localFlagsChangedMonitor: Any?
    var previousModifierFlags: NSEvent.ModifierFlags = []

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        setupOverlayWindows()
        setupMouseMonitors()
        setupKeyboardMonitors()
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
                rootView: OverlayView(
                    mouseTracker: mouseTracker,
                    keyPressTracker: keyPressTracker,
                    screenFrame: screen.frame
                )
            )
            window.setFrame(screen.frame, display: true)
            window.orderFrontRegardless()
            overlayWindows.append(window)
        }
    }

    private func setupMouseMonitors() {
        let tracker = mouseTracker
        let moveEvents: NSEvent.EventTypeMask = [.mouseMoved, .leftMouseDragged, .rightMouseDragged, .otherMouseDragged]
        let clickEvents: NSEvent.EventTypeMask = [.leftMouseDown, .rightMouseDown]

        let handleMove: (NSEvent) -> Void = { _ in
            MainActor.assumeIsolated {
                tracker.updatePosition(NSEvent.mouseLocation)
            }
        }

        let handleClick: (NSEvent) -> Void = { _ in
            MainActor.assumeIsolated {
                tracker.addClick(at: NSEvent.mouseLocation)
                tracker.isClicking = true
            }
        }

        let mouseUpEvents: NSEvent.EventTypeMask = [.leftMouseUp, .rightMouseUp]
        let handleMouseUp: (NSEvent) -> Void = { _ in
            MainActor.assumeIsolated {
                tracker.isClicking = false
            }
        }

        // Global monitors: events from other apps
        globalMouseMovedMonitor = NSEvent.addGlobalMonitorForEvents(matching: moveEvents, handler: handleMove)
        globalMouseClickMonitor = NSEvent.addGlobalMonitorForEvents(matching: clickEvents, handler: handleClick)
        globalMouseUpMonitor = NSEvent.addGlobalMonitorForEvents(matching: mouseUpEvents, handler: handleMouseUp)

        // Local monitors: events within our own app
        localMouseMovedMonitor = NSEvent.addLocalMonitorForEvents(matching: moveEvents) { event in
            handleMove(event)
            return event
        }
        localMouseClickMonitor = NSEvent.addLocalMonitorForEvents(matching: clickEvents) { event in
            handleClick(event)
            return event
        }
        localMouseUpMonitor = NSEvent.addLocalMonitorForEvents(matching: mouseUpEvents) { event in
            handleMouseUp(event)
            return event
        }
    }

    private func setupKeyboardMonitors() {
        let tracker = keyPressTracker

        let handleKeyDown: (NSEvent) -> Void = { event in
            MainActor.assumeIsolated {
                let formatted = KeyPressTracker.formatKeyEvent(
                    characters: event.charactersIgnoringModifiers ?? "",
                    keyCode: event.keyCode,
                    modifiers: event.modifierFlags.intersection(.deviceIndependentFlagsMask)
                )
                tracker.addKeyPress(characters: formatted)
            }
        }

        let handleFlagsChanged: (NSEvent) -> Void = { [weak self] event in
            MainActor.assumeIsolated {
                guard let self else { return }
                let newFlags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
                if let modifiers = KeyPressTracker.formatModifierChange(oldFlags: self.previousModifierFlags, newFlags: newFlags) {
                    for mod in modifiers {
                        tracker.addKeyPress(characters: mod.symbol, label: mod.label)
                    }
                }
                self.previousModifierFlags = newFlags
            }
        }

        globalKeyDownMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown, handler: handleKeyDown)
        localKeyDownMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            handleKeyDown(event)
            return event
        }
        globalFlagsChangedMonitor = NSEvent.addGlobalMonitorForEvents(matching: .flagsChanged, handler: handleFlagsChanged)
        localFlagsChangedMonitor = NSEvent.addLocalMonitorForEvents(matching: .flagsChanged) { event in
            handleFlagsChanged(event)
            return event
        }
    }

    private func setupMainWindow() {
        let mainView = MainWindowView(mouseTracker: mouseTracker, keyPressTracker: keyPressTracker)
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
        for monitor in [globalMouseMovedMonitor, localMouseMovedMonitor, globalMouseClickMonitor, localMouseClickMonitor, globalMouseUpMonitor, localMouseUpMonitor, globalKeyDownMonitor, localKeyDownMonitor, globalFlagsChangedMonitor, localFlagsChangedMonitor] {
            if let monitor { NSEvent.removeMonitor(monitor) }
        }
    }
}
