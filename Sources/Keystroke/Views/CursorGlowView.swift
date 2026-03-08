import SwiftUI

struct CursorGlowView: View {
    let position: CGPoint
    let color: Color
    let size: CGFloat = 80

    var body: some View {
        Circle()
            .fill(
                RadialGradient(
                    gradient: Gradient(colors: [color.opacity(0.5), color.opacity(0.0)]),
                    center: .center,
                    startRadius: 0,
                    endRadius: size / 2
                )
            )
            .frame(width: size, height: size)
            .position(position)
            .allowsHitTesting(false)
    }
}
