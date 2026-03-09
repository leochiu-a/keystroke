import SwiftUI

struct MainWindowView: View {
    @ObservedObject var mouseTracker: MouseTracker
    @ObservedObject var keyPressTracker: KeyPressTracker
    @State private var selectedItem: SidebarItem = .defaultItem

    var body: some View {
        HStack(spacing: 0) {
            SidebarView(selectedItem: $selectedItem, mouseTracker: mouseTracker)

            Divider()

            contentView
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    @ViewBuilder
    private var contentView: some View {
        switch selectedItem {
        case .cursor:
            CursorSettingsView(tracker: mouseTracker)
        case .keyPress:
            KeyPressSettingsView(tracker: keyPressTracker)
        }
    }
}
