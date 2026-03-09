import Testing
import AppKit
@testable import Keystroke

@Test @MainActor func keyPressTrackerInitialState() {
    let tracker = KeyPressTracker()
    #expect(tracker.keyPresses.isEmpty)
    #expect(tracker.isEnabled == true)
}

@Test @MainActor func addKeyPress() {
    let tracker = KeyPressTracker()
    tracker.addKeyPress(characters: "A")
    #expect(tracker.keyPresses.count == 1)
    #expect(tracker.keyPresses.first?.characters == "A")
}

@Test @MainActor func addKeyPressIgnoredWhenDisabled() {
    let tracker = KeyPressTracker()
    tracker.isEnabled = false
    tracker.addKeyPress(characters: "A")
    #expect(tracker.keyPresses.isEmpty)
}

@Test @MainActor func removeKeyPress() {
    let tracker = KeyPressTracker()
    tracker.addKeyPress(characters: "A")
    let id = tracker.keyPresses.first!.id
    tracker.removeKeyPress(id: id)
    #expect(tracker.keyPresses.isEmpty)
}

@Test @MainActor func removeKeyPressOnlyRemovesTarget() {
    let tracker = KeyPressTracker()
    tracker.addKeyPress(characters: "A")
    tracker.addKeyPress(characters: "B")
    let firstId = tracker.keyPresses.first!.id
    tracker.removeKeyPress(id: firstId)
    #expect(tracker.keyPresses.count == 1)
    #expect(tracker.keyPresses.first?.characters == "B")
}

@Test @MainActor func formatKeyEventBasicCharacter() {
    let result = KeyPressTracker.formatKeyEvent(characters: "a", keyCode: 0, modifiers: [])
    #expect(result == "A")
}

@Test @MainActor func formatKeyEventWithCommand() {
    let result = KeyPressTracker.formatKeyEvent(characters: "c", keyCode: 8, modifiers: .command)
    #expect(result == "⌘C")
}

@Test @MainActor func formatKeyEventWithMultipleModifiers() {
    let result = KeyPressTracker.formatKeyEvent(characters: "c", keyCode: 8, modifiers: [.command, .shift])
    #expect(result == "⌘⇧C")
}

@Test @MainActor func formatKeyEventReturnKey() {
    let result = KeyPressTracker.formatKeyEvent(characters: "\r", keyCode: 36, modifiers: [])
    #expect(result == "↩")
}

@Test @MainActor func formatKeyEventEscape() {
    let result = KeyPressTracker.formatKeyEvent(characters: "\u{1b}", keyCode: 53, modifiers: [])
    #expect(result == "⎋")
}

@Test @MainActor func formatKeyEventTab() {
    let result = KeyPressTracker.formatKeyEvent(characters: "\t", keyCode: 48, modifiers: [])
    #expect(result == "⇥")
}

@Test @MainActor func formatKeyEventSpace() {
    let result = KeyPressTracker.formatKeyEvent(characters: " ", keyCode: 49, modifiers: [])
    #expect(result == "␣")
}

@Test @MainActor func formatKeyEventDelete() {
    let result = KeyPressTracker.formatKeyEvent(characters: "\u{7f}", keyCode: 51, modifiers: [])
    #expect(result == "⌫")
}

@Test @MainActor func formatKeyEventArrowUp() {
    let result = KeyPressTracker.formatKeyEvent(characters: "", keyCode: 126, modifiers: [])
    #expect(result == "↑")
}

@Test @MainActor func formatKeyEventArrowDown() {
    let result = KeyPressTracker.formatKeyEvent(characters: "", keyCode: 125, modifiers: [])
    #expect(result == "↓")
}

@Test @MainActor func formatKeyEventArrowLeft() {
    let result = KeyPressTracker.formatKeyEvent(characters: "", keyCode: 123, modifiers: [])
    #expect(result == "←")
}

@Test @MainActor func formatKeyEventArrowRight() {
    let result = KeyPressTracker.formatKeyEvent(characters: "", keyCode: 124, modifiers: [])
    #expect(result == "→")
}

@Test @MainActor func formatKeyEventForwardDelete() {
    let result = KeyPressTracker.formatKeyEvent(characters: "", keyCode: 117, modifiers: [])
    #expect(result == "⌦")
}
