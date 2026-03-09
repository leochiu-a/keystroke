import SwiftUI

struct CursorSettingsView: View {
    @ObservedObject var tracker: MouseTracker

    private let colors: [(String, Color)] = [
        ("Yellow", .yellow),
        ("Blue", .blue),
        ("Green", .green),
        ("Pink", .pink),
        ("White", .white),
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Page header
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Cursor Highlight")
                            .font(.system(size: 22, weight: .bold))
                        Spacer()
                        Toggle("", isOn: $tracker.isEnabled)
                            .toggleStyle(.switch)
                            .controlSize(.small)
                            .labelsHidden()
                    }
                    Text("Customize the cursor glow effect")
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                }

                // Style card
                SettingsCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("STYLE")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(.secondary)
                            .tracking(0.5)

                        HStack(spacing: 10) {
                            StylePreviewButton(
                                label: "Glow",
                                style: .glow,
                                isSelected: tracker.highlightStyle == .glow,
                                color: tracker.glowColor
                            ) {
                                tracker.highlightStyle = .glow
                            }

                            StylePreviewButton(
                                label: "Ring",
                                style: .ring,
                                isSelected: tracker.highlightStyle == .ring,
                                color: tracker.glowColor
                            ) {
                                tracker.highlightStyle = .ring
                            }
                        }
                    }
                }

                // Color card
                SettingsCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("COLOR")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(.secondary)
                            .tracking(0.5)

                        HStack(spacing: 10) {
                            ForEach(colors, id: \.0) { name, color in
                                ColorDot(
                                    color: color,
                                    isSelected: tracker.glowColor == color,
                                    label: name
                                ) {
                                    tracker.glowColor = color
                                }
                            }
                        }
                    }
                }
            }
            .padding(28)
        }
        .background(Color(nsColor: .controlBackgroundColor))
    }
}

// MARK: - Subcomponents

private struct StylePreviewButton: View {
    let label: String
    let style: HighlightStyle
    let isSelected: Bool
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                GeometryReader { geo in
                    ZStack {
                        Color(nsColor: .separatorColor).opacity(0.08)

                        CursorGlowView(
                            position: CGPoint(x: geo.size.width / 2, y: geo.size.height / 2),
                            color: color,
                            style: style
                        )
                    }
                }
                .frame(height: 80)
                .clipped()

                Text(label)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(isSelected ? .primary : .secondary)
                    .padding(.vertical, 8)
            }
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? color.opacity(0.08) : Color(nsColor: .controlBackgroundColor))
            )
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(
                        isSelected ? color.opacity(0.5) : Color(nsColor: .separatorColor).opacity(0.3),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

private struct ColorDot: View {
    let color: Color
    let isSelected: Bool
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Circle()
                .fill(color)
                .frame(width: 28, height: 28)
                .overlay {
                    if isSelected {
                        Circle()
                            .stroke(Color.accentColor, lineWidth: 2.5)
                            .frame(width: 34, height: 34)
                    }
                }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }
}
