import SwiftUI

@MainActor
final class MouseTracker: ObservableObject {
    @Published var cursorPosition: CGPoint = .zero
    @Published var clicks: [ClickEvent] = []
    @Published var isEnabled: Bool = true
    @Published var glowColor: Color = .yellow
    @Published var cursorSize: CGFloat = 40.0
    @Published var ringWidth: CGFloat = 5.0
    @Published var glowRadius: CGFloat = 0.0
    @Published var isRippleEnabled: Bool = true
    @Published var isClicking: Bool = false

    func updatePosition(_ point: CGPoint) {
        guard isEnabled else { return }
        cursorPosition = point
    }

    func addClick(at position: CGPoint) {
        guard isEnabled else { return }
        clicks.append(ClickEvent(position: position))
    }

    func removeClick(id: UUID) {
        clicks.removeAll { $0.id == id }
    }
}
