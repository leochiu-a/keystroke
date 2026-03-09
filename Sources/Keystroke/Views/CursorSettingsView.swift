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

                // Preview card
                SettingsCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("PREVIEW")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(.secondary)
                            .tracking(0.5)

                        GeometryReader { geo in
                            ZStack {
                                Color(nsColor: .separatorColor).opacity(0.08)

                                CursorGlowView(
                                    position: CGPoint(x: geo.size.width / 2, y: geo.size.height / 2),
                                    color: tracker.glowColor,
                                    size: tracker.cursorSize,
                                    ringWidth: tracker.ringWidth,
                                    glowRadius: tracker.glowRadius
                                )
                            }
                        }
                        .frame(height: 100)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
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

                // Size card
                SettingsCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("SIZE")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(.secondary)
                            .tracking(0.5)

                        HStack {
                            Slider(value: $tracker.cursorSize, in: 20...60, step: 1)
                            Text("\(Int(tracker.cursorSize))")
                                .font(.system(size: 12, weight: .medium, design: .monospaced))
                                .foregroundStyle(.secondary)
                                .frame(width: 30, alignment: .trailing)
                        }
                    }
                }

                // Ring width card
                SettingsCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("RING WIDTH")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(.secondary)
                            .tracking(0.5)

                        HStack {
                            Slider(value: $tracker.ringWidth, in: 1...10, step: 0.5)
                            Text(String(format: "%.1f", tracker.ringWidth))
                                .font(.system(size: 12, weight: .medium, design: .monospaced))
                                .foregroundStyle(.secondary)
                                .frame(width: 30, alignment: .trailing)
                        }
                    }
                }

                // Glow radius card
                SettingsCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("GLOW RANGE")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(.secondary)
                            .tracking(0.5)

                        HStack {
                            Slider(value: $tracker.glowRadius, in: 0...20, step: 1)
                            Text("\(Int(tracker.glowRadius))")
                                .font(.system(size: 12, weight: .medium, design: .monospaced))
                                .foregroundStyle(.secondary)
                                .frame(width: 30, alignment: .trailing)
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
