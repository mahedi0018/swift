//
//  NotificationManager.swift
//  TaskFlow
//
//  Created by Md. Mahedi Hasan on 29/8/26.
//

import Foundation
import UserNotifications

@Observable
class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()
    var permissionGranted: Bool  = false
    
    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
        checkPermissionStatus()
    }
    
    // MARK: - Permission Request
    func requestPermission() {
        print("Push notification is starting...")
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, error in
            print("🔔 Permission granted: \(granted)")
            if let error {
                print("🔴 Permission error: \(error.localizedDescription)")
            }
            DispatchQueue.main.async {
                self?.permissionGranted = granted
            }
        }
    }
    
    // MARK: - Check current permission status
    func checkPermissionStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            print("🔍 Current authorization status: \(settings.authorizationStatus.rawValue)")
            DispatchQueue.main.async {
                self?.permissionGranted = (settings.authorizationStatus == .authorized)
            }
        }
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }
    
    // MARK: - Schedule Daily Reminder (protidin akoi somoye repeat)
    func scheduleDailyReminder(hour: Int = 9, minute: Int = 0) {
        let content = UNMutableNotificationContent()
        content.title = "Good morning! ☀️"
        content.body = "Check your tasks and habits for today."
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "dailyReminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    func cancelDailyReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["dailyReminder"])
    }
    
    // MARK: - Schedule Habit Alert (nidisto habit-ar jonno, 10 মিনিট আগে)
    func scheduleHabitAlert(habitId: String, habitTitle: String, hour: Int, minute: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Habit Reminder 🎯"
        content.body = "\(habitTitle) is coming up in 10 minutes."
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "habitAlert_\(habitId)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func cancelHabitAlert(habitId: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["habitAlert_\(habitId)"])
    }
    
    // MARK: - Cancel All Habit Alerts (যখন Habit Alerts toggle off হয়)
    func cancelAllHabitAlerts(habitIds: [String]) {
        let identifiers = habitIds.map { "habitAlert_\($0)" }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }
    
    // just for Development/Testing
    func scheduleTestNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Test Notification 🔔"
        content.body = "If you see this, notifications are working!"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: "test", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                print("🔴 Failed to schedule: \(error.localizedDescription)")
            } else {
                print("✅ Test notification scheduled — wait 5 seconds")
            }
        }
    }
}
