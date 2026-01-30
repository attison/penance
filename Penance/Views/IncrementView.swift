import SwiftUI
import FamilyControls

struct IncrementView: View {
    @EnvironmentObject var counterManager: CounterManager
    @EnvironmentObject var screenTimeMonitor: ScreenTimeMonitor
    @State private var showPulse = false
    @State private var isPickerPresented = false

    var body: some View {
        ZStack {
            // Full page tappable area
            backgroundColor
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
                .onTapGesture {
                    addWorkouts()
                }
                .animation(.easeInOut(duration: 0.5), value: counterManager.balanceMinutes)

            VStack(spacing: 40) {
                Spacer()

                // Balance display
                VStack(spacing: 8) {
                    if counterManager.balanceMinutes == 0 {
                        Text(balanceText)
                            .font(.system(size: 24, weight: .medium, design: .rounded))
                            .foregroundColor(textColor)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                            .scaleEffect(showPulse ? 1.1 : 1.0)
                    } else {
                        Text(balanceText)
                            .font(.system(size: 80, weight: .bold, design: .rounded))
                            .foregroundColor(textColor)
                            .scaleEffect(showPulse ? 1.1 : 1.0)

                        Text(balanceLabel)
                            .font(.system(size: 24, weight: .medium, design: .rounded))
                            .foregroundColor(textColor.opacity(0.7))
                    }
                }
                .allowsHitTesting(false)

                // Instruction text
                Text("Tap to add \(counterManager.workoutsPerMinute) \(counterManager.workoutType)")
                    .font(.system(size: 18, weight: .regular, design: .rounded))
                    .foregroundColor(textColor.opacity(0.5))
                    .allowsHitTesting(false)

                Spacer()

                // Setup button - only show if setup not completed
                if !screenTimeMonitor.hasCompletedSetup {
                    Button(action: {
                        if screenTimeMonitor.isAuthorized {
                            isPickerPresented = true
                        } else {
                            screenTimeMonitor.requestAuthorization()
                        }
                    }) {
                        Text(screenTimeMonitor.isAuthorized ? "Choose Which Apps to Pay Penance For" : "Enable Screen Time Tracking")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.blue)
                    }
                    .padding(.bottom, 16)
                }

                // Scroll hint
                VStack(spacing: 3) {
                    Text("Scroll to see history")
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(textColor.opacity(0.5))
                    Text("˅")
                        .font(.system(size: 24, weight: .regular, design: .rounded))
                        .foregroundColor(textColor.opacity(0.5))
                }
                .allowsHitTesting(false)
                .padding(.bottom, 60)
            }
        }
        .familyActivityPicker(
            isPresented: $isPickerPresented,
            selection: $screenTimeMonitor.selectedApps
        )
        .onChange(of: screenTimeMonitor.selectedApps) { _, newSelection in
            if !newSelection.applicationTokens.isEmpty {
                screenTimeMonitor.startMonitoring()
            }
        }
    }

    private var backgroundColor: Color {
        let balance = counterManager.balanceMinutes
        if balance == 0 {
            // Light gray
            return Color(red: 0.95, green: 0.95, blue: 0.95)
        } else if balance > 0 {
            // Light sage/mint green
            return Color(red: 0.9, green: 0.97, blue: 0.93)
        } else {
            // Light coral/salmon
            return Color(red: 1.0, green: 0.93, blue: 0.93)
        }
    }

    private var textColor: Color {
        let balance = counterManager.balanceMinutes
        if balance == 0 {
            // Dark gray
            return Color(red: 0.4, green: 0.4, blue: 0.4)
        } else if balance > 0 {
            // Dark green
            return Color(red: 0.2, green: 0.5, blue: 0.3)
        } else {
            // Dark red
            return Color(red: 0.7, green: 0.2, blue: 0.2)
        }
    }

    private var balanceText: String {
        let minutes = counterManager.balanceMinutes
        if minutes == 0 {
            return "You have reached a state of perfect equilibrium"
        } else if minutes > 0 {
            return "+\(minutes)"
        } else {
            let workoutsOwed = abs(minutes) * counterManager.workoutsPerMinute
            return "-\(workoutsOwed)"
        }
    }

    private var balanceLabel: String {
        let balance = counterManager.balanceMinutes
        if balance > 0 {
            return balance == 1 ? "minute" : "minutes"
        } else {
            return counterManager.workoutType
        }
    }

    private func addWorkouts() {
        counterManager.addWorkouts(counterManager.workoutsPerMinute)

        // Pulse animation
        withAnimation(.easeInOut(duration: 0.2)) {
            showPulse = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.easeInOut(duration: 0.2)) {
                showPulse = false
            }
        }

        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
}
