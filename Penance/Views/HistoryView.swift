import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var counterManager: CounterManager
    @State private var currentWeekOffset = 0

    private var currentWeekWorkouts: Int {
        let weekData = counterManager.getWeekData(weekOffset: currentWeekOffset)
        return weekData.reduce(0) { $0 + $1.workouts }
    }

    private var currentWeekScreenTime: Int {
        let weekData = counterManager.getWeekData(weekOffset: currentWeekOffset)
        return weekData.reduce(0) { $0 + $1.screenTimeMinutes }
    }

    private var shouldShowAllTime: Bool {
        return counterManager.yearToDateScreenTime != counterManager.totalScreenTimeMinutes
    }

    var body: some View {
        ZStack {
            Color(red: 0.859, green: 0.835, blue: 0.792)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView(.vertical, showsIndicators: true) {
                    VStack(spacing: 0) {
                        TabView(selection: $currentWeekOffset) {
                            ForEach((0..<12).reversed(), id: \.self) { weekOffset in
                                WeeklyChartView(
                                    weekData: counterManager.getWeekData(weekOffset: weekOffset),
                                    title: getWeekLabel(for: weekOffset),
                                    workoutType: counterManager.workoutType,
                                    workoutsPerMinute: counterManager.workoutsPerMinute
                                )
                                .tag(weekOffset)
                                .padding(.horizontal)
                            }
                        }
                        .tabViewStyle(.page(indexDisplayMode: .never))
                        .frame(height: 360)
                        .padding(.top, 60)
                        .padding(.bottom, 16)

                        VStack(spacing: 10) {
                            StatRow(title: "Weekly \(counterManager.workoutType)", value: "\(currentWeekWorkouts)")
                            StatRow(title: "MTD \(counterManager.workoutType)", value: "\(counterManager.monthToDateWorkouts)")
                            StatRow(title: "YTD \(counterManager.workoutType)", value: "\(counterManager.yearToDateWorkouts)")
                            if shouldShowAllTime {
                                StatRow(title: "All-Time \(counterManager.workoutType)", value: "\(counterManager.totalWorkouts)")
                            }

                            Divider()
                                .padding(.vertical, 4)

                            StatRow(title: "Weekly Screen Time", value: "\(currentWeekScreenTime) min")
                            StatRow(title: "MTD Screen Time", value: "\(counterManager.monthToDateScreenTime) min")
                            StatRow(title: "YTD Screen Time", value: "\(counterManager.yearToDateScreenTime) min")
                            if shouldShowAllTime {
                                StatRow(title: "All-Time Screen Time", value: "\(counterManager.totalScreenTimeMinutes) min")
                            }

                            Divider()
                                .padding(.vertical, 4)

                            StatRow(title: "Date Started", value: counterManager.startDateString)
                        }
                        .padding(16)
                        .background(Color(red: 0.929, green: 0.902, blue: 0.855))
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
                        .padding(.horizontal)
                    }
                }

                VStack(spacing: 3) {
                    Text("Scroll to see settings")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.secondary)
                    Text("˅")
                        .font(.system(size: 24, weight: .regular))
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 40)
            }
        }
    }

    private func getWeekLabel(for offset: Int) -> String {
        if offset == 0 {
            return "This Week"
        } else if offset == 1 {
            return "Last Week"
        } else {
            return "\(offset) Weeks Ago"
        }
    }
}

struct StatRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.primary)
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
        }
    }
}
