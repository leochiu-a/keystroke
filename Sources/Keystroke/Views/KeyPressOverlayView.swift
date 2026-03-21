import SwiftUI

struct KeyPressOverlayView: View {
    @ObservedObject var tracker: KeyPressTracker

    @State private var opacity: Double = 1.0
    @State private var currentGeneration: Int = 0
    @State private var fadeWork: DispatchWorkItem?

    var body: some View {
        VStack {
            Spacer()

            if !tracker.keyPresses.isEmpty {
                HStack(spacing: 6) {
                    ForEach(tracker.keyPresses) { keyPress in
                        KeyCapsuleView(keyPress: keyPress)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(white: 0.85).opacity(0.9))
                )
                .padding(.bottom, 60)
                .opacity(opacity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .allowsHitTesting(false)
        .onChange(of: tracker.generation) { _, newGen in
            // New group arrived — reset opacity and restart fade timer
            fadeWork?.cancel()
            opacity = 1.0
            currentGeneration = newGen
            scheduleFadeOut()
        }
        .onChange(of: tracker.keyPresses.count) { oldCount, newCount in
            if oldCount == 0 && newCount > 0 {
                // First keys appeared (no generation change needed)
                fadeWork?.cancel()
                opacity = 1.0
                scheduleFadeOut()
            }
        }
    }

    private func scheduleFadeOut() {
        let work = DispatchWorkItem { [self] in
            withAnimation(.easeOut(duration: 0.5)) {
                opacity = 0.0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
                tracker.keyPresses.removeAll()
            }
        }
        fadeWork = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: work)
    }
}

private struct KeyCapsuleView: View {
    let keyPress: KeyPressEvent

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
            ZStack {
                // Bottom edge for 3D depth
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(white: 0.05))
                    .offset(y: 3)

                // Key face
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(white: 0.15))
            }
            .shadow(color: .black.opacity(0.5), radius: 3, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.2),
                            Color.white.opacity(0.05)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 0.5
                )
        )
        .allowsHitTesting(false)
    }
}
