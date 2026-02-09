import SwiftUI

struct WeeklyChartView: View {
    let weekData: [DayData]
    let title: String
    let workoutType: String
    let workoutsPerMinute: Int

    private let daysOfWeek = ["S", "M", "T", "W", "T", "F", "S"]
    private let chartHeight: CGFloat = 200

    @State private var tappedBar: TappedBarInfo?

    enum BarType {
        case workout
        case screenTime
    }

    struct TappedBarInfo: Equatable {
        let date: Date
        let barType: BarType
        let value: Int
    }

    var maxMinutes: Int {
        let workoutMax = weekData.map { $0.workouts }.max() ?? 0
        let minuteMax = weekData.map { $0.screenTimeMinutes }.max() ?? 0
        let workoutAsMinutes = workoutMax / workoutsPerMinute
        let dataMax = max(workoutAsMinutes, minuteMax)
        let rounded = ((dataMax + 19) / 20) * 20
        return max(rounded, 20)
    }

    var maxWorkouts: Int {
        return maxMinutes * workoutsPerMinute
    }

    var weekTotalWorkouts: Int {
        weekData.reduce(0) { $0 + $1.workouts }
    }

    var weekTotalScreenTime: Int {
        weekData.reduce(0) { $0 + $1.screenTimeMinutes }
    }

    var weekBalance: Int {
        let workoutMinutes = weekTotalWorkouts / workoutsPerMinute
        return workoutMinutes - weekTotalScreenTime
    }

