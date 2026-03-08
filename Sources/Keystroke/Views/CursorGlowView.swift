import SwiftUI

struct CursorGlowView: View {
    let position: CGPoint
    let color: Color
    let style: HighlightStyle
    let size: CGFloat = 80

    var body: some View {
        Group {
            switch style {
            case .glow:
                glowStyle
            case .neonRing:
                neonRingStyle
            case .transparentRing:
                transparentRingStyle
            }
        }
        .position(position)
        .allowsHitTesting(false)
    }

    private var glowStyle: some View {
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
    }

    private var neonRingStyle: some View {
        ZStack {
            // Outer glow
            Circle()
                .stroke(color.opacity(0.3), lineWidth: 6)
                .frame(width: size, height: size)
                .blur(radius: 4)

            // Main ring
            Circle()
                .stroke(color.opacity(0.8), lineWidth: 2)
                .frame(width: size, height: size)

            // Inner glow
            Circle()
                .stroke(color.opacity(0.4), lineWidth: 4)
                .frame(width: size - 4, height: size - 4)
                .blur(radius: 2)
        }
    }

    private var transparentRingStyle: some View {
        Circle()
            .stroke(color.opacity(0.6), lineWidth: 2)
            .frame(width: size, height: size)
    }
}
