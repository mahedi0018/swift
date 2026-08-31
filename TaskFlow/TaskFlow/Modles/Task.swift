//
//  Task.swift
//  TaskFlow
//
//  Created by Md. Mahedi Hasan on 8/8/26.
//

import Foundation
import RealmSwift
import SwiftUI


enum TaskCategory: String, Codable, CaseIterable {
    case work = "Work"
    case health = "Health"
    case learning = "Learning"
    case personal = "Personal"
    
    var color: Color {
        switch self {
        case .work: return Color.categoryWork
        case .health: return Color.categoryHealth
        case .learning: return Color.categoryLearning
        case .personal: return Color.categoryPersonal
        }
    }
}

enum TaskPriority: String, Codable, CaseIterable {
    case high = "High"
    case med = "Medium"
    case low = "Low"
    
    var color: Color {
        switch self {
        case .high: return .red
        case .med: return .yellow
        case .low: return .green
        }
    }
    
    
}



class Task: Object, Identifiable {
    @Persisted(primaryKey: true) var id: UUID = UUID()
    @Persisted var title: String = ""
    @Persisted var isCompleted: Bool = false
    @Persisted var category: String = TaskCategory.work.rawValue       // e.g. "Work", "Health"
    @Persisted var priority: String = TaskPriority.high.rawValue       // e.g. "High", "Med", "Low"
    @Persisted var dueTime: Date = Date()
    @Persisted var createdAt: Date = Date()
    @Persisted var userId: String = ""
    
    
    // 💡 String থেকে Enum নেওয়ার জন্য Computed Property
    var priorityEnum: TaskPriority {
        TaskPriority(rawValue: priority) ?? .low
    }
    
    var categoryEnum: TaskCategory {
        TaskCategory(rawValue: category) ?? .personal
    }
}
