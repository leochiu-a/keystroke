import Foundation

enum SidebarItem: String, CaseIterable, Identifiable, Hashable {
    case cursor

    var id: String { rawValue }

    var title: String {
        switch self {
        case .cursor: return "Cursor"
        }
    }

    var icon: String {
        switch self {
        case .cursor: return "cursorarrow.rays"
        }
    }

    static var defaultItem: SidebarItem { .cursor }
}
