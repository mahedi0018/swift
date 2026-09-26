//
//  SettingsViewModel.swift
//  TaskFlow
//
//  Created by Md. Mahedi Hasan on 5/9/26.
//

import Foundation
import FirebaseAuth
@Observable
class SettingsViewModel {
    // MARK: - Password change state
    var isChangingPassword: Bool = false
    var passwordError: String?
    var passwordSuccess = false
    
    // MARK: - Delete account state
    var isDeleting = false
    var deleteError: String?
    
    // MARK: - Export state
    var isExporting = false
    var exportError: String?
    var exportedFileURL: URL?
    
    private let authManager = AuthManager.shared
    private let realmManager = RealmManager.shared
    
    @MainActor
    func updatePassword(current: String, new: String, confirm: String) async {
        passwordError = nil
        passwordSuccess = false
        
        guard new == confirm else {
            passwordError = "New passwords don't match"
            return
        }
        guard new.count >= 6 else {
            passwordError = "Password must be at least 6 characters"
            return
        }
        
        isChangingPassword = true
        defer { isChangingPassword = false }
        
        do {
            try await authManager.updatePassword(currentPassword: current, newPassword: new)
            passwordSuccess = true
        } catch {
            passwordError = error.localizedDescription
        }
    }
    
    @MainActor
    func exportData() async {
        exportError = nil
        isExporting = true
        defer { isExporting = false }
        
        do {
            let tasks = Array(realmManager.getAllTasks())
            let habits = Array(realmManager.getAllHabits())
            
            let taskPayload = tasks.map { task -> [String: Any] in
                [
                    "title": task.title,
                    "category": task.category,
                    "priority": task.priority,
                    "isCompleted": task.isCompleted
                ]
            }
            let habitPayload = habits.map { habit -> [String: Any] in
                [
                    "title": habit.title,
                    "currentStreak": habit.currentStreak,
                    "longestStreak": habit.longestStreak,
                    "goal": habit.goal
                ]
            }
            
            let payload: [String: Any] = [
                "exportedAt": ISO8601DateFormatter().string(from: Date()),
                "email": AuthManager.shared.currentUser?.email ?? "",
                "tasks": taskPayload,
                "habits": habitPayload
            ]
            
            let data = try JSONSerialization.data(withJSONObject: payload, options: .prettyPrinted)
            let tempURL = FileManager.default.temporaryDirectory
                .appendingPathComponent("taskflow_export_\(Int(Date().timeIntervalSince1970)).json")
            try data.write(to: tempURL)
            exportedFileURL = tempURL
        } catch {
            exportError = "Export failed: \(error.localizedDescription)"
        }
    }
    
    @MainActor
    func deleteAccount(password: String) async {
        deleteError = nil
        isDeleting = true
        defer { isDeleting = false }
        
        do {
            try await authManager.deleteAccount(password: password)
        } catch {
            deleteError = error.localizedDescription
        }
    }
}
