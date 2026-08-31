//
//  Tab.swift
//  TaskFlow
//
//  Created by Md. Mahedi Hasan on 15/8/26.
//

import SwiftUI

enum Tab: String, CaseIterable {
    case home = "Home"
    case habits = "Habits"
    case analytics = "Analytics"
    case settings = "Settings"
    
    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .habits: return "clock.fill"
        case .analytics: return "chart.bar.fill"
        case .settings: return "gearshape.fill"
        }
    }
}
