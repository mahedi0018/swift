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
    var rollingDays: [RollingDayInfo]
    
    // Closures
    var onToggleDate: (Date) -> Void
    var onToggleToday: () -> Void
    var onDelete: () -> Void
    
    private var progress: Double {
        print("habit.currentStreak: \(habit.currentStreak), habit.goal: \(habit.goal)")
        guard !habit.isInvalidated else { return 0 }
        return habit.goal > 0 ? Double(habit.currentStreak) / Double(habit.goal) : 0
    }
    
    private var habitColor: Color {
        Color(habit.colorName)
    }
    
    private var isTodayCompleted: Bool {
        rollingDays.first(where: { $0.isToday })?.isCompleted ?? false
    }
    var body: some View {
        if habit.isInvalidated {
            EmptyView()
        } else {
            HStack(spacing: 14) {
                CircularProgressView(progress: min(progress, 1.0), iconName: habit.iconName, colors: [habitColor, habitColor])
                    .frame(width: 44, height: 44)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(habit.title)
                        .font(.headline)
                        .foregroundStyle(habitColor)
                        .lineLimit(1)
                    
                    HStack(spacing: 4) {
                        Text("\(habit.currentStreak) days")
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.warning)
                        Text("/ \(habit.goal) goal")
                            .foregroundStyle(Color.textSecondary)
                    }
                    .font(.caption)
                    
                    HStack(spacing: 6) {
                        ForEach(rollingDays) { day in
                            VStack(spacing: 4) {
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(day.isCompleted ? habitColor : Color.bgSecondary)
                                    .frame(width: 24, height: 24)
                                    .overlay(
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundStyle(.white)
                                            .opacity(day.isCompleted ? 1 : 0)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 6)
                                            .stroke(day.isToday ? habitColor : .clear, lineWidth: 1.5)
                                    )
                                    .onTapGesture {
                                        onToggleDate(day.date)
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
}

#Preview {
    let habit: Habit = {
        let h = Habit()
        h.title = "Morning Meditation"
        h.currentStreak = 14
        h.goal = 21
        h.colorName = "accentPrimary"
        h.iconName = "figure.mind.and.body"
        for i in 0..<7 {
            h.weeklyCompletion.append(i % 2 == 0)
        }
        return h
    }()
    
    HabitItemView(
        habit: habit,
        rollingDays: [],
        onToggleDate: { _ in },
        onToggleToday: { },
        onDelete: { }
    )
    .padding()
}
