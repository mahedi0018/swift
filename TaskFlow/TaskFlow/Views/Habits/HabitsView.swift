//
//  Habits.swift
//  TaskFlow
//
//  Created by Md. Mahedi Hasan on 15/8/26.
//

import SwiftUI
import RealmSwift

struct HabitsView: View {
    @State private var viewModel = HabitListViewModel()
    @State private var showAddHabit: Bool = false
    @Environment(\.tabBarHeight) private var tabBarHeight
    
    @ObservedResults(HabitCompletionLog.self) private var allLogs
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                
                // MARK: - Today's Progress Card
                HStack(spacing: 20) {
                    CircularProgressView(progress: viewModel.todayProgress(logs: Array(allLogs)))
                        .frame(width: 90, height: 90)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Today's Progress")
                            .font(.caption)
                            .foregroundStyle(Color.textSecondary)
                        Text("\(viewModel.completedTodayCount(logs: Array(allLogs))) / \(viewModel.totalHabitsCount)")
                            .font(.largeTitle.bold())
                            .foregroundStyle(Color.textPrimary)
                        Text("habits completed")
                            .font(.caption)
                            .foregroundStyle(Color.textSecondary)
                        Text("🏆 Best streak: \(viewModel.bestStreak) days")
                            .font(.caption.bold())
                            .foregroundStyle(Color.warning)
                    }
                    Spacer()
                }
                .padding(20)
                .gradientBorder(
                    shape: RoundedRectangle(cornerRadius: 28),
                    duration: 10,
                    gradientModifier: spinCustomAnimation()
                )
                .shimmerLight(shape: RoundedRectangle(cornerRadius: 28))
                
                // MARK: - All Habits
                HStack {
                    Text("All Habits")
                    Spacer()
                    Button {
                        showAddHabit = true
                    } label: {
                        Text("+ New Habit")
                    }
                }
                
                ForEach(viewModel.habits) { habit in
                    HabitItemView(
                        habit: habit,
                        rollingDays: viewModel.rollingDays(for: habit, logs: Array(allLogs)),
                        onToggleDate: { date in viewModel.toggleDate(habit, date: date, logs: Array(allLogs)) },
                        onToggleToday: { viewModel.toggleToday(habit, logs: Array(allLogs)) },
                        onDelete: { viewModel.deleteHabit(habit) }
                    )
                }
            }
            .padding(20)
        }
        .sheet(isPresented: $showAddHabit) {
            AddHabitView(viewModel: viewModel)
        }
    }
}

#Preview {
    HabitsView()
}
