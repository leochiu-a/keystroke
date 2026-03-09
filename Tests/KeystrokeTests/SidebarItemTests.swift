import Testing
@testable import Keystroke

@Test func sidebarItemHasCursorCase() {
    let item = SidebarItem.cursor
    #expect(item.title == "Cursor")
    #expect(item.icon == "cursorarrow.rays")
}

@Test func sidebarItemDefaultIsCursor() {
    let defaultItem = SidebarItem.defaultItem
    #expect(defaultItem == .cursor)
}
