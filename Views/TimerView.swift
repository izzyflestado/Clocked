import SwiftUI
import SwiftData

// MARK: - TimerView

struct TimerView: View {
    @Environment(\.modelContext) private var context
    @EnvironmentObject private var settings: SettingsStore
    @Query(sort: \Project.name) private var projects: [Project]
    @ObservedObject private var timerManager = TimerManager.shared
    @ObservedObject private var selection = SelectionStore.shared

    var body: some View {
        VStack(spacing: 16) {
            ProjectPickerView(selectedProject: selectedProjectBinding, projects: projects)

            Text(TimeFormatter.string(from: displayedElapsed))
                .font(.system(size: 40, weight: .medium, design: .monospaced))
                .monospacedDigit()
                .foregroundColor(settings.textColor)
                .padding(.vertical, 4)

            HStack(spacing: 12) {

                if isRunningForSelected {
                    Button(action: toggleStartPause) {
                        Text("Pause")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.gray.opacity(0.15))
                            )
                    }
                    .buttonStyle(.plain)
                    .disabled(selectedProject == nil || blockedByOtherProject)

                } else {
                    Button(action: toggleStartPause) {
                        Text("Start")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.accentColor)
                    .disabled(selectedProject == nil || blockedByOtherProject)
                }

                Button(action: stop) {
                    Text("Stop")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
                .disabled(!isActiveForSelected)
            }
        }
        .onAppear {
            // Always prefer showing the project that's actually running or
            // paused, regardless of whatever was last manually selected.
            if let runningID = timerManager.runningProjectID {
                selection.selectedProjectID = runningID
            } else if selection.selectedProjectID == nil {
                selection.selectedProjectID = projects.first?.persistentModelID
            }
        }
    }

    private var selectedProject: Project? {
        guard let id = selection.selectedProjectID else { return nil }
        return projects.first { $0.persistentModelID == id }
    }

    private var selectedProjectBinding: Binding<Project?> {
        Binding(
            get: { selectedProject },
            set: { selection.selectedProjectID = $0?.persistentModelID }
        )
    }

    private var displayedElapsed: TimeInterval {
        guard let selectedProject, timerManager.isActive(selectedProject) else { return 0 }
        return timerManager.elapsed
    }

    private var isActiveForSelected: Bool {
        guard let selectedProject else { return false }
        return timerManager.isActive(selectedProject)
    }
    
    private var isRunningForSelected: Bool {
        guard let selectedProject else { return false }
        return timerManager.isRunning(selectedProject)
    }
    private var blockedByOtherProject: Bool {
        guard let selectedProject else { return false }
        return timerManager.hasActiveSession && !timerManager.isActive(selectedProject)
    }

    private var startPauseLabel: String {
        guard let selectedProject else { return "Start" }
        return timerManager.isRunning(selectedProject) ? "Pause" : "Start"
    }

    private func toggleStartPause() {
        guard let selectedProject else { return }
        if timerManager.isRunning(selectedProject) {
            timerManager.pause()
        } else {
            timerManager.start(project: selectedProject)
        }
    }

    private func stop() {
        guard let selectedProject else { return }
        timerManager.stop(project: selectedProject, context: context)
    }
}
