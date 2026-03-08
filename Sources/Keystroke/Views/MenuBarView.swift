import SwiftUI

struct ControlPanelView: View {
    @ObservedObject var tracker: MouseTracker

    private let colors: [(String, Color)] = [
        ("Yellow", .yellow),
        ("Blue", .blue),
        ("Green", .green),
        ("Pink", .pink),
        ("White", .white),
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: "cursor.rays")
                    .font(.system(size: 14, weight: .semibold))
                Text("Keystroke")
                    .font(.system(size: 13, weight: .semibold))
                Spacer()
                Toggle("", isOn: $tracker.isEnabled)
                    .toggleStyle(.switch)
                    .controlSize(.mini)
                    .labelsHidden()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial)

            Divider()

            VStack(spacing: 16) {
                // Style section
                VStack(alignment: .leading, spacing: 8) {
                    Text("STYLE")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(.secondary)
                        .tracking(0.5)

                    HStack(spacing: 8) {
                        StyleButton(
                            label: "Glow",
                            icon: "circle.fill",
                            isSelected: tracker.highlightStyle == .glow,
                            color: tracker.glowColor
                        ) {
                            tracker.highlightStyle = .glow
                        }

                        StyleButton(
                            label: "Ring",
                            icon: "circle",
                            isSelected: tracker.highlightStyle == .ring,
                            color: tracker.glowColor
                        ) {
                            tracker.highlightStyle = .ring
                        }
                    }
                }

                // Color section
                VStack(alignment: .leading, spacing: 8) {
                    Text("COLOR")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(.secondary)
                        .tracking(0.5)

                    HStack(spacing: 6) {
                        ForEach(colors, id: \.0) { name, color in
                            Circle()
                                .fill(color)
                                .frame(width: 22, height: 22)
                                .overlay(
                                    Circle()
                                        .stroke(Color.accentColor, lineWidth: tracker.glowColor == color ? 2.5 : 0)
                                        .frame(width: 28, height: 28)
                                )
                                .onTapGesture {
                                    tracker.glowColor = color
                                }
                                .accessibilityLabel(name)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }

                // Preview
                VStack(alignment: .leading, spacing: 8) {
                    Text("PREVIEW")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(.secondary)
                        .tracking(0.5)

                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.black.opacity(0.3))
                            .frame(height: 60)

                        CursorGlowView(
                            position: CGPoint(x: 110, y: 30),
                            color: tracker.glowColor,
                            style: tracker.highlightStyle
                        )
                        .frame(width: 220, height: 60)
                        .clipped()
                    }
                }
            }
            .padding(16)

            Divider()

            // Footer
            HStack {
                Button(action: { NSApplication.shared.terminate(nil) }) {
                    Text("Quit")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                Spacer()
                Text("⌘Q")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .frame(width: 220)
    }
}

private struct StyleButton: View {
    let label: String
    let icon: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundStyle(isSelected ? color : .secondary)
                Text(label)
                    .font(.system(size: 10))
                    .foregroundStyle(isSelected ? .primary : .secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? color.opacity(0.15) : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? color.opacity(0.4) : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
