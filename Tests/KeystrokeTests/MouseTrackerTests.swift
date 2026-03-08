import Testing
import Foundation
@testable import Keystroke

@Test @MainActor func initialState() {
    let tracker = MouseTracker()
    #expect(tracker.cursorPosition == .zero)
    #expect(tracker.clicks.isEmpty)
    #expect(tracker.isEnabled == true)
}

@Test @MainActor func updatePosition() {
    let tracker = MouseTracker()
    tracker.updatePosition(CGPoint(x: 42, y: 99))
    #expect(tracker.cursorPosition == CGPoint(x: 42, y: 99))
}

@Test @MainActor func updatePositionIgnoredWhenDisabled() {
    let tracker = MouseTracker()
    tracker.isEnabled = false
    tracker.updatePosition(CGPoint(x: 42, y: 99))
    #expect(tracker.cursorPosition == .zero)
}

@Test @MainActor func addClick() {
    let tracker = MouseTracker()
    let pos = CGPoint(x: 10, y: 20)
    tracker.addClick(at: pos)
    #expect(tracker.clicks.count == 1)
    #expect(tracker.clicks.first?.position == pos)
}

@Test @MainActor func addClickIgnoredWhenDisabled() {
    let tracker = MouseTracker()
    tracker.isEnabled = false
    tracker.addClick(at: CGPoint(x: 10, y: 20))
    #expect(tracker.clicks.isEmpty)
}

@Test @MainActor func removeClick() {
    let tracker = MouseTracker()
    tracker.addClick(at: .zero)
    let clickId = tracker.clicks.first!.id
    tracker.removeClick(id: clickId)
    #expect(tracker.clicks.isEmpty)
}

@Test @MainActor func removeClickOnlyRemovesTarget() {
    let tracker = MouseTracker()
    tracker.addClick(at: CGPoint(x: 1, y: 1))
    tracker.addClick(at: CGPoint(x: 2, y: 2))
    let firstId = tracker.clicks.first!.id
    tracker.removeClick(id: firstId)
    #expect(tracker.clicks.count == 1)
    #expect(tracker.clicks.first?.position == CGPoint(x: 2, y: 2))
}
