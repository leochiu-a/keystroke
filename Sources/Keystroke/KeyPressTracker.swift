import AppKit

struct ModifierInfo {
    let symbol: String
    let label: String
}

@MainActor
final class KeyPressTracker: ObservableObject {
    @Published var keyPresses: [KeyPressEvent] = []
    @Published var isEnabled: Bool = true
    @Published var generation: Int = 0

    private static let specialKeys: [UInt16: String] = [
        36: "↩",    // Return
        48: "⇥",    // Tab
        49: "␣",    // Space
        51: "⌫",    // Delete
        53: "⎋",    // Escape
        117: "⌦",   // Forward Delete
        123: "←",   // Arrow Left
        124: "→",   // Arrow Right
        125: "↓",   // Arrow Down
        126: "↑",   // Arrow Up
    ]

    private static let modifiers: [(flag: NSEvent.ModifierFlags, symbol: String, label: String)] = [
        (.control, "⌃", "control"),
        (.option, "⌥", "option"),
        (.command, "⌘", "command"),
        (.shift, "⇧", "shift"),
    ]

    private static let maxVisibleKeyPresses = 15

    func addKeyPress(characters: String, label: String? = nil) {
        guard isEnabled else { return }
        guard !characters.isEmpty else { return }

        let isModifier = label != nil
        let hasRegularKey = keyPresses.contains { $0.label == nil }

        if hasRegularKey {
            keyPresses.removeAll()
            generation += 1
        }

        if isModifier && !keyPresses.isEmpty && keyPresses.last?.label == nil {
            keyPresses.removeAll()
            generation += 1
        }

        if isModifier && keyPresses.contains(where: { $0.characters == characters }) {
            generation += 1
        }

        keyPresses.append(KeyPressEvent(characters: characters, label: label))
    }

    func removeKeyPress(id: UUID) {
        keyPresses.removeAll { $0.id == id }
    }

    static func formatModifierChange(oldFlags: NSEvent.ModifierFlags, newFlags: NSEvent.ModifierFlags) -> [ModifierInfo]? {
        let pressed = newFlags.subtracting(oldFlags)
        if pressed.isEmpty { return nil }

        let result = modifiers
            .filter { pressed.contains($0.flag) }
            .map { ModifierInfo(symbol: $0.symbol, label: $0.label) }

        return result.isEmpty ? nil : result
    }

    static func formatKeyEvent(characters: String, keyCode: UInt16) -> String {
        if let special = specialKeys[keyCode] {
            return special
        }
        return characters.uppercased()
    }
}
