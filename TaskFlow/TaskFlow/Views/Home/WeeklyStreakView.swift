//
//  WeeklyStreakView.swift
//  TaskFlow
//
//  Created by Md. Mahedi Hasan on 10/8/26.
//

import SwiftUI

struct DayProgress: Identifiable {
    let id = UUID()
    let day: String
    let percentage: Int
}

struct WeeklyStreakView: View {
    let weekData: [DayProgress]
   
    var body: some View {
        HStack {
            ForEach(weekData) { data in
                let _ = print("WeeklyStreakView", data)
                
                BarItemView(data: data)
            }
        }
        .frame(maxWidth: .infinity, alignment: .init(horizontal: .center, vertical: .center))
        
        
    }
   
}

// MARK: - Single Bar Item View

struct BarItemView: View {
    let data: DayProgress
    @State private var animatedPercentage: Int = 0
    var body: some View {
        VStack(spacing: 6) {
            Text("\(data.percentage)%")
                .font(.caption2.bold())
                .foregroundStyle(barColor(for: data.percentage))
           
            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.gray.opacity(0.4))
                    .frame(width: 28, height: barHeight(for: 100) )
                RoundedRectangle(cornerRadius: 6)
                    .fill(barColor(for: data.percentage))
                    .frame(width: 28, height: barHeight(for: animatedPercentage) )
                    .onAppear {
                        print("animatedPercentage", animatedPercentage)
                        withAnimation(.spring(response: 3, dampingFraction: 0.8)) {
                                animatedPercentage = data.percentage
                            }
                    }
            }
            .padding(.horizontal, 6)
            .frame(alignment: .bottom)
            
            
            Text(data.day)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(height: 160, alignment: .bottom)
    }
}

private func barColor(for percentage: Int) -> Color {
    switch percentage {
    case 100: return .green
    case 70...99: return .indigo
    case 40...69: return .purple.opacity(0.6)
    default: return .gray.opacity(0.5)
    }
}
private func barHeight(for percentage: Int) -> CGFloat {
    // 100% হলে max 90pt height
    CGFloat(percentage) / 100 * 90
}

#Preview {
    let weekData: [DayProgress] = [
        DayProgress(day: "Sun", percentage: 100),
        DayProgress(day: "Mon", percentage: 50),
        DayProgress(day: "Tue", percentage: 75),
        DayProgress(day: "Wed", percentage: 25),
        DayProgress(day: "Thu", percentage: 100),
        DayProgress(day: "Fri", percentage: 60),
        DayProgress(day: "Sat", percentage: 80),
        ]
    WeeklyStreakView(weekData: weekData)
}
