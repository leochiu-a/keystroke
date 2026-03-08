import Foundation

struct ClickEvent: Identifiable {
    let id = UUID()
    let position: CGPoint
    let timestamp = Date()
}
