//
//  MilestoneHelper.swift
//  TaskFlow
//
//  Created by Md. Mahedi Hasan on 2/9/26.
//

import Foundation


enum MilestoneHelper {
    static let thresholds = [7, 30, 100]

    static func badge(for streak: Int) -> (emoji: String, label: String)? {
        switch streak {
        case 100...: return ("💎", "100-Day")
        case 30..<100: return ("🏆", "30-Day")
        case 7..<30: return ("🔥", "7-Day")
        default: return nil
        }
    }
}
