import Foundation
import SwiftData

// MARK: - TimeSession

/// A single completed timing session belonging to a `Project`.
/// Created only when a session is stopped (paused-but-not-stopped work
/// is not yet persisted, so a crash mid-session simply loses that segment).
@Model
final class TimeSession {
    var startTime: Date
    var endTime: Date
    var duration: TimeInterval
    var project: Project?

    init(startTime: Date, endTime: Date, duration: TimeInterval) {
        self.startTime = startTime
        self.endTime = endTime
        self.duration = duration
    }
}
