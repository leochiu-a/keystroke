import SwiftUI

struct OverlayView: View {
    @ObservedObject var tracker: MouseTracker

    var body: some View {
        ZStack {
            if tracker.isEnabled {
                CursorGlowView(position: tracker.cursorPosition, color: tracker.glowColor, style: tracker.highlightStyle)

                ForEach(tracker.clicks) { click in
                    RippleView(click: click) {
                        tracker.removeClick(id: click.id)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .allowsHitTesting(false)
    }
}
