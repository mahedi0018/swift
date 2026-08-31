//
//  SettingsSectionCard.swift
//  TaskFlow
//
//  Created by Md. Mahedi Hasan on 26/8/26.
//

import SwiftUI

struct SettingsSectionCard<Content: View>: View {
    
    let title: String
    @ViewBuilder var content: Content
    
    var body: some View {
          VStack(alignment: .leading, spacing: 0) {
              Text(title.uppercased())
                  .font(.caption.bold())
                  .foregroundStyle(Color.textSecondary)
                  .padding(.bottom, 10)
                  .padding(.horizontal, 4)

              VStack(spacing: 16) {
                  content
              }
              .padding(16)
              .glassCardStyle()
          }
      }
}

