//
//  CategoryBreakdownRow.swift
//  TaskFlow
//
//  Created by Md. Mahedi Hasan on 23/8/26.
//

import SwiftUI

struct CategoryBreakdownRow: View {
    let stat: AnalyticsViewModel.CategoryStat

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Circle().fill(stat.color).frame(width: 8, height: 8)
                Text(stat.name)
                    .font(.subheadline.bold())
                    .foregroundStyle(Color.textPrimary)
                Spacer()
                Text("\(stat.count) tasks")
                    .font(.caption)
                    .foregroundStyle(Color.textSecondary)
                Text("\(stat.percentage)%")
                    .font(.subheadline.bold())
                    .foregroundStyle(stat.color)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4).fill(Color.bgSecondary)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(stat.color)
                        .frame(width: geo.size.width * (Double(stat.percentage) / 100))
                }
            }
            .frame(height: 6)
        }
    }
}

#Preview {
    let sampleStat = AnalyticsViewModel.CategoryStat(
        name: "Work",
        count: 10,
        percentage: 60,
        color: Color.blue
    )
    CategoryBreakdownRow(stat: sampleStat)
}
