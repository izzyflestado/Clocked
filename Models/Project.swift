import Foundation
import SwiftData
import SwiftUI

// MARK: - Project

@Model
final class Project {
    var name: String
    var totalDuration: TimeInterval
    var colorHex: String?

    @Relationship(deleteRule: .cascade, inverse: \TimeSession.project)
    var sessions: [TimeSession] = []

    init(name: String, totalDuration: TimeInterval = 0, colorHex: String? = nil) {
        self.name = name
        self.totalDuration = totalDuration
        self.colorHex = colorHex
    }

    static let defaultPalette: [Color] = [
        .blue, .green, .orange, .pink, .purple, .yellow, .teal, .red, .indigo, .mint
    ]

    // Picks a palette color not already used by `existingProjects`.
    // Falls back to a random palette color if all are taken.
    static func nextAvailableColorHex(existingProjects: [Project]) -> String {
        let usedHexes = Set(existingProjects.compactMap { $0.colorHex })
        let usedColors = Set(defaultPalette.filter {
            guard let hex = $0.toHex() else { return false }
            return usedHexes.contains(hex)
        })
        let available = defaultPalette.filter { !usedColors.contains($0) }

        let chosen = available.randomElement() ?? defaultPalette.randomElement()!
        return chosen.toHex() ?? "#0000FF" // fallback hex if somehow toHex() fails
    }

    var displayColor: Color {
        if let colorHex, let custom = Color(hex: colorHex) {
            return custom
        }
        // Fallback only — should rarely hit this if colorHex is always assigned at creation.
        return Project.defaultPalette.first!
    }
}
