//
//  HomeView.swift
//  TaskFlow
//
//  Created by Md. Mahedi Hasan on 8/8/26.
//

import SwiftUI
import RealmSwift

struct HomeView: View {
    @State private var authManager = AuthManager.shared
    @State private var viewModel = TaskListViewModel()
    @State private var habitViewModel = HabitListViewModel()
    @State private var showAddTask = false
    
    @Environment(\.topSafeArea) private var topSafeArea
    @Environment(\.tabBarHeight) private var tabBarHeight
    
    private var allLogs: [HabitCompletionLog] {
        Array(RealmManager.shared.getAllCompletionLogs())
    }
    
    var body: some View {
        
        ZStack(alignment: .bottomTrailing) {
            Color.bgPrimary.ignoresSafeArea()
            
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20) {
                    
                    // MARK: - Top Profile Header
                    HeaderView(
                        gretting: Date().timeBasedGreeting,
                        titile: authManager.displayName,
                        subtitle: Date().formattedHeaderDate,
                        hasNotification: true
                    )
                    .staggeredAppear(index: 0)
                    
                    // MARK: - Daily Motivation Banner
                    HStack {
                        DailyMotivationBadge()
                            .shimmerLight()
                        
                    }
                    .staggeredAppear(index: 1)
                    
                    // MARK: - Weekly Habit Streak Card
                    WeeklyStreakCardView(
                        habitViewModel: habitViewModel
                    )
                    .staggeredAppear(index: 2)
                   
                    
                    // MARK: - Tasks Progress Card
                    TasksProgressCardView()
                        .staggeredAppear(index: 3)
                    
                    // MARK: - Today Section Header
                    HStack {
                        Text("Today")
                            .font(.title2.bold())
                        
                        Text("\(viewModel.tasks.filter { !$0.isCompleted }.count) left")
                            .font(.caption.bold())
                            .foregroundColor(Color.accentSecondary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Capsule().fill(Color.accentPrimary.opacity(0.2)))
                        
                        Spacer()
                    }
                    .padding(.top, 4)
                    
                    // MARK: - Task Items List
                    VStack(spacing: 12) {
                        ForEach(viewModel.tasks.enumerated(), id: \.element.id) { index, task in
                            TaskRow(
                                task: task,
                                onToggle: {
                                    viewModel.toggleComplete(task)
                                },
                                onDelete: {
                                    withAnimation {
                                        viewModel.deleteTask(task)
                                    }
                                }
                            )
                            .staggeredAppear(index: index)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)
                .padding(.bottom, 120) // Bottom tab space
            }
            
            // MARK: -  Floating Plus Button
            Button(action: {
                showAddTask = true
            }, label: {
                Image(systemName: "plus")
                    .font(.system(size: 28, weight: .regular))
                    .foregroundStyle(.white)
                    .frame(width: 62, height: 62)
                    .background(Color.accentPrimary)
                    .clipShape(Circle())
                    .shadow(color: Color.accentPrimary.opacity(0.5), radius: 10, x: 0, y: 5)
            })
            .onAppear {
                print("tabBarHeight", tabBarHeight)
            }
            .padding(.trailing, 20)
            .buttonStyle(.plain)
            
        }
        .buttonStyle(.plain)
        .ignoresSafeArea(.keyboard)
        .sheet(isPresented: $showAddTask) {
            AddTaskView(viewModel: viewModel)
                .presentationDetents([.fraction(0.55), .large]) // 55% screen cover korbe
                .presentationCornerRadius(30)
                .presentationDragIndicator(.visible)
                .presentationBackground(.ultraThinMaterial)
        }
        .scaleEffect(showAddTask ? 0.94 : 1.0)
        .cornerRadius(showAddTask ? 28 : 0)
        .blur(radius: showAddTask ? 6 : 0)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showAddTask)
        
        //        .toolbar(.hidden, for: .navigationBar)
        
    }
}

#Preview {
    HomeView()
        .environment(\.realmConfiguration, Realm.Configuration(inMemoryIdentifier: "PreviewRealm"))
}
