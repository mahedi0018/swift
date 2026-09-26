//
//  Habit.swift
//  TaskFlow
//
//  Created by Md. Mahedi Hasan on 8/8/26.
//

import Foundation
import RealmSwift

class Habit: Object, Identifiable {
    @Persisted(primaryKey: true) var id: UUID = UUID()
    @Persisted var title: String = ""
    @Persisted var iconName: String = ""
    @Persisted var currentStreak: Int = 0
    @Persisted var longestStreak: Int = 0
    @Persisted var freezeTokens: Int = 2    // Kotobar freeze use kora jabe
    @Persisted var goal: Int = 0
    @Persisted var weeklyCompletion: List<Bool>
    @Persisted var colorName: String = "accentPrimary"
    @Persisted var createdAt: Date = Date()
    @Persisted var userId: String = ""
    @Persisted var reminderTime: Date = Date() 
}


enum HabitIcon: String, CaseIterable, Identifiable {
    case meditation = "figure.mind.and.body"
    case reading = "book.fill"
    case water = "drop.fill"
    case running = "figure.run"
    case sleep = "moon.zzz.fill"
    case journaling = "pencil.and.scribble"
    case diet = "leaf.fill"
    case workout = "flame.fill"
    case selfCare = "heart.fill"
    case makeBed = "bed.double.fill"
    case gym = "dumbbell.fill"
    case coffeeBreak = "cup.and.saucer.fill"
    case focus = "brain.head.profile"
    case sunshine = "sun.max.fill"
    case walking = "figure.walk"
    case music = "music.note"
    case quitBadHabit = "xmark.shield.fill"
    
    var id: String { rawValue }
    
    // 💡 প্রতিটি আইকনের ডিফল্ট টাইটেল
    var defaultTitle: String {
        switch self {
        case .meditation: return "Meditation"
        case .reading: return "Reading"
        case .water: return "Drink Water"
        case .running: return "Running"
        case .sleep: return "Sleep Early"
        case .journaling: return "Journaling"
        case .diet: return "Healthy Diet"
        case .workout: return "Workout"
        case .selfCare: return "Self Care"
        case .makeBed: return "Make Bed"
        case .gym: return "Gym"
        case .coffeeBreak: return "Coffee Break"
        case .focus: return "Focus / Study"
        case .sunshine: return "Morning Sunshine"
        case .walking: return "Walking"
        case .music: return "Practice Music"
        case .quitBadHabit: return "Quit Bad Habit"
        }
    }
}
