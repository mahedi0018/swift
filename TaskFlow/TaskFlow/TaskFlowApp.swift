//
//  TaskFlowApp.swift
//  TaskFlow
//
//  Created by Md. Mahedi Hasan on 8/8/26.
//

import SwiftUI
import FirebaseCore



@main
struct TaskFlowApp: App {
    
    @State private var settings = AppSettings.shared
    
    init() {
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        
    }
    var body: some Scene {
        WindowGroup {
            RootView()
                .preferredColorScheme(settings.themeMode.colorScheme)
        }
    }
}
