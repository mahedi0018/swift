//
//  Environment+Extension.swift
//  TaskFlow
//
//  Created by Md. Mahedi Hasan on 15/8/26.
//

import SwiftUI

// Custom Environment key create

private struct TopSafeAreaKey: EnvironmentKey {
    static let defaultValue: CGFloat = 0
}

extension EnvironmentValues {
    var topSafeArea: CGFloat {
        get { self[TopSafeAreaKey.self] }
        set { self[TopSafeAreaKey.self] = newValue }
    }
}

// MARK: - TabBarHeight Magerment
/// CustomTabBarView → (Preference দিয়ে উপরে) → MainTabView → (Environment দিয়ে নিচে) → HomeView

// PreferenceKey: CustomTabBarView থেকে height উপরে (MainTabView এ) পাঠানোর জন্য
struct TabBarHeightKey: PreferenceKey {
    static var defaultValue: CGFloat { 0 }
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
// Parent থেকে height নিচে পাঠানো সব screen এ. Like MainView -> HomeView
private struct TabBarHeightEnvironmentKey: EnvironmentKey {
    static let defaultValue: CGFloat = 0
}

extension EnvironmentValues {
    var tabBarHeight: CGFloat {
        get { self[TabBarHeightEnvironmentKey.self] }
        set { self[TabBarHeightEnvironmentKey.self] = newValue }
    }
}



