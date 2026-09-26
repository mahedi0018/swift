//
//  Analytics.swift
//  TaskFlow
//
//  Created by Md. Mahedi Hasan on 15/8/26.
//

import SwiftUI
import RealmSwift
struct AnalyticsView: View {
    
    @Environment(\.tabBarHeight) private var tabBarHeight
    @Environment(\.topSafeArea) private var topSafeArea
    
    @State private var analyticsViewModel = AnalyticsViewModel()
    
    @ObservedResults(Task.self) private var allTasks
    @ObservedResults(Habit.self) private var allHabits
    @ObservedResults(HabitCompletionLog.self) private var allLogs
    
    
    private var currentChartData: [ChartDataPoint] {
        switch analyticsViewModel.currentLevel {
        case .week:
            return analyticsViewModel.weeklyData(Array(allTasks), Array(allHabits), Array(allLogs))
        case .sevenMonth:
            return analyticsViewModel.sevenMonthData(Array(allTasks), Array(allHabits), Array(allLogs))
        case .monthDetail(let month):
            return analyticsViewModel.monthDetailData(Array(allTasks), Array(allHabits), Array(allLogs), for: month)
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
                .staggeredAppear(index: 0)
                
                // MARK: - Stat Cards
                HStack(spacing: 12) {
                    StatCardView(
                        icon: "checkmark",
                        value: "\(analyticsViewModel.tasksDoneThisMonth(Array(allTasks)))",
                        label: "Tasks Done", subtitle: "This month", color: .success
                    )
                    
                    StatCardView(
                        icon: "flame.fill",
                        value: "\(analyticsViewModel.habitRate(Array(allHabits), logs: Array(allLogs)))%",
                        label: "Habit Rate", subtitle: "Avg completion", color: .success
                    )
                    StatCardView(
                        icon: "bolt.fill",
                        value: "\(analyticsViewModel.currentStreak(Array(allHabits)))d",
                        label: "Streak", subtitle: "Current run", color: .warning
                    )
                }
                .staggeredAppear(index: 1)
                
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
                .staggeredAppear(index: 2)
                
                // MARK: - Category Breakdown
                VStack(alignment: .leading, spacing: 20) {
                    Text("Category Breakdown")
                        .font(.title3.bold())
                        .foregroundStyle(Color.textPrimary)
                    
                    ForEach(analyticsViewModel.categoryBreakdown(Array(allTasks))) { stat in
                        CategoryBreakdownRow(stat: stat)
                    }
                }
                .padding(16)
                .glassCardStyle()
                .staggeredAppear(index: 4)
                
                
                // MARK: - Best Performing Day
                if let best = analyticsViewModel.bestPerformingDay(Array(allHabits), logs: Array(allLogs)) {
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
                    .staggeredAppear(index: 5)
                }
                   
            }
            .padding(16)
            .padding(.bottom, tabBarHeight + 20)
        }
        .ignoresSafeArea(edges: .all)
    }
}

#Preview {
    AnalyticsView()
}
