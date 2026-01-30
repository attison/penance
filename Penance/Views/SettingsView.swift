import SwiftUI
import FamilyControls

struct SettingsView: View {
    @EnvironmentObject var screenTimeMonitor: ScreenTimeMonitor
    @State private var workoutType: String = PersistenceService.shared.workoutType
    @State private var workoutsPerMinute: String = String(PersistenceService.shared.workoutsPerMinute)
    @State private var isPickerPresented = false
    @Environment(\.colorScheme) var colorScheme


    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground)
                .ignoresSafeArea()

            GeometryReader { geometry in
                ScrollView(.vertical, showsIndicators: true) {
                    VStack(spacing: 16) {
                        // Header
                        Text("Settings")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        .padding(.top, 60)
                        .padding(.bottom, 0)

                    // Workout Type Setting
                    VStack(alignment: .leading, spacing: 12) {
                        Text("What workout do you want to pay penance with?")
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundColor(.primary)

                        TextField("Pushups", text: $workoutType)
                            .padding(12)
                            .background(colorScheme == .dark ? Color(red: 0.22, green: 0.22, blue: 0.24) : Color(red: 0.98, green: 0.97, blue: 0.95))
                            .cornerRadius(10)
                            .shadow(color: Color.black.opacity(0.06), radius: 2, x: 0, y: 1)
                            .onChange(of: workoutType) { _, newValue in
                                let capitalizedValue = newValue.capitalized
                                PersistenceService.shared.workoutType = capitalizedValue
                                if workoutType != capitalizedValue {
                                    workoutType = capitalizedValue
                                }
                                CounterManager.shared.reloadData()
                            }
                    }
                    .padding(16)
                    .background(colorScheme == .dark ? Color(red: 0.18, green: 0.18, blue: 0.20) : Color(red: 0.98, green: 0.97, blue: 0.95))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)

                    // Workouts Per Minute Setting
                    VStack(alignment: .leading, spacing: 12) {
                        Text("How many \(workoutType.lowercased()) will pay penance for 1 minute of screen time?")
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundColor(.primary)

                        TextField("5", text: $workoutsPerMinute)
                            .padding(12)
                            .background(colorScheme == .dark ? Color(red: 0.22, green: 0.22, blue: 0.24) : Color(red: 0.98, green: 0.97, blue: 0.95))
                            .cornerRadius(10)
                            .shadow(color: Color.black.opacity(0.06), radius: 2, x: 0, y: 1)
                            .keyboardType(.numberPad)
                            .onChange(of: workoutsPerMinute) { _, newValue in
                                if let number = Int(newValue), number > 0 {
                                    PersistenceService.shared.workoutsPerMinute = number
                                    CounterManager.shared.reloadData()
                                }
                            }
                    }
                    .padding(16)
                    .background(colorScheme == .dark ? Color(red: 0.18, green: 0.18, blue: 0.20) : Color(red: 0.98, green: 0.97, blue: 0.95))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)

                    // Change Apps button - only show if setup is completed
                    if screenTimeMonitor.hasCompletedSetup {
                        Button(action: {
                            isPickerPresented = true
                        }) {
                            Text("Change Which Apps to Pay Penance For")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(.blue)
                        }
                        .padding(.top, 8)
                    }

                    Spacer()

                    // What is Penance section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("What is Penance?")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(.primary)

                        Text("Penance was made to encourage you to atone for your social media sins. I was spending too much time on social media and needed a way to remind myself to unwind and stop scrolling.")
                            .font(.system(size: 11, weight: .regular, design: .rounded))
                            .foregroundColor(.secondary)
                            .lineSpacing(3)
                        Text("For every minute you spend on social media, you owe a quick set of pushups or squats etc. Keep track of your balance, build up a bank of social media minutes for a rainy day, or build yourself into a deficit and climb back out again. Just make sure that in the end you bring yourself back to neutral.")
                            .font(.system(size: 11, weight: .regular, design: .rounded))
                            .foregroundColor(.secondary)
                            .lineSpacing(3)
                        
                        Text("Add the widget to your lock screen to see your real-time balance and if you enable notifications you can get pinged whenever your balance hits 0 (time to close the app!)")
                            .font(.system(size: 11, weight: .regular, design: .rounded))
                            .foregroundColor(.secondary)
                            .lineSpacing(3)
                        
                        Text("If you're going to waste your minutes at least earn them.")
                            .font(.system(size: 11, weight: .regular, design: .rounded))
                            .foregroundColor(.secondary)
                            .lineSpacing(3)
                        
                        Text("Attison")
                            .font(.system(size: 11, weight: .regular, design: .rounded))
                            .foregroundColor(.secondary)
                            .padding(.top, 4)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 60)
                    }
                    .frame(minHeight: geometry.size.height)
                }
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
        .simultaneousGesture(
            TapGesture().onEnded {
                hideKeyboard()
            }
        )
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
