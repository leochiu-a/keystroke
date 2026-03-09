import Foundation

struct KeyPressEvent: Identifiable {
    let id = UUID()
    let characters: String
    let label: String?
    let timestamp = Date()

    init(characters: String, label: String? = nil) {
        self.characters = characters
        self.label = label
    }
}
