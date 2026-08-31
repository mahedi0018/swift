//
//  SettingsNavRow.swift
//  TaskFlow
//
//  Created by Md. Mahedi Hasan on 26/8/26.
//

import SwiftUI

import SwiftUI

struct SettingsNavRow: View {
    let icon: String
    let title: String
    let subtitle: String
    var isDestructive: Bool = false
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .frame(width: 40, height: 40)
                    .background(isDestructive ? Color.danger.opacity(0.15) : Color.bgSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline.bold())
                        .foregroundStyle(isDestructive ? Color.danger : Color.textPrimary)
                    if !subtitle.isEmpty {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundStyle(Color.textSecondary)
                    }
                }

                Spacer()

                if !isDestructive {
                    Image(systemName: "chevron.right")
                        .font(.caption.bold())
                        .foregroundStyle(Color.textSecondary)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    SettingsNavRow(
        icon: "gear",
        title:  "iCloud",
        subtitle: "Last synced: 10:30 AM"
    )
}
