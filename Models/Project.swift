import Foundation
import SwiftData

// MARK: - Project

@Model
final class Project {
    var name: String
    var totalDuration: TimeInterval

    @Relationship(deleteRule: .cascade, inverse: \TimeSession.project)
    var sessions: [TimeSession] = []

    init(name: String, totalDuration: TimeInterval = 0) {
        self.name = name
        self.totalDuration = totalDuration
    }
}
