import SwiftUI
import SwiftData
import AppKit

// MARK: - ProjectTimeTrackerApp

@main
struct ProjectTimeTrackerApp: App {
    @StateObject private var settings = SettingsStore.shared

    init() {
              NSApplication.shared.setActivationPolicy(.accessory)
    }

    var body: some Scene {
        MenuBarExtra {
            PopoverContentView()
                .environmentObject(settings)
        } label: {
            Image(systemName: "stopwatch")
        }
        .menuBarExtraStyle(.window)        .modelContainer(sharedModelContainer)
    }

    // MARK: SwiftData

    private var sharedModelContainer: ModelContainer = {
        let schema = Schema([Project.self, TimeSession.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }()
}
