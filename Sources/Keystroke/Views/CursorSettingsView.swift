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
                            StyleCardButton(
                                label: "Glow",
                                icon: "circle.fill",
                                isSelected: tracker.highlightStyle == .glow,
                                color: tracker.glowColor
                            ) {
                                tracker.highlightStyle = .glow
                            }

                            StyleCardButton(
                                label: "Ring",
                                icon: "circle",
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

                // Preview card
                SettingsCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("PREVIEW")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(.secondary)
                            .tracking(0.5)

                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.black.opacity(0.85))
                                .frame(height: 120)

                            CursorGlowView(
                                position: CGPoint(x: 200, y: 60),
                                color: tracker.glowColor,
                                style: tracker.highlightStyle
                            )
                            .frame(maxWidth: .infinity)
                            .frame(height: 120)
                            .clipped()
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

private struct SettingsCard<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        content
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.white)
                    .shadow(color: .black.opacity(0.06), radius: 8, y: 2)
            )
    }
}

private struct StyleCardButton: View {
    let label: String
    let icon: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundStyle(isSelected ? color : .secondary)
                Text(label)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(isSelected ? .primary : .secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? color.opacity(0.12) : Color(nsColor: .controlBackgroundColor))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(
                        isSelected ? color.opacity(0.4) : Color(nsColor: .separatorColor).opacity(0.3),
                        lineWidth: 1
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
                .overlay(
                    Circle()
                        .stroke(Color.accentColor, lineWidth: isSelected ? 2.5 : 0)
                        .frame(width: 34, height: 34)
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }
}
