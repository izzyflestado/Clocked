import Foundation
import SwiftData

// MARK: - TimeSession

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
