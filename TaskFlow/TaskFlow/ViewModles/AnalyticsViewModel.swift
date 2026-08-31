//
//  AnalyticsViewModel.swift
//  TaskFlow
//
//  Created by Md. Mahedi Hasan on 22/8/26.
//

import Foundation
import RealmSwift
import SwiftUI

@Observable
class AnalyticsViewModel {
    var currentLevel: ChartLevel = .week
    
    // MARK: - Stat Card 1: Tasks Done (this month)
    func tasksDoneThisMonth(_ tasks: [Task]) -> Int {
        let calendar = Calendar.current
        return tasks.filter {
            $0.isCompleted && calendar.isDate($0.createdAt, equalTo: Date(), toGranularity: .month)
        }.count
    }
    
    // MARK: - Stat Card 2: Habit Rate (avg completion %)
    func habitRate(_ habits: [Habit]) -> Int {
        guard !habits.isEmpty else { return 0 }
        let totalPossible = habits.count * 7
        let totalCompleted = habits.reduce(0) { sum, habits in
            sum + habits.weeklyCompletion.filter{ $0 }.count
        }
        guard totalPossible > 0 else { return 0 }
        return Int((Double(totalCompleted) / Double(totalPossible)) * 100)
    }
    
    // MARK: - Stat Card 3: Current Streak
    func currentStreak(_ habits: [Habit]) -> Int {
        habits.map(\.currentStreak).max() ?? 0
    }
    
    // MARK: - Category Breakdown
    struct CategoryStat: Identifiable {
        let id = UUID()
        let name: String
        let count: Int
        let percentage: Int
        let color: Color
    }
    
    func categoryBreakdown(_ tasks: [Task]) -> [CategoryStat] {
        guard !tasks.isEmpty else { return [] }
        let grouped = Dictionary(grouping: tasks, by: { $0.category } )
        
        return grouped.map { category, tasksInCategory in
            let percentage = Int((Double(tasksInCategory.count) / Double(tasks.count)) * 100)
            return CategoryStat(
                name: category,
                count: tasksInCategory.count,
                percentage: percentage,
                color: tasksInCategory.first?.categoryEnum.color ?? .accentPrimary
            )
        }
        .sorted { $0.count > $1.count}
    }
    
    // MARK: - Best Performing Day
    func bestPerformingDay(_ habits: [Habit]) -> (day: String, percentage: Int)? {
        let dayLabels = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        guard !habits.isEmpty else { return nil }
        var bestIndex = 0
        var bestCount = 0
        for dayIndex in 0..<7 {
            let completedCount = habits.filter { $0.weeklyCompletion[dayIndex] }.count
            if completedCount > bestCount {
                bestCount = completedCount
                bestIndex = dayIndex
            }
        }
        let percentage = Int((Double(bestCount) / Double(habits.count)) * 100)
        return (dayLabels[bestIndex], percentage)
    }
    
    // MARK: - Week-level data (Every week data for running month)
    func weeklyData(_ tasks: [Task], _ habits: [Habit], _ logs: [HabitCompletionLog]) -> [ChartDataPoint] {
        let calendar = Calendar.current
        let now = Date()
        guard let monthRange = calendar.range(of: .weekOfMonth, in: .month, for: now) else { return [] }

        return monthRange.map { weekNumber in
            var components = calendar.dateComponents([.year, .month], from: now)
            components.weekOfMonth = weekNumber
            components.weekday = 1
            let weekStart = calendar.date(from: components) ?? now
            let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart) ?? weekStart

            let tasksInWeek = tasks.filter {
                calendar.isDate($0.createdAt, equalTo: weekStart, toGranularity: .weekOfMonth)
            }
            let completedCount = tasksInWeek.filter { $0.isCompleted }.count

            let rate = habitCompletionRate(logs: logs, totalHabitsCount: habits.count, in: (weekStart, weekEnd))

            return ChartDataPoint(
                label: "Week \(weekNumber)",
                tasksValue: completedCount,
                habitValue: rate,
                referenceDate: weekStart
            )
        }
    }
    
    // MARK: - 7-Month level data
    func sevenMonthData(_ tasks: [Task], _ habits: [Habit], _ logs: [HabitCompletionLog]) -> [ChartDataPoint] {
        let calendar = Calendar.current
        let now = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"

        return (0..<7).reversed().compactMap { offset -> ChartDataPoint? in
            guard let monthDate = calendar.date(byAdding: .month, value: -offset, to: now) else { return nil }
            guard let monthStart = calendar.dateInterval(of: .month, for: monthDate)?.start,
                  let monthEnd = calendar.dateInterval(of: .month, for: monthDate)?.end else { return nil }

            let tasksInMonth = tasks.filter {
                calendar.isDate($0.createdAt, equalTo: monthDate, toGranularity: .month)
            }
            let completedCount = tasksInMonth.filter { $0.isCompleted }.count

            let rate = habitCompletionRate(logs: logs, totalHabitsCount: habits.count, in: (monthStart, monthEnd))

            return ChartDataPoint(
                label: formatter.string(from: monthDate),
                tasksValue: completedCount,
                habitValue: rate,
                referenceDate: monthDate
            )
        }
    }
    
    // MARK: - Month-detail level data ()
    func monthDetailData(_ tasks: [Task], _ habits: [Habit], _ logs: [HabitCompletionLog], for month: Date) -> [ChartDataPoint] {
        let calendar = Calendar.current
        guard let range = calendar.range(of: .weekOfMonth, in: .month, for: month) else { return [] }

        return range.map { weekNumber in
            var components = calendar.dateComponents([.year, .month], from: month)
            components.weekOfMonth = weekNumber
            components.weekday = 1
            let weekStart = calendar.date(from: components) ?? month
            let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart) ?? weekStart

            let tasksInWeek = tasks.filter {
                calendar.isDate($0.createdAt, equalTo: weekStart, toGranularity: .weekOfMonth) &&
                calendar.isDate($0.createdAt, equalTo: month, toGranularity: .month)
            }
            let completedCount = tasksInWeek.filter { $0.isCompleted }.count

            let rate = habitCompletionRate(logs: logs, totalHabitsCount: habits.count, in: (weekStart, weekEnd))

            return ChartDataPoint(
                label: "W\(weekNumber)",
                tasksValue: completedCount,
                habitValue: rate,
                referenceDate: weekStart
            )
        }
    }
    
    // MARK: - Nirdisto somoyer habit completion rate ber kora (new, real historical)
    private func habitCompletionRate(logs: [HabitCompletionLog], totalHabitsCount: Int, in dateRange: (start: Date, end: Date)) -> Int {
        guard totalHabitsCount > 0 else { return 0 }
        
        let logsInRange = logs.filter { $0.date >= dateRange.start && $0.date < dateRange.end && $0.isCompleted }
        let calendar = Calendar.current
        let daysInRange = calendar.dateComponents([.day], from: dateRange.start, to: dateRange.end).day ?? 1
        let totalPossible = totalHabitsCount * max(daysInRange, 1)
        
        guard totalPossible > 0 else { return 0 }
        return Int((Double(logsInRange.count) / Double(totalPossible)) * 100)
    }
    // MARK: - Navigation actions
    func zoomOut() {
        withAnimation(.easeInOut(duration: 0.3)) { currentLevel = .sevenMonth }
    }
    
    func zoomToWeekView() {
        withAnimation(.easeInOut(duration: 0.3)) { currentLevel = .week }
    }
    
    func drillIntoMonth(_ date: Date) {
        withAnimation(.easeInOut(duration: 0.3)) { currentLevel = .monthDetail(month: date) }
    }
}

