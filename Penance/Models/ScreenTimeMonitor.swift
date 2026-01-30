import Foundation
import Combine
import FamilyControls
import DeviceActivity

class ScreenTimeMonitor: ObservableObject {
    static let shared = ScreenTimeMonitor()

    @Published var isAuthorized = false
    @Published var hasCompletedSetup = false
    @Published var selectedApps = FamilyActivitySelection()

    private let center = AuthorizationCenter.shared
    private let activityCenter = DeviceActivityCenter()
    private let activityName = DeviceActivityName("socialMediaMonitoring")
    private let defaults = UserDefaults(suiteName: "group.com.attison.penance") ?? UserDefaults.standard

    private init() {
        checkAuthorizationStatus()
        hasCompletedSetup = defaults.bool(forKey: "hasCompletedSetup")
    }

    func requestAuthorization() {
        Task {
            do {
                try await center.requestAuthorization(for: .individual)
                await MainActor.run {
                    self.isAuthorized = true
                }
            } catch {
                await MainActor.run {
                    self.isAuthorized = false
                }
            }
        }
    }

    func checkAuthorizationStatus() {
        // System already persists authorization state
        switch center.authorizationStatus {
        case .approved:
            isAuthorized = true
        default:
            isAuthorized = false
        }
    }

    func startMonitoring() {
        guard !selectedApps.applicationTokens.isEmpty else {
            return
        }

        // Daily schedule from midnight to midnight, repeats every day
        let schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: 0, minute: 0),
            intervalEnd: DateComponents(hour: 23, minute: 59),
            repeats: true
        )

        // Create threshold events for each minute up to 480 minutes (8 hours)
        // Each event fires once per day when cumulative usage reaches that threshold
        var events: [DeviceActivityEvent.Name: DeviceActivityEvent] = [:]
        for minute in 1...480 {
            let event = DeviceActivityEvent(
                applications: selectedApps.applicationTokens,
                threshold: DateComponents(minute: minute)
            )
            events[DeviceActivityEvent.Name("min\(minute)")] = event
        }

        do {
            try activityCenter.startMonitoring(
                activityName,
                during: schedule,
                events: events
            )
            hasCompletedSetup = true
            defaults.set(true, forKey: "hasCompletedSetup")
        } catch {
            hasCompletedSetup = false
            defaults.set(false, forKey: "hasCompletedSetup")
        }
    }

    func stopMonitoring() {
        activityCenter.stopMonitoring([activityName])
        hasCompletedSetup = false
        defaults.set(false, forKey: "hasCompletedSetup")
    }

    #if DEBUG
    // Manual method for testing in development only
    func deductScreenTime(minutes: Int) {
        CounterManager.shared.deductScreenTime(minutes: minutes)
    }
    #endif
}
