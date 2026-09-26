//
//  MockData.swift
//  TaskFlow
//
//  Created by Md. Mahedi Hasan on 20/8/26.
//

import Foundation
import RealmSwift

enum MockData {
    static func makeHabits() -> [Habit] {
        [
            makeHabit(title: "Morning Meditation", icon: "figure.mind.and.body", streak: 14, goal: 21, color: "accentPrimary", week: [true, true, false, true, true, true, false]),
            makeHabit(title: "Read 30 minutes", icon: "book.fill", streak: 6, goal: 30, color: "info", week: [true, true, true, true, false, true, false]),
            makeHabit(title: "Drink 8 glasses water", icon: "drop.fill", streak: 21, goal: 30, color: "success", week: [true, true, true, true, true, true, false]),
            makeHabit(title: "Evening workout", icon: "figure.run", streak: 3, goal: 14, color: "danger", week: [false, true, false, true, false, false, false]),
            makeHabit(title: "No phone after 10 PM", icon: "moon.zzz.fill", streak: 9, goal: 21, color: "warning", week: [true, false, true, true, true, true, false]),
            makeHabit(title: "Gratitude journaling", icon: "pencil.and.scribble", streak: 5, goal: 7, color: "categoryPersonal", week: [true, true, false, false, true, true, false])
        ]
    }
    
    
    // MARK: - Private Helper (Habit object bananor repetitive kaj akhane)
    private static func makeHabit(title: String, icon: String, streak: Int, goal: Int, color: String, week: [Bool]) -> Habit {
        let habit = Habit()
        habit.title = title
        habit.iconName = icon
        habit.currentStreak = streak
        habit.goal = goal
        habit.colorName = color
        for isDone in week {
            habit.weeklyCompletion.append(isDone)
        }
        return habit
    }
    
    // MARK: - Logs for current week (weeklyCompletion থেকে real date বসিয়ে)
    static func makeCurrentWeekLogs(for habits: [Habit]) -> [HabitCompletionLog] {
        let calendar = Calendar.current
        let today = Date()
        let currentWeekday = calendar.component(.weekday, from: today)
        let currentIndex = (currentWeekday + 5) % 7   // M=0...S=6
        
        var logs: [HabitCompletionLog] = []
        
        for habit in habits {
            for (dayIndex, isDone) in habit.weeklyCompletion.enumerated() {
                guard isDone else { continue }
                let dayDifference = dayIndex - currentIndex
                guard let logDate = calendar.date(byAdding: .day, value: dayDifference, to: today) else { continue }
                
                let log = HabitCompletionLog()
                log.habitId = habit.id
                log.date = logDate
                log.isCompleted = true
                logs.append(log)
            }
        }
        return logs
    }
    
    // MARK: - Demo historical logs (গত ৬ মাসের জন্য, 7-Month Trend চার্ট সাজানোর জন্য)
    static func makeHistoricalDemoLogs(for habits: [Habit]) -> [HabitCompletionLog] {
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            var logs: [HabitCompletionLog] = []
            
            // 💡 Fix: আজ থেকে ১৮০ দিন আগে শুরু হবে এবং ৭ দিন আগে শেষ হবে।
            // এতে করে Current Week (গত ৭ দিন) এর সাথে কোনো Overlap হবে না!
            guard let startDate = calendar.date(byAdding: .day, value: -180, to: today),
                  let endDate = calendar.date(byAdding: .day, value: -7, to: today) else {
                return logs
            }
            
            var dayCursor = startDate
            while dayCursor <= endDate {
                for habit in habits {
                    // প্রতিটা habit-এর জন্য random completion (৬০-৯০% chance completed)
                    let completionChance = Double.random(in: 0.5...0.9)
                    if Double.random(in: 0...1) < completionChance {
                        let log = HabitCompletionLog()
                        log.habitId = habit.id
                        log.date = dayCursor
                        log.isCompleted = true
                        logs.append(log)
                    }
                }
                // পরের দিনে যাওয়া
                guard let nextDay = calendar.date(byAdding: .day, value: 1, to: dayCursor) else { break }
                dayCursor = nextDay
            }
            
            return logs
        }
}
