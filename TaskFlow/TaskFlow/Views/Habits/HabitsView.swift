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
    
    @Environment(\.topSafeArea) private var topSafeArea
    @Environment(\.tabBarHeight) private var tabBarHeight
    
    @ObservedResults(HabitCompletionLog.self) private var allLogs
    
    private var logsByHabitId: [UUID: [HabitCompletionLog]] {
        Dictionary(grouping: allLogs, by: { $0.habitId })
    }
    
    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    HeaderView(
                        titile: "My Habits",
                        subtitle: Date().formattedHeaderDate,
                        hasNotification: true
                    )
                    
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
                    .staggeredAppear(index: 0)
                    
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
                    
                    ForEach(Array(viewModel.habits.enumerated()), id: \.element.id) { index, habit in
                        if !habit.isInvalidated {
                            let habitLogs = logsByHabitId[habit.id] ?? []
                            HabitItemView(
                                habit: habit,
                                habitViewModel: viewModel,
                                rollingDays: viewModel.rollingDays(for: habit, logs: habitLogs),
                                onToggleDate: { date in viewModel.toggleDate(habit, date: date, logs: habitLogs) },
                                onToggleToday: { viewModel.toggleToday(habit, logs: habitLogs) },
                                onDelete: { viewModel.deleteHabit(habit) },
                                onApplyFreeze: { date in viewModel.useFreezeToken(for: habit, on: date) }
                            )
                            .staggeredAppear(index: index)
                        }
                        
                    }
                }
//                .padding(.top, topSafeArea)
                .padding(.horizontal, 50)
                .padding(.vertical, 20)
                .padding(.bottom, tabBarHeight + 20)
            }
            .ignoresSafeArea(.container)
            
            .sheet(isPresented: $showAddHabit) {
                AddHabitView(viewModel: viewModel)
            }
            .alert("Milestone! 🎉", isPresented: Binding(
                get: { viewModel.celebrationMessage != nil },
                set: { if !$0 { viewModel.celebrationMessage = nil } }
            )) {
                Button("Nice!", role: .cancel) { }
            } message: {
                Text(viewModel.celebrationMessage ?? "")
            }
            .toolbar(.hidden, for: .navigationBar)
            
        }
        
    }
}

#Preview {
    HabitsView()
}
