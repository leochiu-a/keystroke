import SwiftUI

struct KeyPressSettingsView: View {
    @ObservedObject var tracker: KeyPressTracker

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Page header
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("KeyPress Display")
                            .font(.system(size: 22, weight: .bold))
                        Spacer()
                        Toggle("", isOn: $tracker.isEnabled)
                            .toggleStyle(.switch)
                            .controlSize(.small)
                            .labelsHidden()
                    }
                    Text("Show keyboard input on screen")
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

                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(nsColor: .separatorColor).opacity(0.08))
                                .frame(height: 100)

                            HStack(spacing: 6) {
                                KeyPreviewCapsule(symbol: "⌘", label: "command")
                                KeyPreviewCapsule(symbol: "⇧", label: "shift")
                                KeyPreviewCapsule(character: "S")
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

private struct KeyPreviewCapsule: View {
    let symbol: String
    let label: String?

    init(symbol: String, label: String) {
        self.symbol = symbol
        self.label = label
    }

    init(character: String) {
        self.symbol = character
        self.label = nil
    }

    var body: some View {
        Group {
            if let label {
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Spacer()
                        Text(symbol)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.white.opacity(0.9))
                    }
                    Text(label)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.white.opacity(0.8))
                }
                .frame(width: 64, height: 52)
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
            } else {
                Text(symbol)
                    .font(.system(size: 22, weight: .medium, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(minWidth: 44, minHeight: 52)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(white: 0.2))
                .shadow(color: .black.opacity(0.4), radius: 1, y: 1)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.white.opacity(0.15), lineWidth: 0.5)
        )
    }
}
