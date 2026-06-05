
import SwiftUI

struct MainTabView: View {

    enum Tab: Hashable {
        case home
        case tasks
        case personnel
        case profile
        case departments
    }

    @EnvironmentObject private var appState: AppState
    @State private var selected: Tab = .home

    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        appearance.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.86)

        appearance.stackedLayoutAppearance.normal.iconColor = .systemGray
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.systemGray
        ]

        appearance.stackedLayoutAppearance.selected.iconColor = .systemBlue
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor.systemBlue
        ]

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        UITabBar.appearance().isTranslucent = true
    }

    var body: some View {
        TabView(selection: $selected) {

            NavigationStack {
                HomeView()
            }
            .tabItem {
                Image(systemName: selected == .home ? "house.fill" : "house")
                Text(ConstantStrings.tabHomeTitle)
            }
            .tag(Tab.home)

            NavigationStack {
                TasksListView()
            }
            .tabItem {
                Image(systemName: selected == .tasks ? "checklist.checked" : "checklist")
                Text(ConstantStrings.tabActivitiesTitle)
            }
            .tag(Tab.tasks)

            if appState.role.canSeePersonnelTab {
                NavigationStack {
                    PersonnelListView()
                }
                .tabItem {
                    Image(systemName: selected == .personnel ? "person.3.fill" : "person.3")
                    Text(ConstantStrings.tabPersonnelTitle)
                }
                .tag(Tab.personnel)
            }

            if appState.role.canSeePersonnelTab && appState.isSubscribed {
                NavigationStack {
                    DepartmentListView()
                }
                .tabItem {
                    Image(systemName: selected == .departments ? "building.2.fill" : "building.2")
                    Text(ConstantStrings.tabManagmentTitle)
                }
                .tag(Tab.departments)
            }

            NavigationStack {
                ProfileView()
            }
            .tabItem {
                Image(systemName: selected == .profile ? "person.crop.circle.fill" : "person.crop.circle")
                Text(ConstantStrings.tabProfileTitle)
            }
            .tag(Tab.profile)
        }
        .tint(.blue)
    }
}

