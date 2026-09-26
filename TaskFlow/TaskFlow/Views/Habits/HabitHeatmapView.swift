//
//  HabitHeatmapView.swift
//  TaskFlow
//
//  Created by Md. Mahedi Hasan on 2/9/26.
//

import SwiftUI

struct HabitHeatmapView: View {
    
    let days: [HeatmapDay]
    let color: Color
    
    private var weeks: [[HeatmapDay]] {
        stride(from: 0, to: days.count, by: 7).map {
            Array(days[$0..<min($0 + 7, days.count)])
        }
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 4) {
                ForEach(weeks.indices, id: \.self) { weekIndex in
                    VStack(spacing: 4) {
                        ForEach(weeks[weekIndex]) { day in
                            RoundedRectangle(cornerRadius: 3)
                                .fill(cellColor(for: day))
                                .frame(width: 14, height: 14)
                        }
                    }
                }
            }
        }
    }
    private func cellColor(for day: HeatmapDay) -> Color {
        if day.isFrozen { return Color.info.opacity(0.5) }
        if day.isCompleted { return color }
        return Color.bgSecondary
    }
}

//#Preview {
//    HabitHeatmapView(days: <#[HeatmapDay]#>, color: <#Color#>)
//}
