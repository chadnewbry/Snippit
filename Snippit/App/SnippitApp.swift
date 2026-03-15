import RevenueCat
import SwiftData
import SwiftUI

@main
struct SnippitApp: App {
    let container: ModelContainer

    init() {
        SubscriptionManager.shared.configure()
        container = try! CloudKitSyncManager.createContainer()

        #if DEBUG
        if ScreenshotSampleData.isScreenshotMode {
            let context = ModelContext(container)
            ScreenshotSampleData.populate(context: context)
        }
        #endif
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(SubscriptionManager.shared)
        }
        .modelContainer(container)
    }
}
