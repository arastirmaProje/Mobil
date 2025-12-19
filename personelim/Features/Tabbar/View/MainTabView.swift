//
//  MainTabView.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 2.12.2025.
//

import SwiftUI

struct MainTabView: View {

    enum Tab: Hashable { case home, tasks, personnel, profile }

    @EnvironmentObject private var appState: AppState
    @State private var selected: Tab = .home

    private let network = NetworkManager()
    private var authRepo: AuthRepositoryProtocol { AuthRepositoryImpl(network: network) }
    private var memberRepo: BusinessMemberRepositoryProtocol { BusinessMemberRepositoryImpl(network: network) }

    var body: some View {
        TabView(selection: $selected) {

            NavigationStack { HomeView().navigationTitle("Ana Sayfa") }
                .tabItem { Label("Ana Sayfa", systemImage: "house.circle.fill") }
                .tag(Tab.home)

            NavigationStack { TasksView().navigationTitle("Görevler") }
                .tabItem { Label("Görevler", systemImage: "tray.circle.fill") }
                .tag(Tab.tasks)

            if appState.role.canSeePersonnelTab {
                NavigationStack { PersonnelView().navigationTitle("Personel") }
                    .tabItem { Label("Personel", systemImage: "person.3.fill") }
                    .tag(Tab.personnel)
            }

            NavigationStack { ProfileView().navigationTitle("Profil") }
                .tabItem { Label("Profil", systemImage: "person.crop.circle.fill") }
                .tag(Tab.profile)
        }
        .task {
            await appState.loadRoleIfNeeded(
                authRepository: authRepo,
                businessMemberRepository: memberRepo
            )
        }
        .onChange(of: appState.businessId) { _, _ in
            Task {
                await appState.loadRoleIfNeeded(
                    authRepository: authRepo,
                    businessMemberRepository: memberRepo
                )
            }
        }

    }
}
