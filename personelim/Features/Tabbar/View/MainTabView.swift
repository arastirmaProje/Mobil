//
//  MainTabView.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 2.12.2025.
//

import SwiftUI

struct MainTabView: View {

    @State private var selected = 0

    var body: some View {
        TabView(selection: $selected) {

            NavigationStack {
                HomeView()
                    .navigationTitle("Ana Sayfa")
            }
            .tabItem {
                Label("Ana Sayfa", systemImage: "house.circle.fill")
            }
            .tag(0)

            NavigationStack {
                TasksView()
                    .navigationTitle("Görevler")
            }
            .tabItem {
                Label("Görevler", systemImage: "tray.circle.fill")
            }
            .tag(1)

            NavigationStack {
                ProfileView()
                    .navigationTitle("Profil")
            }
            .tabItem {
                Label("Profil", systemImage: "person.crop.circle.fill")
            }
            .tag(2)
        }
        .onAppear {
            selected = 0
        }
    }
}
