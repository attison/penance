import Foundation

class PersistenceService {
    static let shared = PersistenceService()

    // Use App Group for sharing between app and extensions
    private let defaults = UserDefaults(suiteName: "group.com.attison.penance") ?? UserDefaults.standard

    // Keys
    private enum Keys {
        static let balanceMinutes = "balanceMinutes"
        static let totalWorkouts = "totalWorkouts"
        static let totalScreenTimeMinutes = "totalScreenTimeMinutes"
        static let startDate = "startDate"
        static let dailyWorkouts = "dailyWorkouts"
        static let dailyScreenTime = "dailyScreenTime"
        static let ytdWorkouts = "ytdWorkouts"
        static let ytdScreenTime = "ytdScreenTime"
        static let yearOfLastUpdate = "yearOfLastUpdate"
        static let workoutType = "workoutType"
        static let workoutsPerMinute = "workoutsPerMinute"
    }

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    // MARK: - Properties
    var balanceMinutes: Int {
        get { defaults.integer(forKey: Keys.balanceMinutes) }
        set { defaults.set(newValue, forKey: Keys.balanceMinutes) }
    }

    var totalWorkouts: Int {
        get { defaults.integer(forKey: Keys.totalWorkouts) }
        set { defaults.set(newValue, forKey: Keys.totalWorkouts) }
    }

    var totalScreenTimeMinutes: Int {
        get { defaults.integer(forKey: Keys.totalScreenTimeMinutes) }
        set { defaults.set(newValue, forKey: Keys.totalScreenTimeMinutes) }
    }

    var ytdWorkouts: Int {
        get { defaults.integer(forKey: Keys.ytdWorkouts) }
        set { defaults.set(newValue, forKey: Keys.ytdWorkouts) }
    }

    var ytdScreenTime: Int {
        get { defaults.integer(forKey: Keys.ytdScreenTime) }
        set { defaults.set(newValue, forKey: Keys.ytdScreenTime) }
    }

    var yearOfLastUpdate: Int {
        get {
            if defaults.object(forKey: Keys.yearOfLastUpdate) == nil {
                return 2026
            }
            return defaults.integer(forKey: Keys.yearOfLastUpdate)
        }
        set { defaults.set(newValue, forKey: Keys.yearOfLastUpdate) }
    }

    var startDate: Date {
        get {
            if let date = defaults.object(forKey: Keys.startDate) as? Date {
                return date
            } else {
                let now = Date()
                defaults.set(now, forKey: Keys.startDate)
                return now
            }
        }
    }

    var workoutType: String {
        get {
            if let type = defaults.string(forKey: Keys.workoutType) {
                return type
            } else {
                let defaultType = "Pushups"
                defaults.set(defaultType, forKey: Keys.workoutType)
                return defaultType
            }
        }
        set { defaults.set(newValue, forKey: Keys.workoutType) }
    }

    var workoutsPerMinute: Int {
        get {
            let value = defaults.integer(forKey: Keys.workoutsPerMinute)
            if value == 0 {
                // First time - set default
                let defaultValue = 5
                defaults.set(defaultValue, forKey: Keys.workoutsPerMinute)
                return defaultValue
            }
            return value
        }
        set { defaults.set(newValue, forKey: Keys.workoutsPerMinute) }
    }

    private init() {
        checkFirstLaunch()
    }

    private func checkFirstLaunch() {
        // Check if this is first launch after install
        if defaults.object(forKey: "hasLaunchedBefore") == nil {
            // First launch - clear any old data
            reset()
            defaults.set(true, forKey: "hasLaunchedBefore")
        }
    }

    // MARK: - Daily Tracking
    func addDailyWorkouts(_ count: Int, for date: Date = Date()) {
        let dateKey = dateFormatter.string(from: date)
        var dailyData = defaults.dictionary(forKey: Keys.dailyWorkouts) as? [String: [String: Any]] ?? [:]

        // Get existing entry or create new one
        var dayEntry = dailyData[dateKey] as? [String: Any] ?? [:]
        let existingCount = dayEntry["count"] as? Int ?? 0

        // Update with new data
        dayEntry["count"] = existingCount + count
        dayEntry["workoutType"] = workoutType
        dailyData[dateKey] = dayEntry

        defaults.set(dailyData, forKey: Keys.dailyWorkouts)
    }

    func addDailyScreenTime(_ minutes: Int, for date: Date = Date()) {
        let dateKey = dateFormatter.string(from: date)
        var dailyData = defaults.dictionary(forKey: Keys.dailyScreenTime) as? [String: Int] ?? [:]
        dailyData[dateKey, default: 0] += minutes
        defaults.set(dailyData, forKey: Keys.dailyScreenTime)
    }

    func getDailyWorkouts(for date: Date) -> Int {
        let dateKey = dateFormatter.string(from: date)
        let dailyData = defaults.dictionary(forKey: Keys.dailyWorkouts) as? [String: [String: Any]] ?? [:]

        guard let dayEntry = dailyData[dateKey],
              let count = dayEntry["count"] as? Int else {
            return 0
        }

        return count
    }

    func getDailyScreenTime(for date: Date) -> Int {
        let dateKey = dateFormatter.string(from: date)
        let dailyData = defaults.dictionary(forKey: Keys.dailyScreenTime) as? [String: Int] ?? [:]
        return dailyData[dateKey] ?? 0
    }

    func checkAndResetYearIfNeeded() {
        let currentYear = Calendar.current.component(.year, from: Date())
        if currentYear != yearOfLastUpdate {
            ytdWorkouts = 0
            ytdScreenTime = 0
            yearOfLastUpdate = currentYear
        }
    }

    // Recalculate totals from daily dictionaries
    func recalculateTotals() {
        let currentYear = Calendar.current.component(.year, from: Date())

        let workoutData = defaults.dictionary(forKey: Keys.dailyWorkouts) as? [String: [String: Any]] ?? [:]
        let screenTimeData = defaults.dictionary(forKey: Keys.dailyScreenTime) as? [String: Int] ?? [:]

        var allTimeWorkouts = 0
        var allTimeScreenTime = 0
        var ytdWorkoutsCalc = 0
        var ytdScreenTimeCalc = 0

        for (dateKey, dayEntry) in workoutData {
            guard let count = dayEntry["count"] as? Int else { continue }

            allTimeWorkouts += count

            if let date = dateFormatter.date(from: dateKey),
               Calendar.current.component(.year, from: date) == currentYear {
                ytdWorkoutsCalc += count
            }
        }

        for (dateKey, screenTime) in screenTimeData {
            allTimeScreenTime += screenTime

            // Check if this date is from current year
            if let date = dateFormatter.date(from: dateKey),
               Calendar.current.component(.year, from: date) == currentYear {
                ytdScreenTimeCalc += screenTime
            }
        }

        // Update stored totals
        totalWorkouts = allTimeWorkouts
        totalScreenTimeMinutes = allTimeScreenTime
        ytdWorkouts = ytdWorkoutsCalc
        ytdScreenTime = ytdScreenTimeCalc
    }

    func reset() {
        defaults.removeObject(forKey: Keys.balanceMinutes)
        defaults.removeObject(forKey: Keys.totalWorkouts)
        defaults.removeObject(forKey: Keys.totalScreenTimeMinutes)
        defaults.removeObject(forKey: Keys.dailyWorkouts)
        defaults.removeObject(forKey: Keys.dailyScreenTime)
        defaults.removeObject(forKey: Keys.ytdWorkouts)
        defaults.removeObject(forKey: Keys.ytdScreenTime)
        defaults.removeObject(forKey: Keys.yearOfLastUpdate)
    }
}
