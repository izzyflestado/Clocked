import SwiftUI
import SwiftData
import AppKit

// MARK: - ProjectTimeTrackerApp

@main
struct ProjectTimeTrackerApp: App {
    @StateObject private var settings = SettingsStore.shared

    init() {
        // Hide the Dock icon and app switcher entry so this behaves as a
        // pure menu bar utility. (Equivalent to Info.plist's
        // "Application is agent (UIElement)" key, done in code since this
        // is a Swift Package Manager build with no Info.plist.)
        NSApplication.shared.setActivationPolicy(.accessory)
    }

    var body: some Scene {
        MenuBarExtra {
            PopoverContentView()
                .environmentObject(settings)
        } label: {
            Image(systemName: "stopwatch")
        }
        .menuBarExtraStyle(.window) // Gives popover-like floating behavior.
        .modelContainer(sharedModelContainer)
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
