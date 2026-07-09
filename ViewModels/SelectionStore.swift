import Foundation
import SwiftData

// MARK: - SelectionStore

/// Remembers which project is selected across tab switches.
/// `TimerView`'s own `@State` gets destroyed every time it's removed from
/// the view hierarchy (e.g. switching to the Statistics tab), so the
/// selection needs to live outside the view itself.
@MainActor
final class SelectionStore: ObservableObject {
    static let shared = SelectionStore()
    @Published var selectedProjectID: PersistentIdentifier?
    private init() {}
}
