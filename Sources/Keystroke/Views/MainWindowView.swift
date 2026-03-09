import SwiftUI

struct MainWindowView: View {
    @ObservedObject var tracker: MouseTracker
    @State private var selectedItem: SidebarItem = .defaultItem

    var body: some View {
        HStack(spacing: 0) {
            SidebarView(selectedItem: $selectedItem, tracker: tracker)

            Divider()

            contentView
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    @ViewBuilder
    private var contentView: some View {
        switch selectedItem {
        case .cursor:
            CursorSettingsView(tracker: tracker)
        case .keyPress:
            Text("KeyPress settings coming soon")
        }
    }
}
