import AppKit

struct ModifierInfo {
    let symbol: String
    let label: String
}

@MainActor
final class KeyPressTracker: ObservableObject {
    @Published var keyPresses: [KeyPressEvent] = []
    @Published var isEnabled: Bool = true

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
        if keyPresses.count >= Self.maxVisibleKeyPresses {
            keyPresses.removeFirst()
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

    static func formatKeyEvent(characters: String, keyCode: UInt16, modifiers: NSEvent.ModifierFlags) -> String {
        let keyStr: String
        if let special = specialKeys[keyCode] {
            keyStr = special
        } else {
            keyStr = characters.uppercased()
        }

        var prefix = ""
        for mod in self.modifiers where modifiers.contains(mod.flag) {
            prefix += mod.symbol
        }

        return prefix + keyStr
    }
}
