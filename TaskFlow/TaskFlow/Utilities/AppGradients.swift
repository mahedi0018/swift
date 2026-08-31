//
//  AppGradients.swift
//  TaskFlow
//
//  Created by Md. Mahedi Hasan on 15/8/26.
//

import SwiftUI

enum AppGradients {
    static let primary = LinearGradient(
        colors: [Color.accentPrimary, Color.accentColor],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let primaryButton = LinearGradient(
        colors: [Color.accentPrimary, .indigo],
       startPoint: .leading,
       endPoint: .trailing
   )

   static let progressRing = LinearGradient(
    colors: [Color.accentPrimary, Color.accentSecondary],
       startPoint: .top,
       endPoint: .bottom
   )
}
