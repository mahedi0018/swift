//
//  CustomTabBarView.swift
//  TaskFlow
//
//  Created by Md. Mahedi Hasan on 15/8/26.
//

import SwiftUI

struct CustomTabBarView: View {
    @Binding var selectedTab: Tab
    @Namespace private var animationNamespace   // 💡 matchedGeometryEffect-এর জন্য ইউনিক আইডি স্পেস
    var body: some View {
        HStack(spacing: 0) {
            ForEach(Tab.allCases, id: \.self) { tab in
                let isActive = selectedTab == tab
                
                Button{
                    withAnimation(.spring(response: 0.38, dampingFraction: 0.72, blendDuration: 0)) {
                        selectedTab = tab
                    }
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 18, weight: .semibold))
                            .scaleEffect(isActive ? 1.5 : 1.0)
                        
                        Text(tab.rawValue)
                            .font(.system(size: 11, weight: isActive ? .bold : .medium))
                        
                    }
                    .foregroundStyle(isActive ? Color.accentSecondary : Color.secondary.opacity(0.7))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        ZStack {
                            // Dynamic Sliding Glass Pill Background
                            if isActive {
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .fill(Color.accentPrimary.opacity(0.22))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                                            .stroke(Color.accentSecondary.opacity(0.35), lineWidth: 1)
                                    )
                                    .matchedGeometryEffect(id: "activeTabIndicator", in: animationNamespace)
                            }
                        }
                    )
                    
                }
                .buttonStyle(.plain)
                
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .glassCardStyle(cornerRadius: 20, paddingAmount: 0)
        .padding(.horizontal, 16)
    }
}

#Preview {
    CustomTabBarView(selectedTab: .constant(.home))
}
