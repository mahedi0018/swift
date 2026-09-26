//
//  WeeklyStreakCardView.swift
//  TaskFlow
//
//  Created by Md. Mahedi Hasan on 3/9/26.
//

import SwiftUI
import RealmSwift

 struct WeeklyStreakCardView: View {
    let habitViewModel: HabitListViewModel
     
     @ObservedResults(HabitCompletionLog.self) private var allLogs
     
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Weekly Habit Streak").font(.title3.bold())
                    Text(Date().weeklyStreakDateRange).font(.caption).foregroundColor(.secondary)
                }
                Spacer()
                HStack(spacing: 4) {
                    Text("👋").font(.system(size: 21))
                    Text("6 day streak").font(.caption.bold()).foregroundColor(.white)
                }
                .padding(.horizontal, 10).padding(.vertical, 6)
                .background(Capsule().fill(Color.warning.opacity(0.15)))
            }
        }
        WeeklyStreakView(weekData: habitViewModel.rollingWeekChartData(logs: Array(allLogs)))
            .gradientBorder(
                shape: RoundedRectangle(cornerRadius: 28),
                duration: 5,
                gradientModifier: spinCustomAnimation()
            )
    }
}

#Preview {
//    WeeklyStreakCardView()
}
