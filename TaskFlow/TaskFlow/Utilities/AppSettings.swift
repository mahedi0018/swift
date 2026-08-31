//
//  AppSettings.swift
//  TaskFlow
//
//  Created by Md. Mahedi Hasan on 26/8/26.
//

import Foundation
import SwiftUI

@Observable
class AppSettings {
    static let shared = AppSettings()

    var pushNotifications: Bool {
        didSet { UserDefaults.standard.set(pushNotifications, forKey: "pushNotificationsEnabled") }
    }
    var dailyReminder: Bool {
        didSet { UserDefaults.standard.set(dailyReminder, forKey: "dailyReminderEnabled") }
    }
    var habitAlerts: Bool {
        didSet { UserDefaults.standard.set(habitAlerts, forKey: "habitAlertsEnabled") }
    }
    var darkMode: Bool {
        didSet { UserDefaults.standard.set(darkMode, forKey: "darkModeEnabled") }
    }
    var hapticFeedback: Bool {
        didSet { UserDefaults.standard.set(hapticFeedback, forKey: "hapticFeedbackEnabled") }
    }
    var weeklyReport: Bool {
        didSet { UserDefaults.standard.set(weeklyReport, forKey: "weeklyReportEnabled") }
    }
    var accentColorName: String {
        didSet { UserDefaults.standard.set(accentColorName, forKey: "accentColorName") }
    }

    private init() {
        let defaults = UserDefaults.standard
        pushNotifications = defaults.object(forKey: "pushNotificationsEnabled") as? Bool ?? true
        dailyReminder = defaults.object(forKey: "dailyReminderEnabled") as? Bool ?? true
        habitAlerts = defaults.object(forKey: "habitAlertsEnabled") as? Bool ?? false
        darkMode = defaults.object(forKey: "darkModeEnabled") as? Bool ?? true
        hapticFeedback = defaults.object(forKey: "hapticFeedbackEnabled") as? Bool ?? true
        weeklyReport = defaults.object(forKey: "weeklyReportEnabled") as? Bool ?? true
        accentColorName = defaults.string(forKey: "accentColorName") ?? "accentPrimary"
    }
}
