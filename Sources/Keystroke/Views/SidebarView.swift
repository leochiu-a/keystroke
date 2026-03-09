import SwiftUI

struct SidebarView: View {
    @Binding var selectedItem: SidebarItem
    @ObservedObject var mouseTracker: MouseTracker

    var body: some View {
        VStack(spacing: 0) {
            // App header
            HStack(spacing: 8) {
                Image(systemName: "cursor.rays")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.primary)
                Text("Keystroke")
                    .font(.system(size: 15, weight: .bold))
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 16)
            .frame(maxWidth: .infinity, alignment: .leading)

            // Navigation items
            VStack(spacing: 4) {
                ForEach(SidebarItem.allCases) { item in
                    SidebarRow(
                        item: item,
                        isSelected: selectedItem == item
                    ) {
                        selectedItem = item
                    }
                }
            }
            .padding(.horizontal, 12)

            Spacer()

            // Footer
            Divider()
                .padding(.horizontal, 12)

            HStack {
                Button(action: { NSApplication.shared.terminate(nil) }) {
                    HStack(spacing: 6) {
                        Image(systemName: "power")
                            .font(.system(size: 11))
                        Text("Quit")
                            .font(.system(size: 12))
                    }
                    .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                Spacer()
                Text("\u{2318}Q")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .frame(width: 180)
        .background(Color(nsColor: .windowBackgroundColor))
    }
}

private struct SidebarRow: View {
    let item: SidebarItem
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: item.icon)
                    .font(.system(size: 14))
                    .frame(width: 20)
                Text(item.title)
                    .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
            }
            .foregroundStyle(isSelected ? .primary : .secondary)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.accentColor.opacity(0.1) : Color.clear)
            )
        }
        .buttonStyle(.plain)
    }
}
