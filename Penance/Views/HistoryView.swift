import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var counterManager: CounterManager
    @State private var currentWeekOffset = 0
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView(.vertical, showsIndicators: true) {
                    VStack(spacing: 0) {
                        // Header
                        Text("History")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                            .padding(.top, 60)
                            .padding(.bottom, 0)

                        // Swipeable weekly charts
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

                        // Stats Section
                        VStack(spacing: 10) {
                            StatRow(title: "YTD \(counterManager.workoutType)", value: "\(counterManager.yearToDateWorkouts)")
                            StatRow(title: "YTD Screen Time", value: "\(counterManager.yearToDateScreenTime) min")
                            StatRow(title: "All-Time \(counterManager.workoutType)", value: "\(counterManager.totalWorkouts)")
                            StatRow(title: "All-Time Screen Time", value: "\(counterManager.totalScreenTimeMinutes) min")
                            StatRow(title: "Date Started", value: counterManager.startDateString)
                        }
                        .padding(16)
                        .background(colorScheme == .dark ? Color(red: 0.18, green: 0.18, blue: 0.20) : Color(red: 0.98, green: 0.97, blue: 0.95))
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
                        .padding(.horizontal)
                    }
                }

                // Scroll hint - pinned to bottom
                VStack(spacing: 3) {
                    Text("Scroll to see settings")
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(.secondary)
                    Text("˅")
                        .font(.system(size: 24, weight: .regular, design: .rounded))
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 60)
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
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundColor(.primary)
            Spacer()
            Text(value)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(.secondary)
        }
    }
}
