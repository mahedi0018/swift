//
//  HabitListViewModel.swift
//  TaskFlow
//
//  Created by Md. Mahedi Hasan on 18/8/26.
//

import Foundation
import Realm
import RealmSwift
import FirebaseAuth

@Observable
class HabitListViewModel {
    var habits: [Habit] = []
    var celebrationMessage: String?
    
    private var realmManager = RealmManager.shared
    private var habitsToken: NotificationToken?
    private var logsToken: NotificationToken?
    
    
    init() {
        observeHabits()
        //        observeLogs()
        //        recalculateStreakFromLogs()
    }
    
    private func observeHabits() {
        let results = realmManager.getAllHabits()
        habits = Array(results)
        habitsToken = results.observe { [weak self] changes in
            switch changes {
            case .initial(let results): self?.habits = Array(results)
            case .update(let results, _, _, _): self?.habits = Array(results)
            case .error(let error): print("Habits observe error: \(error)")
            }
        }
    }
    
//    private func observeLogs() {
//        let results = realmManager.getAllCompletionLogs()
//        logs = Array(results)
//        logsToken = results.observe { [weak self] changes in
//            switch changes {
//            case .initial(let results): self?.logs = Array(results)
//            case .update(let results, _, _, _): self?.logs = Array(results)
//            case .error(let error): print("Logs observe error: \(error)")
//            }
//        }
//    }
    
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
    
