//
//  HabitCompletionLog.swift
//  TaskFlow
//
//  Created by Md. Mahedi Hasan on 23/8/26.
//

import Foundation
import RealmSwift

class HabitCompletionLog: Object, Identifiable {
    @Persisted(primaryKey: true) var id: UUID = UUID()
    @Persisted var habitId: UUID            // Kon habit ar sathe related 
    @Persisted var date: Date = Date()      // Thik kon dine complete hoyeche
    @Persisted var isCompleted: Bool = true
    @Persisted var userId: String = ""
}
