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
    
    
    
    init() {
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        
    }
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
