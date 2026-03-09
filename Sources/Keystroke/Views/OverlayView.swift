import SwiftUI

struct OverlayView: View {
    @ObservedObject var mouseTracker: MouseTracker
    @ObservedObject var keyPressTracker: KeyPressTracker
    let screenFrame: CGRect

    private var localCursorPosition: CGPoint {
        CoordinateHelper.screenPointToOverlay(
            mouseLocation: mouseTracker.cursorPosition,
            overlayFrame: screenFrame
        )
    }

    private var isCursorOnThisScreen: Bool {
        CoordinateHelper.isPointOnScreen(
            mouseLocation: mouseTracker.cursorPosition,
            screenFrame: screenFrame
        )
    }

    var body: some View {
        ZStack {
            if mouseTracker.isEnabled && isCursorOnThisScreen {
                CursorGlowView(position: localCursorPosition, color: mouseTracker.glowColor, size: mouseTracker.cursorSize, ringWidth: mouseTracker.ringWidth, glowRadius: mouseTracker.glowRadius)

                ForEach(mouseTracker.clicks) { click in
                    if CoordinateHelper.isPointOnScreen(mouseLocation: click.position, screenFrame: screenFrame) {
                        RippleView(
                            position: CoordinateHelper.screenPointToOverlay(
                                mouseLocation: click.position,
                                overlayFrame: screenFrame
                            ),
                            onComplete: { mouseTracker.removeClick(id: click.id) }
                        )
                    }
                }
            }

            if keyPressTracker.isEnabled && screenFrame == NSScreen.main?.frame {
                KeyPressOverlayView(tracker: keyPressTracker)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .allowsHitTesting(false)
    }
}
