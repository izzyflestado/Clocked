import SwiftUI
import AppKit

// MARK: - SettingsStore

/// Holds the app's ONLY two customizable values: background color and
/// text/number color. Persisted to `UserDefaults` as hex strings.
final class SettingsStore: ObservableObject {
    static let shared = SettingsStore()

    @AppStorage("backgroundColorHex") private var backgroundHex: String = "1E1E1E"
    @AppStorage("textColorHex") private var textHex: String = "FFFFFF"

    @Published var backgroundColor: Color
    @Published var textColor: Color

    private init() {
        // Read directly from UserDefaults since @AppStorage isn't available
        // until `self` exists.
        let storedBackground = UserDefaults.standard.string(forKey: "backgroundColorHex") ?? "1E1E1E"
        let storedText = UserDefaults.standard.string(forKey: "textColorHex") ?? "FFFFFF"
        self.backgroundColor = Color(hex: storedBackground) ?? .black
        self.textColor = Color(hex: storedText) ?? .white
    }

    func updateBackground(_ color: Color) {
        backgroundColor = color
        backgroundHex = color.toHex() ?? backgroundHex
    }

    func updateText(_ color: Color) {
        textColor = color
        textHex = color.toHex() ?? textHex
    }
}

// MARK: - Color <-> Hex

extension Color {
    init?(hex: String) {
        let sanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        guard Scanner(string: sanitized).scanHexInt64(&rgb) else { return nil }

        let r = Double((rgb & 0xFF0000) >> 16) / 255
        let g = Double((rgb & 0x00FF00) >> 8) / 255
        let b = Double(rgb & 0x0000FF) / 255

        self = Color(red: r, green: g, blue: b)
    }

    func toHex() -> String? {
        guard let rgb = NSColor(self).usingColorSpace(.deviceRGB) else { return nil }
        let r = Int(round(rgb.redComponent * 255))
        let g = Int(round(rgb.greenComponent * 255))
        let b = Int(round(rgb.blueComponent * 255))
        return String(format: "%02X%02X%02X", r, g, b)
    }
}