    var balanceText: String {
        if weekBalance == 0 {
            let verb = title == "This Week" ? "is" : "was"
            return "Your week \(verb) balanced"
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
            return Color(red: 0.051, green: 0.380, blue: 0.370)
        } else {
            return Color(red: 0.169, green: 0.051, blue: 0.008)
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

    var chartWithGridlines: some View {
        VStack(spacing: 0) {
            HStack(alignment: .bottom, spacing: 4) {
                ForEach(Array(weekData.enumerated()), id: \.element.id) { index, day in
                    ZStack {
                        HStack(alignment: .bottom, spacing: 2) {
                            Color.clear
                                .frame(width: 14)
                                .overlay(
                                    Group {
                                        if let tapped = tappedBar, tapped.date == day.date, tapped.barType == .workout {
                                            let label = workoutType
                                            let color = Color(red: 0.051, green: 0.380, blue: 0.370)
                                            tooltipView(value: tapped.value, label: label, color: color)
                                        }
                                    }
                                )

                            Color.clear
                                .frame(width: 14)
                                .overlay(
                                    Group {
                                        if let tapped = tappedBar, tapped.date == day.date, tapped.barType == .screenTime {
                                            let label = "Minutes"
                                            let color = Color(red: 0.169, green: 0.051, blue: 0.008)
                                            tooltipView(value: tapped.value, label: label, color: color)
                                        }
                                    }
                                )
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 50)
            .padding(.bottom, 4)

            ZStack(alignment: .bottom) {
                gridLines
                HStack(alignment: .bottom, spacing: 4) {
                    ForEach(Array(weekData.enumerated()), id: \.element.id) { index, day in
                        barColumn(for: day)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: chartHeight)
        }
    }

    var gridLines: some View {
        GeometryReader { geometry in
            ForEach([1.0, 0.75, 0.5, 0.25, 0.0], id: \.self) { position in
                gridLine
                    .position(x: geometry.size.width / 2, y: geometry.size.height * (1 - position))
            }
        }
    }

    func barColumn(for day: DayData) -> some View {
        let workoutColor = Color(red: 0.051, green: 0.380, blue: 0.370)
        let screenTimeColor = Color(red: 0.169, green: 0.051, blue: 0.008)
        let workoutHeight = barHeight(workouts: day.workouts)
        let screenTimeHeight = barHeight(minutes: day.screenTimeMinutes)

        return VStack(spacing: 0) {
            Spacer(minLength: 0)

            HStack(alignment: .bottom, spacing: 2) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(workoutColor)
                    .frame(width: 14, height: workoutHeight)
                    .onTapGesture {
                        let newTap = TappedBarInfo(date: day.date, barType: .workout, value: day.workouts)
                        if tappedBar == newTap {
                            tappedBar = nil
                        } else {
                            tappedBar = newTap
                        }
                    }

                RoundedRectangle(cornerRadius: 3)
                    .fill(screenTimeColor)
                    .frame(width: 14, height: screenTimeHeight)
                    .onTapGesture {
                        let newTap = TappedBarInfo(date: day.date, barType: .screenTime, value: day.screenTimeMinutes)
                        if tappedBar == newTap {
                            tappedBar = nil
                        } else {
                            tappedBar = newTap
                        }
                    }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: chartHeight, alignment: .bottom)
    }

    var dayLabels: some View {
        HStack(alignment: .top, spacing: 4) {
            ForEach(Array(weekData.enumerated()), id: \.element.id) { index, day in
                Text(index < daysOfWeek.count ? daysOfWeek[index] : "")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.top, 4)
    }

    var leftAxisLabels: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: 50)
            ZStack(alignment: .trailing) {
                GeometryReader { geometry in
                    ForEach([
                        (1.0, maxWorkouts),
                        (0.75, maxWorkouts * 3 / 4),
                        (0.5, maxWorkouts / 2),
                        (0.25, maxWorkouts / 4),
                        (0.0, 0)
                    ], id: \.0) { position, value in
                        Text("\(value)")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                            .position(x: geometry.size.width / 2, y: geometry.size.height * (1 - position))
                    }
                }
            }
            .frame(width: 30, height: chartHeight)
        }
    }

    var rightAxisLabels: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: 50)
            ZStack(alignment: .leading) {
                GeometryReader { geometry in
                    ForEach([
                        (1.0, maxMinutes),
                        (0.75, maxMinutes * 3 / 4),
                        (0.5, maxMinutes / 2),
                        (0.25, maxMinutes / 4),
                        (0.0, 0)
                    ], id: \.0) { position, value in
                        Text("\(value)")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                            .position(x: geometry.size.width / 2, y: geometry.size.height * (1 - position))
                    }
                }
            }
            .frame(width: 30, height: chartHeight)
        }
    }

    func tooltipView(value: Int, label: String, color: Color) -> some View {
        VStack(spacing: 0) {
            VStack(spacing: 2) {
                Text("\(value)")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(color)
                Text(label)
                    .font(.system(size: 10, weight: .regular))
                    .foregroundColor(color)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(backgroundColor)
            .cornerRadius(6)
            .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 1)

            Triangle()
                .fill(backgroundColor)
                .frame(width: 12, height: 6)
                .shadow(color: Color.black.opacity(0.1), radius: 1, x: 0, y: 1)
                .offset(y: -1)
        }
        .fixedSize()
    }

    struct Triangle: Shape {
        func path(in rect: CGRect) -> Path {
            var path = Path()
            path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
            path.closeSubpath()
            return path
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center) {
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)

                Spacer()

                Text(balanceText)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(balanceColor)
            }

            VStack(spacing: 0) {
                HStack(alignment: .bottom, spacing: 0) {
                    leftAxisLabels
                    chartWithGridlines
                    rightAxisLabels
                }

                HStack(spacing: 0) {
                    Spacer().frame(width: 30)
                    dayLabels
                    Spacer().frame(width: 30)
                }
            }

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
            .padding(.top, 8)
        }
        .padding(16)
        .background(
            backgroundColor
                .onTapGesture {
                    tappedBar = nil
                }
        )
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
    }

    private func barHeight(workouts: Int) -> CGFloat {
        guard maxWorkouts > 0 else { return 0 }
        let height = (CGFloat(workouts) / CGFloat(maxWorkouts)) * chartHeight
        return height.rounded(.toNearestOrAwayFromZero)
    }

    private func barHeight(minutes: Int) -> CGFloat {
        guard maxMinutes > 0 else { return 0 }
        let height = (CGFloat(minutes) / CGFloat(maxMinutes)) * chartHeight
        return height.rounded(.toNearestOrAwayFromZero)
    }
}
