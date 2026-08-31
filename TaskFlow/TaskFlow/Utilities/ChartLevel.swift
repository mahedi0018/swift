//
//  ChartLevel.swift
//  TaskFlow
//
//  Created by Md. Mahedi Hasan on 22/8/26.
//

import Foundation

enum ChartLevel: Equatable {
    case week                       // Running month's week view
    case sevenMonth                // 7 month's trend (zoom out)
    case monthDetail(month: Date)  // Weekly breakdown for a specific month (drill in)
}

struct ChartDataPoint: Identifiable {
    let id: UUID = UUID()
    let label: String               // X-axis level ("Jan", "Week 1")
    let tasksValue : Int
    let habitValue: Int
    let referenceDate: Date         // tab korle kono date ar detail a jabe
}
