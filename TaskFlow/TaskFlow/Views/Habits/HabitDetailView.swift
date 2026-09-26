//
//  HabitDetailView.swift
//  TaskFlow
//
//  Created by Md. Mahedi Hasan on 2/9/26.
//

import SwiftUI
import RealmSwift

struct HabitDetailView: View {
    let habit: Habit
    var viewModel: HabitListViewModel
    
    private var habitColor: Color { Color(habit.colorName) }
    @ObservedResults(HabitCompletionLog.self) private var allLogs
    
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack(spacing: 14) {
                    Image(systemName: habit.iconName)
                        .font(.title)
                        .foregroundStyle(habitColor)
                        .frame(width: 56, height: 56)
                        .background(habitColor.opacity(0.15))
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(habit.title)
                            .font(.title2.bold())
                            .foregroundStyle(Color.textPrimary)
                        if let badge = MilestoneHelper.badge(for: habit.currentStreak) {
                            Text("\(badge.emoji) \(badge.label) Streak")
                                .font(.caption.bold())
                                .foregroundStyle(habitColor)
                        }
                    }
                    Spacer()
                }
                
                HStack(spacing: 12) {
                    statBox(title: "Current", value: "\(habit.currentStreak)d")
                    statBox(title: "Longest", value: "\(habit.longestStreak)d")
                    statBox(title: "Freeze Left", value: "\(habit.freezeTokens)")
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Last 12 Weeks")
                        .font(.headline)
                        .foregroundStyle(Color.textPrimary)
                    HabitHeatmapView(days: viewModel.heatmapDays(for: habit, logs: Array(allLogs)), color: habitColor)
                }
                .padding(16)
                .glassCardStyle()
            }
            .padding(16)
        }
        .navigationTitle(habit.title)
    }
    
    private func statBox(title: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title3.bold())
                .foregroundStyle(Color.textPrimary)
            Text(title)
                .font(.caption2)
                .foregroundStyle(Color.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .glassCardStyle()
    }
}
//
//#Preview { 
//    HabitDetailView()
//}
