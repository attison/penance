import SwiftUI

struct WeeklyChartView: View {
    let weekData: [DayData]
    let title: String
    let workoutType: String
    let workoutsPerMinute: Int

    private let daysOfWeek = ["S", "M", "T", "W", "T", "F", "S"]
    private let chartHeight: CGFloat = 200

    var maxMinutes: Int {
        let workoutMax = weekData.map { $0.workouts }.max() ?? 0
        let minuteMax = weekData.map { $0.screenTimeMinutes }.max() ?? 0

        // Convert workouts to equivalent minutes
        let workoutAsMinutes = (workoutMax + workoutsPerMinute - 1) / workoutsPerMinute // Round up

        // Take the higher of the two to ensure both fit
        let dataMax = max(workoutAsMinutes, minuteMax)

        // Round up to next multiple of 20 so all grid lines (÷4) are divisible by 5
        let rounded = ((dataMax + 19) / 20) * 20
        return max(rounded, 20) // Minimum scale of 20 minutes
    }

    var maxWorkouts: Int {
        // Workouts axis is always minutes * workoutsPerMinute
        return maxMinutes * workoutsPerMinute
    }

    var weekTotalWorkouts: Int {
        weekData.reduce(0) { $0 + $1.workouts }
    }

    var weekTotalScreenTime: Int {
        weekData.reduce(0) { $0 + $1.screenTimeMinutes }
    }

    var weekBalance: Int {
        // Balance = (workouts equivalent in minutes) - screen time minutes
        let workoutMinutes = weekTotalWorkouts / workoutsPerMinute
        return workoutMinutes - weekTotalScreenTime
    }

    var balanceText: String {
        if weekBalance == 0 {
            return "Your week was balanced"
        } else if weekBalance > 0 {
            return "Balance: +\(weekBalance) min"
        } else {
            let workoutsOwed = abs(weekBalance) * workoutsPerMinute
            return "Balance: -\(workoutsOwed) \(workoutType)"
        }
    }

    var balanceColor: Color {
        if weekBalance == 0 {
            return .secondary
        } else if weekBalance > 0 {
            return Color(red: 0.051, green: 0.380, blue: 0.370) // Dark workout color - teal/sage
        } else {
            return Color(red: 0.169, green: 0.051, blue: 0.008) // Dark screen time color
        }
    }

    var backgroundColor: Color {
        return Color(red: 0.929, green: 0.902, blue: 0.855)
    }

    var gridLine: some View {
        Rectangle()
            .fill(Color.secondary.opacity(0.2))
            .frame(height: 1)
    }

    var body: some View {
        VStack(spacing: 8) {
            // Title and Balance
            HStack(alignment: .center) {
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)

                Spacer()

                Text(balanceText)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(balanceColor)
            }
            .padding(.bottom, 8)

            // Chart
            HStack(alignment: .bottom, spacing: 0) {
                // Left axis (Workouts)
                ZStack(alignment: .trailing) {
                    VStack(spacing: 0) {
                        Text("\(maxWorkouts)")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                            .frame(height: 0)
                        Spacer()
                        Text("\(maxWorkouts * 3 / 4)")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                            .frame(height: 0)
                        Spacer()
                        Text("\(maxWorkouts / 2)")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                            .frame(height: 0)
                        Spacer()
                        Text("\(maxWorkouts / 4)")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                            .frame(height: 0)
                        Spacer()
                        Text("0")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                            .frame(height: 0)
                    }
                }
                .frame(width: 30, height: chartHeight)

                // Bars with grid lines
                ZStack(alignment: .bottom) {
                    // Grid lines
                    VStack(spacing: 0) {
                        gridLine
                        Spacer()
                        gridLine
                        Spacer()
                        gridLine
                        Spacer()
                        gridLine
                        Spacer()
                    }
                    .frame(height: chartHeight)

                    // Bars
                    HStack(alignment: .bottom, spacing: 4) {
                        ForEach(Array(weekData.enumerated()), id: \.element.id) { index, day in
                            VStack(spacing: 4) {
                                // Bar container - ensures bottom alignment
                                VStack(spacing: 0) {
                                    Spacer(minLength: 0)

                                    // Bar pair
                                    HStack(alignment: .bottom, spacing: 2) {
                                        // Workout bar (dark workout color - teal/sage)
                                        RoundedRectangle(cornerRadius: 3)
                                            .fill(Color(red: 0.051, green: 0.380, blue: 0.370))
                                            .frame(width: 14, height: max(barHeight(workouts: day.workouts), 3))

                                        // Screen time bar (dark screen time color)
                                        RoundedRectangle(cornerRadius: 3)
                                            .fill(Color(red: 0.169, green: 0.051, blue: 0.008))
                                            .frame(width: 14, height: max(barHeight(minutes: day.screenTimeMinutes), 3))
                                    }
                                }
                                .frame(height: chartHeight, alignment: .bottom)

                                // Day label
                                Text(index < daysOfWeek.count ? daysOfWeek[index] : "")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
                .frame(maxWidth: .infinity)

                // Right axis (Minutes)
                ZStack(alignment: .leading) {
                    VStack(spacing: 0) {
                        Text("\(maxMinutes)")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                            .frame(height: 0)
                        Spacer()
                        Text("\(maxMinutes * 3 / 4)")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                            .frame(height: 0)
                        Spacer()
                        Text("\(maxMinutes / 2)")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                            .frame(height: 0)
                        Spacer()
                        Text("\(maxMinutes / 4)")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                            .frame(height: 0)
                        Spacer()
                        Text("0")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                            .frame(height: 0)
                    }
                }
                .frame(width: 30, height: chartHeight)
            }

            // Legend
            HStack(spacing: 20) {
                HStack(spacing: 6) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color(red: 0.051, green: 0.380, blue: 0.370))
                        .frame(width: 12, height: 12)
                    Text(workoutType)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }

                HStack(spacing: 6) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color(red: 0.169, green: 0.051, blue: 0.008))
                        .frame(width: 12, height: 12)
                    Text("Screen Time")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(16)
        .background(backgroundColor)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
    }

    private func barHeight(workouts: Int) -> CGFloat {
        guard maxWorkouts > 0 else { return 0 }
        return (CGFloat(workouts) / CGFloat(maxWorkouts)) * chartHeight
    }

    private func barHeight(minutes: Int) -> CGFloat {
        guard maxMinutes > 0 else { return 0 }
        return (CGFloat(minutes) / CGFloat(maxMinutes)) * chartHeight
    }
}
