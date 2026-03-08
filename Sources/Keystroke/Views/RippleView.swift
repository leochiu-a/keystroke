import SwiftUI

struct RippleView: View {
    let position: CGPoint
    let onComplete: () -> Void

    @State private var scale: CGFloat = 0.3
    @State private var opacity: Double = 0.6

    var body: some View {
        Circle()
            .stroke(Color.white.opacity(opacity), lineWidth: 2)
            .frame(width: 80, height: 80)
            .scaleEffect(scale)
            .position(position)
            .allowsHitTesting(false)
            .onAppear {
                withAnimation(.easeOut(duration: 0.5)) {
                    scale = 1.0
                    opacity = 0.0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
                    onComplete()
                }
            }
    }
}
