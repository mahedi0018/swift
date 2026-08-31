//
//  SettingsView.swift
//  TaskFlow
//
//  Created by Md. Mahedi Hasan on 15/8/26.
//

import SwiftUI
import FirebaseAuth

struct SettingsView: View {
    @State private var settings = AppSettings.shared
    @State private var showSignOutAlert = false
    @State private var showColorPicker = false
    @Environment(\.tabBarHeight) private var tabBarHeight
    
    @State private var authManager = AuthManager.shared
    
    @State private var notificationManager = NotificationManager.shared
    @State private var habitViewModel = HabitListViewModel()
    
    private var initials: String {
        guard let email = authManager.currentUser?.email, let first = email.first else { return "U" }
        return String(first).uppercased()
    }
    
    let colorOptions = ["accentPrimary", "success", "info", "warning", "danger"]
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                HeaderView(
                    titile: "Settings",
                    subtitle: "Personalize your app",
                    hasNotification: true
                )
                // MARK: - Profile Card
                HStack(spacing: 14) {
                    Circle()
                        .fill(Color.accentSecondary)
                        .frame(width: 56, height: 56)
                        .overlay(
                            Text(authManager.initials)
                                .font(.headline.bold())
                                .foregroundStyle(.white)
                        )
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(authManager.displayName)
                            .font(.headline.bold())
                            .foregroundStyle(Color.textPrimary)
                        Text(authManager.currentUser?.email ?? "")
                            .font(.caption)
                            .foregroundStyle(Color.textSecondary)
                        
                        HStack(spacing: 8) {
                            Text("Pro Plan")
                                .font(.caption2.bold())
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Capsule().fill(Color.accentPrimary.opacity(0.2)))
                                .foregroundStyle(Color.accentSecondary)
                            
                            Text("🔥 6 day streak")
                                .font(.caption2.bold())
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Capsule().fill(Color.success.opacity(0.2)))
                                .foregroundStyle(Color.success)
                        }
                    }
                    Spacer()
                }
                .padding(16)
                .glassCardStyle()
                
                // MARK: - Notifications
                SettingsSectionCard(title: "Notifications") {
                    SettingsToggleRow(
                        icon: "bell.fill",
                        title: "Push Notifications",
                        subtitle: "All alerts and reminders",
                        iconColor: .yellow,
                        isOn: $settings.pushNotifications
                    )
                    .onChange(of: settings.pushNotifications) { _, newValue in
                        print("is it working?")
                        if newValue {
                            notificationManager.requestPermission()
                        } else {
                            notificationManager.cancelDailyReminder()
                            // Habit alerts ও বাতিল করা যেতে পারে এখানে, habitViewModel থেকে id গুলো এনে
                        }
                    }
                    Divider()
                    SettingsToggleRow(
                        icon: "alarm.fill",
                        title: "Daily Reminder",
                        subtitle: "9:00 AM every morning",
                        iconColor: .red,
                        isOn: $settings.dailyReminder
                    )
                    .onChange(of: settings.dailyReminder) { _, newValue in
                        if newValue {
                            notificationManager.scheduleDailyReminder(hour: 9, minute: 0)
                        } else {
                            notificationManager.cancelDailyReminder()
                        }
                    }
                    Divider()
                    SettingsToggleRow(
                        icon: "target",
                        title: "Habit Alerts",
                        subtitle: "30 min before habit time",
                        iconColor: .red,
                        isOn: $settings.habitAlerts
                    )
                    .onChange(of: settings.habitAlerts) { _, newValue in
                        if newValue {
                            habitViewModel.habits.forEach { habitViewModel.scheduleAlert(for: $0) }
                        } else {
                            let ids = habitViewModel.habits.map { $0.id.uuidString }
                            notificationManager.cancelAllHabitAlerts(habitIds: ids)
                        }
                    }
                }
                
                // MARK: - Appearance
                SettingsSectionCard(title: "Appearance") {
                    SettingsToggleRow(
                        icon: "moon.fill",
                        title: "Dark Mode",
                        subtitle: "Slate dark theme (active)",
                        iconColor: .yellow,
                        isOn: $settings.darkMode
                    )
                    Divider()
                    SettingsToggleRow(
                        icon: "iphone.radiowaves.left.and.right",
                        title: "Haptic Feedback",
                        subtitle: "Vibration on interactions",
                        iconColor: .green,
                        isOn: $settings.hapticFeedback
                    )
                    Divider()
                    Button {
                        showColorPicker = true
                    } label: {
                        HStack(spacing: 14) {
                            Image(systemName: "paintpalette.fill")
                                .font(.system(size: 18))
                                .frame(width: 40, height: 40)
                                .background(Color.bgSecondary)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Accent Color")
                                    .font(.subheadline.bold())
                                    .foregroundStyle(Color.textPrimary)
                                Text("Electric Indigo")
                                    .font(.caption)
                                    .foregroundStyle(Color.textSecondary)
                            }
                            Spacer()
                            Circle()
                                .fill(Color(settings.accentColorName))
                                .frame(width: 24, height: 24)
                        }
                    }
                    .buttonStyle(.plain)
                }
                
                // MARK: - Data & Reports
                SettingsSectionCard(title: "Data & Reports") {
                    SettingsToggleRow(
                        icon: "chart.bar.fill",
                        title: "Weekly Report",
                        subtitle: "Every Sunday evening",
                        iconColor: .blue,
                        isOn: $settings.weeklyReport
                    )
                    Divider()
                    SettingsNavRow(
                        icon: "icloud.fill",
                        title: "iCloud Sync",
                        subtitle: "Last synced 2 min ago"
                    )
                    Divider()
                    SettingsNavRow(
                        icon: "tray.and.arrow.up.fill",
                        title: "Export Data",
                        subtitle: "CSV, JSON formats"
                    )
                }
                
                // MARK: - Account
                SettingsSectionCard(title: "Account") {
                    SettingsNavRow(
                        icon: "lock.fill",
                        title: "Privacy & Security",
                        subtitle: ""
                    )
                    Divider()
                    SettingsNavRow(
                        icon: "diamond.fill",
                        title: "TaskFlow Pro",
                        subtitle: "Manage subscription"
                    )
                    Divider()
                    SettingsNavRow(
                        icon: "questionmark.circle.fill",
                        title: "Help & Support",
                        subtitle: ""
                    )
                    Divider()
                    SettingsNavRow(
                        icon: "rectangle.portrait.and.arrow.forward.fill",
                        title: "Sign Out",
                        subtitle: "",
                        isDestructive: true
                    ) {
                        showSignOutAlert = true
                    }
                }
                
                Button("Send Test Notification (5 sec)") {
                    NotificationManager.shared.scheduleTestNotification()
                }
                
                // MARK: - Footer
                Text("TaskFlow v2.4.1 · Made with ❤️ in San Francisco")
                    .font(.caption2)
                    .foregroundStyle(Color.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 8)
            }
            .padding(16)
            .padding(.bottom, tabBarHeight + 20)
        }
        .alert("Sign Out?", isPresented: $showSignOutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Sign Out", role: .destructive) {
                AuthManager.shared.signOut()
            }
        } message: {
            Text("Are you sure you want to sign out of TaskFlow?")
        }
        .sheet(isPresented: $showColorPicker) {
            AccentColorPickerView(selectedColor: $settings.accentColorName, colorOptions: colorOptions)
        }
    }
}



#Preview {
    SettingsView()
}
