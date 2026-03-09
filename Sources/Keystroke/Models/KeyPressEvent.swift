import Foundation

struct KeyPressEvent: Identifiable {
    let id = UUID()
    let characters: String
    let timestamp = Date()
}
