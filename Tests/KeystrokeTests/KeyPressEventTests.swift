import Testing
import Foundation
@testable import Keystroke

@Test func keyPressEventStoresCharactersAndTimestamp() {
    let event = KeyPressEvent(characters: "⌘C")
    #expect(event.characters == "⌘C")
    #expect(event.timestamp.timeIntervalSinceNow < 1)
    #expect(event.id != UUID())
}

@Test func keyPressEventIsIdentifiable() {
    let a = KeyPressEvent(characters: "A")
    let b = KeyPressEvent(characters: "A")
    #expect(a.id != b.id)
}
