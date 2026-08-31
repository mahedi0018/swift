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
              // Preview Canvas এ চলছে — in-memory, isolated Realm ব্যবহার করো
              config = Realm.Configuration(inMemoryIdentifier: "PreviewRealm")
          } else {
              // আসল app/Simulator/Device — normal disk-based Realm
              config = Realm.Configuration(
                  schemaVersion: 2,
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
        let existingLog = realm.objects(HabitCompletionLog.self)
            .filter("habitId == %@", habitId)
            .first{ calendar.isDate($0.date, inSameDayAs: date) }
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
    
    func deleteCompletionLogs(habitId: UUID) {
        let logsToDelete = realm.objects(HabitCompletionLog.self).filter("habitId == %@", habitId)
        try! realm.write{
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
}
