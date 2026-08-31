//
//  RootView.swift
//  TaskFlow
//
//  Created by Md. Mahedi Hasan on 27/8/26.
//


import SwiftUI

struct RootView: View {
    @State private var authManager = AuthManager.shared

    var body: some View {
        Group {
            if authManager.isLoggedIn {
                MainTabView()
                    .onAppear {
                        RealmManager.shared.seedDefaultHabitsIfNeeded()
                        NotificationManager.shared.checkPermissionStatus()
                    }
            } else {
                LoginView()
            }
        }
        .animation(.easeInOut, value: authManager.isLoggedIn)
    }
}

#Preview {
    RootView()
        .preferredColorScheme(.dark)
}
