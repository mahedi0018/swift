//
//  HabitItemView.swift
//  TaskFlow
//
//  Created by Md. Mahedi Hasan on 20/8/26.
//

import SwiftUI
import RealmSwift

struct HabitItemView: View {
    @ObservedRealmObject var habit: Habit
    var habitViewModel: HabitListViewModel
    var rollingDays: [RollingDayInfo]        // ← parameter হিসেবে ফিরিয়ে আনা হলো
    
    // Closures
    var onToggleDate: (Date) -> Void
    var onToggleToday: () -> Void
    var onDelete: () -> Void
    var onApplyFreeze: (Date) -> Void
    
    private var progress: Double {
        guard !habit.isInvalidated else { return 0 }
        return habit.goal > 0 ? Double(habit.currentStreak) / Double(habit.goal) : 0
    }
    
    private var habitColor: Color {
        guard !habit.isInvalidated else { return .gray }
        return Color(habit.colorName)
    }
    
    private var isTodayCompleted: Bool {
        guard !habit.isInvalidated else { return false }
        return rollingDays.first(where: { $0.isToday })?.isCompleted ?? false
    }
    
    var body: some View {
        if habit.isInvalidated {
            EmptyView()
        } else {
            HStack(spacing: 14) {
                CircularProgressView(
                    progress: min(progress, 1.0),
                    iconName: habit.iconName,
                    colors: [habitColor, habitColor]
                )
                    .frame(width: 44, height: 44)
                
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 6) {
                        Text(habit.title)
                            .font(.headline)
                            .foregroundStyle(habitColor)
                            .lineLimit(1)
                        if let badge = MilestoneHelper.badge(for: habit.currentStreak) {
                            Text("\(badge.emoji)")
                                .font(.caption)
                        }
                    }
                    
                    HStack(spacing: 4) {
                        Text("\(habit.currentStreak) days")
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.warning)
                        Text("/ \(habit.goal) goal")
                            .foregroundStyle(Color.textSecondary)
                        Text("❄️ \(habit.freezeTokens)")
                            .font(.caption2)
                            .foregroundStyle(Color.info)
                    }
                    .font(.caption)
                    
                    HStack(spacing: 6) {
                        ForEach(rollingDays) { day in
                            VStack(spacing: 4) {
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(cellColor(for: day))
                                    .frame(width: 24, height: 24)
                                    .overlay(
                                        Image(systemName: day.isFrozen ? "snowflake" : "checkmark")
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundStyle(.white)
                                            .opacity(day.isCompleted || day.isFrozen ? 1 : 0)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 6)
                                            .stroke(day.isToday ? habitColor : .clear, lineWidth: 1.5)
                                    )
                                    .onTapGesture {
                                        onToggleDate(day.date)
                                    }
                                    .contextMenu {
                                        if !day.isCompleted && !day.isFrozen && !day.isToday {
                                            Button {
                                                onApplyFreeze(day.date)
                                            } label: {
                                                Label("Use Freeze (\(habit.freezeTokens) left)", systemImage: "snowflake")
                                            }
                                            .disabled(habit.freezeTokens <= 0)
                                        }
                                    }
                                
                                Text(day.label)
                                    .font(.caption2)
                                    .foregroundStyle(Color.textSecondary)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
                
                NavigationLink {
                    HabitDetailView(habit: habit, viewModel: habitViewModel)
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(Color.textSecondary)
                }
                
                Button {
                    onToggleToday()
                } label: {
                    Image(systemName: isTodayCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.title)
                        .foregroundStyle(isTodayCompleted ? habitColor : Color.textSecondary)
                }
            }
            .glassCardStyle()
            .contextMenu {
                Button(role: .destructive) {
                    onDelete()
                } label: {
                    Label("Delete Habit", systemImage: "trash")
                }
            }
        }
    }
    
    private func cellColor(for day: RollingDayInfo) -> Color {
        if day.isFrozen { return Color.info.opacity(0.6) }
        if day.isCompleted { return habitColor }
        return Color.bgSecondary
    }
}

//#Preview {
//    let habit: Habit = {
//        let h = Habit()
//        h.title = "Morning Meditation"
//        h.currentStreak = 14
//        h.goal = 21
//        h.colorName = "accentPrimary"
//        h.iconName = "figure.mind.and.body"
//        for i in 0..<7 {
//            h.weeklyCompletion.append(i % 2 == 0)
//        }
//        return h
//    }()
//
//    HabitItemView(
//        habit: habit, habitViewModel: <#HabitListViewModel#>,
//        rollingDays: [],
//        onToggleDate: { _ in },
//        onToggleToday: { },
//        onDelete: { },
//        onApplyFreeze: { _ in }
//    )
//    .padding()
//}
