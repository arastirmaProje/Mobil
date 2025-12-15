//
//  personelimApp.swift
//  personelim
//
//  Created by Tuğberk Acabey on 22.11.2025.
//

import SwiftUI

@main
struct personelimApp: App {

    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
        }
    }
}
