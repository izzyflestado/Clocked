import Foundation
import SwiftData
import Combine

// MARK: - TimerManager

/// Owns the single, app-wide active timing session.
///
/// This lives outside any view so the timer keeps running even while the
/// popover is closed (a `MenuBarExtra` tears down its content view when
/// the window is dismissed). Enforces the "only one project running at a
/// time" rule.
@MainActor
final class TimerManager: ObservableObject {
    static let shared = TimerManager()

    /// The project currently being timed (running or paused), if any.
    @Published private(set) var runningProjectID: PersistentIdentifier?
    /// Live elapsed time for the current session, updated once per second.
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

    /// True if some project (any project) currently has an active session.
    var hasActiveSession: Bool {
        runningProjectID != nil
    }

    // MARK: Controls

    /// Starts a fresh session for `project`, or resumes it if it was paused.
    /// No-ops if a *different* project is already active.
    func start(project: Project) {
        if let running = runningProjectID, running != project.persistentModelID {
            return // Only one project may run at a time.
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

    /// Pauses the active session. The elapsed time is kept and can be resumed.
    func pause() {
        guard hasActiveSession, !isPaused else { return }
        commitElapsedSinceResume()
        isPaused = true
        stopTicker()
    }

    /// Stops the active session for `project`, persisting the accumulated
    /// duration as a `TimeSession` and resetting the timer to zero.
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
