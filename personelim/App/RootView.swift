//
//  RootView.swift
//  personelim
//
//  Created by Tuğberk Acabey on 15.12.2025.
//

import SwiftUI

struct RootView: View {

    @EnvironmentObject var appState: AppState

    var body: some View {
        if appState.isLoggedIn {
            MainTabView()   
        } else {
            OnboardingView()
        }
    }
}
