//
//  PrivacyPolicyView.swift
//  TaskFlow
//
//  Created by Md. Mahedi Hasan on 7/9/26.
//


import SwiftUI

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Privacy Policy")
                        .font(.title2.bold())
                    Text("Last updated: September 2026")
                        .font(.caption)
                        .foregroundStyle(Color.textSecondary)
                }
                
                policySection(
                    icon: "internaldrive.fill",
                    title: "Your Data Stays on Your Device",
                    body: "TaskFlow stores your tasks, habits, streaks, and completion history locally on your device using Realm. We do not upload, sync, or share this data with any third-party server or advertiser."
                )
                
                policySection(
                    icon: "person.badge.key.fill",
                    title: "Account & Authentication",
                    body: "We use Firebase Authentication solely to identify your account through your email and a unique user ID. Your password is handled entirely by Firebase's secure infrastructure — TaskFlow never sees or stores it directly."
                )
                
                policySection(
                    icon: "bell.badge.fill",
                    title: "Notifications",
                    body: "Daily reminders, habit alerts, and weekly report notifications are all scheduled and generated directly on your device using Apple's local notification system. No task or habit content ever leaves your phone to create these reminders."
                )
                
                policySection(
                    icon: "square.and.arrow.up.fill",
                    title: "Exporting Your Data",
                    body: "You can export a copy of your tasks and habits as a JSON file at any time from Settings → Privacy & Security → Export My Data. This file is generated locally and only shared if you choose to share it yourself."
                )
                
                policySection(
                    icon: "trash.fill",
                    title: "Deleting Your Data",
                    body: "You can permanently delete all your tasks, habits, and history at any time. Deleting your account also removes your Firebase authentication record. These actions cannot be undone, so we ask for confirmation before proceeding."
                )
                
                policySection(
                    icon: "chart.bar.fill",
                    title: "No Analytics or Tracking",
                    body: "TaskFlow does not use third-party analytics, advertising SDKs, or behavioral tracking. Your habits and productivity data are yours alone."
                )
                
                policySection(
                    icon: "envelope.fill",
                    title: "Questions",
                    body: "If you have any questions about how your data is handled, feel free to reach out through the app's support contact."
                )
            }
            .padding(20)
        }
    }
    
    @ViewBuilder
    private func policySection(icon: String, title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundStyle(Color.accentPrimary)
                Text(title)
                    .font(.headline)
            }
            Text(body)
                .font(.subheadline)
                .foregroundStyle(Color.textSecondary)
        }
    }
}

#Preview {
    PrivacyPolicyView()
}
