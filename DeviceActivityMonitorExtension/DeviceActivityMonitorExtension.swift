import DeviceActivity
import Foundation
import WidgetKit
import UserNotifications

class DeviceActivityMonitorExtension: DeviceActivityMonitor {
    private let screenTimeQueue = DispatchQueue(label: "com.penance.screentime.sync")

    override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventDidReachThreshold(event, activity: activity)

        screenTimeQueue.async {
            self.processEvent()
        }
    }

    private func processEvent() {
        guard let defaults = UserDefaults(suiteName: "group.com.attison.penance") else {
            return
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let today = dateFormatter.string(from: Date())

        let lastProcessedDay = defaults.string(forKey: "lastProcessedDay") ?? ""
        var processedMinutes = defaults.integer(forKey: "processedMinutesToday")

        if today != lastProcessedDay {
            processedMinutes = 0
            defaults.set(today, forKey: "lastProcessedDay")
        }

        processedMinutes += 1
        defaults.set(processedMinutes, forKey: "processedMinutesToday")

        var dailyData = defaults.dictionary(forKey: "dailyScreenTime") as? [String: Int] ?? [:]
        dailyData[today] = processedMinutes
        defaults.set(dailyData, forKey: "dailyScreenTime")

        recalculateTotals(defaults: defaults)

        let totalWorkouts = defaults.integer(forKey: "totalWorkouts")
        let totalScreenTime = defaults.integer(forKey: "totalScreenTimeMinutes")
        let workoutsPerMinute = defaults.integer(forKey: "workoutsPerMinute") > 0 ? defaults.integer(forKey: "workoutsPerMinute") : 5
        let minutesEarned = totalWorkouts / workoutsPerMinute
        let balance = minutesEarned - totalScreenTime
        let previousBalance = defaults.integer(forKey: "balanceMinutes")
        defaults.set(balance, forKey: "balanceMinutes")

        if previousBalance > 0 && balance <= 0 {
            sendTimeUpNotification()
        }

        WidgetCenter.shared.reloadAllTimelines()
    }

    private func sendTimeUpNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Penance"
        content.body = "Time's up loser!"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "timeUp-\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { _ in }
    }

    private func recalculateTotals(defaults: UserDefaults) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let calendar = Calendar.current
        let now = Date()
        let currentYear = calendar.component(.year, from: now)
        let currentMonth = calendar.component(.month, from: now)

        let workoutData = defaults.dictionary(forKey: "dailyWorkouts") as? [String: [String: Any]] ?? [:]
        let screenTimeData = defaults.dictionary(forKey: "dailyScreenTime") as? [String: Int] ?? [:]

        var allTimeWorkouts = 0
        var allTimeScreenTime = 0
        var ytdWorkouts = 0
        var ytdScreenTime = 0
        var mtdWorkouts = 0
        var mtdScreenTime = 0

        for (dateKey, dayEntry) in workoutData {
            guard let count = dayEntry["count"] as? Int else { continue }

            allTimeWorkouts += count

            if let date = dateFormatter.date(from: dateKey) {
                let year = calendar.component(.year, from: date)
                let month = calendar.component(.month, from: date)

                if year == currentYear {
                    ytdWorkouts += count

                    if month == currentMonth {
                        mtdWorkouts += count
                    }
                }
            }
        }

        for (dateKey, screenTime) in screenTimeData {
            allTimeScreenTime += screenTime

            if let date = dateFormatter.date(from: dateKey) {
                let year = calendar.component(.year, from: date)
                let month = calendar.component(.month, from: date)

                if year == currentYear {
                    ytdScreenTime += screenTime

                    if month == currentMonth {
                        mtdScreenTime += screenTime
                    }
                }
            }
        }

        // Update stored totals
        defaults.set(allTimeWorkouts, forKey: "totalWorkouts")
        defaults.set(allTimeScreenTime, forKey: "totalScreenTimeMinutes")
        defaults.set(ytdWorkouts, forKey: "ytdWorkouts")
        defaults.set(ytdScreenTime, forKey: "ytdScreenTime")
        defaults.set(mtdWorkouts, forKey: "mtdWorkouts")
        defaults.set(mtdScreenTime, forKey: "mtdScreenTime")
    }
}
