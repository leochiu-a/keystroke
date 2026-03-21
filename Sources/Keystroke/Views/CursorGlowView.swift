import SwiftUI

struct CursorGlowView: View {
    let position: CGPoint
    let color: Color
    let size: CGFloat
    let ringWidth: CGFloat
    let glowRadius: CGFloat
    let isClicking: Bool

    private var displaySize: CGFloat {
        isClicking ? size * 0.7 : size
    }

    var body: some View {
        ZStack {
            if glowRadius > 0 {
                let glowDisplaySize = isClicking ? (size * 0.7 + glowRadius * 2) : (size + glowRadius * 2)
                let glowStartRadius = isClicking ? (size * 0.7 / 2) : (size / 2)
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [color.opacity(0.5), color.opacity(0.0)]),
                            center: .center,
                            startRadius: glowStartRadius,
                            endRadius: glowStartRadius + glowRadius
                        )
                    )
                    .frame(width: glowDisplaySize, height: glowDisplaySize)
            }

            Circle()
                .stroke(color, lineWidth: ringWidth)
                .frame(width: displaySize, height: displaySize)
        }
        .position(position)
        .animation(.easeOut(duration: 0.1), value: isClicking)
        .animation(nil, value: position)
        .allowsHitTesting(false)
    }
}
