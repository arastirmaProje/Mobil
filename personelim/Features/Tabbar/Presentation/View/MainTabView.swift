import SwiftUI

struct MainTabView: View {

    enum Tab: Hashable { case home, tasks, personnel, profile, departments }

    @EnvironmentObject private var appState: AppState
    @State private var selected: Tab = .home

    var body: some View {
        TabView(selection: $selected) {

            NavigationStack { HomeView() }
                .tabItem { Label(ConstantStrings.tabHomeTitle, systemImage: "house.circle.fill") }
                .tag(Tab.home)

            NavigationStack { TasksListView() }
                .tabItem { Label(ConstantStrings.tabActivitiesTitle, systemImage: "tray.circle.fill") }
                .tag(Tab.tasks)

            if appState.role.canSeePersonnelTab {
                NavigationStack { PersonnelListView() }
                    .tabItem { Label(ConstantStrings.tabPersonnelTitle, systemImage: "person.3.fill") }
                    .tag(Tab.personnel)
            }
            
            if appState.role.canSeePersonnelTab {
                NavigationStack { DepartmentListView() }
                    .tabItem { Label(ConstantStrings.tabManagmentTitle, systemImage: "building.2.fill") }
                    .tag(Tab.departments)
            }

            NavigationStack { ProfileView() }
                .tabItem { Label(ConstantStrings.tabProfileTitle, systemImage: "person.crop.circle.fill") }
                .tag(Tab.profile)
        }
    }
}
