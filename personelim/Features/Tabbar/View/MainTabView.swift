//
//  MainTabView.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 2.12.2025.
//

import SwiftUI

struct MainTabView: View {
    
   // let role: UserRole  // Auth ile gelen rol
    
    @State private var selected = 0
    
    var body: some View {
        TabView(selection: $selected) {
            
            HomeView()
                .tabItem {
                    Label("Ana Sayfa", systemImage: "house.circle.fill")
                }
                .tag(0)
            
            TasksView()
                .tabItem {
                    Label("Görevler", systemImage: "tray.circle.fill")
                }
                .tag(1)
            
            ProfileView()
                .tabItem {
                    Label("Profil", systemImage: "person.crop.circle.fill")
                }
                .tag(2)
            
           // if role == .manager {
          //      PersonnelView()
                    .tabItem {
                        Label("Personel", systemImage: "person.3.fill")
                    }
                    .tag(3)
            }
       // }
        .onAppear { selected = 0 }
    }
}
