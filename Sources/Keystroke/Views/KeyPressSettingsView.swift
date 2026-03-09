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
                                KeyPreviewCapsule(text: "⌘")
                                KeyPreviewCapsule(text: "⇧")
                                KeyPreviewCapsule(text: "S")
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
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 20, weight: .medium, design: .rounded))
            .foregroundStyle(.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.black.opacity(0.7))
            )
    }
}
