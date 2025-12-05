import SwiftUI
import Combine

@main
struct LandlordApp: App {
    @StateObject private var haptics = HapticsManager()
    @StateObject private var paths = RealmPaths()

    var body: some Scene {
        WindowGroup {
            LandlordMainScreen()
                .environmentObject(haptics)
                .environmentObject(paths)
        }
    }
}
