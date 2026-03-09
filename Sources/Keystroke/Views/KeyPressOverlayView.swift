import SwiftUI

struct KeyPressOverlayView: View {
    @ObservedObject var tracker: KeyPressTracker
    let screenHeight: CGFloat

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

    var body: some View {
        Text(keyPress.characters)
            .font(.system(size: 20, weight: .medium, design: .rounded))
            .foregroundStyle(.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.black.opacity(0.7))
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
