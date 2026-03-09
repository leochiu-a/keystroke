import AppKit

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

    private static let maxVisibleKeyPresses = 15

    func addKeyPress(characters: String) {
        guard isEnabled else { return }
        if keyPresses.count >= Self.maxVisibleKeyPresses {
            keyPresses.removeFirst()
        }
        keyPresses.append(KeyPressEvent(characters: characters))
    }

    func removeKeyPress(id: UUID) {
        keyPresses.removeAll { $0.id == id }
    }

    static func formatKeyEvent(characters: String, keyCode: UInt16, modifiers: NSEvent.ModifierFlags) -> String {
        let keyStr: String
        if let special = specialKeys[keyCode] {
            keyStr = special
        } else {
            keyStr = characters.uppercased()
        }

        var prefix = ""
        if modifiers.contains(.control) { prefix += "⌃" }
        if modifiers.contains(.option) { prefix += "⌥" }
        if modifiers.contains(.command) { prefix += "⌘" }
        if modifiers.contains(.shift) { prefix += "⇧" }

        return prefix + keyStr
    }
}
