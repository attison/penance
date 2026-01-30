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

    // MARK: - Published Properties
    @Published var balanceMinutes: Int = 0
    @Published var totalWorkouts: Int = 0
    @Published var totalScreenTimeMinutes: Int = 0

    // MARK: - Private Properties
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

    private init() {
        persistence.checkAndResetYearIfNeeded()
        persistence.recalculateTotals()

        // Load totals
        totalWorkouts = persistence.totalWorkouts
        totalScreenTimeMinutes = persistence.totalScreenTimeMinutes

        // Calculate balance from totals
        let minutesEarned = totalWorkouts / workoutsPerMinute
        balanceMinutes = minutesEarned - totalScreenTimeMinutes
        persistence.balanceMinutes = balanceMinutes

        wasPositive = balanceMinutes >= 0
    }

    // MARK: - Public Methods

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
        // 1. Update daily workouts
        persistence.addDailyWorkouts(count)

        // 2. Recalculate all totals from daily data
        persistence.recalculateTotals()

        // 3. Calculate balance from totals
        totalWorkouts = persistence.totalWorkouts
        totalScreenTimeMinutes = persistence.totalScreenTimeMinutes
        let minutesEarned = totalWorkouts / workoutsPerMinute
        balanceMinutes = minutesEarned - totalScreenTimeMinutes

        saveData()
    }

    func deductScreenTime(minutes: Int) {
        let previousBalance = balanceMinutes

        // 1. Update daily screen time
        persistence.addDailyScreenTime(minutes)

        // 2. Recalculate all totals from daily data
        persistence.recalculateTotals()

        // 3. Calculate balance from totals
        totalWorkouts = persistence.totalWorkouts
        totalScreenTimeMinutes = persistence.totalScreenTimeMinutes
        let minutesEarned = totalWorkouts / workoutsPerMinute
        balanceMinutes = minutesEarned - totalScreenTimeMinutes

        saveData()

        if previousBalance >= 0 && balanceMinutes < 0 && wasPositive {
            notificationService.sendTimeUpNotification()
            wasPositive = false
        } else if balanceMinutes >= 0 {
            wasPositive = true
        }
    }

    // MARK: - Private Methods

    func reloadData() {
        // Recalculate all totals from daily data
        persistence.recalculateTotals()

        // Load totals into memory
        totalWorkouts = persistence.totalWorkouts
        totalScreenTimeMinutes = persistence.totalScreenTimeMinutes

        // Calculate balance from totals
        let minutesEarned = totalWorkouts / workoutsPerMinute
        balanceMinutes = minutesEarned - totalScreenTimeMinutes

        // Save calculated balance
        persistence.balanceMinutes = balanceMinutes
    }

    private func saveData() {
        persistence.balanceMinutes = balanceMinutes
        WidgetCenter.shared.reloadAllTimelines()
    }
}
