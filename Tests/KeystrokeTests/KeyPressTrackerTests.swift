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
    tracker.addKeyPress(characters: "⌘", label: "command")
    tracker.addKeyPress(characters: "⌥", label: "option")
    let firstId = tracker.keyPresses.first!.id
    tracker.removeKeyPress(id: firstId)
    #expect(tracker.keyPresses.count == 1)
    #expect(tracker.keyPresses.first?.characters == "⌥")
}

@Test @MainActor func formatKeyEventBasicCharacter() {
    let result = KeyPressTracker.formatKeyEvent(characters: "a", keyCode: 0)
    #expect(result == "A")
}

@Test @MainActor func formatKeyEventWithCommand() {
    let result = KeyPressTracker.formatKeyEvent(characters: "c", keyCode: 8)
    #expect(result == "C")
}

@Test @MainActor func formatKeyEventWithMultipleModifiers() {
    let result = KeyPressTracker.formatKeyEvent(characters: "c", keyCode: 8)
    #expect(result == "C")
}

@Test @MainActor func formatKeyEventReturnKey() {
    let result = KeyPressTracker.formatKeyEvent(characters: "\r", keyCode: 36)
    #expect(result == "↩")
}

@Test @MainActor func formatKeyEventEscape() {
    let result = KeyPressTracker.formatKeyEvent(characters: "\u{1b}", keyCode: 53)
    #expect(result == "⎋")
}

@Test @MainActor func formatKeyEventTab() {
    let result = KeyPressTracker.formatKeyEvent(characters: "\t", keyCode: 48)
    #expect(result == "⇥")
}

@Test @MainActor func formatKeyEventSpace() {
    let result = KeyPressTracker.formatKeyEvent(characters: " ", keyCode: 49)
    #expect(result == "␣")
}

@Test @MainActor func formatKeyEventDelete() {
    let result = KeyPressTracker.formatKeyEvent(characters: "\u{7f}", keyCode: 51)
    #expect(result == "⌫")
}

@Test @MainActor func formatKeyEventArrowUp() {
    let result = KeyPressTracker.formatKeyEvent(characters: "", keyCode: 126)
    #expect(result == "↑")
}

@Test @MainActor func formatKeyEventArrowDown() {
    let result = KeyPressTracker.formatKeyEvent(characters: "", keyCode: 125)
    #expect(result == "↓")
}

@Test @MainActor func formatKeyEventArrowLeft() {
    let result = KeyPressTracker.formatKeyEvent(characters: "", keyCode: 123)
    #expect(result == "←")
}

@Test @MainActor func formatKeyEventArrowRight() {
    let result = KeyPressTracker.formatKeyEvent(characters: "", keyCode: 124)
    #expect(result == "→")
}

@Test @MainActor func formatKeyEventForwardDelete() {
    let result = KeyPressTracker.formatKeyEvent(characters: "", keyCode: 117)
    #expect(result == "⌦")
}

// MARK: - addKeyPress with label

@Test @MainActor func addKeyPressWithLabel() {
    let tracker = KeyPressTracker()
    tracker.addKeyPress(characters: "⌘", label: "command")
    #expect(tracker.keyPresses.first?.characters == "⌘")
    #expect(tracker.keyPresses.first?.label == "command")
}

@Test @MainActor func addKeyPressWithoutLabel() {
    let tracker = KeyPressTracker()
    tracker.addKeyPress(characters: "A")
    #expect(tracker.keyPresses.first?.label == nil)
}

// MARK: - Clear previous keys on new input

@Test @MainActor func addKeyPressClearsPreviousKeys() {
    let tracker = KeyPressTracker()
    tracker.addKeyPress(characters: "A")
    tracker.addKeyPress(characters: "B")
    #expect(tracker.keyPresses.count == 1)
    #expect(tracker.keyPresses.first?.characters == "B")
}

