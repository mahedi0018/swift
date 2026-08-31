//
//  Analytics.swift
//  TaskFlow
//
//  Created by Md. Mahedi Hasan on 15/8/26.
//

import SwiftUI

struct AnalyticsView: View {
    
    @Environment(\.tabBarHeight) private var tabBarHeight
    @Environment(\.topSafeArea) private var topSafeArea
    
    @State private var taskViewModel = TaskListViewModel()
    @State private var habitViewModel = HabitListViewModel()
    @State private var analyticsViewModel = AnalyticsViewModel()
    
    
    private var allLogs: [HabitCompletionLog] {
        Array(RealmManager.shared.getAllCompletionLogs())
    }
    
    private var currentChartData: [ChartDataPoint] {
        switch analyticsViewModel.currentLevel {
        case .week:
            return analyticsViewModel.weeklyData(taskViewModel.tasks, habitViewModel.habits, allLogs)
        case .sevenMonth:
            return analyticsViewModel.sevenMonthData(taskViewModel.tasks, habitViewModel.habits, allLogs)
        case .monthDetail(let month):
            return analyticsViewModel.monthDetailData(taskViewModel.tasks, habitViewModel.habits, allLogs, for: month)
        }
    }
    
    private var chartTitle: String {
        switch analyticsViewModel.currentLevel {
        case .week: return "This Month"
        case .sevenMonth: return "7-Month Trend"
        case .monthDetail: return "Month Detail"
        }
    }
    
    private var chartSubtitle: String {
        switch analyticsViewModel.currentLevel {
        case .week: return "Weekly breakdown"
        case .sevenMonth: return "Tasks completed vs Habit rate"
        case .monthDetail: return "Weekly breakdown for selected month"
        }
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                
                HeaderView(
                    titile: "Analytics",
                    subtitle: "Your performance overview",
                    hasNotification: true
                )
                
                // MARK: - Stat Cards
                HStack(spacing: 12) {
                    StatCardView(
                        icon: "checkmark",
                        value: "\(analyticsViewModel.tasksDoneThisMonth(taskViewModel.tasks))",
                        label: "Tasks Done", subtitle: "This month", color: .success
                    )
                    
                    StatCardView(
                        icon: "flame.fill",
                        value: "\(analyticsViewModel.habitRate(habitViewModel.habits))%",
                        label: "Habit Rate", subtitle: "Avg completion", color: .success
                    )
                    StatCardView(
                        icon: "bolt.fill",
                        value: "\(analyticsViewModel.currentStreak(habitViewModel.habits))d",
                        label: "Streak", subtitle: "Current run", color: .warning
                    )
                }
                
                // MARK: - Trend Chart
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(chartTitle)
                                .font(.title3.bold())
                                .foregroundStyle(Color.textPrimary)
                            Text(chartSubtitle)
                                .font(.caption)
                                .foregroundStyle(Color.textSecondary)
                        }
                        Spacer()
                        
                        if analyticsViewModel.currentLevel == .week {
                            Button {
                                analyticsViewModel.zoomOut()
                            } label: {
                                Label("7-Month", systemImage: "arrow.up.left.and.arrow.down.right")
                                    .font(.caption.bold())
                            }
                        } else {
                            Button {
                                analyticsViewModel.zoomToWeekView()
                            } label: {
                                Image(systemName: "arrow.uturn.left.circle.fill")
                                    .font(.title3)
                                    .foregroundStyle(Color.accentPrimary)
                            }
                        }
                    }
                    
                    TrendChartView(
                        data: currentChartData,
                        level: analyticsViewModel.currentLevel,
                        onBarTap: { point in analyticsViewModel.drillIntoMonth(point.referenceDate) },
                        onPinchZoomOut: { analyticsViewModel.zoomOut() }
                    )
                    
                    HStack(spacing: 16) {
                        Label("Tasks", systemImage: "circle.fill")
                            .font(.caption)
                            .foregroundStyle(Color.accentPrimary)
                        Label("Habit %", systemImage: "circle.fill")
                            .font(.caption)
                            .foregroundStyle(Color.success)
                    }
                }
                .padding(16)
                .glassCardStyle()
                
                // MARK: - Category Breakdown
                VStack(alignment: .leading, spacing: 20) {
                    Text("Category Breakdown")
                        .font(.title3.bold())
                        .foregroundStyle(Color.textPrimary)
                    
                    ForEach(analyticsViewModel.categoryBreakdown(taskViewModel.tasks)) { stat in
                        CategoryBreakdownRow(stat: stat)
                    }
                }
                .padding(16)
                .glassCardStyle()
                
                // MARK: - Best Performing Day
                if let best = analyticsViewModel.bestPerformingDay(habitViewModel.habits) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Best performing day")
                            .font(.caption)
                            .foregroundStyle(Color.textSecondary)
                        Text("\(best.day) — \(best.percentage)% habits")
                            .font(.title3.bold())
                            .foregroundStyle(Color.textPrimary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .glassCardStyle()
                }
            }
            .padding(.top, topSafeArea)
            .padding(16)
            .padding(.bottom, tabBarHeight + 20)
        }
    }
}

#Preview {
    AnalyticsView()
}
