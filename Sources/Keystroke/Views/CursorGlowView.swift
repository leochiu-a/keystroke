import SwiftUI

struct CursorGlowView: View {
    let position: CGPoint
    let color: Color
    let size: CGFloat
    let ringWidth: CGFloat
    let glowRadius: CGFloat

    var body: some View {
        ZStack {
            if glowRadius > 0 {
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [color.opacity(0.5), color.opacity(0.0)]),
                            center: .center,
                            startRadius: size / 2,
                            endRadius: size / 2 + glowRadius
                        )
                    )
                    .frame(width: size + glowRadius * 2, height: size + glowRadius * 2)
            }

            Circle()
                .stroke(color.opacity(0.7), lineWidth: ringWidth)
                .frame(width: size, height: size)
        }
        .position(position)
        .animation(nil, value: position)
        .allowsHitTesting(false)
    }
}
