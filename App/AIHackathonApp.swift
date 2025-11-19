import SwiftUI
import Firebase

@main
struct AIHackathonApp: App {
    @StateObject private var appState = AppState()
    init() {
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environmentObject(appState)
        }
    }
}
