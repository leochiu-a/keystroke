import Foundation

enum SidebarItem: String, CaseIterable, Identifiable, Hashable {
    case cursor
    case keyPress

    var id: String { rawValue }

    var title: String {
        switch self {
        case .cursor: return "Cursor"
        case .keyPress: return "KeyPress"
        }
    }

    var icon: String {
        switch self {
        case .cursor: return "cursorarrow.rays"
        case .keyPress: return "keyboard"
        }
    }

    static var defaultItem: SidebarItem { .cursor }
}
