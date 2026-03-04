import Foundation
import SwiftData

/// Configures SwiftData with CloudKit sync for collage projects and clipped items.
enum CloudKitSyncManager {
    /// The SwiftData schema for all synced models.
    static let schema = Schema([
        CollageProject.self,
        ClippedItem.self,
    ])

    /// Creates a model container with CloudKit sync enabled.
    static func createContainer(inMemory: Bool = false) throws -> ModelContainer {
        let config: ModelConfiguration
        if inMemory {
            config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        } else {
            config = ModelConfiguration(
                schema: schema,
                cloudKitDatabase: .automatic
            )
        }
        return try ModelContainer(for: schema, configurations: [config])
    }
}
