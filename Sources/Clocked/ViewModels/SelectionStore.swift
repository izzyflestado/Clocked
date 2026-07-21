import Foundation
import SwiftData

// MARK: - SelectionStore

@MainActor
final class SelectionStore: ObservableObject {
    static let shared = SelectionStore()
    @Published var selectedProjectID: PersistentIdentifier?
    private init() {}
}
