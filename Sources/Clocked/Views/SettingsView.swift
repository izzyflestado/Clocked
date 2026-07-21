import SwiftUI
import AppKit

// MARK: - Row frame tracking (so the popup can anchor above the tapped row)

private struct RowFramePreferenceKey: PreferenceKey {
    static var defaultValue: [SettingsView.Field: CGRect] = [:]
    static func reduce(value: inout [SettingsView.Field: CGRect], nextValue: () -> [SettingsView.Field: CGRect]) {
        value.merge(nextValue()) { $1 }
    }
}

// MARK: - SettingsView

struct SettingsView: View {
    @EnvironmentObject private var settings: SettingsStore
    var onDone: () -> Void

    enum Field: Hashable {
        case background
        case text
    }

    @State private var editingField: Field?
    @State private var tempColor: Color = .white
    @State private var rowFrames: [Field: CGRect] = [:]

    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Settings")
                    .font(.headline)

                HStack {
                    Text("Background Color")
                    Spacer()
                    colorSwatchButton(for: .background, color: settings.backgroundColor)
                }

                HStack {
                    Text("Number / Text Color")
                    Spacer()
                    colorSwatchButton(for: .text, color: settings.textColor)
                }

                if editingField != nil {
                    Color.clear.frame(height: 190)
                }

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

            if let editingField,
               let frame = rowFrames[editingField] {
                colorEditor(for: editingField)
                    .position(x: max(100, frame.minX - 20), y: frame.maxY + 100)
            }
        }
        .coordinateSpace(name: "settingsLegend")
        .onPreferenceChange(RowFramePreferenceKey.self) { rowFrames = $0 }
    }

    // MARK: - Swatch button

    @ViewBuilder
    private func colorSwatchButton(for field: Field, color: Color) -> some View {
        Button {
            if editingField == field {
                editingField = nil
            } else {
                tempColor = color
                editingField = field
            }
        } label: {
            Circle()
                .fill(color)
                .frame(width: 14, height: 14)
                .overlay(
                    Circle().stroke(Color.white.opacity(0.3), lineWidth: 0.5)
                )
        }
        .buttonStyle(.plain)
        .background(
            GeometryReader { geo in
                Color.clear.preference(
                    key: RowFramePreferenceKey.self,
                    value: [field: geo.frame(in: .named("settingsLegend"))]
                )
            }
        )
    }

    // MARK: - Floating color editor popup

    @ViewBuilder
    private func colorEditor(for field: Field) -> some View {
        let pickerWidth: CGFloat = 130
        let padding: CGFloat = 10

        VStack(spacing: 10) {
            CustomColorPicker(color: $tempColor)

            HStack(spacing: 8) {
                Button("Cancel") {
                    editingField = nil
                }
                .frame(width: pickerWidth * 0.4)

                Button("Confirm") {
                    switch field {
                    case .background:
                        settings.updateBackground(tempColor)
                    case .text:
                        settings.updateText(tempColor)
                    }
                    editingField = nil
                }
                .frame(width: pickerWidth * 0.6)
                .buttonStyle(.borderedProminent)
            }
            .frame(height: 28)
        }
        .padding(padding)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(NSColor.windowBackgroundColor))
                .shadow(radius: 8)
        )
        .frame(width: pickerWidth + padding * 2)
    }
}