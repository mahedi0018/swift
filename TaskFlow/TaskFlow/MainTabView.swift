//
//  ContentView.swift
//  TaskFlow
//
//  Created by Md. Mahedi Hasan on 8/8/26.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Tab = .home
    @State private var tabBarHeight: CGFloat = 0
    var body: some View {
        GeometryReader { geometry in
            let topSafeArea = geometry.safeAreaInsets.top
            
            ZStack(alignment: .bottom) {
                Color.bgPrimary.ignoresSafeArea()
                
                
                // Screen will switch after selecting a tab
                Group {
                    switch selectedTab {
                    case .home:
                        HomeView()
                    case .habits:
                        HabitsView()
                    case .analytics:
                        AnalyticsView()
                    case .settings:
                        SettingsView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .environment(\.topSafeArea, topSafeArea)
                .environment(\.tabBarHeight, tabBarHeight)
                
                // MARK: - CustomTabBarView()
                .safeAreaInset(edge: .bottom) {
                    CustomTabBarView(selectedTab: $selectedTab)
                        .onGeometryChange(for: CGFloat.self) { geo in
                            geo.size.height
                            
                        } action: { newHeight in
                            withAnimation(.easeOut(duration: 0.2)) {
                                tabBarHeight = newHeight
                                print("MainTabView", tabBarHeight)
                            }
                            
                        }
                }
            }
            .ignoresSafeArea(edges: .top)
            .ignoresSafeArea(.keyboard)
        }
        
    }
}

#Preview {
    MainTabView()
}
