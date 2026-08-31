//
//  HabitListViewModel.swift
//  TaskFlow
//
//  Created by Md. Mahedi Hasan on 18/8/26.
//

import Foundation
import RealmSwift
import Realm
import FirebaseAuth

@Observable
class HabitListViewModel {
    var habits: [Habit] = []
    
    private var realmManager = RealmManager.shared
    private var notificationToken: NotificationToken?
    
    init(){
        observeHabits()
        recalculateAllStreaks()
    }
    
    private func observeHabits() {
        let results = realmManager.getAllHabits()
        habits = Array(results)
        
        notificationToken = results.observe { [weak self] changes in
            switch changes {
            case .initial(let results):
                print("🟢 INITIAL fired, count: \(results.count)")
                self?.habits = Array(results)
            case .update(let results, _, _, let modifications):
                print("🔵 UPDATE fired — modifications: \(modifications)")
                self?.habits = Array(results)
            case .error(let error):
                print("🔴 ERROR: \(error)")
            }
        }
    }
    
    private func recalculateAllStreaks() {
        for habit in habits {
            recalculateStreakFromLogs(habit)
        }
    }
    // MARK: - CREATE
    func addNewHabit(title: String, iconName: String, goal: Int, colorName: String, reminderTime: Date) {
        guard let uid = AuthManager.shared.currentUser?.uid else { return }
        let newHabit = Habit()
        newHabit.title = title
        newHabit.iconName = iconName
        newHabit.goal = goal
        newHabit.colorName = colorName
        newHabit.reminderTime = reminderTime
        newHabit.userId = uid
        realmManager.add(newHabit)
        
        if AppSettings.shared.habitAlerts {
            scheduleAlert(for: newHabit)
        }
    }
    
    // MARK: - DELETE
    func deleteHabit(_ habit: Habit) {
        let habitId = habit.id
        habits = habits.filter { $0.id != habitId }
        
        NotificationManager.shared.cancelHabitAlert(habitId: habitId.uuidString)
        realmManager.deleteCompletionLogs(habitId: habitId)
        realmManager.delete(habit)
    }
    
    // MARK: - Rolling 7-Day Info (For HabitView, UI checkbox row-ar jonno)
    func rollingDays(for habit: Habit, logs: [HabitCompletionLog])->[RollingDayInfo] {
        let calendar = Calendar.current
        let today = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEEE"
        
        return (0..<7).reversed().map { offset in
            let date = calendar.date(byAdding: .day, value: -offset, to: today) ?? today
            let isCompleted = logs.contains {
                $0.habitId == habit.id && $0.isCompleted && calendar.isDate($0.date, inSameDayAs: date)
            }
            let isToday = calendar.isDate(date, inSameDayAs: today)
            return RollingDayInfo(date: date, label: formatter.string(from: date), isCompleted: isCompleted, isToday: isToday)
            
        }
    }
    
    // MARK: - UPDATE (toggle for any date)
    func toggleDate(_ habit: Habit, date: Date, logs: [HabitCompletionLog]) {
        let calendar = Calendar.current
        let currentlyCompleted = logs.contains {
            $0.habitId == habit.id && $0.isCompleted && calendar.isDate($0.date, inSameDayAs: date)
        }
        realmManager.logHabitCompletion(habitId: habit.id, date: date, isCompleted: !currentlyCompleted)
        recalculateStreakFromLogs(habit)
    }
    
    // MARK: - UPDATE( toggle for today- right side's checkmark button)
    func toggleToday(_ habit: Habit, logs: [HabitCompletionLog]) {
        toggleDate(habit, date: Date(), logs: logs)
    }
    
    // MARK: - Helper: dayIndex (0=Mon...6=Sun) theke colti week ar actual Date ber kora
    private func dateFor(dayIndex: Int) -> Date {
        let calendar = Calendar.current
        let today = Date()
        let currentWeekday = calendar.component(.weekday, from: today) // Sun=1...Sat=7
        let currentIndex = (currentWeekday + 5) % 7  // our M=0...S=6 format
        
        let dayDifference = dayIndex - currentIndex
        return calendar.date(byAdding: .day, value: dayDifference, to: today) ?? today
    }
    
    // MARK: - Streak Calculation — Log-based
    private func recalculateStreakFromLogs(_ habit: Habit) {
        let calendar = Calendar.current
        let allLogs = Array(realmManager.getAllCompletionLogs())
        
        var streak = 0
        var checkDate = Date()
        
        while true {
            let completed = allLogs.contains {
                $0.habitId == habit.id && $0.isCompleted && calendar.isDate($0.date, inSameDayAs: checkDate)
            }
            guard completed else { break }
            streak += 1
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: checkDate) else { break }
            checkDate = previousDay
        }
        
        realmManager.update {
            habit.currentStreak = streak
        }
    }
    
    // MARK: - Reminder Scheduling
    func scheduleAlert(for habit: Habit) {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: habit.reminderTime)
        guard let hour = components.hour, let minute = components.minute else { return }
        
        // ৩০ মিনিট আগে alert
        let alertMinute = minute - 59
        let adjustedHour = alertMinute < 0 ? hour - 1 : hour
        let adjustedMinute = alertMinute < 0 ? alertMinute + 60 : alertMinute
        
        NotificationManager.shared.scheduleHabitAlert(
            habitId: habit.id.uuidString,
            habitTitle: habit.title,
            hour: adjustedHour,
            minute: adjustedMinute
        )
    }
    // MARK: - Helper: Which day of the week is today?
    func todayIndex() -> Int {
        let weekday = Calendar.current.component(.weekday, from: Date())
        return (weekday + 5) % 7
    }
    
    // MARK: - Rolling 7-Day Chart Data (For Home Screen)
    func rollingWeekChartData(logs: [HabitCompletionLog]) -> [DayProgress] {
        let calendar = Calendar.current
        let today = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        
        guard !habits.isEmpty else {
            return (0..<7).reversed().map { offset in
                let date = calendar.date(byAdding: .day, value: -offset, to: today) ?? today
                return DayProgress(day: formatter.string(from: date), percentage: 0)
            }
        }
        
        return (0..<7).reversed().map { offset in
            let date = calendar.date(byAdding: .day, value: -offset, to: today) ?? today
            let completedCount = logs.filter {
                $0.isCompleted && calendar.isDate($0.date, inSameDayAs: date)
            }.count
            let percentage = Int((Double(completedCount) / Double(habits.count)) * 100)
            return DayProgress(day: formatter.string(from: date), percentage: percentage)
        }
    }
    
    // MARK: - Computed Properties (For Today's Progress card)
    func completedTodayCount(logs: [HabitCompletionLog]) -> Int {
        let calendar = Calendar.current
        let today = Date()
        let habitIdsCompletedToday = Set(
            logs.filter { $0.isCompleted && calendar.isDate($0.date, inSameDayAs: today) }
                .map { $0.habitId }
        )
        return habits.filter { habitIdsCompletedToday.contains($0.id) }.count
    }
    
    var totalHabitsCount: Int {
        return habits.count
    }
    
    func todayProgress(logs: [HabitCompletionLog]) -> Double {
        guard totalHabitsCount > 0 else { return 0 }
        return Double(completedTodayCount(logs: logs)) / Double(totalHabitsCount)
    }
    
    var bestStreak: Int {
        habits.map(\.currentStreak).max() ?? 0
    }
    
    deinit {
        notificationToken?.invalidate()
    }
    
}
