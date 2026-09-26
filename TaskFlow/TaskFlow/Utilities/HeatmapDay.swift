//
//  HeatmapDay.swift
//  TaskFlow
//
//  Created by Md. Mahedi Hasan on 2/9/26.
//

import Foundation

struct HeatmapDay: Identifiable {
    let id = UUID()
    let date: Date
    let isCompleted: Bool
    let isFrozen: Bool
}
