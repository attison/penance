import SwiftUI
import UserNotifications

@main
struct PenanceApp: App {
    @StateObject private var counterManager = CounterManager.shared
    @StateObject private var screenTimeMonitor = ScreenTimeMonitor.shared
    @Environment(\.scenePhase) private var scenePhase

    init() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(counterManager)
                .environmentObject(screenTimeMonitor)
                .preferredColorScheme(.light)
                .onAppear {
                    counterManager.reloadData()
                    screenTimeMonitor.checkAuthorizationStatus()
                }
                .onChange(of: scenePhase) { oldPhase, newPhase in
                    if newPhase == .active {
                        // App came to foreground - reload data from extension updates
                        counterManager.reloadData()
                    }
                }
        }
    }

}
