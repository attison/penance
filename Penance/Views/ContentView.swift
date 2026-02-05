import SwiftUI

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var scrollViewID = UUID()

    var body: some View {
        GeometryReader { geometry in
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    IncrementView()
                        .frame(width: geometry.size.width, height: geometry.size.height)

                    HistoryView()
                        .frame(width: geometry.size.width, height: geometry.size.height)

                    SettingsView()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.paging)
            .id(scrollViewID)
        }
        .ignoresSafeArea()
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .inactive && oldPhase == .active {
                scrollViewID = UUID()
            }
        }
    }
}
