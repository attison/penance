import Foundation
import Combine
import WidgetKit

struct DayData: Identifiable {
    let date: Date
    let workouts: Int
    let screenTimeMinutes: Int

    var id: Date { date }
}

class CounterManager: ObservableObject {
    static let shared = CounterManager()

    @Published var balanceMinutes: Int = 0
    @Published var totalWorkouts: Int = 0
    @Published var totalScreenTimeMinutes: Int = 0

    private let persistence = PersistenceService.shared
    private let notificationService = NotificationService.shared
    private var wasPositive = true

    var workoutType: String {
        persistence.workoutType
    }

    var workoutsPerMinute: Int {
        persistence.workoutsPerMinute
    }

    var startDate: Date {
        persistence.startDate
    }

    var startDateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: startDate)
    }

    var yearToDateWorkouts: Int {
        persistence.ytdWorkouts
    }

    var yearToDateScreenTime: Int {
        persistence.ytdScreenTime
    }

    var monthToDateWorkouts: Int {
        persistence.mtdWorkouts
    }

    var monthToDateScreenTime: Int {
        persistence.mtdScreenTime
    }

    private init() {
        persistence.checkAndResetYearIfNeeded()
        persistence.recalculateTotals()

        totalWorkouts = persistence.totalWorkouts
        totalScreenTimeMinutes = persistence.totalScreenTimeMinutes

        let minutesEarned = totalWorkouts / workoutsPerMinute
        balanceMinutes = minutesEarned - totalScreenTimeMinutes
        persistence.balanceMinutes = balanceMinutes

        wasPositive = balanceMinutes >= 0
    }

    func getWeekData(weekOffset: Int = 0) -> [DayData] {
        let calendar = Calendar.current
        let today = Date()

        guard let weekStart = calendar.date(byAdding: .weekOfYear, value: -weekOffset, to: today),
              let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: weekStart)) else {
            return generateEmptyWeek()
        }

        var weekData: [DayData] = []
        for dayOffset in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: dayOffset, to: startOfWeek) {
                let workouts = persistence.getDailyWorkouts(for: date)
                let screenTime = persistence.getDailyScreenTime(for: date)
                weekData.append(DayData(date: date, workouts: workouts, screenTimeMinutes: screenTime))
            }
        }

        return weekData
    }

    private func generateEmptyWeek() -> [DayData] {
        return (0..<7).map { _ in
            DayData(date: Date(), workouts: 0, screenTimeMinutes: 0)
        }
    }

    func addWorkouts(_ count: Int) {
        persistence.addDailyWorkouts(count)
        persistence.recalculateTotals()

        totalWorkouts = persistence.totalWorkouts
        totalScreenTimeMinutes = persistence.totalScreenTimeMinutes
        let minutesEarned = totalWorkouts / workoutsPerMinute
        balanceMinutes = minutesEarned - totalScreenTimeMinutes

        saveData()
    }

    func reloadData() {
        persistence.recalculateTotals()

        totalWorkouts = persistence.totalWorkouts
        totalScreenTimeMinutes = persistence.totalScreenTimeMinutes

        let minutesEarned = totalWorkouts / workoutsPerMinute
        balanceMinutes = minutesEarned - totalScreenTimeMinutes

        persistence.balanceMinutes = balanceMinutes
        WidgetCenter.shared.reloadAllTimelines()
    }

    private func saveData() {
        persistence.balanceMinutes = balanceMinutes
        WidgetCenter.shared.reloadAllTimelines()
    }
}
