import SwiftUI

struct CursorGlowView: View {
    let position: CGPoint
    let color: Color
    let style: HighlightStyle

    private var size: CGFloat {
        switch style {
        case .glow: return 80
        case .ring: return 40
        }
    }

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

    private var ringStyle: some View {
        Circle()
            .stroke(color.opacity(0.7), lineWidth: 3)
            .frame(width: size, height: size)
    }
}