@Test @MainActor func addKeyPressWithLabelDoesNotClearPrevious() {
    let tracker = KeyPressTracker()
    tracker.addKeyPress(characters: "⌘", label: "command")
    tracker.addKeyPress(characters: "⌥", label: "option")
    #expect(tracker.keyPresses.count == 2)
}

@Test @MainActor func addKeyPressClearsModifiersToo() {
    let tracker = KeyPressTracker()
    tracker.addKeyPress(characters: "⌘", label: "command")
    tracker.addKeyPress(characters: "⌥", label: "option")
    tracker.addKeyPress(characters: "A")
    #expect(tracker.keyPresses.count == 3)
    #expect(tracker.keyPresses[0].characters == "⌘")
    #expect(tracker.keyPresses[1].characters == "⌥")
    #expect(tracker.keyPresses[2].characters == "A")
}

@Test @MainActor func addDuplicateModifierIsIgnored() {
    let tracker = KeyPressTracker()
    tracker.addKeyPress(characters: "⌘", label: "command")
    tracker.addKeyPress(characters: "⌘", label: "command")
    #expect(tracker.keyPresses.count == 1)
}

@Test @MainActor func newModifierAfterRegularKeyClearsPrevious() {
    let tracker = KeyPressTracker()
    tracker.addKeyPress(characters: "A")
    tracker.addKeyPress(characters: "⌘", label: "command")
    #expect(tracker.keyPresses.count == 1)
    #expect(tracker.keyPresses.first?.characters == "⌘")
}

// MARK: - Generation tracking

@Test @MainActor func generationStartsAtZero() {
    let tracker = KeyPressTracker()
    #expect(tracker.generation == 0)
}

@Test @MainActor func generationIncrementsWhenRegularKeyClearsOld() {
    let tracker = KeyPressTracker()
    tracker.addKeyPress(characters: "A")
    let gen1 = tracker.generation
    tracker.addKeyPress(characters: "B")
    #expect(tracker.generation == gen1 + 1)
}

@Test @MainActor func generationDoesNotIncrementForModifierAccumulation() {
    let tracker = KeyPressTracker()
    tracker.addKeyPress(characters: "⌘", label: "command")
    let gen1 = tracker.generation
    tracker.addKeyPress(characters: "⌥", label: "option")
    #expect(tracker.generation == gen1)
}

// MARK: - Modifier-only key detection

@Test @MainActor func formatModifierChangeCommand() {
    let result = KeyPressTracker.formatModifierChange(oldFlags: [], newFlags: .command)
    #expect(result?.count == 1)
    #expect(result?.first?.symbol == "⌘")
    #expect(result?.first?.label == "command")
}

@Test @MainActor func formatModifierChangeShift() {
    let result = KeyPressTracker.formatModifierChange(oldFlags: [], newFlags: .shift)
    #expect(result?.count == 1)
    #expect(result?.first?.symbol == "⇧")
    #expect(result?.first?.label == "shift")
}

@Test @MainActor func formatModifierChangeOption() {
    let result = KeyPressTracker.formatModifierChange(oldFlags: [], newFlags: .option)
    #expect(result?.count == 1)
    #expect(result?.first?.symbol == "⌥")
    #expect(result?.first?.label == "option")
}

@Test @MainActor func formatModifierChangeControl() {
    let result = KeyPressTracker.formatModifierChange(oldFlags: [], newFlags: .control)
    #expect(result?.count == 1)
    #expect(result?.first?.symbol == "⌃")
    #expect(result?.first?.label == "control")
}

@Test @MainActor func formatModifierChangeReleaseReturnsNil() {
    let result = KeyPressTracker.formatModifierChange(oldFlags: .command, newFlags: [])
    #expect(result == nil)
}

@Test @MainActor func formatModifierChangeMultipleNewModifiers() {
    let result = KeyPressTracker.formatModifierChange(oldFlags: [], newFlags: [.command, .shift])
    #expect(result?.count == 2)
    #expect(result?[0].symbol == "⌘")
    #expect(result?[0].label == "command")
    #expect(result?[1].symbol == "⇧")
    #expect(result?[1].label == "shift")
}
