import SwiftUI

struct CursorGlowView: View {
    let position: CGPoint
    let color: Color
    let style: HighlightStyle
    let size: CGFloat
    let ringWidth: CGFloat

    private var glowSize: CGFloat { size * 2 }

    var body: some View {
        Group {
            switch style {
            case .glow:
                glowStyle
            case .ring:
                ringStyle
            }
        }
        .position(position)
        .animation(nil, value: position)
        .allowsHitTesting(false)
    }

    private var glowStyle: some View {
        Circle()
            .fill(
                RadialGradient(
                    gradient: Gradient(colors: [color.opacity(0.5), color.opacity(0.0)]),
                    center: .center,
                    startRadius: 0,
                    endRadius: glowSize / 2
                )
            )
            .frame(width: glowSize, height: glowSize)
    }

    private var ringStyle: some View {
        Circle()
            .stroke(color.opacity(0.7), lineWidth: ringWidth)
            .frame(width: size, height: size)
    }
}
