import DeviceActivity
import Foundation
import WidgetKit
import UserNotifications

class DeviceActivityMonitorExtension: DeviceActivityMonitor {
    override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventDidReachThreshold(event, activity: activity)

        #if DEBUG
        print("🔔 Extension: Event fired - \(event)")
        #endif

        guard let defaults = UserDefaults(suiteName: "group.com.attison.penance") else {
            #if DEBUG
            print("❌ Extension: Cannot access App Group")
            #endif
            return
        }

        // Extract the minute number from event name (e.g., "min42" -> 42)
        // This IS the total screen time for today
        let eventName = String(describing: event)
        guard let todaysTotalScreenTime = extractMinute(from: eventName) else {
            #if DEBUG
            print("❌ Extension: Cannot extract minute from event name")
            #endif
            return
        }

        #if DEBUG
        print("📊 Extension: Today's total screen time = \(todaysTotalScreenTime) minutes")
        #endif

        let previousBalance = defaults.integer(forKey: "balanceMinutes")

        // 1. Update daily screen time total
        updateDailyScreenTime(defaults: defaults, totalForToday: todaysTotalScreenTime)

        // 2. Recalculate all totals (YTD, all-time) from daily data
        recalculateTotals(defaults: defaults)

        // 3. Calculate balance from totals: (totalWorkouts / workoutsPerMinute) - totalScreenTime
        let totalWorkouts = defaults.integer(forKey: "totalWorkouts")
        let totalScreenTime = defaults.integer(forKey: "totalScreenTimeMinutes")
        let workoutsPerMinute = defaults.integer(forKey: "workoutsPerMinute") > 0 ? defaults.integer(forKey: "workoutsPerMinute") : 5
        let minutesEarned = totalWorkouts / workoutsPerMinute
        let balance = minutesEarned - totalScreenTime
        defaults.set(balance, forKey: "balanceMinutes")

        // Check if reached equilibrium - send notification immediately
        if previousBalance > 0 && balance == 0 {
            sendTimeUpNotification()
            #if DEBUG
            print("🔔 Extension: Reached equilibrium - notification sent")
            #endif
        }

        #if DEBUG
        print("✅ Extension: Updated balance = \(balance)")
        print("📈 Extension: Total workouts = \(defaults.integer(forKey: "totalWorkouts")), Total screen time = \(defaults.integer(forKey: "totalScreenTimeMinutes"))")
        #endif

        WidgetCenter.shared.reloadAllTimelines()
    }

    private func extractMinute(from eventName: String) -> Int? {
        // Extract number from "min42" -> 42
        let digits = eventName.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        return Int(digits)
    }

    private func updateDailyScreenTime(defaults: UserDefaults, totalForToday: Int) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateKey = dateFormatter.string(from: Date())

        // Overwrite with today's total (handles missed events)
        var dailyData = defaults.dictionary(forKey: "dailyScreenTime") as? [String: Int] ?? [:]
        dailyData[dateKey] = totalForToday
        defaults.set(dailyData, forKey: "dailyScreenTime")
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

        UNUserNotificationCenter.current().add(request) { error in
            #if DEBUG
            if let error = error {
                print("❌ Extension: Failed to send notification - \(error)")
            } else {
                print("✅ Extension: Notification scheduled")
            }
            #endif
        }
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
