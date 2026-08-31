//
//  SettingsToggleRow.swift
//  TaskFlow
//
//  Created by Md. Mahedi Hasan on 26/8/26.
//

import SwiftUI

struct SettingsToggleRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let iconColor: Color
    @Binding var isOn: Bool
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .frame(width: 40, height: 40)
                .background(Color.bgSecondary)
                .foregroundStyle(iconColor)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(Color.textPrimary)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(Color.textSecondary)
                
            }
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(Color.accentPrimary)
                
        }
    }
}

#Preview {
    SettingsToggleRow(
        icon: "gear",
        title: "Settings",
        subtitle: "Adjust your settings here",
        iconColor: Color.yellow,
        isOn: .constant(true)
    )
}
