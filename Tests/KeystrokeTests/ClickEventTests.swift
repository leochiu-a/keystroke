import Testing
import Foundation
@testable import Keystroke

@Test func clickEventStoresPositionAndTimestamp() {
    let position = CGPoint(x: 100, y: 200)
    let event = ClickEvent(position: position)

    #expect(event.position == position)
    #expect(event.timestamp.timeIntervalSinceNow < 1)
    #expect(event.id != UUID())
}

@Test func clickEventIsIdentifiable() {
    let a = ClickEvent(position: .zero)
    let b = ClickEvent(position: .zero)
    #expect(a.id != b.id)
}
