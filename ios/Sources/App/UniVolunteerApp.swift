import SwiftUI

@main
struct UniVolunteerApp: App {
    @State private var appState = AppState()
    @State private var showLaunch = true
    @State private var showOnboarding = !UserDefaults.standard.bool(forKey: "hasSeenOnboarding")

    var body: some Scene {
        WindowGroup {
            ZStack {
                if showLaunch {
                    LaunchView()
                        .transition(.opacity)
                } else if showOnboarding {
                    OnboardingView {
                        UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
                        withAnimation(.easeInOut(duration: 0.4)) {
                            showOnboarding = false
                        }
                    }
                    .transition(.opacity)
                } else if !appState.isLoggedIn {
                    LoginView()
                        .environment(appState)
                        .transition(.opacity)
                } else if appState.isSupervisor {
                    SupervisorHomeView()
                        .environment(appState)
                        .transition(.opacity)
                } else {
                    ContentView()
                        .environment(appState)
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.4), value: showLaunch)
            .animation(.easeInOut(duration: 0.4), value: showOnboarding)
            .animation(.easeInOut(duration: 0.3), value: appState.isLoggedIn)
            .animation(.easeInOut(duration: 0.3), value: appState.isSupervisor)
            .task {
                try? await Task.sleep(for: .seconds(1.2))
                withAnimation { showLaunch = false }
            }
        }
    }
}
