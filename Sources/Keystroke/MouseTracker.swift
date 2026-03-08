import SwiftUI

@MainActor
final class MouseTracker: ObservableObject {
    @Published var cursorPosition: CGPoint = .zero
    @Published var clicks: [ClickEvent] = []
    @Published var isEnabled: Bool = true
    @Published var glowColor: Color = .yellow
}
