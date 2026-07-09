import SwiftUI
import AppKit

// MARK: - SettingsView

struct SettingsView: View {
    @EnvironmentObject private var settings: SettingsStore
    var onDone: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Settings")
                .font(.headline)

            ColorPicker(
                "Background Color",
                selection: Binding(
                    get: { settings.backgroundColor },
                    set: { settings.updateBackground($0) }
                )
            )

            ColorPicker(
                "Number / Text Color",
                selection: Binding(
                    get: { settings.textColor },
                    set: { settings.updateText($0) }
                )
            )

            HStack {
                Button("Quit App") {
                    NSApplication.shared.terminate(nil)
                }
                Spacer()
                Button("Done", action: onDone)
            }
        }
        .padding()
        .frame(width: 260)
    }
}
