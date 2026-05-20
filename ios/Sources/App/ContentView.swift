import SwiftUI

struct ContentView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        @Bindable var state = appState
        TabView(selection: $state.selectedTab) {
            ActivitiesView()
                .tabItem {
                    Label("Activities", systemImage: "list.clipboard")
                }
                .tag(0)
            AddNewView()
                .tabItem {
                    Label("Add New", systemImage: "plus.circle.fill")
                }
                .tag(1)
            MyCVView()
                .tabItem {
                    Label("My CV", systemImage: "doc.richtext")
                }
                .tag(2)
        }
        .tint(.brandPrimary)
    }
}
