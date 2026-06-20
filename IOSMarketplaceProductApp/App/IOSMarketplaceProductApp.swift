import SwiftUI

@main
struct IOSMarketplaceProductApp: App {
    @StateObject private var appEnvironment = AppEnvironment()

    init() {
        URLCache.configureMarketplaceCache()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appEnvironment)
        }
    }
}
