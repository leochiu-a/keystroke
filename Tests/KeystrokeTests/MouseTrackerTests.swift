import Testing
import Foundation
@testable import Keystroke

@Test @MainActor func initialState() {
    let tracker = MouseTracker()
    #expect(tracker.cursorPosition == .zero)
    #expect(tracker.clicks.isEmpty)
    #expect(tracker.isEnabled == true)
    #expect(tracker.highlightStyle == .glow)
}

// MARK: - HighlightStyle

@Test func highlightStyleHasAllCases() {
    let allCases = HighlightStyle.allCases
    #expect(allCases.count == 2)
    #expect(allCases.contains(.glow))
    #expect(allCases.contains(.ring))
}

@Test @MainActor func setHighlightStyle() {
    let tracker = MouseTracker()
    tracker.highlightStyle = .ring
    #expect(tracker.highlightStyle == .ring)
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

// MARK: - Cursor size and ring width

@Test @MainActor func cursorSizeDefaultValue() {
    let tracker = MouseTracker()
    #expect(tracker.cursorSize == 40.0)
}

@Test @MainActor func setCursorSize() {
    let tracker = MouseTracker()
    tracker.cursorSize = 60.0
    #expect(tracker.cursorSize == 60.0)
}

@Test @MainActor func ringWidthDefaultValue() {
    let tracker = MouseTracker()
    #expect(tracker.ringWidth == 5.0)
}

@Test @MainActor func setRingWidth() {
    let tracker = MouseTracker()
    tracker.ringWidth = 8.0
    #expect(tracker.ringWidth == 8.0)
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
