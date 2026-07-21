import Foundation

// MARK: - TimeFormatter

enum TimeFormatter {
    /// "HH:MM:SS" — used for the large live timer display.
    static func string(from interval: TimeInterval) -> String {
        let total = Int(interval.rounded(.down))
        let hours = total / 3600
        let minutes = (total % 3600) / 60
        let seconds = total % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

    /// "Xh YYm" — used for totals in the statistics list.
    static func hoursMinutesString(from interval: TimeInterval) -> String {
        let total = Int(interval.rounded(.down))
        let hours = total / 3600
        let minutes = (total % 3600) / 60
        return String(format: "%dh %02dm", hours, minutes)
    }

    /// "Xh YYm ZZs" — used for totals in the statistics list.
    static func hoursMinutesSecondsString(from interval: TimeInterval) -> String {
        let total = Int(interval.rounded(.down))
        let hours = total / 3600
        let minutes = (total % 3600) / 60
        let seconds = total % 60
        return String(format: "%dh %02dm %02ds", hours, minutes, seconds)
    }

    /// "MM:SS" when under an hour, "H:MM:SS" once it crosses an hour —
    /// used for the compact live readout next to the menu bar icon.
    static func menuBarString(from interval: TimeInterval) -> String {
        let total = Int(interval.rounded(.down))
        let hours = total / 3600
        let minutes = (total % 3600) / 60
        let seconds = total % 60
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}
