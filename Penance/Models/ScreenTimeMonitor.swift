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
        loadSelectedApps()

        if hasCompletedSetup && !selectedApps.applicationTokens.isEmpty && isAuthorized {
            startMonitoring()
        }
    }

    private func loadSelectedApps() {
        if let data = defaults.data(forKey: "selectedAppsData") {
            do {
                selectedApps = try JSONDecoder().decode(FamilyActivitySelection.self, from: data)
            } catch {
                selectedApps = FamilyActivitySelection()
            }
        }
    }

    private func saveSelectedApps() {
        do {
            let data = try JSONEncoder().encode(selectedApps)
            defaults.set(data, forKey: "selectedAppsData")
        } catch {
            print("Failed to save selected apps: \(error)")
        }
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

        saveSelectedApps()

        let schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: 0, minute: 0),
            intervalEnd: DateComponents(hour: 23, minute: 59),
            repeats: true
        )

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
}
