import Foundation

// MARK: - TimeFormatter

enum TimeFormatter {
    static func string(from interval: TimeInterval) -> String {
        let total = Int(interval.rounded(.down))
        let hours = total / 3600
        let minutes = (total % 3600) / 60
        let seconds = total % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

    static func hoursMinutesSecondsString(from interval: TimeInterval) -> String {
        let total = Int(interval.rounded(.down))
        let hours = total / 3600
        let minutes = (total % 3600) / 60
        let seconds = total % 60
        return String(format: "%dh %02dm %02ds", hours, minutes, seconds)
    }
}
