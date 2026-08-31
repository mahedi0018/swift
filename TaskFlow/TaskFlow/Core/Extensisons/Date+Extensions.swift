//
//  Date+Extensions.swift
//  TaskFlow
//
//  Created by Md. Mahedi Hasan on 28/8/26.
//

import Foundation

extension Date {
    
    var timeBasedGreeting: String {
        let hour = Calendar.current.component(.hour, from: self)
        
        switch hour {
        case 5..<12:
            return "Good morning \u{1F44B}"
        case 12..<17:
            return "Good afternoon \u{1F44B}"
        case 17..<22:
            return "Good evening \u{1F44B}"
        default:
            return "Good night \u{1F44B}"
        }
    }
    
    /// Today's date k  "Saturday, Aug 8" format a kora
    var formattedHeaderDate: String {
        self.formatted(.dateTime.weekday(.wide).month(.abbreviated).day())
    }
    
    /// Current date and previous 6th day's date format  (like: "Aug 24 – Aug 30, 2026")
    var weeklyStreakDateRange: String {
        let calendar = Calendar.current
        let endDate = self
        let startDate = calendar.date(byAdding: .day, value: -6, to: endDate) ?? endDate
        
        let startFormatted = startDate.formatted(.dateTime.month(.abbreviated).day())
        let endFormatted = endDate.formatted(.dateTime.month(.abbreviated).day().year())
        
        return "\(startFormatted) – \(endFormatted)"
    }
}
