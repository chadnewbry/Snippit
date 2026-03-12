import RevenueCat
import SwiftData
import SwiftUI

@main
struct SnippitApp: App {
    init() {
        SubscriptionManager.shared.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(SubscriptionManager.shared)
        }
        .modelContainer(try! CloudKitSyncManager.createContainer())
    }
}
