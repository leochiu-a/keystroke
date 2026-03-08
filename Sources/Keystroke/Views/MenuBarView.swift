import SwiftUI

struct ControlPanelView: View {
    @ObservedObject var tracker: MouseTracker

    private let colors: [(String, Color)] = [
        ("Yellow", .yellow),
        ("Blue", .blue),
        ("Green", .green),
        ("Pink", .pink),
    ]

    private let styles: [(String, HighlightStyle)] = [
        ("Glow", .glow),
        ("Neon Ring", .neonRing),
        ("Ring", .transparentRing),
    ]

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Keystroke")
                    .font(.headline)
                Spacer()
            }

            Toggle("Enabled", isOn: $tracker.isEnabled)
                .toggleStyle(.switch)

            Divider()

            Text("Style")
                .font(.caption)
                .foregroundColor(.secondary)

            Picker("Style", selection: $tracker.highlightStyle) {
                ForEach(styles, id: \.1) { name, style in
                    Text(name).tag(style)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()

            Divider()

            Text("Color")
                .font(.caption)
                .foregroundColor(.secondary)

            HStack(spacing: 8) {
                ForEach(colors, id: \.0) { name, color in
                    Circle()
                        .fill(color)
                        .frame(width: 24, height: 24)
                        .overlay(
                            Circle()
                                .stroke(Color.primary, lineWidth: tracker.glowColor == color ? 2 : 0)
                        )
                        .onTapGesture {
                            tracker.glowColor = color
                        }
                        .accessibilityLabel(name)
                }
            }

            Divider()

            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
        }
        .padding()
        .frame(width: 200)
    }
}
