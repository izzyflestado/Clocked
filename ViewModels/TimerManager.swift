import Foundation
import SwiftData
import Combine

// MARK: - TimerManager

@MainActor
final class TimerManager: ObservableObject {
    static let shared = TimerManager()

    @Published private(set) var runningProjectID: PersistentIdentifier?
    @Published private(set) var elapsed: TimeInterval = 0
    @Published private(set) var isPaused: Bool = false

    private var accumulated: TimeInterval = 0
    private var resumeDate: Date?
    private var sessionStart: Date?
    private var ticker: Timer?

    private init() {}

    // MARK: Queries

    func isActive(_ project: Project) -> Bool {
        runningProjectID == project.persistentModelID
    }

    func isRunning(_ project: Project) -> Bool {
        isActive(project) && !isPaused
    }

    func isPaused(_ project: Project) -> Bool {
        isActive(project) && isPaused
    }

    var hasActiveSession: Bool {
        runningProjectID != nil
    }

    var isRunningAnything: Bool {
        runningProjectID != nil && !isPaused
    }

    // MARK: Controls

    func start(project: Project) {
        if let running = runningProjectID, running != project.persistentModelID {
            return
        }

        if runningProjectID == nil {
            sessionStart = Date()
            accumulated = 0
        }

        runningProjectID = project.persistentModelID
        isPaused = false
        resumeDate = Date()
        startTicker()
    }

    func pause() {
        guard hasActiveSession, !isPaused else { return }
        commitElapsedSinceResume()
        isPaused = true
        stopTicker()
    }

    func stop(project: Project, context: ModelContext) {
        guard isActive(project) else { return }

        if !isPaused {
            commitElapsedSinceResume()
        }

        let end = Date()
        let start = sessionStart ?? end
        let duration = accumulated

        if duration > 0 {
            let session = TimeSession(startTime: start, endTime: end, duration: duration)
            session.project = project
            project.sessions.append(session)
            project.totalDuration += duration
            try? context.save()
        }

        reset()
    }

    // MARK: Internal

    private func commitElapsedSinceResume() {
        guard let resumeDate else { return }
        accumulated += Date().timeIntervalSince(resumeDate)
        elapsed = accumulated
        self.resumeDate = nil
    }

    private func reset() {
        stopTicker()
        runningProjectID = nil
        isPaused = false
        accumulated = 0
        elapsed = 0
        sessionStart = nil
        resumeDate = nil
    }

    private func startTicker() {
        stopTicker()
        let timer = Timer(timeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.tick() }
        }
        RunLoop.main.add(timer, forMode: .common)
        ticker = timer
    }

    private func stopTicker() {
        ticker?.invalidate()
        ticker = nil
    }

    private func tick() {
        guard let resumeDate else { return }
        elapsed = accumulated + Date().timeIntervalSince(resumeDate)
    }
}
