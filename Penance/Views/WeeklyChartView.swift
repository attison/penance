import SwiftUI

struct WeeklyChartView: View {
    let weekData: [DayData]
    let title: String
    let workoutType: String
    let workoutsPerMinute: Int
    @Environment(\.colorScheme) var colorScheme

    private let daysOfWeek = ["S", "M", "T", "W", "T", "F", "S"]
    private let chartHeight: CGFloat = 200

    var maxWorkouts: Int {
        let workoutMax = weekData.map { $0.workouts }.max() ?? 0
        let minuteMax = weekData.map { $0.screenTimeMinutes }.max() ?? 0

        // Convert minutes to equivalent workouts
        let minuteAsWorkouts = minuteMax * workoutsPerMinute

        // Take the higher of the two to ensure both fit
        let dataMax = max(workoutMax, minuteAsWorkouts)

        // Round up to next 25 to give some headroom
        let rounded = ((dataMax + 24) / 25) * 25
        return max(rounded, 50) // Minimum scale of 50
    }

    var maxMinutes: Int {
        // Minutes axis is always 1/workoutsPerMinute of workout axis
        return maxWorkouts / workoutsPerMinute
    }

    var body: some View {
        VStack(spacing: 16) {
            // Title
            Text(title)
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)

            // Chart
            HStack(alignment: .bottom, spacing: 0) {
                // Left axis (Workouts)
                VStack(alignment: .trailing, spacing: 0) {
                    Text("\(maxWorkouts)")
                        .font(.system(size: 10, design: .rounded))
                        .foregroundColor(.secondary)
                        .offset(y: -4)
                    Spacer()
                    Text("0")
                        .font(.system(size: 10, design: .rounded))
                        .foregroundColor(.secondary)
                }
                .frame(width: 30, height: chartHeight)

                // Bars
                HStack(alignment: .bottom, spacing: 4) {
                    ForEach(Array(weekData.enumerated()), id: \.element.id) { index, day in
                        VStack(spacing: 4) {
                            // Bar container - ensures bottom alignment
                            VStack(spacing: 0) {
                                Spacer(minLength: 0)

                                // Bar pair
                                HStack(alignment: .bottom, spacing: 2) {
                                    // Workout bar (light green)
                                    RoundedRectangle(cornerRadius: 3)
                                        .fill(Color(red: 0.5, green: 0.75, blue: 0.6))
                                        .frame(width: 14, height: max(barHeight(workouts: day.workouts), 3))

                                    // Screen time bar (light red)
                                    RoundedRectangle(cornerRadius: 3)
                                        .fill(Color(red: 0.9, green: 0.5, blue: 0.5))
                                        .frame(width: 14, height: max(barHeight(minutes: day.screenTimeMinutes), 3))
                                }
                            }
                            .frame(height: chartHeight, alignment: .bottom)

                            // Day label
                            Text(index < daysOfWeek.count ? daysOfWeek[index] : "")
                                .font(.system(size: 11, weight: .medium, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .frame(maxWidth: .infinity)

                // Right axis (Minutes)
                VStack(alignment: .leading, spacing: 0) {
                    Text("\(maxMinutes)")
                        .font(.system(size: 10, design: .rounded))
                        .foregroundColor(.secondary)
                        .offset(y: -4)
                    Spacer()
                    Text("0")
                        .font(.system(size: 10, design: .rounded))
                        .foregroundColor(.secondary)
                }
                .frame(width: 30, height: chartHeight)
            }

            // Legend
            HStack(spacing: 20) {
                HStack(spacing: 6) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color(red: 0.5, green: 0.75, blue: 0.6))
                        .frame(width: 12, height: 12)
                    Text(workoutType)
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(.secondary)
                }

                HStack(spacing: 6) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color(red: 0.9, green: 0.5, blue: 0.5))
                        .frame(width: 12, height: 12)
                    Text("Screen Time")
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(16)
        .background(colorScheme == .dark ? Color(red: 0.18, green: 0.18, blue: 0.20) : Color(red: 0.98, green: 0.97, blue: 0.95))
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
