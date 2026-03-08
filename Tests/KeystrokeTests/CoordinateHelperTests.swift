import Testing
import Foundation
@testable import Keystroke

// MARK: - unionFrame

@Test func unionFrameReturnsSingleScreenFrame() {
    let frames = [CGRect(x: 0, y: 0, width: 1920, height: 1080)]
    let result = CoordinateHelper.unionFrame(screenFrames: frames)
    #expect(result == CGRect(x: 0, y: 0, width: 1920, height: 1080))
}

@Test func unionFrameSpansTwoHorizontalScreens() {
    let frames = [
        CGRect(x: 0, y: 0, width: 1920, height: 1080),
        CGRect(x: 1920, y: 0, width: 2560, height: 1440),
    ]
    let result = CoordinateHelper.unionFrame(screenFrames: frames)
    // Union: x=0, y=0, width=1920+2560=4480, height=max(1080,1440)=1440
    #expect(result == CGRect(x: 0, y: 0, width: 4480, height: 1440))
}

@Test func unionFrameHandlesNegativeOrigin() {
    // macOS can have screens with negative y (screen below main)
    let frames = [
        CGRect(x: 0, y: 0, width: 1920, height: 1080),
        CGRect(x: 0, y: -1080, width: 1920, height: 1080),
    ]
    let result = CoordinateHelper.unionFrame(screenFrames: frames)
    #expect(result == CGRect(x: 0, y: -1080, width: 1920, height: 2160))
}

@Test func unionFrameReturnsZeroForEmptyInput() {
    let result = CoordinateHelper.unionFrame(screenFrames: [])
    #expect(result == .zero)
}

// MARK: - screenPointToOverlay

@Test func convertsBottomLeftOriginToTopLeftForSingleScreen() {
    let screenFrame = CGRect(x: 0, y: 0, width: 1920, height: 1080)
    let mouseLocation = CGPoint(x: 500, y: 800)

    let result = CoordinateHelper.screenPointToOverlay(
        mouseLocation: mouseLocation,
        overlayFrame: screenFrame
    )

    #expect(result == CGPoint(x: 500, y: 280))
}

@Test func convertsPointOnSecondaryScreen() {
    let overlayFrame = CGRect(x: 1920, y: 0, width: 2560, height: 1440)
    let mouseLocation = CGPoint(x: 2500, y: 1000)

    let result = CoordinateHelper.screenPointToOverlay(
        mouseLocation: mouseLocation,
        overlayFrame: overlayFrame
    )

    #expect(result == CGPoint(x: 580, y: 440))
}

@Test func convertsPointRegardlessOfWindowBeingHovered() {
    let overlayFrame = CGRect(x: 0, y: 0, width: 1920, height: 1080)
    let mouseLocation = CGPoint(x: 100, y: 900)

    let result = CoordinateHelper.screenPointToOverlay(
        mouseLocation: mouseLocation,
        overlayFrame: overlayFrame
    )

    #expect(result == CGPoint(x: 100, y: 180))
}

// MARK: - isPointOnScreen

@Test func pointInsideScreenReturnsTrue() {
    let screenFrame = CGRect(x: 0, y: 0, width: 1920, height: 1080)
    let mouseLocation = CGPoint(x: 500, y: 500)
    #expect(CoordinateHelper.isPointOnScreen(mouseLocation: mouseLocation, screenFrame: screenFrame) == true)
}

@Test func pointOnSecondScreenReturnsFalseForFirstScreen() {
    let screenA = CGRect(x: 0, y: 0, width: 1920, height: 1080)
    let mouseLocation = CGPoint(x: 2500, y: 500) // on screen B
    #expect(CoordinateHelper.isPointOnScreen(mouseLocation: mouseLocation, screenFrame: screenA) == false)
}

@Test func pointOnSecondScreenReturnsTrueForSecondScreen() {
    let screenB = CGRect(x: 1920, y: 0, width: 2560, height: 1440)
    let mouseLocation = CGPoint(x: 2500, y: 500)
    #expect(CoordinateHelper.isPointOnScreen(mouseLocation: mouseLocation, screenFrame: screenB) == true)
}
