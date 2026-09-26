//
//  HeaderView.swift
//  TaskFlow
//
//  Created by Md. Mahedi Hasan on 25/8/26.
//

import SwiftUI

struct HeaderView: View {
    @Environment(\.topSafeArea) var topSafeArea
    
    @State private var authManager = AuthManager.shared
    
    var gretting: String? = nil
    var titile : String
    var subtitle : String? = nil
    var userInitial : String = "User"
    var showStatusDot : Bool = true
    var hasNotification : Bool = false
    var onNotificationTap : (() -> Void)? = nil
    
    var body: some View {
        HStack(spacing: 12) {
            // MARK: - Avatar Icon
            ZStack(alignment: .bottomTrailing) {
                Circle()
                    .fill(Color.accentSecondary)
                    .frame(width: 64, height: 64)
                    .overlay(
                        Text(authManager.initials)
                            .font(.title2)
                            .foregroundColor(.white)
                            .bold()
                            .padding(5)
                    )
                if showStatusDot {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 15, height: 15)
                        .overlay(
                            Circle()
                                .stroke(Color.black, lineWidth: 2)
                        )
                        .offset(x: -2, y: -1)
                }
            }
            
            // MARK: - Dynamic Titles Stack
            VStack(alignment: .leading, spacing: 2) {
                if let gretting = gretting, !gretting.isEmpty {
                    Text(gretting)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Text(titile)
                    .font(.title3.bold())
                    .foregroundStyle(.primary)
                if let subtitle = subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            // MARK: - Notification Bell
            Button(action: {
                onNotificationTap?()
            }) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "bell.fill")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.primary.opacity(0.8))
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(.ultraThinMaterial)
                        )
                    if hasNotification {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 10, height: 10)
                            .offset(x: -15, y: 12)
                    }
                    
                }
            }
            .buttonStyle(.plain)
        }
//        .padding(.horizontal, 16)
        .padding(.top, topSafeArea > 0 ? topSafeArea : 10)
    }
}

#Preview {
    HeaderView(gretting: "Good Morning", titile: "Arjun Kumar", subtitle: "Software Engineer", hasNotification: true)
}
