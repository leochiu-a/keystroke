import Foundation

enum CoordinateHelper {
    /// Convert screen-absolute mouse location (bottom-left origin) to overlay window coordinates (top-left origin).
    static func screenPointToOverlay(mouseLocation: CGPoint, overlayFrame: CGRect) -> CGPoint {
        CGPoint(
            x: mouseLocation.x - overlayFrame.origin.x,
            y: overlayFrame.height - (mouseLocation.y - overlayFrame.origin.y)
        )
    }

    /// Compute the union of all screen frames to create a single overlay spanning all monitors.
    static func unionFrame(screenFrames: [CGRect]) -> CGRect {
        guard let first = screenFrames.first else { return .zero }
        return screenFrames.dropFirst().reduce(first) { $0.union($1) }
    }

    /// Check if a screen-absolute mouse location falls within a screen's frame.
    static func isPointOnScreen(mouseLocation: CGPoint, screenFrame: CGRect) -> Bool {
        screenFrame.contains(mouseLocation)
    }
}
