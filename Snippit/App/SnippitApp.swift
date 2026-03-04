import SwiftData
import SwiftUI

@main
struct SnippitApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(try! CloudKitSyncManager.createContainer())
    }
}
