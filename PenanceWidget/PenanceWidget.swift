import WidgetKit
import SwiftUI

struct BalanceEntry: TimelineEntry {
    let date: Date
    let balanceMinutes: Int
    let workoutType: String
    let workoutsPerMinute: Int
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> BalanceEntry {
        BalanceEntry(date: Date(), balanceMinutes: 0, workoutType: "Pushups", workoutsPerMinute: 5)
    }

    func getSnapshot(in context: Context, completion: @escaping (BalanceEntry) -> ()) {
        let entry = BalanceEntry(
            date: Date(),
            balanceMinutes: getBalance(),
            workoutType: getWorkoutType(),
            workoutsPerMinute: getWorkoutsPerMinute()
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let currentDate = Date()
        let entry = BalanceEntry(
            date: currentDate,
            balanceMinutes: getBalance(),
            workoutType: getWorkoutType(),
            workoutsPerMinute: getWorkoutsPerMinute()
        )

        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }

    private func getBalance() -> Int {
        guard let defaults = UserDefaults(suiteName: "group.com.attison.penance") else {
            return 0
        }
        return defaults.integer(forKey: "balanceMinutes")
    }

    private func getWorkoutType() -> String {
        guard let defaults = UserDefaults(suiteName: "group.com.attison.penance"),
              let workoutType = defaults.string(forKey: "workoutType") else {
            return "Pushups"
        }
        return workoutType
    }

    private func getWorkoutsPerMinute() -> Int {
        guard let defaults = UserDefaults(suiteName: "group.com.attison.penance") else {
            return 5
        }
        let value = defaults.integer(forKey: "workoutsPerMinute")
        return value > 0 ? value : 5
    }
}

struct PenanceWidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        Group {
            if entry.balanceMinutes == 0 {
                Text("☯")
                    .font(.system(size: 40, weight: .regular))
            } else {
                VStack(spacing: 2) {
                    Text(balanceValue)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                    Text(balanceUnit)
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .opacity(0.8)
                }
            }
        }
        .containerBackground(for: .widget) {
            Color.clear
        }
    }

    private var balanceValue: String {
        let balance = entry.balanceMinutes

        if balance == 0 {
            return "☯"
        } else if balance > 0 {
            return "+\(balance)"
        } else {
            let workouts = abs(balance) * entry.workoutsPerMinute
            return "-\(workouts)"
        }
    }

    private var balanceUnit: String {
        let balance = entry.balanceMinutes

        if balance == 0 {
            return ""
        } else if balance > 0 {
            return "min"
        } else {
            return entry.workoutType
        }
    }
}

struct PenanceWidget: Widget {
    let kind: String = "PenanceWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            PenanceWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Penance Balance")
        .description("Shows your current workout/screen time balance")
        .supportedFamilies([.accessoryCircular])
    }
}
