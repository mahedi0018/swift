//
//  StatCardView.swift
//  TaskFlow
//
//  Created by Md. Mahedi Hasan on 23/8/26.
//

import SwiftUI

struct StatCardView: View {
    let icon: String
    let value: String
    let label: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 24, height: 24)
                .background(color)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            
            Text(value)
                .font(.title.bold())
                .foregroundStyle(color)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            
            Text(label)
                .font(
                    .system(
                        size: 22,
                        weight: .bold,
                        design: .default
                    )
                )
                .foregroundStyle(Color.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .tracking(-1)
                .kerning(-1.5)
            Text(subtitle)
                .font(.caption2)
                .foregroundStyle(Color.textSecondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        
        .glassCardStyle(cornerRadius: 20, paddingAmount: 10)
    }
    
}
#Preview {
    StatCardView(
        icon: "flame.fill",
        value: "14",
        label: "Current Streak",
        subtitle: "Best: 21 days",
        color: .orange
    )
}
