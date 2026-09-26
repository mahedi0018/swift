//
//  RealmManager.swift
//  TaskFlow
//
//  Created by Md. Mahedi Hasan on 8/8/26.
//

import Foundation
import RealmSwift
import Realm
import FirebaseAuth

class RealmManager {
    static let shared = RealmManager()
    private var realm: Realm
    
    private init() {
        var config: Realm.Configuration
        
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            // Preview Canvas a colche — in-memory, isolated Realm use kora hoyeche
            config = Realm.Configuration(inMemoryIdentifier: "PreviewRealm")
        } else {
            // For real app/Simulator/Device — normal disk-based Realm
            config = Realm.Configuration(
                schemaVersion: 3,
                migrationBlock: { migration, oldSchemaVersion in },
                deleteRealmIfMigrationNeeded: true
            )
        }
        
        Realm.Configuration.defaultConfiguration = config
        realm = try! Realm()
        print("Realm file location: \(realm.configuration.fileURL?.absoluteString ?? "Unknown")")
    }
    
    func seedDefaultHabitsIfNeeded() {
        guard let uid = AuthManager.shared.currentUser?.uid else { return }
        
        let existingHabits = getAllHabits()
        guard existingHabits.isEmpty else { return }
        
        let habits = MockData.makeHabits()
        for habit in habits {
            habit.userId = uid
            add(habit)
        }
        
        // running week log
        let currentWeekLogs = MockData.makeCurrentWeekLogs(for: habits)
        for log in currentWeekLogs {
            log.userId = uid
            add(log)
        }
        
        // past 6 month's demo log (7-Month Trend chart ar jonno)
        let historicalLogs = MockData.makeHistoricalDemoLogs(for: habits)
        for log in historicalLogs {
            log.userId = uid
            add(log)
        }
        
        print("✅ Seeded \(habits.count) habits, \(currentWeekLogs.count) current-week logs, \(historicalLogs.count) historical logs")
    }
    
    // CREATE
    func add<T: Object>(_ object: T) {
        try! realm.write {
            realm.add(object)
        }
    }
    
    // READ
    func getAll<T : Object>(_ type: T.Type) -> Results<T> {
        return realm.objects(type)
    }
    
    // UPDATE / DELETE (closure diye flexible rakha holo)
    func update(_ block: () -> Void){
        try! realm.write{
            block()
        }
    }
    
    func delete<T: Object>(_ object: T) {
        try! realm.write {
            realm.delete(object)
        }
    }
    
    // MARK: - Habit Completion Logging
    func logHabitCompletion(habitId: UUID, date: Date, isCompleted: Bool) {
        guard let uid = AuthManager.shared.currentUser?.uid else { return }
        // oi diner jonno age theke kono log ache ki na ta khuje ber kora
        let calendar = Calendar.current
        
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else { return }
        
        let existingLog = realm.objects(HabitCompletionLog.self)
            .filter("habitId == %@ AND date >= %@ AND date < %@", habitId, startOfDay, endOfDay)
            .first
        try! realm.write{
            if let existingLog {
                existingLog.isCompleted = isCompleted
            } else {
                let log = HabitCompletionLog()
                log.habitId = habitId
                log.date = date
                log.isCompleted = isCompleted
                log.userId = uid
                realm.add(log)
            }
        }
    }
    
    func getCompletionLogs(habitId: UUID) -> Results<HabitCompletionLog> {
        realm.objects(HabitCompletionLog.self).filter("habitId == %@", habitId)
    }
    
    func deleteAllLogs(forHabitId habitId: UUID) {
        let logsToDelete = realm.objects(HabitCompletionLog.self).filter("habitId == %@", habitId)
        try! realm.write {
            realm.delete(logsToDelete)
        }
    }
    
    // MARK: - Task Queries (userId filtered)
    func getAllTasks() -> Results<Task> {
        guard let uid = AuthManager.shared.currentUser?.uid else {
            return realm.objects(Task.self).filter("userId == 'NO_USER'")
        }
        return realm.objects(Task.self).filter("userId == %@", uid)
    }
    
    // MARK: - Habit Queries (userId filtered)
    func getAllHabits() -> Results<Habit> {
        guard let uid = AuthManager.shared.currentUser?.uid else {
            return realm.objects(Habit.self).filter("userId == 'NO_USER'")
        }
        return realm.objects(Habit.self).filter("userId == %@", uid)
    }
    
    // MARK: - Completion Logs (userId filtered)
    func getAllCompletionLogs() -> Results<HabitCompletionLog> {
        guard let uid = AuthManager.shared.currentUser?.uid else {
            return realm.objects(HabitCompletionLog.self).filter("userId == 'NO_USER'")
        }
        return realm.objects(HabitCompletionLog.self).filter("userId == %@", uid)
    }
    
    func applyFreeze(habitId: UUID, date: Date) {
        let calendar = Calendar.current
        
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else { return }
        
        let existingLog = realm.objects(HabitCompletionLog.self)
            .filter("habitId == %@ AND date >= %@ AND date < %@", habitId, startOfDay, endOfDay)
            .first
        
        try! realm.write {
            if let existingLog {
                existingLog.isDayFrozen = true
                existingLog.isCompleted = false
            } else {
                let log = HabitCompletionLog()
                log.habitId = habitId
                log.date = date
                log.isCompleted = false
                log.isDayFrozen = true
                log.userId = AuthManager.shared.currentUser?.uid ?? ""
                realm.add(log)
            }
        }
    }
    
    func deleteAllUserData() {
        guard let uid = AuthManager.shared.currentUser?.uid else { return }
        try! realm.write {
            realm.delete(realm.objects(Task.self).filter("userId == %@", uid))
            realm.delete(realm.objects(Habit.self).filter("userId == %@", uid))
            realm.delete(realm.objects(HabitCompletionLog.self).filter("userId == %@", uid))
//            realm.delete(realm.objects(HabitFreezeLog.self).filter("userId == %@", uid))
        }
    }
}
