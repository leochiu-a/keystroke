import SwiftUI

struct OverlayView: View {
    @ObservedObject var tracker: MouseTracker
    let screenFrame: CGRect

    private var localCursorPosition: CGPoint {
        CoordinateHelper.screenPointToOverlay(
            mouseLocation: tracker.cursorPosition,
            overlayFrame: screenFrame
        )
    }

    private var isCursorOnThisScreen: Bool {
        CoordinateHelper.isPointOnScreen(
            mouseLocation: tracker.cursorPosition,
            screenFrame: screenFrame
        )
    }

    var body: some View {
        ZStack {
            if tracker.isEnabled && isCursorOnThisScreen {
                CursorGlowView(position: localCursorPosition, color: tracker.glowColor, style: tracker.highlightStyle)

                ForEach(tracker.clicks) { click in
                    if CoordinateHelper.isPointOnScreen(mouseLocation: click.position, screenFrame: screenFrame) {
                        RippleView(
                            position: CoordinateHelper.screenPointToOverlay(
                                mouseLocation: click.position,
                                overlayFrame: screenFrame
                            ),
                            onComplete: { tracker.removeClick(id: click.id) }
                        )
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .allowsHitTesting(false)
    }
}