    // MARK: - DELETE (fixed: cascade delete + notification cancel)
    func deleteHabit(_ habit: Habit) {
        
        // ১. ডিলিট হওয়ার আগেই প্রয়োজনীয় মানগুলো লোকাল ভেরিয়েবলে সেভ করে রাখুন
        let habitId = habit.id
        let uuidString = habitId.uuidString
        
        // ২. নোটিফিকেশন আগে ক্যানসেল করুন
        NotificationManager.shared.cancelHabitAlert(habitId: uuidString)
        
        // ৩. কমপ্লিশন লগগুলো ডিলিট করুন
        realmManager.deleteAllLogs(forHabitId: habitId)
        
        // ৪. মূল হ্যাবিট ডিলিট করুন এবং SwiftUI-এর রেন্ডারিং সাইকেল থেকে সেফ দূরত্ব বজায় রাখতে মেইন থ্রেডে রান করুন
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            // ভিউ লিস্ট থেকে লোকাল অ্যারে ফিল্টার করে সাথে সাথে UI আপডেট করে দেওয়া,
            // যাতে SwiftUI আর ডিলিট হওয়া অবজেক্টটি নিয়ে লুপ চালাতে না পারে।
            self.habits.removeAll { $0.id == habitId }
            
            // ডাটাবেস থেকে ডিলিট
            self.realmManager.delete(habit)
        }
    }
    
    // MARK: - Rolling 7-Day Info (এখন self.logs ব্যবহার করে, param লাগে না)
    func rollingDays(for habit: Habit, logs: [HabitCompletionLog]) -> [RollingDayInfo] {
        guard !habit.isInvalidated else { return [] }
        let calendar = Calendar.current
        let today = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEEE"
        
        let result = (0..<7).reversed().map { offset -> RollingDayInfo in
            let date = calendar.date(byAdding: .day, value: -offset, to: today) ?? today
            let dayLog = logs.first {
                $0.habitId == habit.id && calendar.isDate($0.date, inSameDayAs: date)
            }
            return RollingDayInfo(
                date: date,
                label: formatter.string(from: date),
                isCompleted: dayLog?.isCompleted ?? false,
                isFrozen: dayLog?.isDayFrozen ?? false,
                isToday: calendar.isDate(date, inSameDayAs: today)
            )
        }
        
        print("🟡 rollingDays for \(habit.title): \(result.map { "\($0.label)=\($0.isCompleted)" })")
        return result
    }
    
    func toggleDate(_ habit: Habit, date: Date, logs: [HabitCompletionLog]) {
        let calendar = Calendar.current
        let currentlyCompleted = logs.contains {
            $0.habitId == habit.id && $0.isCompleted && calendar.isDate($0.date, inSameDayAs: date)
        }
        print("🔵 toggleDate called — habit: \(habit.title), date: \(date), currentlyCompleted: \(currentlyCompleted)")
        
        realmManager.logHabitCompletion(habitId: habit.id, date: date, isCompleted: !currentlyCompleted)
        
        recalculateStreakFromLogs(habit)
        
    }
    
    func toggleToday(_ habit: Habit,  logs: [HabitCompletionLog]) {
        toggleDate(habit, date: Date(), logs: logs)
    }
    
    // MARK: - Streak Calculation (Grace Period + Longest Streak + Freeze-aware)
    private func recalculateStreakFromLogs(_ habit: Habit) {
        let calendar = Calendar.current
        let freshLogs = Array(realmManager.getAllCompletionLogs()).filter { $0.habitId == habit.id }
        
        func isActiveDay(_ date: Date) -> Bool {
            freshLogs.contains {
                ($0.isCompleted || $0.isDayFrozen) && calendar.isDate($0.date, inSameDayAs: date)
            }
        }
        
        // গতকাল থেকে পেছনে হাঁটা — "confirmed" streak (দিন শেষ হয়ে গেছে এমন দিনগুলো)
        var streak = 0
        var checkDate = calendar.date(byAdding: .day, value: -1, to: Date()) ?? Date()
        while isActiveDay(checkDate) {
            streak += 1
            guard let prev = calendar.date(byAdding: .day, value: -1, to: checkDate) else { break }
            checkDate = prev
        }
        // আজকেরটা হয়ে থাকলে যোগ করো
        if isActiveDay(Date()) {
            streak += 1
        }
        
        let oldStreak = habit.currentStreak
        realmManager.update {
            habit.currentStreak = streak
            if streak > habit.longestStreak {
                habit.longestStreak = streak
            }
        }
        
        // Phase 3: Milestone crossed কিনা check
        if MilestoneHelper.thresholds.contains(streak) && streak > oldStreak {
            celebrationMessage = "🎉 \(habit.title) hit a \(streak)-day streak!"
        }
    }
    
    // MARK: - Reminder Scheduling
    func scheduleAlert(for habit: Habit) {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: habit.reminderTime)
        guard let hour = components.hour, let minute = components.minute else { return }
        let alertMinute = minute - 30
        let adjustedHour = alertMinute < 0 ? hour - 1 : hour
        let adjustedMinute = alertMinute < 0 ? alertMinute + 60 : alertMinute
        NotificationManager.shared.scheduleHabitAlert(
            habitId: habit.id.uuidString,
            habitTitle: habit.title,
            hour: adjustedHour,
            minute: adjustedMinute
        )
    }
    
    // MARK: - Home Screen Chart Data
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
    
    // MARK: - Today's Progress
    func completedTodayCount(logs: [HabitCompletionLog]) -> Int {
        let calendar = Calendar.current
        let today = Date()
        let completedIds = Set(
            logs.filter { $0.isCompleted && calendar.isDate($0.date, inSameDayAs: today) }.map { $0.habitId }
        )
        return habits.filter { completedIds.contains($0.id) }.count
    }
    
    var totalHabitsCount: Int { habits.count }
    
    func todayProgress(logs: [HabitCompletionLog]) -> Double {
        guard totalHabitsCount > 0 else { return 0 }
        return Double(completedTodayCount(logs: logs)) / Double(totalHabitsCount)
    }
    
    var bestStreak: Int {
        habits.map(\.longestStreak).max() ?? 0   // 👈 এখন longestStreak, currentStreak না
    }
    
    // MARK: - Phase 3: Freeze Token
    func useFreezeToken(for habit: Habit, on date: Date) {
        guard habit.freezeTokens > 0 else { return }
        realmManager.applyFreeze(habitId: habit.id, date: date)
        
        realmManager.update {
            habit.freezeTokens -= 1
        }
        recalculateStreakFromLogs(habit)
        
    }
    
    // MARK: - Phase 4: Heatmap Data
    func heatmapDays(for habit: Habit, totalDays: Int = 84, logs: [HabitCompletionLog]) -> [HeatmapDay] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let habitLogs = logs.filter { $0.habitId == habit.id }
        
        return (0..<totalDays).reversed().compactMap { offset -> HeatmapDay? in
            guard let date = calendar.date(byAdding: .day, value: -offset, to: today) else { return nil }
            let dayLog = habitLogs.first { calendar.isDate($0.date, inSameDayAs: date) }
            return HeatmapDay(date: date, isCompleted: dayLog?.isCompleted ?? false, isFrozen: dayLog?.isDayFrozen ?? false)
        }
    }
    // MARK: - Helper: logs array সাথে সাথে re-sync করা (notification-এর জন্য অপেক্ষা না করে)
//    private func refreshLogs() {
//        
//        logs = Array(realmManager.getAllCompletionLogs())
//        print("🟢 refreshLogs — new logs.count: \(logs.count)")
//    }
    
    deinit {
        habitsToken?.invalidate()
        logsToken?.invalidate()
    }
}
