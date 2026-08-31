//
//  RollingDayInfo.swift
//  TaskFlow
//
//  Created by Md. Mahedi Hasan on 31/8/26.
//

import Foundation

struct RollingDayInfo: Identifiable {
    let id = UUID()
    let date: Date
    let label: String
    let isCompleted: Bool
    let isToday: Bool
}
