import SwiftUI

struct KeyPressOverlayView: View {
    @ObservedObject var tracker: KeyPressTracker

    var body: some View {
        VStack {
            Spacer()

            HStack(spacing: 6) {
                ForEach(tracker.keyPresses) { keyPress in
                    KeyCapsuleView(keyPress: keyPress) {
                        tracker.removeKeyPress(id: keyPress.id)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
            )
            .padding(.bottom, 60)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .allowsHitTesting(false)
    }
}

private struct KeyCapsuleView: View {
    let keyPress: KeyPressEvent
    let onComplete: () -> Void

    @State private var opacity: Double = 1.0

    private var isModifier: Bool {
        keyPress.label != nil
    }

    var body: some View {
        Group {
            if let label = keyPress.label {
                // Modifier key: symbol top-right, label bottom-left
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Spacer()
                        Text(keyPress.characters)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.white.opacity(0.9))
                    }
                    Text(label)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.white.opacity(0.8))
                }
                .frame(width: 64, height: 52)
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
            } else {
                // Regular key: character centered
                Text(keyPress.characters)
                    .font(.system(size: 22, weight: .medium, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(minWidth: 44, minHeight: 52)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(white: 0.2))
                .shadow(color: .black.opacity(0.4), radius: 1, y: 1)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.white.opacity(0.15), lineWidth: 0.5)
        )
        .opacity(opacity)
        .allowsHitTesting(false)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.easeOut(duration: 0.5)) {
                    opacity = 0.0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
                    onComplete()
                }
            }
        }
    }
}
