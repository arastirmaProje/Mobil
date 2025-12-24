import SwiftUI

struct MainTabView: View {

    enum Tab: Hashable { case home, tasks, personnel, profile }

    @EnvironmentObject private var appState: AppState
    @State private var selected: Tab = .home

    var body: some View {
        TabView(selection: $selected) {

            NavigationStack { HomeView() }
                .tabItem { Label("Ana Sayfa", systemImage: "house.circle.fill") }
                .tag(Tab.home)

            NavigationStack { TasksListView() }
                .tabItem { Label("Görevler", systemImage: "tray.circle.fill") }
                .tag(Tab.tasks)

            if appState.role.canSeePersonnelTab {
                NavigationStack { PersonnelView() }
                    .tabItem { Label("Personel", systemImage: "person.3.fill") }
                    .tag(Tab.personnel)
            }

            NavigationStack { ProfileView() }
                .tabItem { Label("Profil", systemImage: "person.crop.circle.fill") }
                .tag(Tab.profile)
        }
    }
}
